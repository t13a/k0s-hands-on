export DEV_UID ?= $(shell id -u)
export DEV_GID ?= $(shell id -g)
export DEV_HOME ?= dev/home

.PHONY: dev
dev: dev/init dev/up dev/exec

.PHONY: dev/init
dev/init: $(DEV_HOME) .env

$(DEV_HOME):
	mkdir -p $(DEV_HOME)

.env:
	printf "DEV_UID=%s\nDEV_GID=%s\n" $(DEV_UID) $(DEV_GID) > $@.tmp
	mv -f $@.tmp $@

.PHONY: dev/up
dev/up:
	docker-compose up --build -d

.PHONY: dev/exec
dev/exec: dev/exec/dev

.PHONY: dev/exec/dev
dev/exec/dev:
	docker-compose exec dev bash

.PHONY: dev/exec/libvirt
dev/exec/libvirt:
	docker-compose exec libvirt bash

.PHONY: dev/down
dev/down:
	docker-compose down

.PHONY: dev/clean
dev/clean:
	docker-compose down --rmi all -v
	rm -rf $(DEV_HOME) .env
