pwd := $(shell pwd)
ipaddr := $(shell hostname -I | cut -d ' ' -f 1)

all: clean build run

build:
	@docker build -t dingosocks -f Dockerfile .

run:
	@docker run --name dingosocks \
		-p 4040:4040 \
		-v ${pwd}/config.json:/etc/shadowsocks-libev/config.json:ro \
		--restart=unless-stopped \
		-m 512M --memory-swap -1 \
		--cpuset-cpus="0,1" \
		-d dingosocks
logs:
	@docker logs -f --tail 200 dingosocks

clean:
	@-docker rm -v $(docker ps -a -q -f status=dead)
	@-docker rmi $(docker images -f "dangling=true" -q)

.PHONY: all build run clean
