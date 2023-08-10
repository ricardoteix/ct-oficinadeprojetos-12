#!/bin/bash

##############################################
# Defina os valores para as variaveis abaixo #
##############################################

# OBS: A senha do usuario admin e adm2023cms
echo "##############################"
echo "# Senha do admin: adm2023cms #"
echo "##############################"

# Criar credendiais com permissao para leitura e escrita bo bucket
# parameter_name="mediacms"
# json_value=$(aws ssm get-parameter --name "$parameter_name" --query 'Parameter.Value' --output text)

parameter_name="mediacms"
max_attempts=15  # Número máximo de tentativas

for ((attempt=1; attempt<=$max_attempts; attempt++)); do
    json_value=$(aws ssm get-parameter --name "$parameter_name" --query 'Parameter.Value' --output text)
    
    if [ -n "$json_value" ]; then
        echo "##########################################################"
        echo ">>> Valor obtido na tentativa $attempt: $json_value"
        echo "##########################################################"
        break  # Sai do loop se um valor válido for obtido
    else
        echo "##########################################################"
        echo "# Tentativa $attempt: Valor vazio, tentando novamente... # "
        echo "##########################################################"
        sleep 5  # Pausa entre tentativas, se desejar
    fi
done

if [ -z "$json_value" ]; then
    echo "#########################################################################"
    echo "# Não foi possível obter um valor válido após $max_attempts tentativas. #"
    echo "#########################################################################"
fi

s3_user_id=$(echo "$json_value" | jq -r '.s3_user_id')
s3_user_secret=$(echo "$json_value" | jq -r '.s3_user_secret')
s3_bucket_name=$(echo "$json_value" | jq -r '.s3_bucket_name')
rds_addr=$(echo "$json_value" | jq -r '.rds_addr')
FRONTEND_HOST=$(echo "$json_value" | jq -r '.full_domain')

##############################
# Nao mexer daqui para baixo #
##############################

# Removendo valores existentes
sudo su -c "sed -i '/^s3_user_id=/d' /etc/environment"
sudo su -c "sed -i '/^s3_user_secret=/d' /etc/environment"
sudo su -c "sed -i '/^s3_bucket_name=/d' /etc/environment"

# Defição das variáveis de ambiente
sudo su -c "echo s3_user_id=$s3_user_id >> /etc/environment"
sudo su -c "echo s3_user_secret=$s3_user_secret >> /etc/environment"
sudo su -c "echo s3_bucket_name=$s3_bucket_name >> /etc/environment"
sudo su -c "source /etc/environment"
source /etc/environment

# Define o arquivo padrao das credenciais do s3fs
# Usando para montar ao inicializar a maquina
sudo su -c "echo $s3_user_id:$s3_user_secret > /etc/passwd-s3fs"
sudo su -c "chmod 400 /etc/passwd-s3fs"

# Buscar o id do usuario e id do grupo
uid_usuario=$(grep "^www-data:" /etc/passwd | cut -d ':' -f 3)
gid_usuario=$(grep "^www-data:" /etc/passwd | cut -d ':' -f 4)

# Registra no fstab o código para montar o s3fs ao inicializar
sudo su -c "sed -i '/^ct-projeto12/d' /etc/fstab"
sudo su -c "echo $s3_bucket_name /home/mediacms.io/mediacms/media_files fuse.s3fs _netdev,uid=$uid_usuario,gid=$gid_usuario,allow_other,mp_umask=002  0 0 >> /etc/fstab"
# sudo su -c "mount -a"

systemctl stop nginx mediacms celery_long celery_short

# Desmonta
sudo su -c "umount media_files"
cd /home/mediacms.io/mediacms/
sudo s3fs $s3_bucket_name media_files -ouid=$uid_usuario,gid=$gid_usuario,allow_other,mp_umask=002 -o nonempty
# sudo mv ./userlogos/ ./media_files/userlogos/

# Caminho do arquivo que indica que uma implantacao ja foi realizada
file=/home/mediacms.io/mediacms/media_files/started.info

if [ -f "$file" ]
then

    echo "##############################"
    echo "# Banco de dados incializado #"
    echo "##############################"

else

    sudo su -c "echo started > /home/mediacms.io/mediacms/media_files/started.info"

    # Limpando o Banco
    export PGHOST=$rds_addr
    export PGPORT=5432
    export PGDATABASE=postgres
    export PGUSER=mediacms
    export PGPASSWORD=mediacms

    psql -c "DROP DATABASE IF EXISTS mediacms"
    psql -c "CREATE DATABASE mediacms"
    psql -c "GRANT ALL PRIVILEGES ON DATABASE mediacms TO mediacms"

    # sudo chmod 755 media_files/.env
    sudo su

    # Atualizando Banco de Dados
    cd /home/mediacms.io
    source /home/mediacms.io/bin/activate
    cd mediacms

    python manage.py migrate
    python manage.py loaddata fixtures/encoding_profiles.json
    python manage.py loaddata fixtures/categories.json
    python manage.py collectstatic --noinput

    ADMIN_PASS=adm2023cms
    echo "from users.models import User; User.objects.create_superuser('admin', 'admin@example.com', '$ADMIN_PASS')" | python manage.py shell
    echo "from django.contrib.sites.models import Site; Site.objects.update(name='$FRONTEND_HOST', domain='$FRONTEND_HOST')" | python manage.py shell

fi

# Tema
sudo sed -i 's#"light"#"dark"#g' /home/mediacms.io/mediacms/cms/settings.py

# Titulo com id da instancis
instance_id=`curl http://169.254.169.254/latest/meta-data/instance-id`
PORTAL_NAME="$instance_id - Oficina de Projetos 12"
echo 'PORTAL_NAME='\'"$PORTAL_NAME"\' >> /home/mediacms.io/mediacms/cms/local_settings.py

systemctl start nginx mediacms celery_long celery_short

# Desabilita celery_long para evitar processamento de video
upload=`curl http://169.254.169.254/latest/meta-data/tags/instance | grep -c "ProcessUpload"`
if [[ $upload -eq 0 ]];
then
    systemctl stop celery_long
else

    sudo su -c echo "##################################################################' >> /var/log/syslog"
    sudo su -c echo "#### Criando serviço para desligar a instância quando inativa ####' >> /var/log/syslog"
    sudo su -c echo "##################################################################' >> /var/log/syslog"

    cd /home/mediacms.io/mediacms/

    sudo su -c "echo ${upload_cpu_check_script} | base64 --decode > /home/mediacms.io/mediacms/cpu_check.sh"
    sudo chmod +x /home/mediacms.io/mediacms/cpu_check.sh

    # sudo echo "${upload_cpu_check_script}" > /home/mediacms.io/mediacms/cpu_check.sh
    # sudo chmod +x /home/mediacms.io/cpu_check.sh

    sudo su -c "echo ${upload_cpu_check_service} | base64 --decode > /home/mediacms.io/mediacms/cpu_check.service"
    # sudo echo "${upload_cpu_check_service}" > /home/mediacms.io/mediacms/cpu_check.service

    sudo su -c "mv /home/mediacms.io/mediacms/cpu_check.service /etc/systemd/system/"
    
    systemctl daemon-reload
    systemctl start cpu_check.service
    systemctl enable cpu_check.service

    echo "######################"
    echo "# Fim da Implantacao #"
    echo "######################"
fi
