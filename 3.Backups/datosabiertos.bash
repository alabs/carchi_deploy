#!/bin/bash
# 
# Script para la copia de seguridad de la plataforma de Datos Abiertos de Carchi
# Autor: apereira@alabs.org
#

source /usr/lib/ckan/default/bin/activate || exit 1

paster --plugin=ckan db dump /usr/local/backup/dump/datosabiertos-daily --config=/etc/ckan/default/production.ini
rm /usr/local/backup/dump/datosabiertos-daily.gz
gzip /usr/local/backup/dump/datosabiertos-daily

cd /usr/local/backup/dump
tar czf etc_ckan.tgz /etc/ckan/

# Restauraci�n de la copia de seguridad
#
#   $ cd /usr/lib/ckan/default/src/ckan
#   $ source /usr/lib/ckan/default/bin/activate
#   $ gunzip /usr/local/backup/dump/datosabiertos-daily.gz
#   $ paster --plugin=ckan db clean --config=/etc/ckan/default/production.ini
#   $ paster --plugin=ckan db load /usr/local/backup/dump/datosabiertos-daily --config=/etc/ckan/default/production.ini
