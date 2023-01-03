include *.mk

.PHONY: up
up: node/up cluster/up

.PHONY: down
down: node/down

.PHONY: clean
clean: node/clean clsuter/clean
