terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.4.0"
    }
  }

  backend "s3" {
    bucket         = "tcdimitriacosta2023"
    key            = "technologia/terraform.tfstate"
    region         = "us-east-1"
    profile        = "tcdimitri"
    dynamodb_table = "technologia-terraform-state"
  }
}

# Configure the AWS provider
provider "aws" {
  # Configuration options
  region  = "us-east-1"
  profile = "tcdimitri"
}

# Define variables
variable "infra_env" {
  type        = string
  description = "infrastructure environment"
}

variable "default_region" {
  type        = string
  description = "the region this infrastructur is in"
  default     = "us-east-1"
}

variable "instance_size" {
  type        = string
  description = "EC2 web server size"
  default     = "t2.micro"
}

# Get data
data "aws_ami" "ami" {

  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["099720109477"] # Cannonical official
}

# Create resources
resource "aws_instance" "technologia_web" {
  ami           = data.aws_ami.ami.id
  instance_type = var.instance_size

  root_block_device {
    volume_size = 8 #GB
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    "Name"        = "technologia-${var.infra_env}-app"
    "Project"     = "technologia.app"
    "Environment" = var.infra_env
    "ManagedBy"   = "terraform"
  }
}

resource "aws_eip" "technologia_eip" {
  # instance = aws_instance.technologia_web.id
  domain = "vpc"

  # lifecycle {
  #   prevent_destroy = true
  # }

  tags = {
    "Name"        = "technologia-${var.infra_env}-app"
    "Project"     = "technologia.app"
    "Environment" = var.infra_env
    "ManagedBy"   = "terraform"
  }
}

resource "aws_eip_association" "technologia_eip_association" {
  instance_id   = aws_instance.technologia_web.id
  allocation_id = aws_eip.technologia_eip.id
}
