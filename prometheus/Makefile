pwd := $(shell pwd)
ipaddr := $(shell hostname -I | cut -d ' ' -f 1)
uid := $(shell id -u)
ver := v2.24.1

init:
	@docker pull prom/prometheus:$(ver)
	@[ -d $(pwd)/data ] \
		|| mkdir -p $(pwd)/data

run: init
	@docker run --name prometheus \
	  -p 9090:9090 \
	  --restart=unless-stopped \
	  -v $(pwd)/conf/prometheus.yml:/etc/prometheus/prometheus.yml \
	  -v $(pwd)/data:/var/lib/prometheus:rw \
	  -m 512M --memory-swap -1 \
	  --cpuset-cpus="0,1" \
	  -d prom/prometheus:$(ver)

clean_all:
	@sudo rm -rf $(pwd)/data
	@docker stop prometheus && docker rm prometheus
	@docker rmi prom/prometheus:$(ver)

.PHONY: init run clean_all
