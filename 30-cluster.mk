CLUSTER_K0SCTL_YAML := $(DEV_HOME)/k0sctl.yaml

CLUSTER_KUBECONFIG := $(DEV_HOME)/.kube/config

.PHONY: cluster/up
cluster/up: $(addprefix cluster/up/,apply kubeconfig wait)

.PHONY: cluster/up/apply
cluster/up/apply: $(CLUSTER_K0SCTL_YAML)
	k0sctl apply --config $<
	mkdir -p $(@D)

.PHONY: cluster/up/kubeconfig
cluster/up/kubeconfig: $(CLUSTER_KUBECONFIG)

$(CLUSTER_KUBECONFIG): $(CLUSTER_K0SCTL_YAML)
	mkdir -p $(@D)
	k0sctl kubeconfig --config $< \
	| yq '.clusters[0].cluster.server |= "https://127.0.0.1:6443"' > $@.tmp
	mv -f $@.tmp $@

$(CLUSTER_K0SCTL_YAML):
	k0sctl init $(NODE_SSH_USERNAME)@$(NODE_DOM) \
	| yq '.spec.hosts[0].role |= "single"' \
	| yq '.spec.hosts[0].ssh.bastion |= { "address": "libvirt", "user": "libvirt" }' > $@.tmp
	mv -f $@.tmp $@

.PHONY: cluster/up/wait
cluster/up/wait:
	while ! kubectl wait --for=condition=Ready=true "node/${NODE_DOM}"; do sleep 1; done
	kubectl get node

# TODO: cluster/upgrade, cluster/down, etc...

.PHONY: cluster/clean
cluster/clean:
	rm -rf $(CLUSTER_K0SCTL_YAML) $(CLUSTER_KUBECONFIG)
