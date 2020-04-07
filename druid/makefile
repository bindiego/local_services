pwd := $(shell pwd)
ver := 1.0
druid_ver := 0.9.2

.PHONY:
buildzk:
	docker build -f docker/Dockerfile.zookeeper -t ptzookeeper:3.4.9 .
.PHONY:
runzk: buildzk
	@@[ -d zk ] || mkdir zk
	@[ -d zk/logs ] || mkdir zk/logs
	@docker run --name ptzookeeper \
		-p 42181:2181 \
		-p 42888:2888 \
		-p 43888:3888 \
		-v $(pwd)/zk/logs:/opt/zookeeper/logs \
		--restart=unless-stopped \
		-m 512M --memory-swap -1 \
		--cpuset-cpus="0,1" \
		-d ptzookeeper:3.4.9

.PHONY:
runrdb:
	@[ -d db ] || mkdir db
	@[ -d db/data ] || mkdir -p db/data
	@docker run --name ptmysql \
		-p 43306:3306 \
		-v $(pwd)/db/data:/var/lib/mysql \
		-e MYSQL_ROOT_PASSWORD=R0ot \
		-e MYSQL_DATABASE=druid \
		-e MYSQL_USER=druid \
		-e MYSQL_PASSWORD=druid2016 \
		--restart=unless-stopped \
		-m 512M --memory-swap -1 \
		--cpuset-cpus="0,1" \
		-d mysql:5.7 --character-set-server=utf8 --collation-server=utf8_general_ci
.PHONY:
initrdb:
	@mysql -h 127.0.0.1 -P 43306 -u root -pR0ot \
		-e "GRANT ALL PRIVILEGES ON druid.* TO 'druid'@'%' IDENTIFIED BY 'druid2016';"
	@mysql -h 127.0.0.1 -P 43306 -u root -pR0ot \
		-e "flush privileges;"

.PHONY:
runmc:
	@docker run --name ptmc \
		-p 41211:11211 \
		--restart=unless-stopped \
		-m 256M --memory-swap -1 \
		--cpuset-cpus="0,1" \
		-d memcached:1.4-alpine

.PHONY:
builddruid:
	@cd $(pwd)/druid-$(druid_ver) && \
		java -classpath "$(pwd)/druid-$(druid_ver)/lib/*" io.druid.cli.Main tools \
			pull-deps --defaultVersion 0.9.2 --clean \
			-c io.druid.extensions:mysql-metadata-storage \
			-c io.druid.extensions:druid-datasketches \
			-c io.druid.extensions:druid-histogram \
			-c io.druid.extensions:druid-stats \
			-c io.druid.extensions.contrib:druid-rabbitmq \
			-c io.druid.extensions.contrib:druid-rocketmq \
			-h org.apache.hadoop:hadoop-client:2.3.0 \
			-h org.apache.hadoop:hadoop-client:2.4.0 && \
		cd $(pwd)
	@[ -d druiddata ] || mkdir -p druiddata
	@[ -d druiddata/logs ] || mkdir -p druiddata/logs
	@docker build -f docker/Dockerfile.druid -t ptdruid:$(druid_ver) .
	@-docker rmi $(docker images --filter "dangling=true" -q --no-trunc)

.PHONY:
rundruid: builddruid rundruidbroker rundruidhist rundruidcoord rundruidmm rundruidol rundruidrt

.PHONY:
cleandruid:
	@docker stop ptbroker pthist ptcoord ptmm ptol ptrt && \
		docker rm ptbroker pthist ptcoord ptmm ptol ptrt
	@-rm -rf druidconfs

