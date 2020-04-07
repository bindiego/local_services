.PHONY: run

build: main.c
	@gcc main.c -lpthread -o ptscan

run: build
	@sudo ./ptscan www.baidu.com
