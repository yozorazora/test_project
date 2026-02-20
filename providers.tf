terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
      # version = "~> 6.32.1"
      # version = "~> 8.0.0"
    }
  }

  # backend "s3" {
  #   bucket         = "gtn-candidate-tfstate-bucket"
  #   key            = "assessment.tfstate"
  #   region         = "us-east-2"
  # }
}

provider "aws" {
  access_key = var.ak
  secret_key = var.sk
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
