# Devserver

This container provides builds on [jc21/docker-appserver](https://github.com/jc21/docker-appserver) to provide extra development tools with which to run your web applications.

* Runs on Alpine Linux, a very secure, light os
* Nginx with PHP FPM 5.6 and Lua
* PHP Libraries: json, zlib, xml, pdo, phar, openssl, pdo_mysql, mysqli, gd, iconv, mcrypt, soap, apcu, gmp, ctype, pgsql, pdo_pgsql, ftp, gettext, dom
* All logs are sent to stdout so you can use `docker logs` to get your info
* Image is approx 65mb
* Contains Node, NPM, Bower, Composer and Gulp

## Setup

Since this is meant to be a highly configurable image from a Nginx point of view, you'll need to create
your own nginx config file(s) to define your server(s).

Your conf must have at least 1 `server` block in there, listening on port 80.

Inside that conf you can reference `/var/app` as the root of your App code. Your http paths inside the config
can be whatever you want from there.

Here's an example config file that is perfect for Yii and most other PHP frameworks using /index.php as the main script:

```bash
server {
    server_name mysite.com;
    listen 80;

    charset utf-8;
    client_max_body_size 128M;
    server_tokens off;

    root        /var/app/frontend/web;
    index       index.php;

    location / {
        # Redirect everything that isn't a real file to index.php
        try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php$ {
        try_files $uri =404;

        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_index           index.php;

        fastcgi_pass                127.0.0.1:9000;
        fastcgi_connect_timeout     30s;
        fastcgi_read_timeout        30s;
        fastcgi_send_timeout        60s;
        fastcgi_ignore_client_abort on;
        fastcgi_pass_header         "X-Accel-Expires";

        fastcgi_param  SCRIPT_FILENAME  $document_root$fastcgi_script_name;
        fastcgi_param  PATH_INFO        $fastcgi_path_info;
        fastcgi_param  HTTP_REFERER     $http_referer;
        include fastcgi_params;
    }

    location ~ /\.(ht|svn|git) {
        deny all;
    }
}
```

Let's assume your PHP application has a folder structure like this:

```
/path/to/your/app
- config
  - nginx
    - nginx.conf
- web
  - index.php
```

## Start the Container

```bash
sudo docker run \
    -d \
    --name devserver-something \
    -e APP_ENV=dev \
    -v /path/to/your/app:/var/app \
    -v /path/to/your/app/config/nginx/nginx.conf:/etc/nginx/conf.d/app.conf \
    -p 1234:80 \
    jc21/devserver
```

If the docker started successfully you should be able to hit your docker host on port 1234 like so:

http://dockerhost:1234/

Nginx will load all *.conf files in `/etc/nginx/conf.d` so you should be able to link an entire dir of nginx confs istead of a single conf file using this -v, replacing the one above:

```bash
    -v /path/to/your/app/config/nginx:/etc/nginx/conf.d \
```
