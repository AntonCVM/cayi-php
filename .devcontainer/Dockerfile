FROM mcr.microsoft.com/devcontainers/php:1-8.2-bookworm

# Install MariaDB server, Apache and required packages
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y mariadb-server mariadb-client apache2 wget unzip supervisor \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Configure Apache
RUN a2enmod rewrite && \
    sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf

# Download and install WordPress
RUN wget https://wordpress.org/latest.tar.gz -O /tmp/wordpress.tar.gz && \
    tar -xzf /tmp/wordpress.tar.gz -C /tmp && \
    mkdir -p /var/www/wordpress && \
    mv /tmp/wordpress/* /var/www/wordpress/ && \
    chown -R www-data:www-data /var/www/wordpress && \
    rm /tmp/wordpress.tar.gz

# Download and install Joomla
RUN wget https://downloads.joomla.org/cms/joomla5/5-1-4/Joomla_5-1-4-Stable-Full_Package.tar.gz -O /tmp/joomla.tar.gz && \
    mkdir -p /var/www/joomla && \
    tar -xzf /tmp/joomla.tar.gz -C /var/www/joomla && \
    chown -R www-data:www-data /var/www/joomla && \
    rm /tmp/joomla.tar.gz

# Configure Apache virtual hosts
RUN echo '<VirtualHost *:8080>\n\
    DocumentRoot /var/www/wordpress\n\
    <Directory /var/www/wordpress>\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
</VirtualHost>' > /etc/apache2/sites-available/wordpress.conf && \
    echo '<VirtualHost *:8081>\n\
    DocumentRoot /var/www/joomla\n\
    <Directory /var/www/joomla>\n\
        AllowOverride All\n\
        Require all granted\n\
    </Directory>\n\
</VirtualHost>' > /etc/apache2/sites-available/joomla.conf && \
    echo 'Listen 8080\nListen 8081' >> /etc/apache2/ports.conf && \
    a2ensite wordpress joomla

# Configure supervisor
RUN echo '[supervisord]\n\
nodaemon=true\n\
\n\
[program:mariadb]\n\
command=/usr/bin/mysqld_safe\n\
autostart=true\n\
autorestart=true\n\
\n\
[program:apache2]\n\
command=/usr/sbin/apache2ctl -D FOREGROUND\n\
autostart=true\n\
autorestart=true' > /etc/supervisor/conf.d/services.conf

# Initialize MariaDB and create databases
RUN service mariadb start && \
    mysql -e "CREATE DATABASE wordpress;" && \
    mysql -e "CREATE DATABASE joomla;" && \
    mysql -e "CREATE USER 'mariadb'@'%' IDENTIFIED BY 'mariadb';" && \
    mysql -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'mariadb'@'%';" && \
    mysql -e "GRANT ALL PRIVILEGES ON joomla.* TO 'mariadb'@'%';" && \
    mysql -e "FLUSH PRIVILEGES;"

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]

