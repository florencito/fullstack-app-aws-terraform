output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet_id" {
  value = aws_subnet.private.id
}

output "mysql_endpoint" {
  value = aws_db_instance.mysql.endpoint
}

output "ec2_public_ip" {
  description = "Dirección IP pública de la instancia EC2"
  value       = aws_instance.flask_server.public_ip
}
