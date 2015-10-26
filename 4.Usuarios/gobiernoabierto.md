Para modificar la contraseña a un usuario administrador se recomienda hacerlo a través del formulario de "¿Ha olvidado su contraseña?", ingresando el correo electrónico del usuario: https://gobiernoabierto.carchi.gob.ec/es/password_resets/new

Para crear un usuario nuevo se recomienda hacerlo a través del propio Administrador, cambiar permisos o correos electronicos, se recomienda hacerlo con un usuario con grado de acceso "Administrador total de la plataforma" en: https://gobiernoabierto.carchi.gob.ec/es/admin/users

El usuario puede acceder al admin a través de la URL https://gobiernoabierto.carchi.gob.ec/admin

Para crear un usuario sin acceso al administrador, o modificar contraseñas, permisos o correos electronicos de los usuarios, se puede hacer con la consola de Ruby On Rails, accediendo al servidor que corresponda. 
En el caso del ejemplo lo haremos sobre gobiernoabierto.carchi.gob.ec con entorno de Rails (RAILS_ENV) production. 

```
cd /var/www/gobiernoabierto.carchi.gob.ec/current 
RAILS_ENV=production bundle exec rails console

user = User.new 
user.type = "Admin"
user.name = "Administrador"
user.email = "email@dominio.com"
user.password = "contraseña"
user.password_confirmation = "contraseña"
user.admin = true
user.save
```

Los permisos se gestionan a través del modelo relacionado Permission, por ejemplo:

```
> User.first.permissions
=> [#<Permission id: 19, user_id: 1, module: "events", action: "create_private", created_at: "2015-09-23 17:26:50", updated_at: "2015-09-23 17:26:50">,
#<Permission id: 20, user_id: 1, module: "events", action: "create_irekia", created_at: "2015-09-23 17:26:50", updated_at: "2015-09-23 17:26:50">,
#<Permission id: 21, user_id: 1, module: "news", action: "create", created_at: "2015-09-23 17:26:50", updated_at: "2015-09-23 17:26:50">,
#<Permission id: 22, user_id: 1, module: "news", action: "edit", created_at: "2015-09-23 17:26:50", updated_at: "2015-09-23 17:26:50">,
#<Permission id: 23, user_id: 1, module: "news", action: "complete", created_at: "2015-09-23 17:26:50", updated_at: "2015-09-23 17:26:50">,
#<Permission id: 24, user_id: 1, module: "news", action: "export", created_at: "2015-09-23 17:26:50", updated_at: "2015-09-23 17:26:50">,
#<Permission id: 25, user_id: 1, module: "proposals", action: "edit", created_at: "2015-09-23 17:26:50", updated_at: "2015-09-23 17:26:50">,
#<Permission id: 26, user_id: 1, module: "comments", action: "official", created_at: "2015-09-23 17:26:50", updated_at: "2015-09-23 17:26:50">,
#<Permission id: 27, user_id: 1, module: "comments", action: "edit", created_at: "2015-09-23 17:26:50", updated_at: "2015-09-23 17:26:50">,
#<Permission id: 28, user_id: 1, module: "recommendations", action: "rate", created_at: "2015-09-23 17:26:50", updated_at: "2015-09-23 17:26:50">,
#<Permission id: 29, user_id: 1, module: "headlines", action: "approve", created_at: "2015-09-23 17:26:50", updated_at: "2015-09-23 17:26:50">,
#<Permission id: 30, user_id: 1, module: "permissions", action: "administer", created_at: "2015-09-23 17:33:40", updated_at: "2015-09-23 17:33:40">]
```

Para darle permisos al usuario hay que realizar lo siguiente: 

```
user.permissions.create(module: "news", action: "create") 
```

Con respecto a los permisos, se detallan en el fichero *app/models/permission.rb*. Estas son las opciones disponibles en este momento:

  module          |    action       | Que puede hacer
------------------+-----------------+-------------------------
  news            | create          | Crear noticias
  news            | edit            | Modificar y traducir noticias
  news            | complete        | Modificar, traducir y modificar la informacion adicional de noticias (multimedia)
  news            | export          | Exportar noticias para importar en euskadi.net
  comments        | edit            | Moderar comentarios
  comments        | official        | Responder comentarios de manera oficial
  events          | create_private  | Eventos de uso interno del Gobierno
  events          | create_irekia   | Eventos para Irekia
  permissions     | administer      | Repartir permisos entre el resto de usuarios
  recommendations | rate            | Puede marcar las noticias relacionadas como acertadas o no
  headlines       | approve         | Puede aprobar los titulares importados desde Entzumena. También puede editar el area y el idioma. 


