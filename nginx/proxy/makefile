pwd := $(shell pwd)
ipaddr := $(shell hostname -I | cut -d ' ' -f 1)
nginx_ver := $(shell cat ver)

build:
	@./build $(nginx_ver)
	@cp nginx-$(nginx_ver)/objs/nginx $(pwd)

builder:
	@[ -d builder ] || mkdir -p builder
	@cp build makefile ver builder
	@docker build -t nginx-builder -f Dockerfile.builder .

builder-build: builder
	@docker run --name ng-builder -it \
		-v $(pwd)/builder:/builder:rw \
		nginx-builder /builder/build
	@cp $(pwd)/builder/nginx-$(nginx_ver)/objs/nginx .
	@docker rm ng-builder

clean:
	@-sudo rm -rf ng* builder
	# @-docker rmi `docker images --filter "dangling=true" -q --no-trunc`
	@-docker stop l7-nginx; docker rm l7-nginx
	@-docker stop l4-nginx; docker rm l4-nginx


l7:
	docker run --name l7-nginx \
	  -p 7780:80 \
	  -p 7443:443 \
	  -v $(pwd)/nginx:/usr/sbin/nginx:ro \
	  -v $(pwd)/all-nginx.conf:/etc/nginx/nginx.conf:ro \
	  -v $(pwd)/L7-nginx.conf:/etc/nginx/conf.d/L7-nginx.conf:ro \
	  --restart=unless-stopped \
	  -m 512M --memory-swap -1 \
	  --cpuset-cpus="0,1" \
	  -d nginx:$(nginx_ver)

l4:
	docker run --name l4-nginx \
	  -p 4480:80 \
	  -p 4443:443 \
	  -v $(pwd)/nginx:/usr/sbin/nginx:ro \
	  -v $(pwd)/L4-nginx.conf:/etc/nginx/nginx.conf:ro \
	  --restart=unless-stopped \
	  -m 512M --memory-swap -1 \
	  --cpuset-cpus="0,1" \
	  -d nginx:$(nginx_ver)

.PHONY: build builder builder-build clean l7 l4
