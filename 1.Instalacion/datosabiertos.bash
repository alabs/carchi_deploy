#!/bin/bash
# 
# Script para la instalación de la plataforma de Datos Abiertos de Carchi
# Autor: apereira@alabs.org
# Fecha: 8 de Septiembre de 2015 
#

date

#URL=datosabiertos.carchi.gob.ec
#DB_NAME=datosabier_prod
#DB_USER=datosabier_prd
#DBDAT_USER=datastore_prod
#DBDAT_NAME=datastore_prod

URL=beta.datosabiertos.carchi.gob.ec
DB_NAME=datosabier_stag
DB_USER=datosabier_stag
##DBDAT_USER=datastore_stag
##DBDAT_NAME=datastore_stag

########################################################################
DB_PASS=$(date +%s | sha256sum | base64 | head -c 16 ; echo)
#DBDAT_PASS=$(date +%s | sha256sum | base64 | head -c 16 ; echo)
IP_ADDRESS=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')

echo "**************************************************************************"
echo ""
echo "             INSTALACION DATOS ABIERTOS CARCHI - empieza"
echo ""
echo " En un servidor limpio de Ubuntu 12.04 instalará la plataforma de"
echo " Datos Abiertos de El Carchi. Tardará aproximadamente 1 hora."
echo " Empieza en 10 segundos, puede cancelar con CTRL + C"
echo ""
echo "**************************************************************************"

sleep 10

set -e 
set -x

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

# install nginx apache2
apt-get update
apt-get install -y nginx apache2 libapache2-mod-wsgi libpq5 wget

# install postfix (SMTP)
echo postfix postfix/main_mailer_type select Internet Site | debconf-set-selections
echo postfix postfix/mailname string localhost | debconf-set-selections
apt-get install -y postfix

# install ckan
wget http://packaging.ckan.org/python-ckan_2.3_amd64.deb
dpkg -i python-ckan_2.3_amd64.deb

# install solr
apt-get install -y solr-jetty

cat > /etc/default/jetty <<EOL
NO_START=0
VERBOSE=yes
JETTY_HOST=127.0.0.1
JETTY_PORT=8983
JAVA_HOME=/usr/lib/jvm/java-6-openjdk-amd64/
EOL
mv /etc/solr/conf/schema.xml /etc/solr/conf/schema.xml.bak
ln -s /usr/lib/ckan/default/src/ckan/ckan/config/solr/schema.xml /etc/solr/conf/schema.xml
service jetty start

# install postgres
apt-get install -y postgresql 

# create database CKAN - general
sudo -u postgres createuser -S -D -R ${DB_USER}
sudo -u postgres psql -c "ALTER USER ${DB_USER} PASSWORD '${DB_PASS}';"
sudo -u postgres createdb -O ${DB_USER} ${DB_NAME} # -E utf-8

# create database CKAN - datastore
#sudo -u postgres createuser -S -D -R ${DBDAT_USER}
#sudo -u postgres psql -c "ALTER USER ${DBDAT_USER} PASSWORD '${DBDAT_PASS}';"
#sudo -u postgres createdb -O ${DB_USER} ${DBDAT_NAME} # -E utf-8

# config database
cd /usr/lib/ckan/default/src/ckan
source /usr/lib/ckan/default/bin/activate
sed -i "/sqlalchemy.url/c\sqlalchemy.url = postgresql://${DB_USER}:${DB_PASS}@localhost/${DB_NAME}" /etc/ckan/default/production.ini
#ckan.datastore.read_url = postgresql://${DB_USER}:${DB_PASS}@localhost/${DBDAT_NAME}
#ckan.datastore.write_url = postgresql://${DBDAT_USER}:${DBDAT_PASS}@localhost/${DBDAT_NAME}" 
paster db init -c /etc/ckan/default/production.ini
#paster datastore set-permissions postgres -c /etc/ckan/default/production.ini

# Agregar en /etc/ckan/default/production.ini:
# ckan.site_url = https://beta.datosabiertos.carchi.gob.ec
# ckan.storage_path = /var/lib/ckan
# ckan.max_resource_size = 10
# ckan.max_image_size = 2

mkdir -p /var/lib/ckan
chown www-data: /var/lib/ckan
chmod u+rwx /var/lib/ckan

# install carchi_theme
#pip install --upgrade --no-deps --force-reinstall https://github.com/alabs/ckanext-carchi_theme/zipball/master
apt-get install -y git
cd /usr/local/src/ 
git clone https://github.com/alabs/ckanext-carchi_theme 
cd ckanext-carchi_theme 
python setup.py install 

sed -i "/ckan.plugins = /c\ckan.plugins = stats text_view image_view recline_view carchi_theme"  /etc/ckan/default/production.ini
#sed -i "/ckan.plugins = /c\ckan.plugins = stats text_view image_view recline_view datastore carchi_theme"  /etc/ckan/default/production.ini
sed -i "/ckan.site_title = /c\ckan.site_title = Datos Abiertos El Carchi"  /etc/ckan/default/production.ini
sed -i "/ckan.locale_default = /c\ckan.locale_default = es"  /etc/ckan/default/production.ini

service apache2 restart
service nginx restart

set +x

echo "**************************************************************************"
echo ""
echo "             INSTALACION DATOS ABIERTOS CARCHI - termina"
echo ""
echo " 1. Comprobar en configuración del Host (LXC) y dominios que funcione."
echo ""
echo " Dirección IP: ${IP_ADDRESS}"
echo " Dirección URL: https://${URL}"
echo " A continuación le pediremos la contraseña para el usuario admin. "
echo ""
echo "**************************************************************************"

paster sysadmin add admin -c /etc/ckan/default/production.ini

date


