locals {
  name_prefix = "three-tier-${var.environment}"
}

module "vpc" {
  source = "./modules/vpc"
  name   = local.name_prefix
}

module "ecr" {
  source = "./modules/ecr"
  name   = local.name_prefix
}

module "alb" {
  source = "./modules/alb"
  name   = local.name_prefix
  vpc_id = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
}

module "ecs" {
  source        = "./modules/ecs-fargate"
  name          = local.name_prefix
  vpc_id        = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets
  public_subnet_ids  = module.vpc.public_subnets
  app_image     = var.app_image
  datadog_api_key = var.datadog_api_key
  lb_target_group_arn = module.alb.target_group_arn
  alb_security_group_id = module.alb.alb_security_group_id
  aws_region = var.aws_region
}

module "rds" {
  source = "./modules/rds"
  name   = local.name_prefix
  vpc_id = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
}

module "monitoring" {
  source = "./modules/monitoring"
  name   = local.name_prefix
  datadog_api_key = var.datadog_api_key
  ecs_cluster_name = module.ecs.cluster_name
  rds_identifier = module.rds.db_identifier
  alert_email = var.alert_email
  aws_region = var.aws_region
}

output "cluster_name" {
  value = module.ecs.cluster_name
}

output "alb_dns" {
  value = module.alb.alb_dns_name
}
