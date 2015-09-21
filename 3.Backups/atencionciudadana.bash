#!/bin/bash
# 
# Script para la copia de seguridad de la plataforma de Atención Ciudadana de Carchi
# Autor: apereira@alabs.org
#

URL=beta.atencionciudadana.carchi.gob.ec

[ ! -d /usr/local/backup/dump/ ] || mkdir -p /usr/local/backup/dump/

mysqldump --all-databases > /usr/local/backup/dump/dump.sql 
gzip /usr/local/backup/dump/dump.sql 

tar czf /usr/local/backup/dump/shared_config.tgz /var/www/${URL}/shared/config/
tar czf /usr/local/backup/dump/shared_public.tgz /var/www/${URL}/shared/public/
