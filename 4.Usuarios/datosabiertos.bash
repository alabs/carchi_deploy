
Para modificar la contraseña a un usuario administrador es necesario acceder al servidor que corresponda. 

```
cd /usr/lib/ckan/default/src/ckan
source /usr/lib/ckan/default/bin/activate
paster sysadmin add carchi -c /etc/ckan/default/production.ini
```

Para crear un usuario llamado carchi. Es el único tipo de usuario que se permite en la instalación. 

