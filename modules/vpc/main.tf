data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 2)
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.6.0"

  name = var.cluster_name
  cidr = var.cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(var.cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(var.cidr, 4, k + 4)]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

# ----------------------------------------------------------
# VPC Protection Resource
# ----------------------------------------------------------
resource "null_resource" "vpc_protect" {
  lifecycle {
    prevent_destroy = true
  }

  # Connect to the VPC so Terraform treats this as dependent
  triggers = {
    vpc_id = module.vpc.vpc_id
  }
}
