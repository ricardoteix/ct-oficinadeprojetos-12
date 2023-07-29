resource "aws_s3_bucket" "projeto-static" {
  bucket = var.nome-bucket

  force_destroy = true # CUIDADO! Em um ambiente de produção você pode não querer apagar tudo no bucket

  tags = {
    Name = var.tag-base
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "projeto-static-config" {
  bucket = aws_s3_bucket.projeto-static.id

  rule {
    id = var.nome-bucket

    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

  }

}


# Enviando .env ao S3
resource "random_string" "random_etag" {
  length  = 6
  special = false
  upper   = true
  lower   = true
  numeric  = true
}

resource "aws_s3_object" "env_upload" {
  bucket = var.nome-bucket
  key    = ".env"
  source = "${path.module}/usando_ami/.env"
  etag   = "${random_string.random_etag.result}"
  
  depends_on = [ 
    local_file.dot_env,
    aws_s3_bucket.projeto-static
  ]
}

resource "aws_s3_object" "banner_upload" {
  bucket = var.nome-bucket
  key    = "userlogos/banner.jpg"
  source = "${path.module}/usando_ami/subir_para_bucket/userlogos/banner.jpg"
  etag   = "${random_string.random_etag.result}"
  
  depends_on = [ 
    aws_s3_bucket.projeto-static
  ]
}

resource "aws_s3_object" "user_upload" {
  bucket = var.nome-bucket
  key    = "userlogos/user.jpg"
  source = "${path.module}/usando_ami/subir_para_bucket/userlogos/user.jpg"
  etag   = "${random_string.random_etag.result}"
  
  depends_on = [ 
    aws_s3_bucket.projeto-static
  ]
}

resource "aws_s3_object" "hls_upload" {
  bucket = var.nome-bucket
  key    = "hls/placeholder.txt"
  source = "${path.module}/usando_ami/subir_para_bucket/hls/placeholder.txt"
  etag   = "${random_string.random_etag.result}"
  
  depends_on = [ 
    aws_s3_bucket.projeto-static
  ]
}