.PHONY:
rundruidbroker:
	@[ -d druidconfs/confbroker ] || mkdir -p druidconfs/confbroker
	@cp -a druidconf/* druidconfs/confbroker
	@cp -a docker/ptrun druidconfs/confbroker
	@docker run --name ptbroker \
		--network="bridge" \
		-p 48081:48081 \
		-p 47071:47071 \
		-u="root" \
		-v $(pwd)/druidconfs/confbroker:/opt/druid/conf/druid:rw \
		-v $(pwd)/druidconfs/confbroker/ptrun:/opt/druid/ptrun:rw \
		-v $(pwd)/druiddata:/data/druid:rw \
		-v $(pwd)/druiddata/logs:/opt/druid/log:rw \
		--restart=unless-stopped \
		-m 64G --memory-swap -1 \
		--cpuset-cpus="0,1" \
		-e "DRUID_FORM=broker" \
		-e "DRUID_OPERATION=start" \
		-d ptdruid:$(druid_ver)

.PHONY:
rundruidhist:
	@[ -d druidconfs/confhist ] || mkdir -p druidconfs/confhist
	@cp -a druidconf/* druidconfs/confhist
	@cp -a docker/ptrun druidconfs/confhist
	@docker run --name pthist \
		--network="bridge" \
		-p 48082:48082 \
		-u="root" \
		-v $(pwd)/druidconfs/confhist:/opt/druid/conf/druid:rw \
		-v $(pwd)/druidconfs/confhist/ptrun:/opt/druid/ptrun:rw \
		-v $(pwd)/druiddata:/data/druid:rw \
		-v $(pwd)/druiddata/logs:/opt/druid/log:rw \
		--restart=unless-stopped \
		-m 32G --memory-swap -1 \
		--cpuset-cpus="0,1" \
		-e "DRUID_FORM=historical" \
		-e "DRUID_OPERATION=start" \
		-d ptdruid:$(druid_ver)

.PHONY:
rundruidcoord:
	@[ -d druidconfs/confcoord ] || mkdir -p druidconfs/confcoord
	@cp -a druidconf/* druidconfs/confcoord
	@cp -a docker/ptrun druidconfs/confcoord
	@docker run --name ptcoord \
		--network="bridge" \
		-p 48083:48083 \
		-u="root" \
		-v $(pwd)/druidconfs/confcoord:/opt/druid/conf/druid:rw \
		-v $(pwd)/druidconfs/confcoord/ptrun:/opt/druid/ptrun:rw \
		-v $(pwd)/druiddata:/data/druid:rw \
		-v $(pwd)/druiddata/logs:/opt/druid/log:rw \
		--restart=unless-stopped \
		-m 16G --memory-swap -1 \
		--cpuset-cpus="0,1" \
		-e "DRUID_FORM=coordinator" \
		-e "DRUID_OPERATION=start" \
		-d ptdruid:$(druid_ver)

.PHONY:
rundruidmm:
	@[ -d druidconfs/confmm ] || mkdir -p druidconfs/confmm
	@cp -a druidconf/* druidconfs/confmm
	@cp -a docker/ptrun druidconfs/confmm
	@docker run --name ptmm \
		--network="bridge" \
		-p 48084:48084 \
		-u="root" \
		-v $(pwd)/druidconfs/confmm:/opt/druid/conf/druid:rw \
		-v $(pwd)/druidconfs/confmm/ptrun:/opt/druid/ptrun:rw \
		-v $(pwd)/druiddata:/data/druid:rw \
		-v $(pwd)/druiddata/logs:/opt/druid/log:rw \
		--restart=unless-stopped \
		-m 2G --memory-swap -1 \
		--cpuset-cpus="0,1" \
		-e "DRUID_FORM=middleManager" \
		-e "DRUID_OPERATION=start" \
		-d ptdruid:$(druid_ver)

.PHONY:
rundruidol:
	@[ -d druidconfs/confol ] || mkdir -p druidconfs/confol
	@cp -a druidconf/* druidconfs/confol
	@cp -a docker/ptrun druidconfs/confol
	@docker run --name ptol \
		--network="bridge" \
		-p 48085:48085 \
		-u="root" \
		-v $(pwd)/druidconfs/confol:/opt/druid/conf/druid:rw \
		-v $(pwd)/druidconfs/confol/ptrun:/opt/druid/ptrun:rw \
		-v $(pwd)/druiddata:/data/druid:rw \
		-v $(pwd)/druiddata/logs:/opt/druid/log:rw \
		--restart=unless-stopped \
		-m 4G --memory-swap -1 \
		--cpuset-cpus="0,1" \
		-e "DRUID_FORM=overlord" \
		-e "DRUID_OPERATION=start" \
		-d ptdruid:$(druid_ver)

.PHONY:
rundruidrt:
	@[ -d druidconfs/confrt ] || mkdir -p druidconfs/confrt
	@cp -a druidconf/* druidconfs/confrt
	@cp -a docker/ptrun druidconfs/confrt
	@docker run --name ptrt \
		--network="bridge" \
		-p 48086:48086 \
		-p 47072:47072 \
		-u="root" \
		-v $(pwd)/druidconfs/confrt:/opt/druid/conf/druid:rw \
		-v $(pwd)/druidconfs/confrt/ptrun:/opt/druid/ptrun:rw \
		-v $(pwd)/druiddata:/data/druid:rw \
		-v $(pwd)/druiddata/logs:/opt/druid/log:rw \
		--restart=unless-stopped \
		-m 24G --memory-swap -1 \
		--cpuset-cpus="0,1" \
		-e "DRUID_FORM=realtime" \
		-e "DRUID_OPERATION=start" \
		-d ptdruid:$(druid_ver)

.PHONY:
buildhd:
	@docker build -f docker/Dockerfile.hadoop -t pthadoop:2.7.1 .
.PHONY:
runhd: buildhd
	@docker run --name pthadoop \
		-p 48020:8020 \
		--restart=unless-stopped \
		-m 2G --memory-swap -1 \
		--cpuset-cpus="0,1" \
		-d pthadoop:2.7.1
