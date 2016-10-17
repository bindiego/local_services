pwd := $(shell pwd)

.PHONY:
build:
	docker build -t reg.ptone.cn/ptmind/sugarcrm -f Dockerfile .

.PHONY:
run:
	docker run --name ptcrm \
		-e DB_HOST_NAME=172.16.100.103 \
		-e DATABASE_NAME=sugarcrm \
		-e DB_USER_NAME=ptmind \
		-e DB_PASSWORD=Ptmind2016 \
		-e DB_TYPE=mysql \
		-e DB_TCP_PORT=3306 \
		-e DB_MANAGER=MysqlManager \
		-p 42080:80 \
		--restart=unless-stopped \
		-m 1G --memory-swap -1 \
		--cpuset-cpus="0,1" \
		-v $(pwd)/code:/var/www/html:rw \
		-d reg.ptone.cn/ptmind/sugarcrm
