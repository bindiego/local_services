pwd := $(shell pwd)
ver := 1.0
hostip := $(shell hostname -I | cut -d ' ' -f 1)

init:
	sudo sysctl -w vm.max_map_count=262144
	sudo sysctl -w fs.file-max=65536
	#sudo ulimit -n 65536
	#sudo ulimit -u 4096
	[ -d sonarqube ] || \
		mkdir -p sonarqube/conf && \
		mkdir -p sonarqube/data && \
		mkdir -p sonarqube/extensions && \
		mkdir -p sonarqube/lib && \
		mkdir -p sonarqube/logs && \
		mkdir -p sonarqube/lib/bundled-plugins && \
		chmod -R 777 sonarqube

dbinit:
	[ -d db ] || mkdir -p db/data

db: dbinit
	docker run --name rdb-sonar \
	  -p 35432:5432 \
	  -v ${pwd}/db/data:/var/lib/postgresql/data \
	  -e POSTGRES_DB=sonar \
	  -e POSTGRES_USER=sonar \
	  -e POSTGRES_PASSWORD=sonar \
	  --restart=unless-stopped \
	  -m 1G --memory-swap -1 \
	  --cpuset-cpus="0,1" \
	  -d postgres:12
sonar: init 
	docker run --name sonarqube \
		-p 39000:9000 -p 39092:9092 \
		-v $(pwd)/sonarqube/conf:/opt/sonarqube/conf \
		-v $(pwd)/sonarqube/data:/opt/sonarqube/data \
		-v $(pwd)/sonarqube/extensions:/opt/sonarqube/extensions \
		-v $(pwd)/sonarqube/lib/bundled-plugins:/opt/sonarqube/lib/bundled-plugins \
		-v $(pwd)/sonarqube/logs:/opt/sonarqube/logs \
		-e SONARQUBE_JDBC_USERNAME=sonar \
		-e SONARQUBE_JDBC_PASSWORD=sonar \
		-e SONARQUBE_JDBC_URL=jdbc:postgresql://$(hostip):35432/sonar \
		-m 8G --memory-swap -1 \
		--cpuset-cpus="0,1" \
		-d sonarqube:lts

dc: init dbinit
	docker-compose up -d

.PHONY: init docker dc
