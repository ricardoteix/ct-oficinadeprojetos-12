# Arquivo com a definição das variáveis. O arquivo poderia ter qualquer outro nome, ex. valores.tf

variable "regiao" {
  description = "Região da AWS para provisionamento"
  type        = string
  default     = "us-east-1"
}

variable "profile" {
  description = "Profile com as credenciais criadas no IAM"
  type = string
  default = "ricardoteixcloud"
}

variable "tag-base" {
  description = "Nome utilizado para nomenclaruras no projeto"
  type        = string
  default     = "projeto"
}

# EC2

variable "certificate-domain" {
  description = "Domínio do certificado no Certificate Manager"
  type        = string
  # Espefique o valor desta variáel no arquivoterraform.tfvars
}

variable "ec2-ami" {
  description = "AMI base"
  type        = string
  default     = "ami-0c4f7023847b90238" # Canonical, Ubuntu, 20.04 LTS
}

variable "ec2-usar-ip-publico" {
  description = "Definine se a instância ficará em subnet pública ou não"
  type        = bool
  default     = true
}


variable "ec2-tipo-instancia" {
  description = "Tipo da instância do EC2"
  type        = string
  default     = "t2.micro" # 2 vCPU, 1 GB
}

variable "ec2-chave-instancia" {
  description = "Nome da chave para acesso SSH"
  type        = string
  default     = "chave_especializacao"
}

variable "ec2-tamanho-ebs" {
  description = "Tamanho do disco"
  type        = number
  default     = 8
}

variable "autoscaling-min" {
  description = "Quantidade mínima de instâncias"
  type        = number
  default     = 1
}

variable "autoscaling-max" {
  description = "Quantidade máxima de instâncias"
  type        = number
  default     = 1
}

variable "autoscaling-desejado" {
  description = "Quantidade desejada de instâncias"
  type        = number
  default     = 1
}

variable "arquivo-user-data" {
  description = "Script que será executado ao subir a instância"
  type        = string
  default     = "projeto_user_data.sh"
}

variable "health_check" {
   type = map(string)
   default = {
      "timeout"  = "10"
      "interval" = "20"
      "path"     = "/"
      "port"     = "80"
      "unhealthy_threshold" = "2"
      "healthy_threshold" = "3"
      "matcher" = "200,302"
    }
}

# RDS

variable "rds-identificador" {
  description = "Tipo da instância do RDS"
  type        = string
  default     = "projeto-db"
}

variable "rds-tipo-instancia" {
  description = "Tipo da instância do RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "rds-nome-banco" {
  description = "Nome do schema criado inicialmente para usar no Projeto"
  type        = string
  default     = "projeto_db"
}

variable "rds-nome-usuario" {
  description = "Nome do usuário administrador da instância RDS"
  type        = string
  
  # default     = "nao colocar valor padrão aqui" # Não deixar padrão para versionar com git.
  # Veja o arquivo terraform.tfvars.exemplo para definir um valor fixo para esta variável.
}

variable "rds-senha-usuario" {
  description = "Senha do usuário administrador da instância RDS"
  type        = string

  # default     = "nao colocar valor padrão aqui" # Não deixar padrão para versionar com git.
  # Veja o arquivo terraform.tfvars.exemplo para definir um valor fixo para esta variável.
}

# SNS

variable "sns-email" {
  description = "Email para registrar no tópino SNS e enviar mensagens sobre a infra"
  type = string
  # default = "" # Não deixar padrão para versionar com git.
  # Veja o arquivo terraform.tfvars.exemplo para definir um valor fixo para esta variável.
}

# S3

variable "nome-bucket" {
  description = "Nome do bucket para configurar no Projeto"
  type = string
  default = "projeto-files"  # Como o bucket deve ser unico em toda a AWS, sugiro modifica este nome para evitar conflito.
}

variable "hosted_zone_name" {
  description = "Domínio da zona hospedada"
  type = string
}

variable "domain" {
  description = "Nome do domínio utilizado para a implantação"
  type = string
  default = "https://www.domain.com"
}

variable "create-domain-www" {
  description = "Indica o record www no Route53"
  type = bool
  default = false
}

variable "has-domain" {
  description = "Indica se deve criar o domínio especificado no Route53"
  type = bool
  default = false
}