# .tflint.hcl
# TFLint configuration for Terraform + AWS

tflint {
  # Pin the minimum TFLint version your project expects
  required_version = ">= 0.52.0"
}

# Install & enable the AWS ruleset plugin
plugin "aws" {
  enabled = true
  # Use a known-good plugin version (update as needed)
  version = "0.35.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"

  # 🔧 Set your default region (used by some rules: instance types, AMIs, etc.)
  region  = "us-east-1"
}

# -------------------------------------------------------------------
# Optional rule tweaks (uncomment to enforce more strictly)
# -------------------------------------------------------------------

# # Core Terraform rules (built-in)
# rule "terraform_deprecated_interpolation" { enabled = true }
# rule "terraform_deprecated_quoted_type"   { enabled = true }
# rule "terraform_unused_declarations"      { enabled = true }
# rule "terraform_required_providers"       { enabled = true }
# rule "terraform_module_pinned_source"     { enabled = true }
# rule "terraform_naming_convention"        { enabled = true }

# # AWS rules (subset examples). Many AWS rules are enabled with sensible defaults.
# # Explicitly enable any you want to fail the build on:
# rule "aws_iam_policy_no_statements_with_admin_access" { enabled = true }
# rule "aws_s3_bucket_encryption"                       { enabled = true }
# rule "aws_s3_bucket_versioning"                       { enabled = true }
# rule "aws_s3_bucket_public_access_block"              { enabled = true }
