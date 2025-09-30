output "prod_bucket_name" { value = module.s3.bucket_name }
output "prod_bucket_arn" { value = module.s3.bucket_arn }
output "prod_oidc_role_arn" { value = module.s3.oidc_role_arn }