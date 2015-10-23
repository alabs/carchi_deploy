#!/bin/bash
# 
# Script para la copia de seguridad de la plataforma de Gobierno Abierto de Carchi
# Autor: apereira@alabs.org
#
# 

URL=beta.gobiernoabierto.carchi.gob.ec

upload_to_dropbox() {
  # acepta un parametro, fichero a subir
  dropbox_uploader.sh upload $1 $1
}

backup_postgres() {
  cd /usr/local/backup/dump/
  chown -R postgres: /usr/local/backup/dump/
  sudo -u postgres pg_dumpall > dump.sql
  rm dump.sql.gz
  gzip dump.sql 
}

[ ! -d /usr/local/backup/dump/ ] || mkdir -p /usr/local/backup/dump/
cd /usr/local/backup/dump/

backup_postgres

tar czf etc.tgz /etc
tar czf shared_config.tgz /var/www/${URL}/shared/config/
tar czf shared_public.tgz /var/www/${URL}/shared/public/

upload_to_dropbox dump.sql.gz
upload_to_dropbox etc.tgz
upload_to_dropbox shared_config.tgz
upload_to_dropbox shared_public.tgz

