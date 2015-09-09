#!/bin/bash
# 
# Script para la instalación de la plataforma de Gobierno Abierto de Carchi
# Autor: apereira@alabs.org
# Fecha: 8 de Septiembre de 2015 
#

date

URL=beta.gobiernoabierto.carchi.gob.ec
RAILS_ENV=staging
DB_NAME=gobiernabi_stag
DB_USER=gobiernabi_stag
DB_PASS=$(date +%s | sha256sum | base64 | head -c 16 ; echo)
IP_ADDRESS=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')

echo "**************************************************************************"
echo ""
echo "             INSTALACION GOBIERNO ABIERTO CARCHI - empieza"
echo ""
echo " En un servidor limpio de Ubuntu 14.04 instalará la plataforma de"
echo " Gobierno Abierto de El Carchi. Tardará aproximadamente 30 minutos."
echo " Empieza en 10 segundos, puede cancelar con CTRL + C"
echo ""
echo "**************************************************************************"

sleep 10

set -e 
set -x

VER=$(lsb_release -sr)

if [ $VER != "14.04" ]; then 
   echo "Este script debe ejecutarse en Ubuntu 14.04" 1>&2
   exit 1
fi

if [ "$(id -u)" != "0" ]; then
   echo "Este script debe ejecutarse como root" 1>&2
   exit 1
fi

cat >/etc/apt/apt-conf << EOL 
Acquire::http::Proxy "http://10.0.3.1:3142";
EOL

apt-get update

# Paquetes básicos de Ubuntu
apt-get -y install build-essential zlib1g-dev libxml2-dev libxslt-dev
apt-get -y install git htop nodejs libssl-dev
apt-get -y install libreadline-dev libpq-dev libcurl4-openssl-dev
apt-get -y install libyaml-dev libsqlite3-dev sqlite3 autoconf bison
apt-get -y install libgdbm-dev libncurses5-dev automake libtool libffi-dev
apt-get -y install imagemagick libmagick++-dev flvmeta qrencode
apt-get -y install lighttpd curl lynx vim
apt-get -y install ffmpegthumbnailer
apt-get -y install libgio-cil libav-tools libavcodec-extra


# install nginx + passenger 
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
apt-get install -y apt-transport-https ca-certificates
sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main > /etc/apt/sources.list.d/passenger.list'
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
	root /web/openirekia/carchi_gobiernoabierto/public;
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

# Java y ElasticSearch
apt-get -y install software-properties-common
add-apt-repository ppa:webupd8team/java -y
apt-get update
echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections
apt-get -y install oracle-java7-installer

if [ ! -d /usr/share/elasticsearch/plugins/kopf ] ; then
        wget -O - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add -
        echo "deb http://packages.elasticsearch.org/elasticsearch/1.3/debian stable main" > /etc/apt/sources.list.d/elasticsearch.list
        apt-get update
        apt-get install elasticsearch
        cd /usr/share/elasticsearch/
        bin/plugin --install lmenezes/elasticsearch-kopf/1.3
        service elasticsearch start
        update-rc.d elasticsearch defaults 95 10
fi

# Instalar CouchDB:
apt-get -y install couchdb
service couchdb restart
# Activar el logging desde el servido Apache al CouchDB:
# Instalar el log-reader:
apt-get -y install python-dev python-simplejson
apt-get -y install python-httplib2 python-couchdb

if [ ! -d /usr/local/src/log_reader_git ] ; then 
	cd /usr/local/src
	wget http://www.efaber.net/ogov/log_reader_git.tar.gz
	tar -xzvf log_reader_git.tar.gz
	cd log_reader_git
	python setup.py install
	curl -X PUT http://localhost:5984/ilog3
	curl -X PUT http://localhost:5984/wlog4
fi

if [ ! -d /web/openirekia ] ; then 
	# Crear usuario Irekia 
	[ $(getent group rails) ] || groupadd -g 95 rails
	id -u irekia &>/dev/null || useradd -m -s /bin/bash -G rails irekia
	mkdir -p /web/openirekia
	chown irekia:rails /web/openirekia
	#sudo -u postgres createuser -S -d -R irekia

	# create database
	sudo -u postgres createuser -S -D -R ${DB_USER}
	sudo -u postgres psql -c "ALTER USER ${DB_USER} PASSWORD '${DB_PASS}';"
	sudo -u postgres createdb -O ${DB_USER} ${DB_NAME} # -E utf-8
fi

echo "irekia      ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/irekia
chmod 440 /etc/sudoers.d/irekia

# TODO: download alabs/carchi_gobiernoabierto

cat >/home/irekia/install_rvm.bash <<EOL
#!/bin/bash
set -e 

if [ ! -d /home/irekia/.rvm ] ; then 
	gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
	\curl -sSL https://get.rvm.io | bash -s stable
fi

source /home/irekia/.rvm/scripts/rvm

rvm install 2.1.2
rvm use --default 2.1.2
gem install bundler 
EOL

chmod +x /home/irekia/install_rvm.bash
sudo -u irekia /home/irekia/install_rvm.bash -

mkdir -p /var/www/${URL}/shared/config/
chown -R irekia: /var/www

# config database 
cat > /var/www/${URL}/shared/config/database.yml <<EOL
${RAILS_ENV}:
  adapter: mysql2
  encoding: utf8
  database: ${DB_NAME}
  username: ${DB_USER}
  password: ${DB_PASS}
  pool: 5
  timeout: 5000
EOL

# config secrets
cat > /var/www/${URL}/shared/config/secrets.yml <<EOL
${RAILS_ENV}:
  secret_key_base: changemewithrakesecret
EOL

service nginx restart

set +x

echo "**************************************************************************"
echo ""
echo "             INSTALACION GOBIERNO ABIERTO CARCHI - termina"
echo ""
echo " 1. Configura tu clave SSH con ssh-copy-id o poniendo tu clave pública en "
echo "    /home/irekia/.ssh/authorized_keys"
echo " 2. Comprobar que funcione el acceso SSH sin contraseña"
echo "    ssh ${URL}"
echo " 3. Ejecutar en local (development)"
echo "    $ cap ${RAILS_ENV} deploy"
echo "    $ cap ${RAILS_ENV} invoke[db:seed]"
echo " 4. Comprobar en configuración del Host (LXC) y dominios que funcione."
echo ""
echo " Dirección IP: ${IP_ADDRESS}"
echo " Dirección URL: https://${URL}"
echo ""
echo "**************************************************************************"

date

# Recargar código:
#   $ sudo su - irekia 
#   $ cd /web/openirekia/carchi_gobiernoabierto
#   $ git pull origin master
#   $ bundle install
#   $ bundle exec rake db:migrate
#   $ touch tmp/restart.txt

# Agregar usuario admin: 

# Realizar copia de seguridad: 

# Restaurar copia de seguridad: 
