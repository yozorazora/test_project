resource "aws_security_group" "alb_sg" {
  name   = "alb-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "app_sg" {
  name   = "app-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

## ALB
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 10.5.0"

  name               = "app-alb"
  load_balancer_type = "application"
  vpc_id             = var.vpc_id
  subnets            = var.public_subnet_ids
  security_groups    = [aws_security_group.alb_sg.id]

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"
      forward = {
        target_group_key = "app"
      }
    }
  }

  target_groups = {
    app = {
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"

      # THIS IS THE KEY FIX FOR VERSION 10.x
      create_attachment = false

      health_check = {
        path    = "/"
        matcher = "200"
      }
    }
  }
}

##AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

#Launch Template
resource "aws_launch_template" "app" {
  name_prefix   = "app-lt-"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = base64encode(<<-EOF
#!/bin/bash
dnf update -y
dnf install -y nginx
systemctl enable nginx
systemctl start nginx
echo "Hello from $(hostname)" > /usr/share/nginx/html/index.html
EOF
  )
}

#Auto Scaling
module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 9.0.0"

  name = "app-asg"
  min_size         = 1
  max_size         = 3
  desired_capacity = 1

  vpc_zone_identifier = var.private_subnet_ids
  launch_template_id      = aws_launch_template.app.id
  launch_template_version = "$Latest"

  traffic_source_attachments = {
    alb = {
      # Ensure this reference matches the key 'app' in your ALB module
      traffic_source_identifier = module.alb.target_groups["app"].arn
      traffic_source_type       = "elbv2"
    }
  }

  health_check_type = "ELB"
}

