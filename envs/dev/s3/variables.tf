variable "project_id" { type = string }
variable "bucket_base_name" { type = string }
variable "aws_region" { type = string }
variable "versioning_enabled" { type = bool }
variable "enable_kms_encryption" { type = bool }
variable "create_kms_key" { type = bool }
variable "kms_key_arn" {
  type    = string
  default = null
}

variable "github_owner" {
  type = string
}

variable "github_repo" {
  type = string
}

variable "github_branch" {
  type = string
}

variable "aws_account_id" {
  type = string
}

variable "existing_oidc_provider_arn" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
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

