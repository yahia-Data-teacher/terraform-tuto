resource "aws_s3_bucket" "data_bucket" {
  count  = var.create_bucket ? 1 : 0
  bucket = var.bucket_name

  tags = {
    Name        = "DataBucket-${terraform.workspace}"
    Environment = terraform.workspace
  }
}

# Activer le chiffrement par défaut avec KMS
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  count  = var.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.data_bucket[0].id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.encryption_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

variable "bucket_name" {
  description = "The name of the S3 bucket to create"
  type        = string
}

variable "create_bucket" {
  description = "Whether to create the S3 bucket. Set to false if bucket already exists"
  type        = bool
  default     = true
}

locals {
  # Utilise le bucket créé ou le nom du bucket existant
  bucket_id = var.create_bucket ? (length(aws_s3_bucket.data_bucket) > 0 ? aws_s3_bucket.data_bucket[0].id : var.bucket_name) : var.bucket_name
  bucket_arn = var.create_bucket ? (length(aws_s3_bucket.data_bucket) > 0 ? aws_s3_bucket.data_bucket[0].arn : "arn:aws:s3:::${var.bucket_name}") : "arn:aws:s3:::${var.bucket_name}"
}

output "bucket_id" {
  description = "The ID of the S3 bucket"
  value       = local.bucket_id
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = local.bucket_arn
}
