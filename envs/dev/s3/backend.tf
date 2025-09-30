terraform {
  required_version = ">= 1.0.0"


  backend "s3" {
    # Replace with your state bucket/region/table
    bucket         = "kada-terraform-eks-state-s3-bucket"
    key            = "s3-oidc-dev-terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "kada-terraform-eks-state-lock"
    encrypt        = true
  }
}
