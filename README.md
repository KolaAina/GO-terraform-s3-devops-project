# Terraform S3 OIDC Project

A production-ready Terraform project that creates S3 buckets with GitHub OIDC authentication, KMS encryption, automated CI/CD pipeline using GitHub Actions, and comprehensive testing with Terratest.

## 🏗️ Architecture

This project creates:
- **S3 Buckets** with versioning, encryption, and public access blocking
- **KMS Keys** for server-side encryption (optional)
- **GitHub OIDC Provider** for secure authentication
- **IAM Roles & Policies** with least-privilege access
- **GitHub Actions CI/CD** pipeline for automated deployments
- **Terratest** for comprehensive infrastructure testing

## 📁 Project Structure

```
Project/
├── .github/workflows/
│   └── terraform.yaml          # CI/CD pipeline
├── test/                       # Terratest test suite
│   └── plan_test.go            # Plan validation tests
├── go.mod                      # Go module definition (repo root)
├── go.sum                      # Go dependencies checksum (repo root)
├── .tflint.hcl                 # TFLint configuration
├── envs/
│   ├── dev/s3/                 # Development environment
│   │   ├── main.tf            # Module configuration
│   │   ├── variables.tf       # Variable definitions
│   │   ├── outputs.tf         # Output values
│   │   ├── backend.tf         # State backend configuration
│   │   └── terraform.tfvars   # Environment-specific values
│   └── prod/s3/               # Production environment
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       ├── backend.tf
│       └── terraform.tfvars
└── modules/
    └── s3/                    # Reusable S3 module
        ├── main.tf           # Module implementation
        ├── variables.tf      # Module variables
        └── outputs.tf        # Module outputs
```

## 🚀 Features

### Security
- **OIDC Authentication**: Secure GitHub Actions integration without long-lived credentials
- **KMS Encryption**: Optional server-side encryption with customer-managed keys
- **Public Access Blocking**: All public access disabled by default
- **Least-Privilege IAM**: Minimal required permissions for GitHub Actions

### Infrastructure
- **Multi-Environment**: Separate dev and prod configurations
- **State Management**: S3 backend with locking
- **Versioning**: Optional S3 bucket versioning
- **Tagging**: Consistent resource tagging

### CI/CD
- **Automated Pipeline**: GitHub Actions for plan/apply
- **Environment Protection**: Manual approval for production
- **Linting & Validation**: Terraform fmt, tflint, and validate
- **Destructive Change Protection**: Prevents accidental deletions

### Testing
- **Terratest Integration**: Go-based infrastructure testing
- **Plan Validation**: Automated validation of Terraform plans
- **Security Checks**: Validation of encryption, access controls, and OIDC configuration
- **CI/CD Testing**: Automated test execution in GitHub Actions

## 🛠️ Prerequisites

- **Terraform** >= 1.0
- **AWS CLI** configured with appropriate permissions
- **GitHub Repository** with Actions enabled
- **AWS Account** with IAM, S3, and KMS permissions
- **Go** >= 1.21 (for Terratest)

## ⚙️ Configuration

### 1. Environment Variables

Update `envs/dev/s3/terraform.tfvars` and `envs/prod/s3/terraform.tfvars`:

```hcl
project_id            = "your-project-name"
bucket_base_name      = "your-bucket-name"
aws_region            = "us-east-1"
versioning_enabled    = true
enable_kms_encryption = true
create_kms_key        = true
kms_key_arn           = null  # or existing KMS key ARN

github_owner          = "your-github-username"
github_repo           = "your-repo-name"
github_branch         = "main"

aws_account_id        = "123456789012"
existing_oidc_provider_arn = "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"

tags = {
  Project = "your-project"
  Owner   = "your-name"
}
```

### 2. Backend Configuration

Update `envs/dev/s3/backend.tf` and `envs/prod/s3/backend.tf`:

```hcl
terraform {
  backend "s3" {
    bucket       = "your-terraform-state-bucket"
    key          = "s3-oidc-dev-terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}
```

### 3. GitHub Actions Setup

1. **Repository Variables**: Set in GitHub → Settings → Secrets and variables → Actions:
   - `AWS_ROLE_ARN_DEV`: ARN of the dev IAM role (output after first deployment)
   - `AWS_ROLE_ARN_PROD`: ARN of the prod IAM role (output after first deployment)

2. **Environment Protection**: Configure GitHub Environments for `dev` and `prod` with appropriate protection rules.

## 🧪 Testing

### Running Tests Locally

```bash
# Install Go dependencies (from repo root)
go mod download
go mod tidy

# Run all tests (from repo root)
go test -v ./test

# Run specific test (from repo root)
go test -v ./test -run Test_PlanChecks

# Run tests with timeout (from repo root)
go test -v -timeout 30m ./test
```

### Test Coverage

The test suite validates:

1. **S3 Bucket Creation**: Ensures bucket is created with correct configuration
2. **Versioning**: Validates bucket versioning is enabled
3. **Encryption**: Checks for KMS encryption configuration
4. **Public Access Blocking**: Verifies all public access is disabled
5. **OIDC Configuration**: Validates GitHub OIDC provider setup
6. **IAM Role**: Ensures IAM role exists with proper naming

### Test Output Example

