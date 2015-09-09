#!/bin/bash
# 
# Script para la copia de seguridad de la plataforma de Atención Ciudadana de Carchi
# Autor: apereira@alabs.org
# Fecha: 8 de Septiembre de 2015 
#

URL=beta.atencionciudadana.carchi.gob.ec

mysqldump --all-databases > /usr/local/backup/dump/dump.sql 
gzip /usr/local/backup/dump/dump.sql 
tar czf /usr/local/backup/dump/shared_config.tgz /var/www/${URL}/shared/config/
tar czf /usr/local/backup/dump/shared_public.tgz /var/www/${URL}/shared/config/

# Restauraci�n de la copia de seguridad
#
#   $ cd /usr/local/backup/dump/ 
#   $ gunzip dump.sql.gz
#   $ mysql ...
