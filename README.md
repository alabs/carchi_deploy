
# Carchi Deploy 

Scripts para la instalación de los contenedores LXC para las plataformas de la Prefectura de Carchi de Gobierno Abierto, Datos Abiertos y Atención Ciudadana. 

* https://atencionciudadana.carchi.gob.ec/
* https://datosabiertos.carchi.gob.ec/
* https://gobiernoabierto.carchi.gob.ec/
* https://beta.atencionciudadana.carchi.gob.ec/
* https://beta.datosabiertos.carchi.gob.ec/
* https://beta.gobiernoabierto.carchi.gob.ec/

Para crear las maquinas virtuales, primero debemos saber que plataforma será:
* Gobierno Abierto: trusty (Ubuntu 14.04) 
* Datos Abiertos: precise (Ubuntu 12.04)
* Atención Ciudadana: precise (Ubuntu 12.04)

Una vez creada la maquina descargaremos el script "install_${PLATAFORMA}.bash" 
y modificaremos las variables que están al inicio, dependiendo del script. 
Por ejemplo para la plataforma de Atencion Ciudadana, entorno de producción (production): 

* URL=atencionciudadana.carchi.gob.ec
* RAILS_ENV=production
* DB_NAME=atencion_prod
* DB_USER=atencion_prod

Ejemplos de comandos a ejecutar: 
```
lxc-create -n stag-atencionciudadana -t ubuntu -- -r precise
lxc-start -n stag-atencionciudadana -d
lxc-attach -n stag-atencionciudadana  --clear-env
wget https://raw.githubusercontent.com/alabs/carchi_deploy/master/install_atencionciudadana.bash
# Descargar el script, adaptar variables
bash atencionciudadana.bash

lxc-create -n prod-atencionciudadana -t ubuntu -- -r precise
lxc-start -n prod-atencionciudadana -d
lxc-attach -n prod-atencionciudadana  --clear-env
wget https://raw.githubusercontent.com/alabs/carchi_deploy/master/install_atencionciudadana.bash
# Descargar el script, adaptar variables
bash atencionciudadana.bash

lxc-create -n stag-datosabiertos -t ubuntu -- -r precise
lxc-start -n stag-datosabiertos -d
lxc-attach -n stag-datosabiertos  --clear-env
wget https://raw.githubusercontent.com/alabs/carchi_deploy/master/install_datosabiertos.bash
# Descargar el script, adaptar variables
bash datosabiertos.bash

lxc-create -n prod-datosabiertos -t ubuntu -- -r precise
lxc-start -n prod-datosabiertos -d
lxc-attach -n prod-datosabiertos  --clear-env
wget https://raw.githubusercontent.com/alabs/carchi_deploy/master/install_datosabiertos.bash
# Descargar el script, adaptar variables
bash datosabiertos.bash

lxc-create -n stag-gobiernoabierto -t ubuntu -- -r trusty
lxc-start -n stag-gobiernoabierto -d
lxc-attach -n stag-gobiernoabierto  --clear-env
wget https://raw.githubusercontent.com/alabs/carchi_deploy/master/install_gobiernoabierto.bash
# Descargar el script, adaptar variables
bash gobiernoabierto.bash

lxc-create -n prod-gobiernoabierto -t ubuntu -- -r trusty
lxc-start -n prod-gobiernoabierto -d
lxc-attach -n prod-gobiernoabierto  --clear-env
# Descargar el script, adaptar variables
bash gobiernoabierto.bash
```

