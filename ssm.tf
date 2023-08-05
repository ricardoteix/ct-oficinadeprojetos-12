resource "aws_ssm_parameter" "mediacms_params" {
  name  = "mediacms"
  type  = "String"
  value = jsonencode(
    {
        region = "${var.regiao}",
        sns_topic_arn = aws_sns_topic.projeto-events.arn,
        rds_addr = aws_db_instance.projeto-rds.address,
        full_domain = var.has-domain ? "${var.domain}.${var.hosted_zone_name}" : "localhost"
        s3_user_id = aws_iam_access_key.s3_user_key.id,
        s3_user_secret = aws_iam_access_key.s3_user_key.secret,
        s3_bucket_name = var.nome-bucket,
        cloudfront_domain_name = aws_cloudfront_distribution.media_cloudfront.domain_name,
        sns_email = var.sns-email,
        smtp_user = aws_iam_access_key.smtp_user.id,
        smtp_password = aws_iam_access_key.smtp_user.ses_smtp_password_v4,
        smtp_host = "email-smtp.${var.regiao}.amazonaws.com",
        redis_endpoint = aws_elasticache_cluster.redis.cache_nodes.0.address
    }
  )
}