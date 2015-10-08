#!/bin/bash
# 
# Script para la instalación de la plataforma de Atención Ciudadana de Carchi
# Autor: apereira@alabs.org
# Fecha: 8 de Septiembre de 2015 
#

date

URL=atencionciudadana.carchi.gob.ec
RAILS_ENV=production
#DB_NAME=atencion_prod
#DB_USER=atencion_prod

#URL=beta.atencionciudadana.carchi.gob.ec
#RAILS_ENV=staging
DB_NAME=atencion_stag
DB_USER=atencion_stag

########################################################################
DBLEG_NAME=atencion_leg
DBLEG_USER=atencion_leg
DB_PASS=$(date +%s | sha256sum | base64 | head -c 16 ; echo)
DBLEG_PASS=$(date +%s | sha256sum | base64 | head -c 16 ; echo)
DB_ROOTPASS=$(date +%s | sha256sum | base64 | head -c 16 ; echo)
IP_ADDRESS=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')

echo "**************************************************************************"
echo ""
echo "             INSTALACION ATENCION CIUDADANA CARCHI - empieza"
echo ""
echo " En un servidor limpio de Ubuntu 12.04 instalará la plataforma de"
echo " Atención Ciudadana de El Carchi. Tardará aproximadamente 15 minutos."
echo " Empieza en 10 segundos, puede cancelar con CTRL + C"
echo ""
echo "**************************************************************************"

sleep 10

set -x
set -e

VER=$(lsb_release -sr)

if [ $VER != "12.04" ]; then 
   echo "Este script debe ejecutarse en Ubuntu 12.04" 1>&2
   exit 1
fi

if [ "$(id -u)" != "0" ]; then
   echo "Este script debe ejecutarse como root" 1>&2
   exit 1
fi

cat >/etc/apt/apt-conf << EOL 
Acquire::http::Proxy "http://10.0.3.1:3142";
EOL

# install nginx + passenger 
apt-get update
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
apt-get install -y apt-transport-https ca-certificates
sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger precise main > /etc/apt/sources.list.d/passenger.list'
apt-get update
apt-get install -y nginx-extras passenger

sed -i '/passenger_root/s/#//g'  /etc/nginx/nginx.conf
sed -i '/passenger_ruby/s/#//g' /etc/nginx/nginx.conf

if [ ! -f /etc/nginx/sites-available/${URL} ] ; then 
	cat >/etc/nginx/sites-available/${URL} << EOL 
server {
	listen 80 default_server;
	listen [::]:80 default_server;
	passenger_enabled on;
	rails_env ${RAILS_ENV};
	root /var/www/${URL}/current/public;
	server_name ${URL};
}
EOL
	rm /etc/nginx/sites-enabled/default
	ln -s /etc/nginx/sites-available/${URL} /etc/nginx/sites-enabled/
	service nginx restart
fi

# Base de datos PostgreSQL
apt-get -y install language-pack-es postgresql
pg_dropcluster --stop 9.3 main
pg_createcluster --locale=es_ES.utf8 --start 9.3 main

# create database
sudo -u postgres createuser -S -D -R ${DB_USER}
sudo -u postgres psql -c "ALTER USER ${DB_USER} PASSWORD '${DB_PASS}';"
sudo -u postgres createdb -O ${DB_USER} ${DB_NAME} # -E utf-8

sudo -u postgres createuser -S -D -R ${DBLEG_USER}
sudo -u postgres psql -c "ALTER USER ${DBLEG_USER} PASSWORD '${DBLEG_PASS}';"
sudo -u postgres createdb -O ${DBLEG_USER} ${DBLEG_NAME} # -E utf-8

sed -i '/local.*all.*all.*peer/c\local\tall\t\tall\t\t\t\t\tmd5'  /etc/postgresql/9.3/main/pg_hba.conf
service postgresql reload

# install postfix (SMTP)
echo postfix postfix/main_mailer_type select Internet Site | debconf-set-selections
echo postfix postfix/mailname string localhost | debconf-set-selections
apt-get install -y postfix

# install dependencias varias de RVM/rails
apt-get install -y libpq-dev curl build-essential git

if [ ! -f /etc/sudoers.d/capistrano ] ; then
	useradd -s /bin/bash -m capistrano
	echo "capistrano      ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/capistrano
	chmod 440 /etc/sudoers.d/capistrano
fi

# install rvm (for rubies) 
cat > /home/capistrano/install_rvm.bash <<EOL
#!/bin/bash
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
\curl -sSL https://get.rvm.io | bash -s stable
source /home/capistrano/.rvm/scripts/rvm
rvm install 2.2.2
rvm use --default 2.2.2
gem install bundler
EOL

chmod +x /home/capistrano/install_rvm.bash
su -s /bin/bash - capistrano -c /home/capistrano/install_rvm.bash

mkdir -p /var/www/${URL}/shared/config/
chown -R capistrano: /var/www

# config database 
cat > /var/www/${URL}/shared/config/database.yml <<EOL
${RAILS_ENV}:
  adapter: postgresql
  encoding: utf8
  database: ${DB_NAME}
  username: ${DB_USER}
  password: ${DB_PASS}
  pool: 5
  timeout: 5000

legacy:
  adapter: postgresql
  encoding: utf8
  database: ${DBLEG_NAME}
  username: ${DBLEG_USER}
  password: ${DBLEG_PASS}
  pool: 5
  timeout: 5000
EOL

# config secrets
cat > /var/www/${URL}/shared/config/secrets.yml <<EOL
${RAILS_ENV}:
  secret_key_base: changemewithrakesecret
  email:
    default_from: 'notifications@example.com'
  errbit:
    api_key: changeme
    host: 'sub.example.com'
EOL

service nginx restart

set +x 

echo "**************************************************************************"
echo ""
echo "             INSTALACION ATENCION CIUDADANA CARCHI - termina"
echo ""
echo " 1. Configura tu clave SSH con ssh-copy-id o poniendo tu clave pública en "
echo "    /home/capistrano/.ssh/authorized_keys"
echo " 2. Comprobar que funcione el acceso SSH sin contraseña"
echo "    ssh ${URL}"
echo " 3. Ejecutar en local (development)"
echo "    $ cap ${RAILS_ENV} deploy"
echo "    $ cap ${RAILS_ENV} invoke[db:seed]"
echo " 4. Comprobar en configuración del Host (LXC), proxy (nginx) y dominios que funcione."
echo ""
echo " Dirección IP: ${IP_ADDRESS}"
echo " Dirección URL: https://${URL}"
echo ""
echo "**************************************************************************"

date
