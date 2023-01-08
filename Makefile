include *.mk

.PHONY: up
up: node/up cluster/up

.PHONY: down
down: cluster/down node/down

.PHONY: clean
clean: node/clean cluster/clean
