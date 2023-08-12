[<img src="https://em-content.zobj.net/thumbs/120/openmoji/338/flag-united-states_1f1fa-1f1f8.png" alt="us flag" width="48"/>](./README_en.md)

# Usando umaa AMI para o MediaCMS

Como todo o processo de preparação da aplicação após subir com o user data pode demorar alguns minutos, é recomendado que se crie uma AMI a partir de uma instância sendo executada plenamente.

Essa AMI poderá ser especificada no arquivo **terraform.tfvars** para ser utilizada lugar da instância padrão do Ubuntu. Dessa forma a aplicação vai ficar disponível muito mais rápido para as instâncias seguintes que forem criadas pelo AutoScaling.

Após criar a AMI faça as seguintes alterações no arquivo **terraform.tfvars**.

- Espeficique o um novo arquivo a seguir para o user data. Ele é apenas um placeholder e não vai afetar a instância.

    ``arquivo-user-data="./usando_ami/placeholder_user_data.sh"``

- Especifique a nova AMI para ser utilizada. 

    ``ec2-ami="ami-12334545656790"``

- Bloquei a criação de instâncias em redes públicas, pois não será necessário acesso externo. Os VPC Endpoints estão interligando os serviços da AWS com a rede privada.

    ``ec2-usar-ip-publico=false``

Após aplicar estas alterações uma nova instância de upload será criada com base na AMI e o LaunchTemplate será atualizado. Instâncias do AutoScaling precisam ser finalizadas para que novas sejam criadas a partir da AMI, se assim desejar.