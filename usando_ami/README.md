# Usando a AMI do MediaCMS para a Oficina de Projetos 12

Para subir o Media CMS publicamos uma AMI com diversas pré-configurações.

No [AMI Catalog](https://us-east-1.console.aws.amazon.com/ec2/v2/home?region=us-east-1#AMICatalog:) se você procurar por "projeto12" você de encontrar a AMI 

```
ct-projeto12-mediacms-v3
ami-0f5458d90eb72ccdc
```

Use essa AMI para subir a instância EC2 no devido passo da lista a seguir.

- Criar o usuário no IAM com permissão **S3FullAccess**
- Criar credencial para este usuário e informar nas variáveis ``s3_user_id`` e ``s3_user_secret``.
- Criar o bucket informado no ``s3_bucket_name``
    - Crie uma pasta chamada **hls** no bucket
    - Crie uma pasta chamada **userlogos** no bucket
    - Envie as imagens **banner.jpg** e **user.jpg** para a pasta **userlogos**. As imagens estão na pasta ``usando_ami/subir_para_bucket`` deste repositório.
- Criar CloudFront:
    - *Origin domain origem* sendo o ``s3_bucket_name``
    - *Origin access* como *Legacy access identities*
    - *Origin access identity* : Criar OAI
    - *Bucket policy* : *Yes, update the bucket policy*
    - *Cache key and origin requests* marcar **SimpleCORS**
    - Price class : Use only North America and Europe
- Criar no SES as credenciais SMTP e especificar em ``smtp_user`` e ``smtp_password``.
    - ``smtp_host`` para us-east-1 deve ser **email-smtp.us-east-1.amazonaws.com**
- Criar RDS PostgresSQL. Testado com a versão 15.2 e t3.micro
    - *Username* : ``mediacms``
    - *Password* : ``mediacms``
    - Em *Additional configuration* usar *Initial database name* : **mediacms**
- Criar ElastiCache Redis.
    - Não habilite o modo Cluster (a aplicação mostra um erro).
    - Após a criação do *Node* um Endpoint ficará disponível com o formato similar a este: ``redis-projeto12-ami-nocluster-001.dpe5c4.0001.use1.cache.amazonaws.com``. Não especifique a porta, na variável redis_endpoint, apenas até o .com.
- Criar Application Load Balancer e TargetGroup
- Criar Domínio/Subdomínio no Route53 apontando para o Load Balancer
- Criar um Parameter Store no SSM chamado **mediacms**, com todas as variáveis definidas com base no que foi criado, em um json como código abaixo. Você pode usar o site [jsonlint.com](jsonlint.com) para validar seu json antes de salvar no Parameter Store. 
```json
{
  "cloudfront_domain_name":  "Endereço da distribuição CloudFront",
  "full_domain":  "Domínio da aplicação. Se não tiver use o DNS do Load Balancer ou IP do EC2",
  "rds_addr":  "Endereço do RDS",
  "redis_endpoint":  "Endpoint do Redis",
  "region":  "us-east-1",
  "s3_bucket_name":  "Nome do bucket",
  "s3_user_id":  "KEY ID",
  "s3_user_secret":  "SECRET KEY",
  "smtp_host":  "Host do SMTP",
  "smtp_password":  "Senha do SMTL",
  "smtp_user":  "Usuário do SMTL",
  "sns_email":  "Email do admin",
  "sns_topic_arn": "ARN do tópico SNS caso necessario"
}
```
- Criar o EC2 com base na AMI **ct-projeto12-mediacms-v3 (ami-085937d2247364b89)** e usar o modelo do arquivo ``image_user_data.sh`` com as devidas variáveis ataulizadas para o Advanced details : User data.
    - Precisa ser no mínimo t3a.small
    - Variáveis para atualizar no arquivo: 
        - ``s3_user_id``
        - ``s3_user_secret``
        - ``s3_bucket_name``
        - ``rds_addr``