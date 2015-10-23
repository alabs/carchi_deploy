#!/bin/bash
# 
# Script para la restauración de la copia de seguridad de la plataforma de Atención Ciudadana de Carchi
# Autor: apereira@alabs.org
# Fecha: 8 de Septiembre de 2015 
#
# Restaura la última copia de seguridad que encuentre en /usr/local/backup/dump/dump.sql.gz
#

DB_NAME=atencion_stag

restore_from_dropbox() {
  # acepta un parametro, fichero a subir
  dropbox_uploader.sh download $1 $1
}

if [ -d /usr/local/backup/restore/ ] ; then
  echo "Ya hay un restore realizado. Por favor comprueba el directorio /usr/local/backup/restore/, renombralo o borralo y vuelve a ejecutar este script."
  exit 1;
fi

[ ! -d /usr/local/backup/restore/ ] || mkdir -p /usr/local/backup/restore/

cd /usr/local/backup/restore/ 

restore_from_dropbox dump.sql.gz
restore_from_dropbox etc.tgz
restore_from_dropbox shared_config.tgz
restore_from_dropbox shared_public.tgz

gunzip dump.sql.gz
tar xzf etc 
tar xzf shared_config.tgz 
tar xzf shared_public.tgz 

