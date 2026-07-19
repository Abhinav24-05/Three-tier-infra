variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "dev"
}

variable "datadog_api_key" {
  description = "Datadog API key (provide via env or tfvars)"
  type        = string
  sensitive   = true
}

variable "alert_email" {
  description = "Optional email address to subscribe to SNS alerts"
  type = string
  default = ""
}

variable "app_image" {
  description = "Container image for the app (ECR URI or image:tag)"
  type        = string
  default     = ""
}
