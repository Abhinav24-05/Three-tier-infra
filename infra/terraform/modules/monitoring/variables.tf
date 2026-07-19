variable "name" { type = string }
variable "ecs_cluster_name" { type = string }
variable "rds_identifier" { type = string }
variable "alert_email" { type = string, default = "" }
variable "aws_region" { type = string }
