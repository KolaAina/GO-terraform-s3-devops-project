output "bucket_name" {
  value       = aws_s3_bucket.this.bucket
  description = "Created S3 bucket name"
}

output "bucket_arn" {
  value       = aws_s3_bucket.this.arn
  description = "Created S3 bucket ARN"
}

output "oidc_role_arn" {
  value       = aws_iam_role.github_actions.arn
  description = "IAM Role ARN for GitHub OIDC"
}

output "kms_key_arn" {
  value       = var.enable_kms_encryption && length(aws_kms_key.bucket) > 0 ? aws_kms_key.bucket[0].arn : null
  description = "KMS Key ARN for bucket encryption (if created)"
}

output "kms_key_id" {
  value       = var.enable_kms_encryption && length(aws_kms_key.bucket) > 0 ? aws_kms_key.bucket[0].key_id : null
  description = "KMS Key ID for bucket encryption (if created)"
}

