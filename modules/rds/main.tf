resource "aws_db_subnet_group" "this" {
  name       = "${var.identifier}-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.identifier}-subnet-group"
  }
}

resource "aws_db_instance" "this" {
  identifier             = var.identifier
  engine                 = "postgresql"
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  storage_type           = "gp3"

  # db_name                = var.db_name
  username               = var.username
  password               = var.password

  # vpc_security_group_ids = var.security_group_ids
  vpc_security_group_ids = [
    aws_security_group.rds.id
  ]
  db_subnet_group_name   = aws_db_subnet_group.this.name

  multi_az               = var.multi_az
  publicly_accessible   = var.publicly_accessible
  skip_final_snapshot   = var.skip_final_snapshot
  deletion_protection   = var.deletion_protection

  backup_retention_period = var.backup_retention_days
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window

  tags = var.tags
}
