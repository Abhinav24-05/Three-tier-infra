# Terraform infra

This folder contains Terraform configuration for AWS infrastructure focused on a 3-tier design (ALB -> ECS Fargate -> RDS) and Datadog integration.

Structure:
- `providers.tf` - provider declarations
- `backend.tf` - remote state backend (S3 + DynamoDB)
- `envs/` - environment-specific tfvars
- `modules/` - reusable modules (vpc, ecr, ecs, alb, rds, monitoring)

Replace placeholders in `backend.tf` and provider configuration before `terraform init`.
