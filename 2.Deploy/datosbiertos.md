# Deploy Datos Abiertos

1. Para recargar el código hace falta descargar el código del tema, 
ver en https://github.com/alabs/ckanext-carchi_theme
Si no se quiere montar el entorno de desarrollo se puede instalar en una 
máquina virtual (por ejemplo VirtualBox) y realizar el proceso de instalación. 

2. Se suben los cambios a la rama de git master

3. Se conecta al servidor que corresponda (stag-datosabiertos o prod-datosabiertos) de la maquina LXC.

```
ssh 186.3.11.222
sudo lxc-attach -n stag-datosabiertos
source /usr/lib/ckan/default/bin/activate
pip install --upgrade --no-deps --force-reinstall https://github.com/alabs/ckanext-carchi_theme/zipball/master 
sudo service apache2 reload
```
