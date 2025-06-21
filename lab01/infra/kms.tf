# KMS key pour le chiffrement
resource "aws_kms_key" "encryption_key" {
  description             = "KMS key for ${terraform.workspace} environment"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name        = "encryption-key-${terraform.workspace}"
    Environment = terraform.workspace
  }

  # Politique permettant l'utilisation de la clé
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
        Sid    = "Allow Lambda to use the key"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.lambda_role.arn
        }
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
      }
    ]
  })
}

# Alias pour la clé KMS (plus facile à gérer que l'ID)
resource "aws_kms_alias" "encryption_key_alias" {
  name          = "alias/${terraform.workspace}-encryption-key"
  target_key_id = aws_kms_key.encryption_key.key_id
}

# Data source pour obtenir l'ID du compte AWS actuel
data "aws_caller_identity" "current" {}

# Outputs
output "kms_key_id" {
  description = "L'ID de la clé KMS"
  value       = aws_kms_key.encryption_key.key_id
}

output "kms_key_arn" {
  description = "L'ARN de la clé KMS"
  value       = aws_kms_key.encryption_key.arn
}

output "kms_key_alias" {
  description = "L'alias de la clé KMS"
  value       = aws_kms_alias.encryption_key_alias.name
}
