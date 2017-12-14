pwd := $(shell pwd)
ver := 6.1.0

pre_deploy:
	[ -d $(pwd)/deploy ] || mkdir -p $(pwd)/deploy

dl_es: pre_deploy
	@[ -f $(pwd)/deploy/elasticsearch.tar.gz ] || \
		curl https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$(ver).tar.gz \
		--output $(pwd)/deploy/elasticsearch.tar.gz
	-tar xzf $(pwd)/deploy/elasticsearch.tar.gz -C $(pwd)/deploy && \
		mv $(pwd)/deploy/elasticsearch-$(ver) $(pwd)/deploy/elasticsearch

dl_log: pre_deploy
	@[ -f $(pwd)/deploy/logstash.tar.gz ] || \
		curl https://artifacts.elastic.co/downloads/logstash/logstash-$(ver).tar.gz \
		--output $(pwd)/deploy/logstash.tar.gz 
	-tar xzf $(pwd)/deploy/logstash.tar.gz -C $(pwd)/deploy && \
		mv $(pwd)/deploy/logstash-$(ver) $(pwd)/deploy/logstash

dl_kbn: pre_deploy
	@[ -f $(pwd)/deploy/kibana.tar.gz ] || \
		curl https://artifacts.elastic.co/downloads/kibana/kibana-$(ver)-linux-x86_64.tar.gz \
		-o $(pwd)/deploy/kibana.tar.gz
	-tar xzf $(pwd)/deploy/kibana.tar.gz -C $(pwd)/deploy && \
		mv $(pwd)/deploy/kibana-$(ver)-linux-x86_64 $(pwd)/deploy/kibana

start_es: dl_es
	@$(pwd)/deploy/elasticsearch/bin/elasticsearch

start_log: dl_log
	@$(pwd)/deploy/logstash/bin/logstash -f conf/logstash-simple.conf

start_kbn: dl_kbn
	@$(pwd)/deploy/kibana/bin/kibana

start_all: start_es start_log start_kbn

dl_all: dl_es dl_log dl_kbn

clean: 
	@rm -rf $(pwd)/deploy

.PHONY: clean dl_es dl_log dl_kbn dl_all
