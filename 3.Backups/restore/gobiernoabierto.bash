#!/bin/bash
# 
# Script para la restauración de la copia de seguridad de la plataforma de Atención Ciudadana de Carchi
# Autor: apereira@alabs.org
# Fecha: 8 de Septiembre de 2015 
#
# Restaura la última copia de seguridad que encuentre en /usr/local/backup/dump/dump.sql.gz
#

URL=beta.gobiernoabierto.carchi.gob.ec
DB_NAME=gobiernabi_stag

cd /usr/local/backup/dump/ 
gunzip dump.sql.gz
tar xzf shared_config.tgz
tar xzf shared_public.tgz

#mv /var/www/${URL}/shared/config/ /var/www/${URL}/shared/config.$(date +"%Y%m%d")
#mv var/www/${URL}/shared/config/ /var/www/${URL}/shared/config/

mv /var/www/${URL}/shared/public/ /var/www/${URL}/shared/public.$(date +"%Y%m%d")
mv var/www/${URL}/shared/public/ /var/www/${URL}/shared/public/

sudo -u postgres psql -d ${DB_NAME} -f /usr/local/backup/dump/dump.sql
