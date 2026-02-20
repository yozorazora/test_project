resource "aws_security_group" "rds" {
  # count = length(var.security_group_ids) == 0 ? 1 : 0

  name        = "${var.identifier}-rds-sg"
  description = "Auto-created security group for RDS MySQL"
  vpc_id      = var.vpc_id

  ingress {
    description = "private subnet access"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = var.private_subnet_ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.identifier}-rds-sg"
  }
}
