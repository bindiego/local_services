#!/bin/bash

pwd=`pwd`

docker run --name nginx \
  -p 80:80 \
  -p 443:443 \
  -v ${pwd}/conf/nginx/nginx.conf:/etc/nginx/nginx.conf:ro \
  -v ${pwd}/conf/nginx:/opt/nginx/conf:ro \
  --restart=unless-stopped \
  -m 128M --memory-swap -1 \
  --cpuset-cpus="0,1" \
  -d nginx:1.16-alpine
  #-v ${pwd}/conf.d:/etc/nginx/conf.d:ro \
  #-v /home/ptmind/workspace/www:/var/www/html:rw \
  #--link phpengine \

