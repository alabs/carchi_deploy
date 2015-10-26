
Para modificar la contraseña a un usuario administrador se recomienda hacerlo a través de la consola de Ruby On Rails, accediendo al servidor que corresponda. 
En el caso del ejemplo lo haremos sobre atencionciudadana.carchi.gob.ec con entorno de Rails (RAILS_ENV) production. 

cd /var/www/atencionciudadana.carchi.gob.ec/current 
RAILS_ENV=production bundle exec rails console

user = AdminUser.new 
user.email = "email@dominio.com"
user.password = "contraseña"
user.password_confirmation = "contraseña"
user.admin = true
user.save

El usuario puede acceder al admin a través de la URL https://atencionciudadana.carchi.gob.ec/admin

Cada usuario puede tener distintos grados de permisos, en el caso del ejemplo le estamos dando el grado de acceso "Administrador total de la plataforma". Los otros grados son:  

user.actividad: "Sólo acceso a inscritos de Actividades de la Casa de la Juventud"
user.plantas: "Sólo acceso a inscritos de Plantas de Gestión Ambiental"
user.audiencia: "Sólo acceso a inscritos de Audiencia con el Prefecto"
user.admin: "Administrador total de la plataforma"

Para elegir un grado distinto debe hacerse cambiando al línea `user.admin = true` por `user.audiencia = true` segun corresponda.

