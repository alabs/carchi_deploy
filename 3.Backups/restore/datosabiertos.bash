#!/bin/bash
# 
# Script para la restauración de la copia de seguridad de la plataforma de Atención Ciudadana de Carchi
# Autor: apereira@alabs.org
# Fecha: 8 de Septiembre de 2015 
#
# Restaura la última copia de seguridad que encuentre en /usr/local/backup/dump/dump.sql.gz
# 
# Hay que tener en cuenta una cosa de la configuración de ALTER_PERMISSIONS. 
#
# Si es ALTER_PERMISSIONS=true significa que aparte de restaurar la base de datos y ficheros del backup 
# también se encargará de renombrar los usuarios y base de datos para que funcione en el servidor. 
# Esto es para el caso de un restore de la maquina de prod-datosabiertos a stag-datosabiertos.
#
# Por otro lado si se quiere restaurar la base de datos de producción en producción (restaurar una copia 
# de seguridad de prod-datosabiertos a prod-datosabiertos, o sea, se conectaría al mismo usuario y contraseña
# que ya tiene.), lo que se debe hacer es poner ALTER_PERMISSIONS=false.
#  
 

ALTER_PERMISSIONS=true
# ALTER_PERMISSIONS=false
DB_NAME_OLD=datosabier_stag
DB_NAME_NEW=datosabier_prod
WEBSERVER=apache2

################################################################################

install_dropbox_uploader() {
  if [ ! -f /usr/local/bin/dropbox_uploader.sh ] ; then 
    which curl || sudo apt-get install -y curl 
    curl "https://raw.githubusercontent.com/andreafabrizi/Dropbox-Uploader/master/dropbox_uploader.sh" -o /usr/local/bin/dropbox_uploader.sh
    chmod +x /usr/local/bin/dropbox_uploader.sh 
    dropbox_uploader.sh
  fi
}

restore_from_dropbox() {
  # acepta un parametro, fichero a subir
  dropbox_uploader.sh download $1 $1
}

create_dir() {
  # comprueba si existe el directorio, si no existe lo crea 
  # ve al directorio
  dir=$1
  [ ! -d $dir ] && mkdir -p $dir
  cd $dir
}

if [ -d /usr/local/backup/restore/ ] ; then
  echo "Ya hay un restore realizado. Por favor comprueba el directorio /usr/local/backup/restore/, renombralo o borralo y vuelve a ejecutar este script."
  exit 1;
fi

restore_postgres() {
  gunzip dump.sql.gz
  today=$(date +%Y%m%d)
  dump=/var/lib/postgresql/dump.sql
  
  # paramos el webserver porque sino no nos va dejar cambiar la DB con conexiones abiertas
  service ${WEBSERVER} stop
  cp dump.sql /var/lib/postgresql
  chown postgres: $dump
  sudo -u postgres psql -f $dump 

  if [ ${ALTER_PERMISSIONS} ] ; then
    sudo -u postgres psql -c "ALTER DATABASE ${DB_NAME_OLD} RENAME TO datosabier_${today};"
    sudo -u postgres psql -c "ALTER DATABASE ${DB_NAME_NEW} RENAME TO ${DB_NAME_OLD};"
    sudo -u postgres psql -c "ALTER DATABASE ${DB_NAME_OLD} OWNER TO ${DB_NAME_OLD};"
    sudo -u postgres psql ${DB_NAME_OLD} -c "REASSIGN OWNED BY ${DB_NAME_NEW} TO ${DB_NAME_OLD};"
  fi

  service ${WEBSERVER} start
}

restore_files() {
  tar xzfP etc.tgz
  tar xzfP ckan.tgz
  today=$(date +%Y%m%d)
  mv /var/lib/ckan/ /var/lib/ckan.${today}
  mv /usr/local/backup/restore/var/lib/ckan /var/lib/
}

################################################################################

init_restore () {
  # pre-requisites
  install_dropbox_uploader 
  create_dir /usr/local/backup/restore/

  # downloading from dropbox...
  restore_from_dropbox dump.sql.gz
  restore_from_dropbox etc.tgz
  restore_from_dropbox ckan.tgz

  # restoring database...
  restore_postgres

  # restoring files...
  restore_files
}

init_restore
