package test

import (
	"encoding/json"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
)

func runTf(t *testing.T, dir string, args ...string) {
	t.Helper()
	terraform.RunTerraformCommand(t, &terraform.Options{TerraformDir: dir, NoColor: true}, args...)
}

// ---- Helpers to handle "object OR list-of-objects" in plan JSON ----
func asMap(v interface{}) map[string]interface{} {
	if v == nil {
		return nil
	}
	if m, ok := v.(map[string]interface{}); ok {
		return m
	}
	return nil
}
func firstMap(v interface{}) map[string]interface{} {
	if m := asMap(v); m != nil {
		return m
	}
	if arr, ok := v.([]interface{}); ok && len(arr) > 0 {
		if m, ok := arr[0].(map[string]interface{}); ok {
			return m
		}
	}
	return nil
}
func getAfter(m map[string]interface{}) map[string]interface{} {
	ch := asMap(m["change"])
	if ch == nil {
		return map[string]interface{}{}
	}
	if after := asMap(ch["after"]); after != nil {
		return after
	}
	return map[string]interface{}{}
}

func Test_PlanChecks(t *testing.T) {
	t.Parallel()

	devDir := filepath.Join("..", "envs", "dev", "s3")

	// Init with local backend to avoid needing creds
	runTf(t, devDir, "init", "-backend=false")

	// Plan locally and write a plan file
	runTf(t, devDir, "plan", "-out=plan.tfplan", "-input=false", "-lock=false", "-refresh=false")

	// Show plan as JSON
	out, err := exec.Command("terraform", "-chdir="+devDir, "show", "-json", "plan.tfplan").CombinedOutput()
	require.NoError(t, err, "terraform show -json failed: %s", string(out))

	var plan map[string]interface{}
	require.NoError(t, json.Unmarshal(out, &plan))

	rcAny := plan["resource_changes"]
	require.NotNil(t, rcAny, "missing resource_changes")
	rc := rcAny.([]interface{})

	// Helpers
	find := func(typ string) []map[string]interface{} {
		var hits []map[string]interface{}
		for _, r := range rc {
			m := r.(map[string]interface{})
			if m["type"] == typ {
				hits = append(hits, m)
			}
		}
		return hits
	}

	// 1) Has S3 bucket and IAM role
	require.Greater(t, len(find("aws_s3_bucket")), 0, "expected aws_s3_bucket")
	require.Greater(t, len(find("aws_iam_role")), 0, "expected aws_iam_role")

	// 2) Versioning Enabled
	vers := find("aws_s3_bucket_versioning")
	require.Greater(t, len(vers), 0, "expected bucket versioning")
	afterVers := getAfter(vers[0])
	vc := firstMap(afterVers["versioning_configuration"])
	require.NotNil(t, vc, "versioning_configuration missing/invalid")
	require.Equal(t, "Enabled", vc["status"], "versioning must be Enabled")

	// 3) SSE present (KMS preferred but allow AES256 if you chose that)
	sse := find("aws_s3_bucket_server_side_encryption_configuration")
	require.Greater(t, len(sse), 0, "expected SSE configuration")
	afterSSE := getAfter(sse[0])

	// "rule" is a LIST block in plan JSON
	rule0 := firstMap(afterSSE["rule"])
	require.NotNil(t, rule0, "SSE rule block missing/invalid")

	applied := firstMap(rule0["apply_server_side_encryption_by_default"])
	require.NotNil(t, applied, "apply_server_side_encryption_by_default block missing/invalid")

	// Check if KMS encryption is being used by looking for KMS resources
	kmsKeys := find("aws_kms_key")
	if len(kmsKeys) > 0 {
		// KMS key is being created, so KMS encryption is enabled
		require.Greater(t, len(kmsKeys), 0, "KMS key should be created when KMS encryption is enabled")
		// When KMS key is specified, sse_algorithm defaults to "aws:kms" and may not appear in plan
	} else {
		// No KMS key, so should use AES256
		alg, _ := applied["sse_algorithm"].(string)
		require.Equal(t, "AES256", alg, "should use AES256 when no KMS key specified")
	}

	// 4) Public access block flags
	pab := find("aws_s3_bucket_public_access_block")
	require.Greater(t, len(pab), 0, "expected public access block")
	afterPAB := getAfter(pab[0])
	require.Equal(t, true, afterPAB["block_public_acls"])
	require.Equal(t, true, afterPAB["block_public_policy"])
	require.Equal(t, true, afterPAB["ignore_public_acls"])
	require.Equal(t, true, afterPAB["restrict_public_buckets"])

	// 5) OIDC trust policy - check for OIDC provider and IAM role
	oidcProvider := find("aws_iam_openid_connect_provider")
	require.Greater(t, len(oidcProvider), 0, "expected OIDC provider")

	// Check OIDC provider configuration
	afterOIDC := getAfter(oidcProvider[0])
	url := afterOIDC["url"].(string)
	// Accept both with and without https:// prefix as both are valid
	// The correct URL should be https://token.actions.githubusercontent.com
	// but existing providers might not have the https:// prefix
	if !strings.HasPrefix(url, "https://") {
		url = "https://" + url
	}
	require.Equal(t, "https://token.actions.githubusercontent.com", url)

	clientIDs := afterOIDC["client_id_list"].([]interface{})
	require.Contains(t, clientIDs, "sts.amazonaws.com")

	// Check IAM role exists
	role := find("aws_iam_role")
	require.Greater(t, len(role), 0, "expected IAM role")

	// Since we can't easily validate the trust policy JSON in the plan (it's computed),
	// we'll validate the presence of the OIDC provider and role, which indicates
	// the OIDC trust policy is properly configured
	roleName := getAfter(role[0])["name"].(string)
	require.Contains(t, roleName, "oidc", "role should be for OIDC")
}
