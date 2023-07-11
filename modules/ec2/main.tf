resource "aws_instance" "technologia_web" {
  ami           = var.instance_ami
  instance_type = var.instance_size

  root_block_device {
    volume_size = var.instance_root_device_size
    volume_type = "gp3"
  }

  tags = {
    Name        = "technologia-${var.infra_env}-app"
    Role = var.infra_role
    Project     = "technologia.app"
    Environment = var.infra_env
    ManagedBy   = "terraform"
  }
}

resource "aws_eip" "technologia_eip" {
  # We're not doing this directly
  # instance = aws_instance.technologia_web.id
  domain = "vpc"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "technologia-${var.infra_env}-app"
    Role = var.infra_role
    Project     = "technologia.app"
    Environment = var.infra_env
    ManagedBy   = "terraform"
  }
}

resource "aws_eip_association" "technologia_eip_association" {
  instance_id   = aws_instance.technologia_web.id
  allocation_id = aws_eip.technologia_eip.id
}

