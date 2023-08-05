
resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id              = aws_vpc.vpc-projeto.id
  service_name        = "com.amazonaws.${var.regiao}.s3"
  vpc_endpoint_type   = "Gateway"

  route_table_ids = [aws_route_table.rt-projeto-private.id]

  tags = {
    Name = "${var.tag-base}-s3-endpoint"
  }
}

resource "aws_vpc_endpoint" "ses_endpoint" {
  vpc_id              = aws_vpc.vpc-projeto.id
  service_name        = "com.amazonaws.${var.regiao}.email-smtp"
  vpc_endpoint_type   = "Interface"

  private_dns_enabled = true
  security_group_ids  = [aws_security_group.sg_projeto_ses.id]
  subnet_ids          = [
    # aws_subnet.sn-projeto-private-1.id, # Não suportada
    aws_subnet.sn-projeto-private-2.id,
    aws_subnet.sn-projeto-private-3.id,
  ]  # Select the appropriate private subnet

  tags = {
    Name = "${var.tag-base}-ses-endpoint"
  }
}

resource "aws_vpc_endpoint" "endpoint_elasticache" {
  vpc_id              = aws_vpc.vpc-projeto.id
  service_name        = "com.amazonaws.${var.regiao}.elasticache"
  vpc_endpoint_type   = "Interface"

  private_dns_enabled = true
  security_group_ids  = [aws_security_group.sg_projeto_cache.id]
  subnet_ids          = [
    aws_subnet.sn-projeto-private-1.id,
    aws_subnet.sn-projeto-private-2.id,
    aws_subnet.sn-projeto-private-3.id,
  ]

  tags = {
    Name = "${var.tag-base}-elasticache-endpoint"
  }
}

resource "aws_vpc_endpoint" "endpoint_ssm" {
  vpc_id              = aws_vpc.vpc-projeto.id
  service_name        = "com.amazonaws.${var.regiao}.ssm"
  vpc_endpoint_type   = "Interface"

  private_dns_enabled = true
  security_group_ids  = [aws_security_group.sg_projeto_web.id]
  subnet_ids          = [
    aws_subnet.sn-projeto-private-1.id,
    aws_subnet.sn-projeto-private-2.id,
    aws_subnet.sn-projeto-private-3.id,
  ]

  tags = {
    Name = "${var.tag-base}-ssm-endpoint"
  }
}

resource "aws_ec2_instance_connect_endpoint" "ec2_conn" {
  subnet_id = aws_subnet.sn-projeto-private-1.id

  tags = {
    Name = "${var.tag-base}-ec2-conn-endpoint"
  }
}