# Data source to get the latest Amazon Linux 2 AMI
data "aws_ami" "default_vpc_ami" {
  most_recent = true
  owners      = ["099720109477"] # This is the official Ubuntu AMI owner ID.

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"]
  }
}


# Security Group for the EC2 instance
resource "aws_security_group" "app_security_group" {
  name_prefix = "${var.vpc_name}-sg"
  vpc_id      = aws_vpc.main.id # Use the VPC ID from the main VPC

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

  tags = {
    Name = "${var.vpc_name}-app-security-group"
  }
}

# EC2 Instance Configuration
resource "aws_instance" "webapp_ec2_instance" {
  ami                    = var.custom_ami          # Use the fetched AMI from default VPC
  instance_type          = "t2.micro"              # Adjust instance type if needed
  subnet_id              = aws_subnet.public[0].id # Launch EC2 in the first public subnet (adjust as necessary)
  vpc_security_group_ids = [aws_security_group.app_security_group.id]
  key_name               = "dev-keypair"
  # EBS Volume Configuration (Root Volume)
  root_block_device {
    volume_size           = 25    # 25 GB
    volume_type           = "gp2" # General Purpose SSD
    delete_on_termination = true  # Terminate volume when EC2 instance is terminated
  }

  # Disable termination protection (you can change this to "true" if you want protection)
  disable_api_termination = false

  tags = {
    Name = "My webapp_ec2_Instance {{timestamp}}"
  }

  user_data = <<-EOF
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
              AWS_ACCESS_KEY_ID=${var.aws_access}
              AWS_SECRET_ACCESS_KEY=${var.aws_secret_access}
              AWS_REGION=${var.aws_region}
              AWS_BUCKET_NAME=${aws_s3_bucket.this.id}
              EOT

              # Set correct permissions for security
              chmod 600 .env
              EOF
}

output "ec2_instance_public_ip" {
  value = aws_instance.webapp_ec2_instance.public_ip
}

output "ec2_instance_id" {
  value = aws_instance.webapp_ec2_instance.id
}
