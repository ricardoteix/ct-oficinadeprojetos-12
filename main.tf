# Configurações inicias do projeto com AWS

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.regiao
  profile =  var.profile # Não usar credenciais em repositórios GIT. Configurar o profile para o AWS CLI com do profile
}

# Obtém o ID da AWS com
# data.aws_caller_identity.current.account_id
data "aws_caller_identity" "current" {
}