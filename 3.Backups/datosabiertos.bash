#!/bin/bash
# 
# Script para la copia de seguridad de la plataforma de Datos Abiertos de Carchi
# Autor: apereira@alabs.org
#

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
tar czf files_ckan.tgz /var/lib/ckan

upload_to_dropbox etc.tgz 
upload_to_dropbox files_ckan.tgz

