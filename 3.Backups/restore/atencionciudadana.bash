#!/bin/bash
# 
# Script para la restauración de la copia de seguridad de la plataforma de Atención Ciudadana de Carchi
# Autor: apereira@alabs.org
# Fecha: 8 de Septiembre de 2015 
#
# Restaura la última copia de seguridad que encuentre en /usr/local/backup/dump/dump.sql.gz
#

DB_NAME=atencion_stag

cd /usr/local/backup/dump/ 
gunzip dump.sql.gz
mysql ${DB_NAME} < dump.sql
