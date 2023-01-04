NODE_HOSTNAME := debian
NODE_USERNAME := debian

.PHONY: node
node: node/up node/exec

.PHONY: node/up
node/up: node/up/init node/up/apply node/up/wait

.PHONY: node/up/init
node/up/init: ~/.ssh/id_rsa
	terraform -chdir=node init

~/.ssh/id_rsa:
	ssh-keygen -N '' -f $@

.PHONY: node/up/apply
node/up/apply:
	terraform -chdir=node apply -auto-approve

.PHONY: node/up/wait
node/up/wait:
	while ! ssh -o ConnectTimeout=1 $(NODE_HOSTNAME) true; do sleep 1; done
	ssh $(NODE_HOSTNAME) uptime

.PHONY: node/exec
node/exec:
	@ssh $(NODE_HOSTNAME)

# TODO: node/upgrade, etc...

.PHONY: node/down
node/down:
	terraform -chdir=node apply -auto-approve -destroy

.PHONY: node/clean
node/clean:
	rm -rf node/.terraform node/.terraform.* node/*.tfstate node/*.tfstate.*
