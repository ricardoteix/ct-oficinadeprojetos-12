# IAM User S3
resource "aws_iam_user" "s3_user" {
  name = "s3_user"
  path = "/"

  tags = {
    tag-key = "${var.tag-base}"
  }
}

resource "aws_iam_access_key" "s3_user_key" {
  user = aws_iam_user.s3_user.name
}

resource "aws_iam_user_policy" "s3_user_policy" {
  name = "s3_user_policy"
  user = aws_iam_user.s3_user.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}


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
                "sns:Publish",
                "s3:ListBucket",
                "elasticfilesystem:DescribeFileSystems"
            ],
            "Resource": [
                "arn:aws:s3:::${var.nome-bucket}",
                "arn:aws:elasticfilesystem:*:930779231265:file-system/*",
                "${aws_sns_topic.projeto-events.arn}"
            ]
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "*",
            "Resource": "arn:aws:s3:::${var.nome-bucket}/*"
        }
    ]
}
EOF
}