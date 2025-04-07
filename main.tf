module "vpc" {
  source = "./modules/vpc"

  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

module "s3_state" {
  source = "./modules/s3"

  bucket_name = "interview-project-bucket-009909"
  environment = var.environment
}

module "dynamodb_lock" {
  source = "./modules/dynamodb"

  table_name  = "terraform-state-lock"
  environment = var.environment
}

module "compute" {
  source = "./modules/compute"

  environment       = var.environment
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  instance_type     = var.instance_type
  key_name          = var.key_name
  min_size          = var.asg_min_size
  max_size          = var.asg_max_size
  desired_capacity  = var.asg_desired_capacity
}

module "monitoring" {
  source = "./modules/monitoring"

  environment       = var.environment
  logs_bucket_name  = var.logs_bucket_name
  vpc_id            = module.vpc.vpc_id
  enable_cloudtrail = var.enable_monitoring
  asg_name          = module.compute.asg_name
}
