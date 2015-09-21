
# Deploy Gobierno Abierto

1. Para comprobar los cambios en el código en local hace falta configurar 
el entorno de desarrollo, ver en https://github.com/alabs/carchi_gobiernoabierto.
Si no se quiere montar el entorno de desarrollo se puede instalar en una 
máquina virtual (por ejemplo VirtualBox) y realizar el proceso de instalación. 

2. Para comenzar hace falta tener configurado en la configuración local 
de SSH ($HOME/.ssh/config) los siguientes hosts: 

```
Host beta.gobiernoabierto.carchi.gob.ec
  Port 22
  Hostname 10.0.3.${IP}
  User capistrano
  ProxyCommand ssh -A -p 22 usuario@carchi-lxc nc %h %p

Host gobiernoabierto.carchi.gob.ec
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
ssh beta.gobiernoabierto.carchi.gob.ec
ssh gobiernoabierto.carchi.gob.ec
```

5. Se trabaja sobre la rama de git master. Una vez se tengan los cambios hechos se suben 
a la rama git production o staging.

```
git checkout staging 
git merge master 
git push origin staging
cap staging deploy
git checkout master
```
