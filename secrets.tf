# Secrets Manager secret for RDS password
resource "random_password" "db_password" {
  length  = 16
  special = false
}
resource "aws_secretsmanager_secret" "db_master_password_secret" {
  name                    = "${var.vpc_name}-db-master-password"
  description             = "RDS master password for ${var.vpc_name}"
  kms_key_id              = aws_kms_key.secrets_manager_key.arn
  recovery_window_in_days = 0 # Allows immediate deletion for testing; set to 7-30 in production

  tags = {
    Name = "${var.vpc_name}-db-master-password-secret"
  }
}

# Secret version
resource "aws_secretsmanager_secret_version" "db_master_password_version" {
  secret_id     = aws_secretsmanager_secret.db_master_password_secret.id
  secret_string = jsonencode({ password = random_password.db_password.result })
}