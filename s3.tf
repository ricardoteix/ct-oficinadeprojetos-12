resource "aws_s3_bucket" "projeto-static" {
  bucket = var.nome-bucket

  force_destroy = true # CUIDADO! Em um ambiente de produção você pode não querer apagar tudo no bucket

  tags = {
    Name = var.tag-base
  }
}

# resource "aws_s3_bucket_acl" "projeto-static-acl" {
#   bucket = aws_s3_bucket.projeto-static.id
#   acl    = "private"
# }


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