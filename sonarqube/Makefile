pwd := $(shell pwd)
ver := 1.0
hostip := 10.140.0.3

init:
	[ -d sonarqube ] || mkdir -p sonarqube/{conf,data,extensions,lib} && \
		mkdir -p sonarqube/lib/bundled-plugins

dbinit:
	[ -d db ] || mkdir -p db/data

docker: init
	docker run -d --name sonarqube \
		-p 39000:9000 -p 39092:9092 \
		-v $(pwd)/sonarqube/conf:/opt/sonarqube/conf \
		-v $(pwd)/sonarqube/data:/opt/sonarqube/data \
		-v $(pwd)/sonarqube/extensions:/opt/sonarqube/extensions \
		-v $(pwd)/sonarqube/lib/bundled-plugins:/opt/sonarqube/lib/bundled-plugins \
		-e SONARQUBE_JDBC_USERNAME=sonar \
		-e SONARQUBE_JDBC_PASSWORD=sonar \
		-e SONARQUBE_JDBC_URL=jdbc:postgresql://localhost/sonar \
		sonarqube:lts

dc: init dbinit
	docker-compose up -d

.PHONY: init docker dc
