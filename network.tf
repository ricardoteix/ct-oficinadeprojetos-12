
# Criando a VPC
resource "aws_vpc" "vpc-projeto" {
    cidr_block = "10.0.0.0/16"  
		enable_dns_hostnames = true # DNS hostnames
 		enable_dns_support = true # DNS resolution
    tags = {
        Name = "vpc-${var.tag-base}"
    }
}

# Criando o Internert Gateway
resource "aws_internet_gateway" "igw-projeto" {
  vpc_id = aws_vpc.vpc-projeto.id
  tags = {
    Name = "igw-${var.tag-base}"
  }
}

# Criando a Route Table pública
resource "aws_route_table" "rt-projeto-public" {
  vpc_id = aws_vpc.vpc-projeto.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-projeto.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_internet_gateway.igw-projeto.id
  }

  tags = {
    Name = "rt-${var.tag-base}-public"
  }
}

# Criando a Route Table privada
resource "aws_route_table" "rt-projeto-private" {
  vpc_id = aws_vpc.vpc-projeto.id
  route = []
  tags = {
    Name = "rt-${var.tag-base}-private"
  }
}

# Criando Subnets Públicas
resource "aws_subnet" "sn-projeto-public-1" {
  vpc_id = aws_vpc.vpc-projeto.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "${var.regiao}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "sn-${var.tag-base}-public-1"
  }
}

resource "aws_subnet" "sn-projeto-public-2" {
  vpc_id = aws_vpc.vpc-projeto.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "${var.regiao}b"
  map_public_ip_on_launch = true
  tags = {
    Name = "sn-${var.tag-base}-public-2"
  }
}

resource "aws_subnet" "sn-projeto-public-3" {
  vpc_id = aws_vpc.vpc-projeto.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "${var.regiao}c"
  map_public_ip_on_launch = true
  tags = {
    Name = "sn-${var.tag-base}-public-3"
  }
}

# Criando Subnets Privadas
resource "aws_subnet" "sn-projeto-private-1" {
  vpc_id = aws_vpc.vpc-projeto.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "${var.regiao}a"
  tags = {
    Name = "sn-${var.tag-base}-private-1"
  }
}

resource "aws_subnet" "sn-projeto-private-2" {
  vpc_id = aws_vpc.vpc-projeto.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "${var.regiao}b"
  tags = {
    Name = "sn-${var.tag-base}-private-2"
  }
}

resource "aws_subnet" "sn-projeto-private-3" {
  vpc_id = aws_vpc.vpc-projeto.id
  cidr_block = "10.0.5.0/24"
  availability_zone = "${var.regiao}c"
  tags = {
    Name = "sn-${var.tag-base}-private-3"
  }
}

# Criando a relação entre Subnet e Route Table
resource "aws_route_table_association" "rt-projeto-assoc-pb-1" {
  subnet_id      = aws_subnet.sn-projeto-public-1.id
  route_table_id = aws_route_table.rt-projeto-public.id
}

resource "aws_route_table_association" "rt-projeto-assoc-pb-2" {
  subnet_id      = aws_subnet.sn-projeto-public-2.id
  route_table_id = aws_route_table.rt-projeto-public.id
}

resource "aws_route_table_association" "rt-projeto-assoc-pb-3" {
  subnet_id      = aws_subnet.sn-projeto-public-3.id
  route_table_id = aws_route_table.rt-projeto-public.id
}

resource "aws_route_table_association" "rt-projeto-assoc-pv-1" {
  subnet_id      = aws_subnet.sn-projeto-private-1.id
  route_table_id = aws_route_table.rt-projeto-private.id
}

resource "aws_route_table_association" "rt-projeto-assoc-pv-2" {
  subnet_id      = aws_subnet.sn-projeto-private-2.id
  route_table_id = aws_route_table.rt-projeto-private.id
}

resource "aws_route_table_association" "rt-projeto-assoc-pv-3" {
  subnet_id      = aws_subnet.sn-projeto-private-3.id
  route_table_id = aws_route_table.rt-projeto-private.id
}

# Definindo Main Route
resource "aws_main_route_table_association" "rt-projeto-assoc-main" {
  vpc_id         = aws_vpc.vpc-projeto.id
  route_table_id = aws_route_table.rt-projeto-private.id
}

# Network ACL criado automático com tudo Allow para todas as subnets

# Criando Network Interface
resource "aws_network_interface" "nic-projeto-instance" {
  subnet_id       = var.ec2-usar-ip-publico ? aws_subnet.sn-projeto-public-1.id : aws_subnet.sn-projeto-private-1.id
  private_ips     = var.ec2-usar-ip-publico ? ["10.0.0.51"] : ["10.0.3.51"]
  security_groups = [aws_security_group.sg_projeto_web.id]

  # Pode relacionar a instância na criação do nic, mas pode ser feito depois na instância
  # attachment {
  #   instance     = aws_instance.test.id
  #   device_index = 1
  # }
}