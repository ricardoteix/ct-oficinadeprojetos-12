# Exibindo dados no console após criaçao

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

output "nome-bucket" {
  value = var.nome-bucket
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

output "ec2_conn_dns_name" {
    value = aws_ec2_instance_connect_endpoint.ec2_conn.dns_name
}

output "ec2_conn_arn" {
    value = aws_ec2_instance_connect_endpoint.ec2_conn.arn
}

output "ec2-instance-conn" {
  value = "aws ec2-instance-connect ssh --instance-id EC2_ID --profile ${var.profile} --os-user ubuntu"
}
