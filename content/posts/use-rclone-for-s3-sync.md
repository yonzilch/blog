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
      - 0.0.0.0:5572:5572
    entrypoint:
      - rclone
      - rcd
      - --rc-web-gui
      - --rc-web-gui-no-open-browser
      - --rc-addr=0.0.0.0:5572
      - --rc-user=xxxxxx
      - --rc-pass=xxxxxxxxxxxxxxxx
      ###- --rc-no-auth

```


Notice: just replace [rc-user] and [rc-pass] at line 21, 22

More reference to see how it works: [https://rclone.org/gui/](https://rclone.org/gui/)

Then configure reserved proxy programs like Nginx, Caddy, Traefik, and so on.

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

Also, set the other s3 provider as backup, here I set `static-yon-cloudflare`(Cloudflare R2).


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

So you just need to set a cronjob so that it would run regularly.

e.g.

```
crontab -e

0 */2 * * * bash -c 'docker exec rclone rclone sync static-yon-4everland: static-yon-cloudflare:'
```

## Acknowledgements

[https://github.com/rclone/rclone](https://github.com/rclone/rclone)
