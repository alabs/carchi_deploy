# Deploy Datos Abiertos

1. Para recargar el código hace falta descargar el código del tema, 
ver en https://github.com/alabs/ckanext-carchi_theme
Si no se quiere montar el entorno de desarrollo se puede instalar en una 
máquina virtual (por ejemplo VirtualBox) y realizar el proceso de instalación. 

2. Se suben los cambios a la rama de git master

3. Se conecta al servidor que corresponda (stag-datosabiertos o prod-datosabiertos) de la maquina LXC.

```
ssh carchi-lxc
sudo lxc-attach -n stag-datosabiertos
source /usr/lib/ckan/default/bin/activate
cd /usr/local/src/ckanext-carchi_theme 
git pull origin master 
python setup.py install 
sudo service apache2 reload
```
