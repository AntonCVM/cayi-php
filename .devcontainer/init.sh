#!/bin/bash
set -e

# Cargar variables de entorno
set -a
source /usr/local/bin/.env
set +a

# Editar /etc/hosts dentro del container
echo "127.0.0.1 $DOMAIN_WORDPRESS" >> /etc/hosts
echo "127.0.0.1 $DOMAIN_JOOMLA" >> /etc/hosts

# Esperar a que MariaDB esté listo
until mysql -h "$WP_DB_HOST" -u root -p"$MYSQL_ROOT_PASSWORD" -e "SELECT 1" &> /dev/null; do
  echo "Esperando a MariaDB..."
  sleep 2
done

# Crear directorios
mkdir -p /var/www/html/$DOMAIN_WORDPRESS
mkdir -p /var/www/html/$DOMAIN_JOOMLA

# Crear index.html de prueba para WordPress
cat > /var/www/html/$DOMAIN_WORDPRESS/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>$DOMAIN_WORDPRESS</title>
</head>
<body>
    <h1>$DOMAIN_WORDPRESS</h1>
    <p>Sitio de WordPress</p>
</body>
</html>
EOF

# Crear index.html de prueba para Joomla
cat > /var/www/html/$DOMAIN_JOOMLA/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>$DOMAIN_JOOMLA</title>
</head>
<body>
    <h1>$DOMAIN_JOOMLA</h1>
    <p>Sitio de Joomla</p>
</body>
</html>
EOF

# Crear Virtual Host para WordPress
cat > /etc/apache2/sites-available/$DOMAIN_WORDPRESS.conf << EOF
<VirtualHost *:80>
    ServerName $DOMAIN_WORDPRESS
    ServerAdmin admin@$DOMAIN_WORDPRESS
    DocumentRoot /var/www/html/$DOMAIN_WORDPRESS
    
    <Directory /var/www/html/$DOMAIN_WORDPRESS>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

# Crear Virtual Host para Joomla
cat > /etc/apache2/sites-available/$DOMAIN_JOOMLA.conf << EOF
<VirtualHost *:80>
    ServerName $DOMAIN_JOOMLA
    ServerAdmin admin@$DOMAIN_JOOMLA
    DocumentRoot /var/www/html/$DOMAIN_JOOMLA
    
    <Directory /var/www/html/$DOMAIN_JOOMLA>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

# Habilitar sitios
a2ensite $DOMAIN_WORDPRESS.conf 2>/dev/null || true
a2ensite $DOMAIN_JOOMLA.conf 2>/dev/null || true

# Deshabilitar default
a2dissite 000-default.conf 2>/dev/null || true

# Crear bases de datos
mysql -h "$WP_DB_HOST" -u root -p"$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE $WP_DB_NAME;" 2>/dev/null || true
mysql -h "$JOOMLA_DB_HOST" -u root -p"$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE $JOOMLA_DB_NAME;" 2>/dev/null || true

# Crear usuarios
mysql -h "$WP_DB_HOST" -u root -p"$MYSQL_ROOT_PASSWORD" -e "CREATE USER '$WP_DB_USER'@'%' IDENTIFIED BY '$WP_DB_PASSWORD';" 2>/dev/null || true
mysql -h "$JOOMLA_DB_HOST" -u root -p"$MYSQL_ROOT_PASSWORD" -e "CREATE USER '$JOOMLA_DB_USER'@'%' IDENTIFIED BY '$JOOMLA_DB_PASSWORD';" 2>/dev/null || true

# Otorgar permisos
mysql -h "$WP_DB_HOST" -u root -p"$MYSQL_ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES ON $WP_DB_NAME.* TO '$WP_DB_USER'@'%';" 2>/dev/null || true
mysql -h "$JOOMLA_DB_HOST" -u root -p"$MYSQL_ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES ON $JOOMLA_DB_NAME.* TO '$JOOMLA_DB_USER'@'%';" 2>/dev/null || true

# Descargar WordPress
cd /var/www/html/$DOMAIN_WORDPRESS
rm -f index.html
if [ ! -f wp-config.php ]; then
  curl -s -O https://wordpress.org/latest.tar.gz
  tar -xzf latest.tar.gz --strip-components=1
  rm latest.tar.gz
  
  # Copiar wp-config.php
  cp wp-config-sample.php wp-config.php
  sed -i "s/database_name_here/$WP_DB_NAME/g" wp-config.php
  sed -i "s/username_here/$WP_DB_USER/g" wp-config.php
  sed -i "s/password_here/$WP_DB_PASSWORD/g" wp-config.php
  sed -i "s/localhost/$WP_DB_HOST/g" wp-config.php
fi

# Descargar Joomla
cd /var/www/html/$DOMAIN_JOOMLA
rm -f index.html
if [ ! -f configuration.php ]; then
  curl -s -O https://downloads.joomla.org/cms/joomla5/Joomla_5.0.3-Stable.tar.gz
  tar -xzf Joomla_5.0.3-Stable.tar.gz
  rm Joomla_5.0.3-Stable.tar.gz
fi

# Fijar permisos
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Recargar Apache
apache2ctl configtest 2>/dev/null || true
apache2ctl reload 2>/dev/null || true

echo "Inicialización completada"
