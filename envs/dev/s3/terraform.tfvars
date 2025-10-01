project_id            = "kolam"
bucket_base_name      = "s3-deploy-artifacts"
aws_region            = "us-east-1"
versioning_enabled    = true
enable_kms_encryption = true
create_kms_key        = false
kms_key_arn           = null # or "arn:aws:kms:...:key/..." if you have one

github_owner  = "KolaAina"
github_repo   = "GO-terraform-s3-devops-project"
github_branch = "main" # must match your workflow triggers

aws_account_id             = "443370701422"
existing_oidc_provider_arn = null # set if you already have it
#existing_oidc_provider_arn = "arn:aws:iam::443370701422:oidc-provider/token.actions.githubusercontent.com" # set if you already have it

# State bucket for IAM permissions
terraform_state_bucket         = "kada-terraform-eks-state-s3-bucket"
terraform_state_key            = "s3-oidc-dev-terraform.tfstate"
terraform_state_dynamodb_table = "kada-terraform-eks-state-lock"

tags = {
  Project = "kolam"
  Owner   = "kolam"
}
