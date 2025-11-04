FROM mcr.microsoft.com/devcontainers/php:1-8.2-bookworm

# Install Apache, MariaDB client, PHP extensions, and tools
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get install -y \
    apache2 \
    mariadb-client \
    mariadb-server \
    curl \
    wget \
    unzip \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install mysqli pdo pdo_mysql

# Enable Apache modules
RUN a2enmod rewrite && a2enmod proxy && a2enmod proxy_fcgi

# Copy configuration files
COPY .env /usr/local/bin/.env
COPY init.sh /usr/local/bin/init.sh
RUN chmod +x /usr/local/bin/init.sh

# Copy startup script
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

CMD ["/usr/local/bin/start.sh"]

