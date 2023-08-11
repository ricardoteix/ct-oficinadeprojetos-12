# IAM Role 
resource "aws_iam_role" "projeto-role" {
  name = "${var.tag-base}-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Sid    = ""
          Principal = {
            Service = "ec2.amazonaws.com"
          }
        },
      ]
    }
  )
  tags = {
    Name = "${var.tag-base}-role"
  }
}

resource "aws_iam_instance_profile" "projeto-profile" {
  name = "${var.tag-base}-profile"
  role = aws_iam_role.projeto-role.name
}

resource "aws_iam_role_policy" "projeto-policy" {
  name = "${var.tag-base}-policy"
  role = aws_iam_role.projeto-role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "sns:Publish"
            ],
            "Resource": [
                "${aws_sns_topic.projeto-events.arn}"
            ]
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
              "s3:DeleteObject",
              "s3:GetObject",
              "s3:ListBucket",
              "s3:PutObject"
            ],
            "Resource": [
              "arn:aws:s3:::${var.nome-bucket}",
              "arn:aws:s3:::${var.nome-bucket}/*"
            ]
        },
        {
            "Sid": "AllowGetParameterStoreMediaCMS",
            "Effect": "Allow",
            "Action": "ssm:GetParameter",
            "Resource": "arn:aws:ssm:us-east-1:${data.aws_caller_identity.current.account_id}:parameter/mediacms"
        }
    ]
}
EOF
}