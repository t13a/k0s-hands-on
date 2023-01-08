NODE_NAMES = $(shell yq -r '.spec.hosts[].ssh.address' $(CLUSTER_K0SCTL_OVERRIDE_YAML))

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
	for node_name in $(NODE_NAMES); do while ! ssh -o ConnectTimeout=1 $${node_name} true; do sleep 1; done; ssh $${node_name} uname -a; done

# TODO: node/upgrade, etc...

.PHONY: node/down
node/down:
	terraform -chdir=node apply -auto-approve -destroy

.PHONY: node/clean
node/clean:
	rm -rf node/.terraform node/.terraform.* node/*.tfstate node/*.tfstate.*
