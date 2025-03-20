# Database Security Group
resource "aws_security_group" "db_security_group" {
  name_prefix = "${var.vpc_name}-db-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_security_group.id]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.app_security_group.id]
  }

  tags = {
    Name = "${var.vpc_name}-db-security-group"
  }
}

# RDS Parameter Group
resource "aws_db_parameter_group" "csye6225_db_pg" {
  name_prefix = "csye6225-pg-"
  family      = "mysql8.0" # Adjust for PostgreSQL or MariaDB if needed

  parameter {
    name  = "max_connections"
    value = "100"
  }

  # Ensure the parameter group is deleted before the RDS instance
  lifecycle {
    create_before_destroy = true
  }
}

# RDS Subnet Group
resource "aws_db_subnet_group" "csye6225_db_subnet_group" {
  name_prefix = "csye6225-db-subnet-group-"
  subnet_ids  = aws_subnet.private[*].id

  tags = {
    Name = "${var.vpc_name}-db-subnet-group"
  }

  # Ensure the subnet group is deleted before the RDS instance
  lifecycle {
    create_before_destroy = true
  }
}

# RDS Instance
resource "aws_db_instance" "csye6225_db" {
  identifier             = "csye6225"
  engine                 = "mysql" # Change to "postgres" or "mariadb" if needed
  engine_version         = "8.0"   # Specify the MySQL version
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  username               = var.db_username
  password               = var.db_password
  db_name                = var.db_name
  parameter_group_name   = aws_db_parameter_group.csye6225_db_pg.name
  vpc_security_group_ids = [aws_security_group.db_security_group.id]
  db_subnet_group_name   = aws_db_subnet_group.csye6225_db_subnet_group.name
  publicly_accessible    = false
  skip_final_snapshot    = true

  # Ensure the RDS instance is deleted before the parameter group and subnet group
  depends_on = [
    aws_db_parameter_group.csye6225_db_pg,
    aws_db_subnet_group.csye6225_db_subnet_group
  ]
}

output "rds_endpoint" {
  value = aws_db_instance.csye6225_db.endpoint
}