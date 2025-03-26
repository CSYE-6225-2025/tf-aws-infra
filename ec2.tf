# Data source to get the latest Amazon Linux 2 AMI
data "aws_ami" "default_vpc_ami" {
  most_recent = true
  owners      = ["099720109477"] # This is the official Ubuntu AMI owner ID.

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"]
  }
}

# # Create IAM Role for EC2
# resource "aws_iam_role" "ec2_cloudwatch_role" {
#   name = "EC2-CloudWatch-Role-${var.vpc_name}"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#       }
#     ]
#   })
# }

# # Attach CloudWatch policy to the role
# resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy" {
#   role       = aws_iam_role.ec2_cloudwatch_role.name
#   policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
# }

# Create IAM Instance Profile
# resource "aws_iam_instance_profile" "ec2_profile" {
#   name = "EC2-CloudWatch-Profile-${var.vpc_name}"
#   role = aws_iam_role.ec2_cloudwatch_role.name
# }



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
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name # Attach IAM role


  # Enable IMDSv2 (required for credential access)
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required" # Use IMDSv2
  }

  # EBS Volume Configuration (Root Volume)
  root_block_device {
    volume_size           = 25    # 25 GB
    volume_type           = "gp2" # General Purpose SSD
    delete_on_termination = true  # Terminate volume when EC2 instance is terminated
  }

  # Disable termination protection (you can change this to "true" if you want protection)
  disable_api_termination = false

  tags = {
    Name = "${var.vpc_name}-webapp-instance"
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
}

output "ec2_instance_public_ip" {
  value = aws_instance.webapp_ec2_instance.public_ip
}

output "ec2_instance_id" {
  value = aws_instance.webapp_ec2_instance.id
}
