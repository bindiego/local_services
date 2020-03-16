pwd := $(shell pwd)
lib := $(shell gsutil ls gs://cloud-profiler/java/cloud-profiler-* | tail -n 1)
threads = 2

build: Main.java
	@javac Main.java

run: build
	@java Main $(threads)

clean:
	@-rm -rf *.class *.tar.gz lib

init:
	@[ -d lib ] || mkdir -p lib
	@gsutil -m cp $(lib) .
	@tar xzf *.tar.gz -C lib

profile: init build
	@java -agentpath:$(pwd)/lib/profiler_java_agent.so=-cprof_service=dingoburn,-cprof_service_version=1.0.0,-cprof_cpu_use_per_thread_timers=true,-cprof_heap_sampling_interval=262144 \
		Main $(threads)

.PHONY: profile clean init
