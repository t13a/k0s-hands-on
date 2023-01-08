include *.mk

.PHONY: up
up: node/up cluster/up

.PHONY: down
down: cluster/down node/down

.PHONY: clean
clean: cluster/clean node/clean
