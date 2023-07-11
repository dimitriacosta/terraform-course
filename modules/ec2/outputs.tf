output "app_eip" {
  value = aws_eip.technologia_eip.public_ip
}

output "app_instance" {
  value = aws_instance.technologia_web.id
}