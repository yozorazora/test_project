# provider "aws" {
#   access_key = var.ak
#   secret_key = var.sk
#   region = var.aws_region
# }

module "vpc" {
  source = "./modules/vpc"
  cluster_name = var.vpc_name
  cidr = var.cidr
}

# module "rds" {
#   source = "./modules/rds"
#   cluster_name = var.cluster_name
#   cidr = var.cidr
# }

module "rds" {
  source = "./modules/rds"

  identifier            = "billionpay-rds-prd"
  instance_class        = "db.t3.micro"
  username              = "root"
  password              = var.db_password

  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnets
  public_subnet_ids     = module.vpc.public_subnets
  # security_group_ids    = var.security_group_ids

  multi_az              = false
  publicly_accessible   = false
}

module "ec2" {
  source = "./modules/ec2"
  vpc_id = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnets
  public_subnet_ids     = module.vpc.public_subnets
}
