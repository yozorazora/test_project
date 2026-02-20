# variable "ak" {
#   description = "AWS Access Key"
#   type        = string
#   default     = "asasas"
# }
#
# variable "sk" {
#   description = "AWS Secret Key"
#   type        = string
#   default     = "asasasasasas"
# }

variable "aws_region" {
  description = "The AWS region where resources will be managed"
  type        = string
  default     = "us-east-2"
}

variable "project_name" {
  description = "The name of your startup"
  type        = string
  default     = "new-project"
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_name" {
  description = "vpc name"
  type        = string
  default     = "new-project"
}

variable "cidr" {
  description = "vpc cidr"
  type        = string
  default     = "192.168.0.0/16"
}

variable "db_password" {
  description = "db password"
  type        = string
  default     = "asas"
}