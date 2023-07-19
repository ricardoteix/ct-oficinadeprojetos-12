 
 # Criando variáveis no arquivo projeto_user_data.sh
 data "template_file" "projeto-user-data-script" {
  template = file(var.arquivo-user-data)
  vars = {
    efs_id = aws_efs_file_system.projeto-efs.id
    region = "${var.regiao}",
    sns_topic_arn = aws_sns_topic.projeto-events.arn,
    rds_addr = aws_db_instance.projeto-rds.address,
    full_domain = var.has-domain ? "${var.domain}.${var.hosted_zone_name}" : "localhost"
  }
}

# Criando uma instância EC2
resource "aws_instance" "projeto" {
  ami = var.ec2-ami
  instance_type = "${var.ec2-tipo-instancia}"
  availability_zone = "${var.regiao}a"
  key_name = "${var.ec2-chave-instancia}"

  iam_instance_profile = aws_iam_instance_profile.projeto-profile.name

  network_interface {
    device_index = 0 # ordem da interface 
    network_interface_id = aws_network_interface.nic-projeto-instance.id
  }

  # EBS root
  root_block_device {
    volume_size = var.ec2-tamanho-ebs
    volume_type = "gp2"
  }

  # Script para execução na primeira inicialização.
  # Usado para instalar o projeto
  # user_data = file("projeto_user_data.sh")

  # Usando renderização do arquivo pelo template_file
  user_data = data.template_file.projeto-user-data-script.rendered  

  tags = {
      Name = "${var.tag-base}"
  }
}

resource "aws_lb" "projeto-elb" {
  name               = "projeto-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_projeto_elb.id]
  subnets            = [
    aws_subnet.sn-projeto-public-1.id, 
    aws_subnet.sn-projeto-public-2.id, 
    aws_subnet.sn-projeto-public-3.id
  ]

  enable_deletion_protection = false

  tags = {
    Name = "elb-${var.tag-base}"
  }
}

resource "aws_lb_target_group" "tg-projeto" {
  # for_each  = [aws_lb.projeto-elb.name]
  name     = "tg-projeto"
  target_type   = "instance"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc-projeto.id
  health_check {
      healthy_threshold   = var.health_check["healthy_threshold"]
      interval            = var.health_check["interval"]
      unhealthy_threshold = var.health_check["unhealthy_threshold"]
      timeout             = var.health_check["timeout"]
      path                = var.health_check["path"]
      port                = var.health_check["port"]
  }
}

# Attach the target group for "test" ALB
resource "aws_lb_target_group_attachment" "tg_attachment_projeto-elb" {
    target_group_arn = aws_lb_target_group.tg-projeto.arn
    target_id        = aws_instance.projeto.id
    port             = 80
}

# Listener rule for HTTP traffic on each of the ALBs
resource "aws_lb_listener" "lb_listener_http" {
  load_balancer_arn    = aws_lb.projeto-elb.arn
  port                 = "80"
  protocol             = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.tg-projeto.arn
    type             = "forward"
  }
}

# Listener rule for HTTPs traffic on "test" ALB
resource "aws_lb_listener" "lb_listner_https" {
  # for_each  = [aws_lb.projeto-elb.name]
  count = var.has-domain ? 1 : 0
  load_balancer_arn = aws_lb.projeto-elb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.has-domain ? data.aws_acm_certificate.issued[0].arn : ""  # Testar 
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg-projeto.arn
  }
}

# resource "aws_ec2_instance_connect_endpoint" "conn" {
#   subnet_id = aws_subnet.sn-projeto-private-1.id
#   security_group_ids = [
#     aws_security_group.sg_projeto_web.id
#   ]
# }