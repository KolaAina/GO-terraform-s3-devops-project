# 🔐 KMS Encryption Deployment Guide

## Overview
This guide explains how to properly deploy KMS encryption across dev and prod environments without failures.

## 🎯 Approach 1: Shared KMS Key (Recommended)

### Step 1: Deploy Dev Environment First
```bash
cd envs/dev/s3
terraform init
terraform plan
terraform apply

# Capture the KMS key ARN from output
terraform output kms_key_arn
```

### Step 2: Update Prod Configuration
After dev deployment, update `envs/prod/s3/terraform.tfvars`:
```hcl
kms_key_arn = "arn:aws:kms:us-east-1:443370701422:key/12345678-1234-1234-1234-123456789012"
```

### Step 3: Deploy Prod Environment
```bash
cd envs/prod/s3
terraform init
terraform plan
terraform apply
```

## 🎯 Approach 2: Separate KMS Keys (Current Config)

### Keep Current Configuration
- Dev: `create_kms_key = true` (creates its own key)
- Prod: `create_kms_key = true` (creates its own key)

**Pros:**
- Environment isolation
- No dependencies between environments
- Simpler deployment

**Cons:**
- Higher costs (multiple KMS keys)
- Inconsistent security model
- More complex key management

## 🎯 Approach 3: No KMS (Simplest)

### Disable KMS in Both Environments
```hcl
# In both dev and prod terraform.tfvars
enable_kms_encryption = false
create_kms_key        = false
kms_key_arn           = null
```

**Pros:**
- Simpler deployment
- Lower costs
- No key management

**Cons:**
- Uses AES256 (AWS-managed encryption)
- May not meet compliance requirements
- Less control over encryption

## 🚀 Automated Deployment Script

Create this script to automate the shared KMS approach:

```bash
#!/bin/bash
# deploy-with-shared-kms.sh

set -e

echo "🚀 Starting KMS-enabled deployment..."

# Deploy dev first
echo "📦 Deploying dev environment..."
cd envs/dev/s3
terraform init
terraform plan
terraform apply

# Capture KMS key ARN
KMS_KEY_ARN=$(terraform output -raw kms_key_arn)
echo "🔑 Dev KMS Key ARN: $KMS_KEY_ARN"

# Update prod configuration
echo "📝 Updating prod configuration..."
cd ../../prod/s3
sed -i "s/kms_key_arn.*=.*null/kms_key_arn = \"$KMS_KEY_ARN\"/" terraform.tfvars

# Deploy prod
echo "📦 Deploying prod environment..."
terraform init
terraform plan
terraform apply

echo "✅ Deployment complete!"
echo "🔑 Shared KMS Key ARN: $KMS_KEY_ARN"
```

## 🔧 GitHub Actions Integration

### Option A: Manual KMS Key Management
1. Deploy dev manually first
2. Get KMS key ARN from dev output
3. Update prod terraform.tfvars with KMS key ARN
4. Commit and push to trigger prod deployment

### Option B: Automated KMS Key Sharing
Add this to your GitHub Actions workflow:

```yaml
- name: Get Dev KMS Key ARN
  id: get-kms-arn
  run: |
    cd envs/dev/s3
    terraform output -raw kms_key_arn > ../../prod/s3/kms-key-arn.txt
    
- name: Update Prod Configuration
  run: |
    KMS_ARN=$(cat envs/prod/s3/kms-key-arn.txt)
    sed -i "s/kms_key_arn.*=.*null/kms_key_arn = \"$KMS_ARN\"/" envs/prod/s3/terraform.tfvars
```

## 🛡️ Security Considerations

### KMS Key Permissions
The module automatically grants the GitHub OIDC role permissions to use the KMS key:

```hcl
# In modules/s3/main.tf
dynamic "statement" {
  for_each = local.effective_kms_key_arn != null ? [1] : []
  content {
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt", 
      "kms:GenerateDataKey",
      "kms:DescribeKey"
    ]
    resources = [local.effective_kms_key_arn]
  }
}
```

### Key Rotation
KMS keys are created with automatic rotation enabled:
```hcl
enable_key_rotation = true
```

## 💰 Cost Implications

### KMS Pricing (US East 1)
- **Customer-managed key**: $1/month + $0.03 per 10,000 requests
- **AWS-managed key**: Free (AES256)

### Cost Comparison
- **No KMS**: $0/month
- **Shared KMS**: $1/month (both environments)
- **Separate KMS**: $2/month (each environment)

## 🚨 Troubleshooting

### Common Issues

1. **KMS Key Not Found**
   ```bash
   # Check if key exists
   aws kms describe-key --key-id YOUR_KEY_ARN
   ```

2. **Permission Denied**
   ```bash
   # Check IAM role permissions
   aws iam get-role-policy --role-name ROLE_NAME --policy-name POLICY_NAME
   ```

3. **Cross-Region Issues**
   - Ensure KMS key and S3 bucket are in same region
   - Update `aws_region` in both environments

### Debug Commands
```bash
# Check KMS key status
aws kms describe-key --key-id $(terraform output -raw kms_key_arn)

# List all KMS keys
aws kms list-keys

# Check S3 bucket encryption
aws s3api get-bucket-encryption --bucket YOUR_BUCKET_NAME
```

## 📋 Recommendations

### For Development/Testing
- Use **Approach 3** (No KMS) for simplicity
- Focus on functionality over security

### For Production/Enterprise
- Use **Approach 1** (Shared KMS) for consistency
- Implement proper key management policies
- Consider AWS KMS key policies for additional security

### For Compliance Requirements
- Use **Approach 2** (Separate KMS) for isolation
- Implement key rotation policies
- Add CloudTrail logging for audit trails
