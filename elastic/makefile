pwd := $(shell pwd)
ipaddr := $(shell hostname -I | cut -d ' ' -f 1)
ver := 6.1.0

pre_deploy:
	[ -d $(pwd)/deploy ] || mkdir -p $(pwd)/deploy

dl_es: pre_deploy
	@[ -f $(pwd)/deploy/elasticsearch.tar.gz ] || \
		curl https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$(ver).tar.gz \
		--output $(pwd)/deploy/elasticsearch.tar.gz
	-[ -d $(pwd)/deploy/elasticsearch ] || \
		tar xzf $(pwd)/deploy/elasticsearch.tar.gz -C $(pwd)/deploy && \
		mv $(pwd)/deploy/elasticsearch-$(ver) $(pwd)/deploy/elasticsearch

dl_log: pre_deploy
	@[ -f $(pwd)/deploy/logstash.tar.gz ] || \
		curl https://artifacts.elastic.co/downloads/logstash/logstash-$(ver).tar.gz \
		--output $(pwd)/deploy/logstash.tar.gz 
	-[ -d $(pwd)/deploy/logstash ] || \
		tar xzf $(pwd)/deploy/logstash.tar.gz -C $(pwd)/deploy && \
		mv $(pwd)/deploy/logstash-$(ver) $(pwd)/deploy/logstash

dl_kbn: pre_deploy
	@[ -f $(pwd)/deploy/kibana.tar.gz ] || \
		curl https://artifacts.elastic.co/downloads/kibana/kibana-$(ver)-linux-x86_64.tar.gz \
		-o $(pwd)/deploy/kibana.tar.gz
	-[ -d $(pwd)/deploy/kibana ] || \
		tar xzf $(pwd)/deploy/kibana.tar.gz -C $(pwd)/deploy && \
		mv $(pwd)/deploy/kibana-$(ver)-linux-x86_64 $(pwd)/deploy/kibana

inst_xpack: dl_es dl_kbn
	@$(pwd)/deploy/elasticsearch/bin/elasticsearch-plugin install x-pack
	@$(pwd)/deploy/kibana/bin/kibana-plugin install x-pack

start_es: dl_es
	@-[ -f $(pwd)/deploy/elasticsearch/config/elasticsearch.yml.bak ] || \
		cp $(pwd)/deploy/elasticsearch/config/elasticsearch.yml \
		$(pwd)/deploy/elasticsearch/config/elasticsearch.yml.bak
	@-cp $(pwd)/deploy/elasticsearch/config/elasticsearch.yml.bak \
		$(pwd)/deploy/elasticsearch/config/elasticsearch.yml
	#@echo 'network.host: 0.0.0.0' >> \
		#$(pwd)/deploy/elasticsearch/config/elasticsearch.yml
	@$(pwd)/deploy/elasticsearch/bin/elasticsearch -d -p $(pwd)/deploy/es.pid

start_log: dl_log
	@$(pwd)/deploy/logstash/bin/logstash -f conf/logstash-simple.conf > /dev/null 2>&1 &

start_kbn: dl_kbn
	@-[ -f $(pwd)/deploy/kibana/config/kibana.yml.bak ] || \
		cp $(pwd)/deploy/kibana/config/kibana.yml \
		$(pwd)/deploy/kibana/config/kibana.yml.bak
	@-cp $(pwd)/deploy/kibana/config/kibana.yml.bak \
		$(pwd)/deploy/kibana/config/kibana.yml
	@echo 'elasticsearch.url: "http://$(ipaddr):9200"' >> \
		$(pwd)/deploy/kibana/config/kibana.yml
	@$(pwd)/deploy/kibana/bin/kibana > /dev/null 2>&1 &

stop_es:
	-$(pwd)/bin/stop_service.sh elasticsearch 
	@-rm $(pwd)/deploy/es.pid

stop_log:
	-$(pwd)/bin/stop_service.sh logstash

stop_kbn:
	-$(pwd)/bin/stop_service.sh kibana

dl_all: dl_es dl_log dl_kbn

start_all: start_es start_log start_kbn

clean: stop_kbn stop_log stop_es
	@rm -rf $(pwd)/deploy

.PHONY: clean dl_es dl_log dl_kbn dl_all
