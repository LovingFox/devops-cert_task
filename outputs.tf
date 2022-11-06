# outputs.tf

output "builder_dns_name" {
  value = aws_instance.builder_instance.public_dns
  description = "DNS name of the Builder"
}

# end of outputs.tf
