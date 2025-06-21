# IAM role pour Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role-${terraform.workspace}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = terraform.workspace
    Project     = var.project
  }
}

# Attachment de la policy de base pour Lambda
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

# Fonction Lambda
resource "aws_lambda_function" "example_lambda" {
  filename         = var.lambda_zip_path
  function_name    = "example-lambda-python-${terraform.workspace}"
  role            = aws_iam_role.lambda_role.arn
  handler         = "lambda_function.handler"
  runtime         = "python3.9"
  timeout         = 30
  memory_size     = 128

  environment {
    variables = {
      ENVIRONMENT = terraform.workspace
      PROJECT     = var.project
    }
  }

  tags = {
    Name        = "ExampleLambdaPython-${terraform.workspace}"
    Environment = terraform.workspace
    Project     = var.project
  }
}

# Variables pour Lambda
variable "lambda_zip_path" {
  description = "Path to the Lambda function's deployment package"
  type        = string
  default     = "lambda/function.zip"
}

variable "project" {
  description = "Project name for tagging"
  type        = string
  default     = "terraform-lab01"
}

# Outputs
output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.example_lambda.arn
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.example_lambda.function_name
}

output "lambda_role_arn" {
  description = "ARN of the Lambda IAM role"
  value       = aws_iam_role.lambda_role.arn
}
