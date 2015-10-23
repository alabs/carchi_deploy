

En todos los casos (tanto para realizar una copia de seguridad como una restauración), se utilizará el script [Dropbox-Uploader](http://github.com/andreafabrizi/Dropbox-Uploader) para realizar la subida de los ficheros a otro servidor y localización (backup off-site). 

Para esto hay que descargarlo y configurarlo inicialmente, siguiendo los pasos que detalla la herramienta, como usuario root:

```
cd /usr/local/bin
curl "https://raw.githubusercontent.com/andreafabrizi/Dropbox-Uploader/master/dropbox_uploader.sh" -o dropbox_uploader.sh
chmod +x dropbox_uploader.sh 
dropbox_uploader.sh 
```

Se recomienda crear 3 Aplicaciones distintas para cada una de las herramientas (con su par de key y secret) para mantener la seguridad y separación entre cada herramienta. 

