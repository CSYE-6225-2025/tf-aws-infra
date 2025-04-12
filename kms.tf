
# Data source for account ID
data "aws_caller_identity" "current" {}

# KMS Key for EC2 (EBS encryption)
resource "aws_kms_key" "ec2_key" {
  description             = "KMS key for EC2 EBS encryption"
  enable_key_rotation     = true
  rotation_period_in_days = 90
  is_enabled              = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid" : "Allow service-linked role use of the customer managed key",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
          ]
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "Allow attachment of persistent resources",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
          ]
        },
        "Action" : [
          "kms:CreateGrant"
        ],
        "Resource" : "*",
        "Condition" : {
          "Bool" : {
            "kms:GrantIsForAWSResource" : true
          }
        }
      },
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow EC2 and Auto Scaling Services"
        Effect = "Allow"
        Principal = {
          Service = [
            "ec2.amazonaws.com",
            "autoscaling.amazonaws.com"
          ]
        }
        Action = [
          "kms:CreateGrant",
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKeyWithoutPlainText",
          "kms:ReEncrypt*",
          "kms:Encrypt",
          "kms:GenerateDataKey*"
        ]
        Resource = "*"
      },
      {
        Sid    = "Allow EC2 Role"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.ec2_role.arn
        }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "${var.vpc_name}-ec2-kms-key"
  }
}

resource "aws_kms_alias" "ec2_key_alias" {
  name          = "alias/${var.vpc_name}-ec2-key"
  target_key_id = aws_kms_key.ec2_key.key_id
}

# KMS Key for RDS
resource "aws_kms_key" "rds_key" {
  description             = "KMS key for RDS encryption"
  enable_key_rotation     = true
  rotation_period_in_days = 90
  is_enabled              = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow RDS Service"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "${var.vpc_name}-rds-kms-key"
  }
}

resource "aws_kms_alias" "rds_key_alias" {
  name          = "alias/${var.vpc_name}-rds-key"
  target_key_id = aws_kms_key.rds_key.key_id
}

# KMS Key for S3
resource "aws_kms_key" "s3_key" {
  description             = "KMS key for S3 bucket encryption"
  enable_key_rotation     = true
  rotation_period_in_days = 90
  is_enabled              = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"


        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow S3 Service"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      },
      {
        Sid    = "Allow EC2 Role"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.ec2_role.arn
        }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "${var.vpc_name}-s3-kms-key"
  }
}

resource "aws_kms_alias" "s3_key_alias" {
  name          = "alias/${var.vpc_name}-s3-key"
  target_key_id = aws_kms_key.s3_key.key_id
}

# KMS Key for Secrets Manager
resource "aws_kms_key" "secrets_manager_key" {
  description             = "KMS key for Secrets Manager"
  enable_key_rotation     = true
  rotation_period_in_days = 90
  is_enabled              = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow Secrets Manager Service"
        Effect = "Allow"
        Principal = {
          Service = "secretsmanager.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      },
      {
        Sid    = "Allow EC2 Role"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.ec2_role.arn
        }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "${var.vpc_name}-secrets-manager-kms-key"
  }
}

resource "aws_kms_alias" "secrets_manager_key_alias" {
  name          = "alias/${var.vpc_name}-secrets-manager-key"
  target_key_id = aws_kms_key.secrets_manager_key.key_id
}
