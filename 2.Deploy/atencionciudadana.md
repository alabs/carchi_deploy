
# Deploy Atención Ciudadana

1. Para comprobar los cambios en el código en local hace falta configurar 
el entorno de desarrollo, ver en https://github.com/alabs/carchi_tramites.
Si no se quiere montar el entorno de desarrollo se puede instalar en una 
máquina virtual (por ejemplo VirtualBox) y realizar el proceso de instalación. 

2. Para comenzar hace falta tener configurado en la configuración local 
de SSH ($HOME/.ssh/config) los siguientes hosts: 

```
Host beta.atencionciudadana.carchi.gob.ec
  Port 22
  Hostname 10.0.3.${IP}
  User capistrano
  ProxyCommand ssh -A -p 22 usuario@carchi-lxc nc %h %p

Host atencionciudadana.carchi.gob.eccarchi-lxc
  Port 22
  Hostname 10.0.3.${IP}
  User capistrano
  ProxyCommand ssh -A -p 22 usuario@carchi-lxc nc %h %p
```

3. Configurar las claves públicas SSH en los servidores en el fichero 
/home/capistrano/.ssh/authorized_keys

4. La primera vez que conectemos deberemos aceptar el certificado SSH y comprobar 
que tengamos nuestra clave bien configurada. 

```
ssh beta.atencionciudadana.carchi.gob.ec
ssh atencionciudadana.carchi.gob.ec
```

5. Se trabaja sobre la rama de git master. Una vez se tengan los cambios hechos se suben 
al servidor correcto en funcion del entorno.

```
git push origin master 
cap staging deploy
```

```
git push origin master 
cap production deploy
```
