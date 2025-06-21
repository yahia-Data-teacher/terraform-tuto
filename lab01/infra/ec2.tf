resource "aws_instance" "ec2" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name = "ExampleInstance-${terraform.workspace}"
  }

}

variable "ami_id" {
  description = "The AMI ID to use for the EC2 instance"
  type        = string
  default     = "ami-09e6f87a47903347c"
}

variable "instance_type" {
  description = "The type of instance to use for the EC2 instance"
  type        = string
  default     = "t2.micro"
}