```bash
=== RUN   Test_PlanChecks
--- PASS: Test_PlanChecks (4.80s)
PASS
ok      github.com/<OWNER>/test    4.802s
```

## 🚀 Deployment

### Local Development

```bash
# Initialize and deploy dev environment
cd envs/dev/s3
terraform init
terraform plan
terraform apply

# Initialize and deploy prod environment
cd envs/prod/s3
terraform init
terraform plan
terraform apply
```

### CI/CD Pipeline

The GitHub Actions workflow automatically:
1. **Lints** and **validates** Terraform code
2. **Runs Terratest** to validate infrastructure configuration
3. **Plans** changes for dev environment
4. **Applies** dev changes (on main branch)
5. **Plans** changes for prod environment
6. **Applies** prod changes (with manual approval)

## 📊 Outputs

After deployment, you'll get:

```hcl
# Development Environment
dev_bucket_name     = "your-project-name-your-bucket-name"
dev_bucket_arn      = "arn:aws:s3:::your-project-name-your-bucket-name"
dev_oidc_role_arn   = "arn:aws:iam::123456789012:role/your-project-name-gh-oidc-role"

# Production Environment
prod_bucket_name    = "your-project-name-prod-your-bucket-name-prod"
prod_bucket_arn     = "arn:aws:s3:::your-project-name-prod-your-bucket-name-prod"
prod_oidc_role_arn  = "arn:aws:iam::123456789012:role/your-project-name-prod-gh-oidc-role"
```

## 🔧 Usage in GitHub Actions

Use the created IAM role in your GitHub Actions workflows:

```yaml
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v3
  with:
    role-to-assume: ${{ vars.AWS_ROLE_ARN_DEV }}  # or AWS_ROLE_ARN_PROD
    aws-region: us-east-1
```

## 🛡️ Security Features

- **OIDC Trust**: Only allows GitHub Actions from specified repository and branch
- **Encryption**: Server-side encryption with KMS (optional)
- **Access Control**: Public access completely blocked
- **Audit Trail**: All actions logged via CloudTrail
- **Least Privilege**: Minimal IAM permissions for GitHub Actions

## 🔄 Maintenance

### Adding New Environments

1. Copy `envs/dev/s3/` to `envs/new-env/s3/`
2. Update `terraform.tfvars` with environment-specific values
3. Update backend configuration
4. Add environment to GitHub Actions workflow
5. Update test configuration if needed

### Updating Module

1. Modify `modules/s3/` files
2. Update tests in `test/` directory
3. Test in dev environment
4. Promote to prod after validation

## 🐛 Troubleshooting

### Common Issues

1. **OIDC Provider Already Exists**: Set `existing_oidc_provider_arn` to use existing provider
2. **IAM Policy Name Conflict**: Module now uses unique names with bucket base name
3. **Backend Lock Issues**: Use `use_lockfile = true` for local development
4. **Test Failures**: Ensure Go is installed and dependencies are downloaded

### Debug Commands

```bash
# Validate configuration
terraform validate

# Check formatting
terraform fmt -check

# View plan details
terraform show plan.tfplan

# Import existing resources
terraform import module.s3.aws_iam_policy.bucket arn:aws:iam::ACCOUNT:policy/POLICY_NAME

# Debug tests (from repo root)
go test -v -run Test_PlanChecks -timeout 30m ./test
```

## 📝 Post-GitHub Setup Instructions

After pushing to your GitHub repository:

### 1. Initial Setup
```bash
# Clone your repository
git clone https://github.com/your-username/your-repo-name.git
cd your-repo-name

# Update configuration files
# - envs/dev/s3/terraform.tfvars
# - envs/prod/s3/terraform.tfvars
# - envs/dev/s3/backend.tf
# - envs/prod/s3/backend.tf

# Install Go dependencies
go mod download
go mod tidy

# Commit and push changes
git add .
git commit -m "Update configuration for deployment"
git push origin main
```

### 2. GitHub Repository Configuration

1. **Enable GitHub Actions**: Go to Settings → Actions → General → Allow all actions
2. **Set Repository Variables**: Settings → Secrets and variables → Actions → Variables
3. **Configure Environments**: Settings → Environments → Create `dev` and `prod`
4. **Set Environment Protection Rules**: Require reviewers for `prod` environment

### 3. First Deployment

1. **Create S3 Backend Bucket**: Create the S3 bucket specified in your backend configuration
2. **Trigger Initial Run**: Push to main branch to trigger GitHub Actions
3. **Monitor Deployment**: Check Actions tab for deployment progress
4. **Capture Outputs**: Note the IAM role ARNs from the deployment outputs

### 4. Configure AWS Credentials

After first deployment, update your GitHub repository variables:
- `AWS_ROLE_ARN_DEV`: Use the dev role ARN from deployment outputs
- `AWS_ROLE_ARN_PROD`: Use the prod role ARN from deployment outputs

### 5. Test Your Setup

```bash
# Run tests locally to validate configuration (from repo root)
go test -v ./test

# Verify GitHub Actions pipeline
# Check the Actions tab in your GitHub repository
```

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add/update tests as needed
5. Test thoroughly
6. Submit a pull request

## 📞 Support

For issues and questions:
- Create a GitHub issue
- Check the troubleshooting section
- Review AWS and Terraform documentation
- Check test output for validation errors 