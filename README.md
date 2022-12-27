# Mantis - Unofficial Docker Container

Platforms: AMD/ARM

This is an unofficial docker container for the Mantis bugtracking system. It features persistent file systems and databases and examples of how it can be setup in a way where upgrades and tear downs are possible without losing data and maintaining security.

You can begin using the bugtracker using a small `docker-compose.yml` file. You can use any compatible database with MantisBT, but for this example and on my sites, I have elected to use MariaDB version 10.6 as it is the most stable as of this writing.

```yaml
version: '3'
services:

  webapp:
    image: mbagnall/mantis:latest
    container_name: mantis
    ports:
      - 8111:80
    volumes:
      - ./mantis/config:/var/www/html/config
    networks:
      - mantis
    restart: unless-stopped

  datastore:
    image: mariadb:10.6
    container_name: mantisdb
    environment:
      MYSQL_USER: 'user'
      MYSQL_DATABASE: 'bugtracker'
      MYSQL_PASSWORD: 'strongpassword'
      MYSQL_ROOT_PASSWORD: 'strongpassword'
      MYSQL_ALLOW_EMPTY_PASSWORD: 'no'
    expose:
      - "3306"
    volumes:
      - ./mantis/mariadb:/var/lib/mysql
    networks:
      mantis:
        aliases:
          - db
    restart: unless-stopped

networks:
  mantis:
```

Once you have this in place, you can issue the `docker-compose-up-d` command to start up your container.

## Setup

Run the setup scripts. If you change the MySQL passwords in the `docker-compose` file, be sure to use that password on the setup screen. Use root as the user for both the administrative MySQL user and regular one as well. Keep the database named `bugtracker` unless you set it up differently in `docker-compose.yml`, but I do not recommend doing that.

Once the self setup is complete and provided you have followed the example volume settings in the `docker-compose.yml` file, you will have a working MantisBT instance you can proxy to via Apache or Nginx on port 8111.

To persistently remove the /admin folder with every build, add the following lines to your config file:

```php
if (file_exists('/var/www/html/web/admin')) {
  rrmdir('/var/www/html/web/admin');
}

function rrmdir($dir) {
   if (is_dir($dir)) {
     $objects = scandir($dir);
     foreach ($objects as $object) {
       if ($object != "." && $object != "..") {
         if (filetype($dir."/".$object) == "dir") rrmdir($dir."/".$object); else unlink($dir."/".$object);
       }
     }
     reset($objects);
     rmdir($dir);
  }
}
```
