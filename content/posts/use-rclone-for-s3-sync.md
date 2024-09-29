+++
title = "Use rclone for s3 sync"
date = "2024-09-29"
+++

### Needs

As I found that my data is in risk of losing, because as the saying goes "Free is the most expensive."

It is a strange thing that people usually escape the thoughts on personal data protection.But this is a true fact that often catches people off guard.

So I researched from Internet in order to find a way to backup my images on S3 storage provider, and worth the effort, finally I make it works.


## Overview

1. Use docker to deploy rclone webui
2. Configure the backend storage
3. Create an automated task using a time trigger

## Environment

Here, I deploy rclone on my personal VPS server.

`docker-compose.yaml`

```
version: "3"

services:
  rclone:
    container_name: rclone
    image: "rclone/rclone:latest"
    restart: unless-stopped
    stdin_open: true
    tty: true
    volumes:
      - /var/lib/docker/volumes/rclone/_data/config:/config
      - /var/lib/docker/volumes/rclone/_data/data:/data
    ports:
      - 127.0.0.1:5572:5572
    entrypoint:
      - rclone
      - rcd
      - --rc-web-gui
      - --rc-web-gui-no-open-browser
      - --rc-addr=0.0.0.0:5572
      - --rc-user=xxxxxx
      - --rc-pass=xxxxxxxxxxxxxxxx
      ###- --rc-no-auth
    networks:
      - nginx

networks:
  nginx:
    external: true

```


Notice: just replace [rc-user] and [rc-pass] at line 21, 22

More reference to see how it works: [https://rclone.org/gui/](https://rclone.org/gui/)


Configure NGINX config to make reserved proxy done.

```
rclone.conf
```

```
server {
    listen 80;
    listen [::]:80;
    server_name rclone.example.com;

    # Uncomment to redirect HTTP to HTTPS
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;

    server_name rclone.example.com;
    #Do not use .pem format,otherwise NGINX will have errors
    ssl_certificate		/www/server/nginx/cert/self-sign.cer;
    ssl_certificate_key	/www/server/nginx/cert/private.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    # HSTS (ngx_http_headers_module is required) (63072000 seconds)
    add_header Strict-Transport-Security "max-age=63072000" always;


    location / {

    proxy_set_header    Host            $http_host;
    proxy_set_header    X-Real-IP       $remote_addr;
    proxy_set_header    X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_pass http://rclone:5572;

    # Nginx by default only allows file uploads up to 1M in size
    client_max_body_size 100M;

    proxy_http_version 1.1;
    proxy_redirect off;
    # For WebSocket
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Frame-Options SAMEORIGIN;

    # Set as shown below. You can use other values for the numbers as you wish
    proxy_headers_hash_max_size 512;
    proxy_headers_hash_bucket_size 128;

    # Cache settings
    #proxy_cache cache1;
    #proxy_cache_lock on;
    #proxy_cache_use_stale updating;
    #add_header X-Cache
    #$upstream_cache_status;

    proxy_connect_timeout 600s;
    proxy_read_timeout 5400s;
    proxy_send_timeout 600s;
    send_timeout 5400s;
    }

    set_real_ip_from 127.0.0.1;
    set_real_ip_from 0.0.0.0;
    set_real_ip_from 173.249.206.186;
    real_ip_header X-Forwarded-For;
    real_ip_recursive on;

    access_log  /www/server/nginx/logs/rclone.yzlab.eu.org.log;
    error_log  /www/server/nginx/logs/rclone.yzlab.eu.org.log;
}

```



Notice: just replace [rclone.example.com] at line 4, 28

You can also use other reserved proxy program like Caddy, Traefik, and so on.

Also, do not forget adding a DNS record.

## Setup

Browse to your rclone domain(or ip:5572 if you deploy rclone locally)

When you get into Rclone Webui after insert [rc-user] and [rc-pass], open link [https://rclone.example.com/#/newdrive](https://rclone.example.com/#/newdrive) to add backend remote storage.

Notice: you can also click `Configs` > `Create a New Config` to get in this page.

Like this:

![1](https://static.yon.im/image/blog/use-rclone-for-s3-sync/1.avif)


Here I set `Name of this drive` as static-yon-4everland (it is my main s3 provider currently)

![2](https://static.yon.im/image/blog/use-rclone-for-s3-sync/2.avif)



Then just fill in AWS Access Key ID, AWS Secret Access Key, Region, Endpoint by yourself.

Also, set the other s3 provider as backup,here I set `static-yon-cloudflare`(Cloudflare R2).


![3](https://static.yon.im/image/blog/use-rclone-for-s3-sync/3.webp)


More reference to see how it works:

- [https://rclone.org/overview/](https://rclone.org/overview/)
- [https://rclone.org/commands/rclone_config/](https://rclone.org/commands/rclone_config/)



## Trigger

After setting up two S3 backend storage providers, just run this command:

```
docker exec rclone rclone sync static-yon-4everland: static-yon-cloudflare:
```

then files in `static-yon-4everland` will sync to `static-yon-cloudflare`

So you just need set a cronjob make it run regularly.

e.g.

```
crontab -e

0 */2 * * * bash -c 'docker exec rclone rclone sync static-yon-4everland: static-yon-cloudflare:'
```

## Acknowledgements

[https://github.com/rclone/rclone](https://github.com/rclone/rclone)
[https://github.com/nginx/nginx](https://github.com/nginx/nginx)
