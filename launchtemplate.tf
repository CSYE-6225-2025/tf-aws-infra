# Data source to get the latest Ubuntu AMI
data "aws_ami" "default_vpc_ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"]
  }
}

# Security Group for the EC2 instances (WebAppSecurityGroup)
resource "aws_security_group" "app_security_group" {
  name_prefix = "${var.vpc_name}-webapp-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_name}-webapp-security-group"
  }
}

# Launch Template for Auto Scaling Group
resource "aws_launch_template" "webapp" {
  name_prefix   = "csye6225_asg"
  image_id      = var.custom_ami
  instance_type = "t2.micro"
  key_name      = "dev-keypair"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.app_security_group.id]
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash

              # Ensure webapp directory exists
              mkdir -p /opt/csye6225/webapp
              cd /opt/csye6225/webapp

              # Ensure .env file exists before modifying
              touch .env

              # Update environment variables in .env file
              cat <<EOT > .env
              MYSQL_USER=${aws_db_instance.csye6225_db.username}
              MYSQL_PASSWORD=${aws_db_instance.csye6225_db.password}
              MYSQL_HOST=$(echo ${aws_db_instance.csye6225_db.endpoint} | cut -d ':' -f 1)
              MYSQL_DB=${aws_db_instance.csye6225_db.db_name}
              MYSQL_PORT=3306
              PORT=8080
              AWS_REGION=${var.aws_region}
              AWS_BUCKET_NAME=${aws_s3_bucket.this.id}
              EOT

              # Set correct permissions for security
              chmod 600 .env
              
              # Ensure logs directory exists
              mkdir -p /opt/csye6225/webapp/logs
              chown csye6225:csye6225 /opt/csye6225/webapp/logs
              chmod 755 /opt/csye6225/webapp/logs

              # Start CloudWatch Agent
              systemctl start amazon-cloudwatch-agent.service

              # Enable CloudWatch Agent to start on boot (redundant but ensures it's enabled)
              systemctl enable amazon-cloudwatch-agent.service

              # Verify CloudWatch Agent status
              if ! systemctl is-active --quiet amazon-cloudwatch-agent.service; then
                  echo "ERROR: Failed to start CloudWatch Agent!"
                  exit 1
              fi
              EOF
  )

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required" # IMDSv2
  }

  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size           = 25
      volume_type           = "gp2"
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.vpc_name}-webapp-instance"
    }
  }
}