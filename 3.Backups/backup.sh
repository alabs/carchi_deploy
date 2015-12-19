#!/bin/bash
# 
# Script para la copia de seguridad para las tres plataformas de Gobierno Abierto
# de la Prefectura de Carchi: Gobierno Abierto (rails), Datos Abiertos (ckan) y Atención Ciudadana (rails). 
#
# Autor: apereira@alabs.org
# 
# Para llamar al script y que diferencie de que directorio debe realizar la copia, 
# hace falta hacerlo con dos parámetros obligatorios: 
# 
# backup.sh -t tipo -u url
#
# Las opciones de tipo son rails o ckan y de entorno production o staging.
#
# Para cada una de las platafomas con su tipo sería: 
#
# Atención Ciudadana: 
# $ backup.sh -t rails -u atencionciudadana.carchi.gob.ec
# $ backup.sh -t rails -u beta.atencionciudadana.carchi.gob.ec
# 
# Gobierno Abierto: 
# $ backup.sh -t rails -u gobiernoabierto.carchi.gob.ec 
# $ backup.sh -t rails -u beta.gobiernoabierto.carchi.gob.ec
# 
# Datos Abiertos: 
# $ backup.sh -t ckan -u datosabiertos.carchi.gob.ec
# $ backup.sh -t ckan -u beta.datosabiertos.carchi.gob.ec
# 
# Durante la instalación inicial pedirá la configuración de la cuenta de Dropbox, 
# debemos seguir los pasos y darle permisos a la Aplicación que creemos. 
#
################################################################################

usage() { 
  # muestra ayuda cuando faltan parámetros
  echo "Usage: $0 [-t <ckan|rails>] [-u <url>]" 1>&2; exit 1; 
}

install_dropbox_uploader() {
  # comprueba si existe el script de Dropbox, si no lo tiene lo descarga y configura.
  if [ ! -f /usr/local/bin/dropbox_uploader.sh ] ; then 
    which curl || sudo apt-get install -y curl 
    curl "https://raw.githubusercontent.com/andreafabrizi/Dropbox-Uploader/master/dropbox_uploader.sh" -o /usr/local/bin/dropbox_uploader.sh
    chmod +x /usr/local/bin/dropbox_uploader.sh 
    /usr/local/bin/dropbox_uploader.sh
  fi
}

create_dir() {
  # comprueba si existe el directorio, si no existe lo crea 
  # ve al directorio
  dir=$1
  [ ! -d $dir ] && mkdir -p $dir
  cd $dir
}

backup_postgres() {
  # realiza
  cd /usr/local/backup/dump/
  chown -R postgres: /usr/local/backup/dump/
  sudo -u postgres pg_dumpall > dump.sql
  rm dump.sql.gz
  gzip dump.sql 
}

backup_file() {
  # comprime un fichero o directorio
  # acepta un parametro, fichero a comprimir
  file=$1
  name=$(basename ${file})
  tar czfP ${name}.tgz ${file}
}

upload_to_dropbox() { 
  # sube un fichero a dropbox
  # acepta un parametro, fichero a subir
  /usr/local/bin/dropbox_uploader.sh -q upload $1 backup.${URL}.${1}
}

init_backup () {
  # pre-requisites
  install_dropbox_uploader 
  create_dir /usr/local/backup/dump/

  # backing up database...
  backup_postgres

  case "$BACKUP_TYPE" in 
    # si la aplicación es ckan
    ckan) 
      # backing up files...
      backup_file /etc
      backup_file /var/lib/ckan

      # uploading to dropbox...
      upload_to_dropbox dump.sql.gz
      upload_to_dropbox etc.tgz 
      upload_to_dropbox ckan.tgz 
      ;; 
    # si la aplicación es ruby on rails
    rails)
      # backing up files...
      backup_file /etc
      backup_file /var/www/${URL}/shared/config/
      backup_file /var/www/${URL}/shared/public/

      # uploading to dropbox...
      upload_to_dropbox dump.sql.gz
      upload_to_dropbox etc.tgz 
      upload_to_dropbox config.tgz 
      upload_to_dropbox public.tgz
      ;;
  esac

}

# toma opciones de la linea de comando
while getopts ":t:u:" o; do
    case "${o}" in
        t)
            BACKUP_TYPE=${OPTARG}
            ((BACKUP_TYPE == rails || BACKUP_TYPE == ckan)) || usage
            ;;
        u)
            URL=${OPTARG} || usage
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${BACKUP_TYPE}" ] || [ -z "${URL}" ]; then
    usage
fi

if [ "$(id -u)" != "0" ]; then
   echo "Este script debe ejecutarse como root" 1>&2
   exit 1
fi

init_backup

