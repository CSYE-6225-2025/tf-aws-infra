provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

resource "aws_vpc" "main" {
  cidr_block         = var.vpc_cidr
  enable_dns_support = true

  tags = {
    Name = "${var.vpc_name}"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

resource "aws_subnet" "public" {
  count = length(var.public_subnets_cidr)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnets_cidr[count.index]
  availability_zone = var.public_subnets_az[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-public-subnet-${count.index}"
  }
}

resource "aws_subnet" "private" {
  count = length(var.private_subnets_cidr)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets_cidr[count.index]
  availability_zone = var.private_subnets_az[count.index]

  tags = {
    Name = "${var.vpc_name}-private-subnet-${count.index}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-public-route-table"
  }
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-private-route-table"
  }
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}


resource "random_uuid" "s3_bucket_name" {}

resource "aws_s3_bucket" "this" {
  bucket        = random_uuid.s3_bucket_name.result
  force_destroy = true # Allows Terraform to delete the bucket even if it contains objects

  tags = {
    Name = "${var.vpc_name}-s3-bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_key.arn
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "transition-to-ia"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}

output "s3_bucket_name" {
  value = aws_s3_bucket.this.id
}