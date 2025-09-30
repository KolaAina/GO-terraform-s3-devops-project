variable "project_id" {
  description = "Project identifier prefix for the bucket name (e.g., acme)"
  type        = string
}

variable "bucket_base_name" {
  description = "Base bucket name (will be prefixed by project_id: project_id-bucket_base_name)"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "versioning_enabled" {
  description = "Enable S3 bucket versioning"
  type        = bool
  default     = true
}

variable "enable_kms_encryption" {
  description = "Enable SSE-KMS encryption for the bucket"
  type        = bool
  default     = true
}

variable "create_kms_key" {
  description = "Create a new customer-managed KMS key (if true) or use AWS-managed S3 key if false. If kms_key_arn is provided, that one is used instead."
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "Optional existing KMS key ARN to use for encryption"
  type        = string
  default     = null
}

variable "github_owner" {
  description = "GitHub org/user that owns the repo"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "github_branch" {
  description = "Branch to allow (e.g., main)"
  type        = string
  default     = "main"
}

variable "aws_account_id" {
  description = "Your AWS Account ID (12 digits)"
  type        = string
}

variable "existing_oidc_provider_arn" {
  description = "If you already have a GitHub OIDC provider in IAM, pass its ARN; otherwise, module will create one."
  type        = string
  default     = null
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}

variable "terraform_state_bucket" {
  description = "S3 bucket name for Terraform state (for IAM permissions)"
  type        = string
  default     = null
}

variable "terraform_state_key" {
  description = "S3 key for Terraform state (for IAM permissions)"
  type        = string
  default     = null
}

variable "terraform_state_dynamodb_table" {
  description = "DynamoDB table name for Terraform state locking (for IAM permissions)"
  type        = string
  default     = null
}

