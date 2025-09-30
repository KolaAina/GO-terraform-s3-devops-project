output "dev_bucket_name" { value = module.s3.bucket_name }
output "dev_bucket_arn" { value = module.s3.bucket_arn }
output "dev_oidc_role_arn" { value = module.s3.oidc_role_arn }