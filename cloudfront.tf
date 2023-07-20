resource "aws_cloudfront_origin_access_identity" "default" {
  comment = "Access identity for CloudFront to access the S3 bucket"
}

resource "aws_cloudfront_distribution" "media_cloudfront" {
  origin {
    domain_name = aws_s3_bucket.projeto-static.bucket_domain_name
    origin_id   = aws_s3_bucket.projeto-static.id
    
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.default.cloudfront_access_identity_path
    }
    
    # Configuração para permitir que o CloudFront envie cabeçalhos CORS ao S3
    # custom_origin_config {
    #   http_port              = 80
    #   https_port             = 443
    #   origin_protocol_policy = "http-only"
    #   origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    # }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for ct-projeto12-rts-mediacms"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = aws_s3_bucket.projeto-static.id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }

      # Configuração para permitir que o CloudFront inclua os cabeçalhos CORS nos pedidos
      # Isso é essencial para evitar erros de CORS
      headers = ["Origin"]
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Configuração para evitar a inclusão do cabeçalho "Referer" nos pedidos para o S3
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    # acm_certificate_arn = data.aws_acm_certificate.issued[0].arn  # Substitua pelo ARN do seu certificado ACM, se desejar HTTPS
    # ssl_support_method  = "sni-only"
    cloudfront_default_certificate = true
  }
}


# Definindo a Bucket policy para permitir o acesso do CloudFront aos objetos no bucket S3
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.projeto-static.bucket

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect  = "Allow",
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.default.iam_arn
        },
        Action = "s3:GetObject",
        Resource = "${aws_s3_bucket.projeto-static.arn}/*"
      }
    ]
  })
}