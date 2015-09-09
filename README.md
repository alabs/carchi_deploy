
# Carchi Deploy 

Scripts para la instalación de los contenedores LXC para las plataformas de la Prefectura de Carchi de Gobierno Abierto, Datos Abiertos y Atención Ciudadana. 

* https://atencionciudadana.carchi.gob.ec/
* https://datosabiertos.carchi.gob.ec/
* https://gobiernoabierto.carchi.gob.ec/
* https://beta.atencionciudadana.carchi.gob.ec/
* https://beta.datosabiertos.carchi.gob.ec/
* https://beta.gobiernoabierto.carchi.gob.ec/

Para crear las maquinas virtuales, primero debemos saber que plataforma será, en el caso de Gobierno Abierto tendrá que ser trusty (Ubuntu 14.04) pero en Datos Abiertos y Atención Ciudadana debe ser precise (Ubuntu 12.04).

El nombre de la maquina (VMNAME) será un codigo de entorno-plataforma. Ejemplos: stag-datosabiertos, prod-gobiernoabierto, dev-atencionciudadana. 

lxc-create -n ${VMNAME} -t ubuntu -- -r precise
lxc-start -n ${VMNAME} -d
lxc-attach -n ${VMNAME}  --clear-env

Una vez creada la maquina copiaremos el script "install_${PLATAFORMA}" y modificaremos las variables que están al inicio, dependiendo del script. Por ejemplo para la plataforma de Atencion Ciudadana, entorno de producción (production): 

* URL=atencionciudadana.carchi.gob.ec
* RAILS_ENV=production
* DB_NAME=atencion_prod
* DB_USER=atencion_prod

