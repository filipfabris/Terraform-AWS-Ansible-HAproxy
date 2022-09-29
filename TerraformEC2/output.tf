output "load_balancer_public_ip" {
  value = aws_instance.haproxy_load_balancer[0].public_ip
}

output "web1_public_ip" {
  value = aws_instance.web[0].public_ip
}

output "web2_public_ip" {
  value = aws_instance.web[1].public_ip
}
