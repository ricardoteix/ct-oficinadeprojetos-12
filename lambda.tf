# Faz upload do código da função Lambda para a AWS
resource "aws_lambda_function" "mediacms-upload-control" {
    count = var.use-upload-instance == 1 ? 1 : 0
    function_name = "mediacms-upload-control"
    handler       = "lambda_function.lambda_handler"
    publish       = true
    runtime      = "python3.11"
    timeout = 15
    role         = aws_iam_role.mediacms-lambda-role[0].arn
    filename      = data.archive_file.lambda_function.output_path
    source_code_hash = data.archive_file.lambda_function.output_base64sha256
}

# Define o código da função Lambda
data "archive_file" "lambda_function" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/mediacms-upload-control.zip"
}

# Cria uma política de segurança que permite a função Lambda publicar logs no CloudWatch
resource "aws_iam_policy" "mediacms-log-policy" {
    count = var.use-upload-instance == 1 ? 1 : 0    
    name        = "mediacms-log-policy"
    policy      = jsonencode(
    {
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow",
                Action = "logs:CreateLogGroup",
                Resource = "arn:aws:logs:${var.regiao}:${data.aws_caller_identity.current.account_id}:*"
            },
            {
              Effect = "Allow",
              Action = [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
              ],
              Resource = [
                "arn:aws:logs:${var.regiao}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${aws_lambda_function.mediacms-upload-control[0].function_name}:*"
              ]
            }
        ]
    })
}

# Cria uma política de segurança que permite a função Lambda acessar recursos do EC2
resource "aws_iam_policy" "mediacms-ec2-policy" {
    count = var.use-upload-instance == 1 ? 1 : 0
    name        = "mediacms-ec2-policy"
    policy      = jsonencode(
    {
        Version = "2012-10-17"
        Statement = [
          {
            Sid = "VisualEditor0",
            Effect = "Allow",
            Action = [
                "ec2:DescribeInstances",
            ],
            Resource = "*"
          },
          {
            Sid = "VisualEditor1",
            Effect = "Allow",
            Action = [
                "ec2:StartInstances",
                "ec2:DescribeTags",
            ],
            Resource = "arn:aws:ec2:${var.regiao}:${data.aws_caller_identity.current.account_id}:instance/*"
          }
        ]
    })
}


# Cria uma função IAM que permite a função Lambda acessar o EC2
resource "aws_iam_role" "mediacms-lambda-role" {
    count = var.use-upload-instance == 1 ? 1 : 0    
    name = "mediacms-lambda-role"
    assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Anexa a política de segurança à função IAM
resource "aws_iam_role_policy_attachment" "mediacms-log-policy-attachment" {
    count = var.use-upload-instance == 1 ? 1 : 0
    policy_arn = aws_iam_policy.mediacms-log-policy[0].arn
    role       = aws_iam_role.mediacms-lambda-role[0].name
}

# Anexa a política de segurança à função IAM
resource "aws_iam_role_policy_attachment" "mediacms-ec2-policy-attachment" {
    count = var.use-upload-instance == 1 ? 1 : 0
    policy_arn = aws_iam_policy.mediacms-ec2-policy[0].arn
    role       = aws_iam_role.mediacms-lambda-role[0].name
}

# Cria uma regra de evento que é ativada sempre que uma um arquivo
# é enviar por multipart upload
resource "aws_s3_bucket_notification" "bucket_notification" {
    bucket = var.nome-bucket
    count = var.use-upload-instance == 1 ? 1 : 0

    lambda_function {
        lambda_function_arn = aws_lambda_function.mediacms-upload-control[0].arn
        events              = ["s3:ObjectCreated:CompleteMultipartUpload"]
        # filter_prefix       = "original/"
        filter_suffix       = ".mp4"
    }

    lambda_function {
        lambda_function_arn = aws_lambda_function.mediacms-upload-control[0].arn
        events              = ["s3:ObjectCreated:CompleteMultipartUpload"]
        # filter_prefix       = "original/"
        filter_suffix       = ".mov"
    }

    lambda_function {
        lambda_function_arn = aws_lambda_function.mediacms-upload-control[0].arn
        events              = ["s3:ObjectCreated:CompleteMultipartUpload"]
        # filter_prefix       = "original/"
        filter_suffix       = ".avi"
    }

    lambda_function {
        lambda_function_arn = aws_lambda_function.mediacms-upload-control[0].arn
        events              = ["s3:ObjectCreated:CompleteMultipartUpload"]
        # filter_prefix       = "original/"
        filter_suffix       = ".m4v"
    }
  
    depends_on = [aws_lambda_permission.allow_bucket[0]]
}

resource "aws_lambda_permission" "allow_bucket" {
    count = var.use-upload-instance == 1 ? 1 : 0
    statement_id  = "AllowExecutionFromS3Bucket"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.mediacms-upload-control[0].arn
    principal     = "s3.amazonaws.com"
    source_arn    = aws_s3_bucket.projeto-static.arn
}