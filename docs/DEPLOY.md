# Deployment Guide

1. Create an S3 bucket and DynamoDB table for Terraform remote state. Update `infra/terraform/backend.tf` accordingly.
2. Store your Datadog API key in SSM Parameter Store or GitHub Secrets (recommended: SSM SecureString).
3. Build and push the API Docker image to ECR:

```bash
export AWS_REGION=us-east-1
./scripts/build-and-push.sh <ECR_REPO_URI>
```

4. Update `infra/terraform/envs/dev.tfvars` with `app_image` set to your pushed image.
5. Initialize Terraform and apply:

```bash
cd infra/terraform
terraform init
terraform plan -var-file=envs/dev.tfvars
terraform apply -var-file=envs/dev.tfvars
```

Notes:
- For production, use separate tfvars and remote state. Do not store secrets in plaintext.
- The Datadog API key should be passed via SSM/Secrets Manager and referenced in Terraform.
