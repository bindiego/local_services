pwd := $(shell pwd)
ipaddr := $(shell hostname -I | cut -d ' ' -f 1)
uid := $(shell id -u)
ver := 7.4.0

init:
	@docker pull grafana/grafana:$(ver)
	@[ -d $(pwd)/grafana_vol ] \
		|| mkdir -p $(pwd)/grafana_vol/data
		#|| mkdir -p $(pwd)/grafana_vol/var/lib/grafana/plugins; \
		#mkdir -p $(pwd)/grafana_vol/etc/grafana/provisioning; \
		#mkdir -p $(pwd)/grafana_vol/usr/share/grafana

run: init
	@docker run \
		--name grafana \
		-p 3000:3000 \
		--user="$(uid)" \
		--volume $(pwd)/grafana_vol/data:/var/lib/grafana:rw \
		-d grafana/grafana:$(ver)
		#--volume $(pwd)/grafana_vol/etc:/etc:rw \
		#--volume $(pwd)/grafana_vol/var:/var:rw \
		#--volume $(pwd)/grafana_vol/usr:/usr:rw \

clean_all:
	@sudo rm -rf $(pwd)/grafana_vol
	@docker stop grafana && docker rm grafana
	@docker rmi grafana/grafana:$(ver)

.PHONY: init run clean_all
