module "s3" {
  source = "../../../modules/s3"

  # ==== REPLACE with your values ====
  project_id            = var.project_id
  bucket_base_name      = var.bucket_base_name
  aws_region            = var.aws_region
  versioning_enabled    = var.versioning_enabled #true/false
  enable_kms_encryption = var.enable_kms_encryption
  create_kms_key        = var.create_kms_key
  kms_key_arn           = var.kms_key_arn # null to auto-create

  github_owner  = var.github_owner  # "YOUR_GH_OWNER"
  github_repo   = var.github_repo   # "YOUR_REPO"
  github_branch = var.github_branch # "main"

  aws_account_id             = var.aws_account_id
  existing_oidc_provider_arn = var.existing_oidc_provider_arn
  terraform_state_bucket         = var.terraform_state_bucket
  terraform_state_key            = var.terraform_state_key
  terraform_state_dynamodb_table = var.terraform_state_dynamodb_table

  tags = merge(var.tags, { Environment = "dev" })
}

