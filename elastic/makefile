pwd := $(shell pwd)
ipaddr := $(shell hostname -I | cut -d ' ' -f 1)
ver := 6.1.3

pre_deploy:
	[ -d $(pwd)/deploy ] || mkdir -p $(pwd)/deploy
	[ -d $(pwd)/data ] || mkdir -p $(pwd)/data/{es,ls,kbn,fb}
	[ -d $(pwd)/data/es/logs ] || mkdir -p $(pwd)/data/es/logs
	[ -d $(pwd)/data/kbn/logs ] || mkdir -p $(pwd)/data/kbn/logs
	[ -d $(pwd)/data/ls/logs ] || mkdir -p $(pwd)/data/ls/logs
	[ -d $(pwd)/data/fb/logs ] || mkdir -p $(pwd)/data/fb/logs
	@-sudo sysctl -w vm.max_map_count=262144

dl_es: pre_deploy
	@[ -f $(pwd)/deploy/elasticsearch.tar.gz ] || \
		curl https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-$(ver).tar.gz \
		--output $(pwd)/deploy/elasticsearch.tar.gz
	-[ -d $(pwd)/deploy/elasticsearch ] || \
		tar xzf $(pwd)/deploy/elasticsearch.tar.gz -C $(pwd)/deploy && \
		mv $(pwd)/deploy/elasticsearch-$(ver) $(pwd)/deploy/elasticsearch

dl_ls: pre_deploy
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

dl_fb: pre_deploy
	@[ -f $(pwd)/deploy/filebeat.tar.gz ] || \
		curl https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-$(ver)-linux-x86_64.tar.gz \
		--output $(pwd)/deploy/filebeat.tar.gz
	-[ -d $(pwd)/deploy/filebeat ] || \
		tar xzf $(pwd)/deploy/filebeat.tar.gz -C $(pwd)/deploy && \
		mv $(pwd)/deploy/filebeat-$(ver)-linux-x86_64 $(pwd)/deploy/filebeat

inst_xpack: dl_es dl_kbn
	@$(pwd)/deploy/elasticsearch/bin/elasticsearch-plugin install x-pack
	@$(pwd)/deploy/kibana/bin/kibana-plugin install x-pack

start_es: dl_es
	@-[ -f $(pwd)/deploy/elasticsearch/config/elasticsearch.yml.bak ] || \
		cp $(pwd)/deploy/elasticsearch/config/elasticsearch.yml \
		$(pwd)/deploy/elasticsearch/config/elasticsearch.yml.bak
	@-cp $(pwd)/deploy/elasticsearch/config/elasticsearch.yml.bak \
		$(pwd)/deploy/elasticsearch/config/elasticsearch.yml
	#@echo 'network.host: _global_' >> \
		#$(pwd)/deploy/elasticsearch/config/elasticsearch.yml
	@$(pwd)/deploy/elasticsearch/bin/elasticsearch -d -p $(pwd)/deploy/es.pid \
		-Ecluster.name=bindigo \
		-Enode.name=tiger \
		-Epath.data=$(pwd)/data/es \
		-Epath.logs=$(pwd)/data/es/logs \
		-Enetwork.host=$(ipaddr)

start_ls: dl_ls
	@-[ -f $(pwd)/conf/logstash-simple.conf ] && rm $(pwd)/conf/logstash-simple.conf
	@-cp $(pwd)/conf/logstash-simple.conf.template \
		$(pwd)/conf/logstash-simple.conf
	@egrep -lRZ "\%ES\%" $(pwd)/conf/*.conf \
		| xargs -0 -l sed -i -e 's/\%ES\%/$(ipaddr)/g'
	@$(pwd)/deploy/logstash/bin/logstash \
		-f $(pwd)/conf/logstash-simple.conf \
		--path.data $(pwd)/data/ls \
		--path.logs $(pwd)/data/ls/logs \
		--config.reload.automatic > /dev/null 2>&1 &

test_ls: dl_ls
	@-[ -f $(pwd)/conf/logstash-simple.conf ] && rm $(pwd)/conf/logstash-simple.conf
	@-cp $(pwd)/conf/logstash-simple.conf.template \
		$(pwd)/conf/logstash-simple.conf
	@egrep -lRZ "\%ES\%" $(pwd)/conf/*.conf \
		| xargs -0 -l sed -i -e 's/\%ES\%/$(ipaddr)/g'
	@$(pwd)/deploy/logstash/bin/logstash \
		-f $(pwd)/conf/logstash-simple.conf  \
		--config.test_and_exit

start_kbn: dl_kbn
	@-[ -f $(pwd)/deploy/kibana/config/kibana.yml.bak ] || \
		cp $(pwd)/deploy/kibana/config/kibana.yml \
		$(pwd)/deploy/kibana/config/kibana.yml.bak
	@-cp $(pwd)/deploy/kibana/config/kibana.yml.bak \
		$(pwd)/deploy/kibana/config/kibana.yml
	@echo 'elasticsearch.url: "http://$(ipaddr):9200"' >> \
		$(pwd)/deploy/kibana/config/kibana.yml
	@$(pwd)/deploy/kibana/bin/kibana \
		-p 5601 \
		--pid.file=$(pwd)/deploy/kbn.pid \
		--path.data=$(pwd)/data/kbn \
		--host $(ipaddr) \
		-e http://$(ipaddr):9200 \
		-l $(pwd)/data/kbn/logs/kbn.log > /dev/null 2>&1 &

start_fb: dl_fb
	@-[ -f $(pwd)/conf/filebeat.yml ] && rm $(pwd)/conf/filebeat.yml
	@-cp $(pwd)/conf/filebeat.yml.template \
		$(pwd)/conf/filebeat.yml && \
		chmod go-w $(pwd)/conf/filebeat.yml
	@egrep -lRZ "\%LS\%" $(pwd)/conf/*.yml \
		| xargs -0 -l sed -i -e 's/\%LS\%/$(ipaddr)/g'
	@egrep -lRZ "\%PWD\%" $(pwd)/conf/*.yml \
		| xargs -0 -l sed -i -e 's/\%PWD\%/\/home\/ptmind\/workspace\/local_services\/elastic/g'
	@$(pwd)/deploy/filebeat/filebeat \
		--path.data $(pwd)/data/fb \
		--path.logs $(pwd)/data/fb/logs \
		-d "publish" \
		-c $(pwd)/conf/filebeat.yml > /dev/null 2>&1 &

stop_es:
	-$(pwd)/bin/stop_service.sh elasticsearch 
	@-rm $(pwd)/deploy/es.pid

stop_ls:
	-$(pwd)/bin/stop_service.sh logstash

stop_kbn:
	-$(pwd)/bin/stop_service.sh kibana
	@-rm $(pwd)/deploy/kbn.pid

stop_fb:
	-$(pwd)/bin/stop_service.sh filebeat

clean: stop_kbn stop_ls stop_es stop_fb
	@rm -rf $(pwd)/deploy

.PHONY: clean dl_es dl_ls dl_kbn dl_all
