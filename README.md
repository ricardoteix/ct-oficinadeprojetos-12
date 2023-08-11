[<img src="https://em-content.zobj.net/thumbs/120/openmoji/338/flag-united-states_1f1fa-1f1f8.png" alt="us flag" width="48"/>](./README_en.md)

# Introdução

Este projeto permite criar a infraestrutura na AWS para execução do [MediaCMS](https://github.com/mediacms-io/mediacms), que consiste em um gerenciador de mídia opensource. 

A proposta é criar todos os recursos necessários, como VPC, Subnet, Route Tables, EC2, RDS, S3 etc, para rodar um projeto em uma instância Ubuntu 20.04 LTS. 

A maior parte do projeto está escrito em Terraform com alguns scripts shell.

É possível deverminar a configuração de alguns recursos a partir do arquivo **terraform.tfvars**. Neste repositório o arquivo [terraform.tfvars.exemplo](./terraform.tfvars.exemplo) uma base para criação do **terraform.tfvars**.

# Arquitetura

Abaixo temos o diagrama principal da arquitetura e um segundo diagrama com uma proposta de automação de uma instância para encoding dos vídeos.

## Diagrama Principal
![Diagrama Principal](./arquitetura/Diagrama%20Principal.png)

## Diagrama Automação
![Diagrama Automação](./arquitetura/Diagrama%20Automacao.png)

# Terraform

Terraform é tecnologia para uso de infraestrutura como código (IaaC), assim como Cloudformation da AWS. 

Porém com Terraform é possível definir infraestrutura para outras clouds como GCP e Azure.

## Instalação

Para utilizar é preciso baixar o arquivo do binário compilado para o sistema que você usa. Acesse https://www.terraform.io/downloads

## Iniciaizando o repositório

É preciso inicializar o Terraform na raiz deste projeto executando 

```
terraform init
```

## Definindo credenciais

O arquivo de definição do Terraform é o *main.tf*.

É nele que especificamos como nossa infraestrutura será.

É importante observar que no bloco do ``provider "aws"`` é onde definimos que vamos usar Terraform com AWS. 

```
provider "aws" {
  region = "us-east-1"
  profile = "oficina-de-projetos"
}
```

Como Terraform cria toda a infra automaticamente na AWS, é preciso dar permissão para isso por meio de credenciais.

Apenar se ser possível especificar as chaves no próprio provider, esta abordagem não é indicada. Principalmente por este código estar em um repositório git, pois que tiver acesso ao repositório saberá qual são as credenciais.

Uma opção melhor é usar um *profile* da AWS configurado localmente. 

Aqui usamos o profile chamado *projeto*. Para criar um profile execute o comando abaixo usando o AWS CLI e preencha os parâmetros solicitados.

```
aws configure --profile projeto
```

## Variáveis - Configurações adicionais 

Além da configuração do profile será preciso definir algumas variáveis.

Para evitar expor dados sensíveis no git, como senha do banco de dados, será preciso copiar o arquivo ``terraform.tfvars.exemplo`` para ``terraform.tfvars``.

No arquivo ``terraform.tfvars`` redefina os valores das variáveis. Perceba que será necessário ter um domínio já no Route53 caso deseje usar um domínio e não apenas acessar via url do LoadBalancer.

Todas as variáveis possíveis para este arquivo podem ser vistas no arquivo ``variables.tf``. Apenas algumas delas foram utilizadas no exemplo.

## Aplicando a infra definida

O Terraform provê alguns comandos básicos para planejar, aplicar e destroir a infraestrutura. 

Ao começar a aplicar a infraestrutura, o Terraform cria o arquivo ``terraform.tfstate``, que deve ser preservado e não deve ser alterado manualmente.

Por meio deste arquivo o Terraform sabe o estado atual da infraestrutura e é capar de adicionar, alterar ou remover recursos.

Neste repositório não estamos versionando este arquivo por se tratar de um repositório compartilhado e para estudo. Em um repositório real possívelmente você vai querer manter este arquivo preservado no git.

###  Verificando o que será criado, removido ou alterado
```
terraform plan
```

###  Aplicando a infraestrutura definida
```
terraform apply
```
ou, para confirmar automáticamente.
```
terraform apply --auto-approve
```

###  Destruindo toda sua infraestrutura

<font color="red">
  <span><b>CUIDADO!</b><br>
  Após a execução dos comandos abaixo você perderá tudo que foi especificado no seu arquivo Terraform (banco de dados, EC2, EBS etc).</span>.
</font>

```
terraform destroy
```
ou, para confirmar automáticamente.
```
terraform destroy --auto-approve
```

## O arquivo terraform.tfvars



## Considerações sobre a criação da infraestrutura

1. Após executar o ``terraform apply``, é apresentado no terminal quantos recursos forma adicionados, alterados ou destruídos na sua infra.

1. Como o [SES](https://docs.aws.amazon.com/pt_br/ses/latest/dg/request-production-access.html) é limitado à certos limites, para receber e enviar emails da plataforma você precisa validar o endereço de email que especificou. Pouco depois de executar o  ``terraform apply`` você deve receber no email especificado no **terraform.tfvars** 2 emails para confirmação e subscrição.

1. No nosso código adicionamos mais algumas informações de saída (outputs) necessárias para acessarmos os recursos criados, como o banco de dados. Observe abaixo.

1. O acesso à aplicação será pelo endereço apresentado no ``elb-dns`` ou pelo domínio, caso especificado e configurado para tal.

1. Algumas configurações, como host do banco de dados, smtp e nome do bucket, serão salvas em um [System Manager Parameter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html) chamado **mediacms**.

1. Para logar inicialmente use o login **admin** e a senha **adm2023cms**.

1. Ao destruir a infra, além dos dados na EC2, RDS e Elasticache, todos os arquivos do bucket serão perdidos.

---

# Considerações finais

Este é um projeto para experimentações e estudo do Terraform. 
Mesmo proporcionando a criação dos recursos mínimos para execução do projeto na AWS, é desaconselhado o uso deste projeto para implantação de cargas de trabalho em ambiente produtivo.

Apesar de utilizar técnicas para suportar crescimento no número de acessos, não foram realizados testes em ambiente com usuários reais, apenas com simulação de teste de carga mínimo com até 200 usuários virtuais usando a ferramenta [Locust](https://locust.io/). Ver arquivos na pasta [locust-load-test](./locust-load-test/).

# Referências

1. [Media CMS](https://github.com/mediacms-io/mediacms/)
1. [Media CMS - Server Installation](https://github.com/mediacms-io/mediacms/blob/main/docs/admins_docs.md#2-server-installation)
1. [Media CMS - Configuration](https://github.com/mediacms-io/mediacms/blob/main/docs/admins_docs.md#5-configuration)
1. [S3FS](https://github.com/s3fs-fuse/s3fs-fuse)
1. [AWS Storage Gateway](https://aws.amazon.com/pt/storagegateway/)
1. [Terraform](https://www.terraform.io/)
1. [Locust](https://locust.io/)
