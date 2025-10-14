# telerising-api
A docker container for running [telerising-api](https://github.com/sunsettrack4/telerising-api#telerising-api)

## Getting started

**Start the container with `docker run`**

```sh
docker run -d \
  --name telerising-api \
  -p 5000:5000 \
  --mount type=bind,source="/path/to/settings.json",target=/app/settings.json \
  --mount type=bind,source="/path/to/cookie_files/dir",target=/app/cookie_files \
  --restart=unless-stopped \
  myrck/telerising-api:latest
```

> [!NOTE]  
> The container will run using a user uid and gid 1000 by default, add `--user <your-UID>:<your-GID>` to the docker command to adjust it if necessary. Make sure this match the permissions of your settings.json file and cookie_files directory.

**or `docker-compose`**

```yaml
services:
  telerising-api:
    image: myrck/telerising-api:latest
    container_name: telerising-api
    volumes:
      - /path/to/settings.json:/app/settings.json
      - /path/to/cookie_files:/app/cookie_files
    ports:
      - 5000:5000
    user: 1000:1000
    restart: unless-stopped
```
