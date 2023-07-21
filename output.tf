
# Exibindo dados no console após criaçao

output "projeto-id" {
  value = aws_instance.projeto.id
}

output "projeto-dns" {
  value = aws_instance.projeto.public_dns
}

output "projeto-ip" {
  value = aws_instance.projeto.public_ip
}

output "elb-dns" {
  value = aws_lb.projeto-elb.dns_name
}

output "projeto-rds-nome-banco" {
  value = var.rds-nome-banco
}

output "projeto-rds-nome-usuario" {
  value = var.rds-nome-usuario
}

output "projeto-rds-nome-senha" {
  value = var.rds-senha-usuario
}

output "projeto-rds-dns" {
  value = aws_db_instance.projeto-rds.domain
}

output "projeto-rds-host" {
  value = aws_db_instance.projeto-rds.address
}

output "server" {
  value = "http://${aws_instance.projeto.public_dns}/info.php"
}

output "projeto-efs_id" {
  value = aws_efs_file_system.projeto-efs.id
}

output "nome-bucket" {
  value = var.nome-bucket
}

# output "projeto-user-data-script" {
#   value = data.template_file.projeto-user-data-script.rendered
# }

output "s3-user-id" {
  value = aws_iam_access_key.s3_user_key.id
}

output "s3-user-secret" {
  value = aws_iam_access_key.s3_user_key.secret
  sensitive = true
}

output "domain" {
  value = var.domain
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.media_cloudfront.domain_name
}

output "smtp_username" {
  value = aws_iam_access_key.smtp_user.id
}

output "smtp_password" {
  value = aws_iam_access_key.smtp_user.ses_smtp_password_v4
  sensitive = true
}

output "redis_endpoint" {
    value = aws_elasticache_cluster.redis.cache_nodes.0.address
}