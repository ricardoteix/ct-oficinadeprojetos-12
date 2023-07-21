#!/bin/bash

sudo apt update
sudo apt-get install postgresql-client -y
sudo apt install s3fs -y

# Configura o s3fs
mkdir -p /home/mediacms.io/mediacms/media_files
cd /home/mediacms.io/mediacms

# Cria o arquivo com as credenciais do S3
echo '${s3_user_id}:${s3_user_secret}' > .passwd-s3fs
chmod 600 .passwd-s3fs

uid_usuario=$(grep "^www-data:" /etc/passwd | cut -d ':' -f 3)
gid_usuario=$(grep "^www-data:" /etc/passwd | cut -d ':' -f 4)
sudo s3fs ${s3_bucket_name} media_files -ouid=$uid_usuario,gid=$gid_usuario,allow_other,mp_umask=002 -o passwd_file=.passwd-s3fs

# Baixando o projeto
cd /home/mediacms.io/mediacms
sudo git init 
sudo git remote add origin https://github.com/mediacms-io/mediacms
sudo git pull origin main 

# Define o endereço das mídias
sudo sed -i 's#MEDIA_URL = "/media/"#MEDIA_URL = "https://${cloudfront_domain_name}/"#g' /home/mediacms.io/mediacms/cms/settings.py

# Define os dados do EMAIL e SES
sudo sed -i 's#EMAIL_HOST_USER = "info@mediacms.io"#EMAIL_HOST_USER = "${smtp_user}"#g' /home/mediacms.io/mediacms/cms/settings.py
sudo sed -i 's#info@mediacms.io#${sns_email}#g' /home/mediacms.io/mediacms/cms/settings.py
sudo sed -i 's#xyz#${smtp_password}#g' /home/mediacms.io/mediacms/cms/settings.py
sudo sed -i 's#EMAIL_HOST = "mediacms.io"#EMAIL_HOST = "${smtp_host}"#g' /home/mediacms.io/mediacms/cms/settings.py

# Redis
# REDIS_LOCATION = "redis://127.0.0.1:6379/1" 
sudo sed -i 's#//127.0.0.1#//${redis_endpoint}#g' /home/mediacms.io/mediacms/cms/settings.py

# Localização
sudo sed -i 's#en-us#pt-br#g' /home/mediacms.io/mediacms/cms/settings.py
sudo sed -i 's#Europe/London#America/Recife#g' /home/mediacms.io/mediacms/cms/settings.py

# Define as credenciais do banco
sudo sed -i 's#"HOST": "127.0.0.1"#"HOST": "${rds_addr}"#g' /home/mediacms.io/mediacms/cms/settings.py

# Instalação do MediacMS
echo "Welcome to the MediacMS installation!";

osVersion=$(lsb_release -d)
if [[ $osVersion == *"Ubuntu 20"* ]] || [[ $osVersion == *"Ubuntu 22"* ]] || [[ $osVersion == *"buster"* ]] || [[ $osVersion == *"bullseye"* ]]; then
    echo 'Performing system update and dependency installation, this will take a few minutes'
    apt-get update && apt-get -y upgrade && apt-get install python3-venv python3-dev virtualenv redis-server postgresql nginx git gcc vim unzip imagemagick python3-certbot-nginx certbot wget xz-utils -y
else
    echo "This script is tested for Ubuntu 20/22 versions only, if you want to try MediaCMS on another system you have to perform the manual installation"
    exit
fi

# install ffmpeg
echo "Downloading and installing ffmpeg"
wget -q https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz
mkdir -p tmp
tar -xf ffmpeg-release-amd64-static.tar.xz --strip-components 1 -C tmp
cp -v tmp/{ffmpeg,ffprobe,qt-faststart} /usr/local/bin
rm -rf tmp ffmpeg-release-amd64-static.tar.xz
echo "ffmpeg installed to /usr/local/bin"

PORTAL_NAME="Oficina de Projetos 12"
FRONTEND_HOST="${full_domain}"

echo 'Creating database to be used in MediaCMS'

su -c "psql -c \"CREATE DATABASE mediacms\"" postgres
su -c "psql -c \"CREATE USER mediacms WITH ENCRYPTED PASSWORD 'mediacms'\"" postgres
su -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE mediacms TO mediacms\"" postgres

echo 'Creating python virtualenv on /home/mediacms.io'

cd /home/mediacms.io
virtualenv . --python=python3
source  /home/mediacms.io/bin/activate
cd mediacms
pip install -r requirements.txt

