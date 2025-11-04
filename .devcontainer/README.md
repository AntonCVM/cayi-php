# 🚀 DevContainer - Apache + PHP + MariaDB + WordPress + Joomla

## Inicio Rápido

### Paso 1: Editar hosts de Windows (UNA SOLA VEZ)

Abre `C:\Windows\System32\drivers\etc\hosts` como administrador y añade:

```
127.0.0.1  wordpress.dominio.es
127.0.0.1  joomla.dominio.es
```

Guarda y cierra.

### Paso 2: Abrir DevContainer

```
Ctrl+Shift+P → Dev Containers: Reopen in Container
```

Espera 2-3 minutos mientras se construye.

### Paso 3: Acceder a los sitios

```
http://wordpress.dominio.es
http://joomla.dominio.es
```

---

## Qué sucede automáticamente

1. ✅ Apache 2.4 instalado y configurado
2. ✅ PHP 8.2 con extensiones mysqli, pdo, pdo_mysql
3. ✅ MariaDB 10.4 instalado
4. ✅ Virtual Hosts configurados para ambos sitios
5. ✅ WordPress descargado y configurado
6. ✅ Joomla descargado y configurado
7. ✅ Bases de datos creadas
8. ✅ `/etc/hosts` del container editado automáticamente

---

## Credenciales

### MariaDB
- Usuario: `root`
- Contraseña: `mariadb`

### WordPress
- Base de datos: `wordpress`
- Usuario: `wordpress`
- Contraseña: `wordpress`

### Joomla
- Base de datos: `joomla`
- Usuario: `joomla`
- Contraseña: `joomla`

---

## Cambiar Credenciales

Edita `.devcontainer/.env`:

```env
MYSQL_ROOT_PASSWORD=tu_contraseña
WP_DB_PASSWORD=tu_contraseña
JOOMLA_DB_PASSWORD=tu_contraseña
```

Luego reconstruye:

```
Ctrl+Shift+P → Dev Containers: Rebuild Container
```

---

## Si algo falla

### Los sitios no cargan

1. Espera 30 segundos (MariaDB tarda)
2. Recarga con `F5`
3. Revisa logs:

```bash
tail -f /var/log/apache2/access.log
```

### Restablecer todo

```
Ctrl+Shift+P → Dev Containers: Rebuild Container
```

---

## Cuando termines

Cierra el DevContainer:

```
Ctrl+Shift+P → Dev Containers: Reopen Locally
```

Todo se limpia. Windows no se modifica permanentemente.

---

## Archivos importantes

- **`Dockerfile`**: Define la imagen (Apache, PHP, MariaDB)
- **`docker-compose.yml`**: Orquesta los servicios
- **`init.sh`**: Script que configura todo al iniciar
- **`.env`**: Credenciales de bases de datos
