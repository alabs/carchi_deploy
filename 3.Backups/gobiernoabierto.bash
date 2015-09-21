#!/bin/bash
# 
# Script para la copia de seguridad de la plataforma de Gobierno Abierto de Carchi
# Autor: apereira@alabs.org
#

URL=beta.gobiernoabierto.carchi.gob.ec

[ ! -d /usr/local/backup/dump/ ] || mkdir -p /usr/local/backup/dump/
chown -R postgres: /usr/local/backup/dump/

sudo -u postgres pg_dumpall > /usr/local/backup/dump/dump.sql
rm /usr/local/backup/dump/dump.sql.gz
gzip /usr/local/backup/dump/dump.sql 

tar czf /usr/local/backup/dump/shared_config.tgz /var/www/${URL}/shared/config/
tar czf /usr/local/backup/dump/shared_public.tgz /var/www/${URL}/shared/public/
