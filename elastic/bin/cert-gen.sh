#!/bin/bash -ex

[ -d conf/nginx ] || mkdir -p conf/nginx

openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout conf/nginx/cert.key -out conf/nginx/cert.crt
