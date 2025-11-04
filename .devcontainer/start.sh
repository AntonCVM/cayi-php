#!/bin/bash

# Iniciar MariaDB
service mysql start

# Ejecutar inicialización
/usr/local/bin/init.sh

# Iniciar Apache en primer plano
apache2ctl start
tail -f /var/log/apache2/access.log
