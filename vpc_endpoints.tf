
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
  subnet_ids          = [aws_subnet.sn-projeto-private-2.id]  # Select the appropriate private subnet

  tags = {
    Name = "${var.tag-base}-ses-endpoint"
  }
}
