
Para modificar la contraseña a un usuario administrador es necesario acceder al servidor que corresponda. 

```
cd /usr/lib/ckan/default/src/ckan
source /usr/lib/ckan/default/bin/activate
paster sysadmin add carchi -c /etc/ckan/default/production.ini
```

Para crear un usuario llamado carchi. Es el único tipo de usuario que se permite en la instalación.

Para modificar datos de usuarios:
* Nombre de usuario
* Nombre completo
* Dirección de correo electrónico
* Contraseña

Se puede realizar a con un usuario administrador en esta URL: https://datosabiertos.carchi.gob.ec/user

Los logos de los usuarios se gestionan a través del servicio Gravatar: http://es.gravatar.com/ 
