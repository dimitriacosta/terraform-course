terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.4.0"
    }
  }

  backend "s3" {
    bucket  = "tcdimitriacosta2023"
    key     = "technologia/terraform.tfstate"
    region  = "us-east-1"
    profile = "tcdimitri"
    # dynamodb_table = "technologia-terraform-state"
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
module "ec2_app" {
  source = "./modules/ec2"

  infra_env     = var.infra_env
  infra_role    = "app"
  instance_size = "t2.micro"
  instance_ami  = data.aws_ami.ami.id
  # instance_root_device_size = 12 # optional
}

module "ec2_worker" {
  source = "./modules/ec2"

  infra_env                 = var.infra_env
  infra_role                = "worker"
  instance_size             = "t3.large"
  instance_ami              = data.aws_ami.ami.id
  instance_root_device_size = 50
}
