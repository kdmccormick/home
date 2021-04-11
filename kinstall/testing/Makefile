.PHONY: build run

build:
	docker build . --tag kdmccormick96/kinstall

run: build
	docker run -it kdmccormick96/kinstall /bin/bash
