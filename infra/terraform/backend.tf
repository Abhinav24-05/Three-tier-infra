# Configure your remote state backend (S3 + DynamoDB) before running `terraform init`.
# Example (uncomment and fill values):
#
# terraform {
#   backend "s3" {
#     bucket         = "my-tf-state-bucket"
#     key            = "three-tier/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "my-tf-locks"
#   }
# }
