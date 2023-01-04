CLUSTER_K0SCTL_YAML := $(DEV_HOME)/k0sctl.yaml
CLUSTER_KUBECONFIG := $(DEV_HOME)/.kube/config

.PHONY: cluster/up
cluster/up: cluster/up/init cluster/up/apply cluster/up/wait

.PHONY: cluster/up/init
cluster/up/init: $(CLUSTER_K0SCTL_YAML)

$(CLUSTER_K0SCTL_YAML):
	k0sctl init $(NODE_USERNAME)@$(NODE_HOSTNAME) \
	| yq '.spec.hosts[0].role |= "single"' \
	| yq '.spec.hosts[0].ssh.bastion |= { "address": "libvirt", "user": "libvirt" }' > $@.tmp
	mv -f $@.tmp $@

.PHONY: cluster/up/apply
cluster/up/apply: $(CLUSTER_K0SCTL_YAML)
	k0sctl apply --config $<
	mkdir -p $(dir $(CLUSTER_KUBECONFIG))
	k0sctl kubeconfig --config $< \
	| yq '.clusters[0].cluster.server |= "https://127.0.0.1:6443"' > $(CLUSTER_KUBECONFIG).tmp
	mv -f $(CLUSTER_KUBECONFIG).tmp $(CLUSTER_KUBECONFIG)

.PHONY: cluster/up/wait
cluster/up/wait:
	while ! kubectl wait --for=condition=Ready=true "node/$(NODE_HOSTNAME)"; do sleep 1; done
	kubectl get node

# TODO: cluster/upgrade, cluster/down, etc...

.PHONY: cluster/clean
cluster/clean:
	rm -rf $(CLUSTER_K0SCTL_YAML) $(CLUSTER_KUBECONFIG)