SECRET_KEY=`python -c 'from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())'`

sed -i s/localhost/$FRONTEND_HOST/g deploy/local_install/mediacms.io

FRONTEND_HOST_HTTP_PREFIX='http://'$FRONTEND_HOST


echo 'FRONTEND_HOST='\'"$FRONTEND_HOST_HTTP_PREFIX"\' >> cms/local_settings.py
echo 'PORTAL_NAME='\'"$PORTAL_NAME"\' >> cms/local_settings.py
echo "SSL_FRONTEND_HOST = FRONTEND_HOST.replace('http', 'https')" >> cms/local_settings.py

echo 'SECRET_KEY='\'"$SECRET_KEY"\' >> cms/local_settings.py
echo "LOCAL_INSTALL = True" >> cms/local_settings.py

mkdir logs
mkdir pids
python manage.py migrate
python manage.py loaddata fixtures/encoding_profiles.json
python manage.py loaddata fixtures/categories.json
python manage.py collectstatic --noinput

ADMIN_PASS=`python -c "import secrets;chars = 'abcdefghijklmnopqrstuvwxyz0123456789';print(''.join(secrets.choice(chars) for i in range(10)))"`
echo "from users.models import User; User.objects.create_superuser('admin', 'admin@example.com', '$ADMIN_PASS')" | python manage.py shell

echo "from django.contrib.sites.models import Site; Site.objects.update(name='$FRONTEND_HOST', domain='$FRONTEND_HOST')" | python manage.py shell

chown -R www-data. /home/mediacms.io/
cp deploy/local_install/celery_long.service /etc/systemd/system/celery_long.service && systemctl enable celery_long && systemctl start celery_long
cp deploy/local_install/celery_short.service /etc/systemd/system/celery_short.service && systemctl enable celery_short && systemctl start celery_short
cp deploy/local_install/celery_beat.service /etc/systemd/system/celery_beat.service && systemctl enable celery_beat &&systemctl start celery_beat
cp deploy/local_install/mediacms.service /etc/systemd/system/mediacms.service && systemctl enable mediacms.service && systemctl start mediacms.service

mkdir -p /etc/letsencrypt/live/mediacms.io/
mkdir -p /etc/letsencrypt/live/$FRONTEND_HOST
mkdir -p /etc/nginx/sites-enabled
mkdir -p /etc/nginx/sites-available
mkdir -p /etc/nginx/dhparams/
rm -rf /etc/nginx/conf.d/default.conf
rm -rf /etc/nginx/sites-enabled/default
cp deploy/local_install/mediacms.io_fullchain.pem /etc/letsencrypt/live/$FRONTEND_HOST/fullchain.pem
cp deploy/local_install/mediacms.io_privkey.pem /etc/letsencrypt/live/$FRONTEND_HOST/privkey.pem
cp deploy/local_install/dhparams.pem /etc/nginx/dhparams/dhparams.pem
cp deploy/local_install/mediacms.io /etc/nginx/sites-available/mediacms.io
ln -s /etc/nginx/sites-available/mediacms.io /etc/nginx/sites-enabled/mediacms.io
cp deploy/local_install/uwsgi_params /etc/nginx/sites-enabled/uwsgi_params
cp deploy/local_install/nginx.conf /etc/nginx/
systemctl stop nginx
systemctl start nginx

# Bento4 utility installation, for HLS

cd /home/mediacms.io/mediacms
wget http://zebulon.bok.net/Bento4/binaries/Bento4-SDK-1-6-0-637.x86_64-unknown-linux.zip
unzip Bento4-SDK-1-6-0-637.x86_64-unknown-linux.zip
mkdir /home/mediacms.io/mediacms/media_files/hls

# last, set default owner
chown -R www-data. /home/mediacms.io/

echo 'MediaCMS installation completed, open browser on http://'"$FRONTEND_HOST"' and login with user admin and password '"$ADMIN_PASS"''

echo 'O login do administrador é admin e a senha é '"$ADMIN_PASS"'' > /home/mediacms.io/mediacms/admin.txt

echo '##### INSTALANDO O AWS CLI #####'

cd /home/ubuntu
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

echo '############### Publicando SNS ################'

echo Publicando SNS
topic_arn="${sns_topic_arn}"
aws sns publish --topic-arn $topic_arn --message "Implantação do Projeto finalizada. Senha admin: $ADMIN_PASS"

echo "################# FIM ###################"