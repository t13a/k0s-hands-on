CLUSTER_K0SCTL_YAML := $(DEV_HOME)/k0sctl.yaml
CLUSTER_KUBECONFIG := $(DEV_HOME)/.kube/config
CLUSTER_NODES = $(shell print-config-as-yaml | yq -r '.nodes[]|select(.role != "controller").name')

.PHONY: cluster/up
cluster/up: cluster/up/init cluster/up/apply cluster/up/wait

.PHONY: cluster/up/init
cluster/up/init: $(CLUSTER_K0SCTL_YAML)

$(CLUSTER_K0SCTL_YAML):
	(k0sctl init && echo '---' && cue export github.com/t13a/k0s-hands-on/cluster -e k0sctl.init.override) | yq -P ea '. as $$item ireduce({}; . * $$item)' > $@.tmp
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
	while ! kubectl wait --for=condition=Ready=true $(addprefix node/,$(CLUSTER_NODES)); do sleep 1; done
	kubectl get node

.PHONY: cluster/down
cluster/down: $(CLUSTER_K0SCTL_YAML)
	k0sctl reset --config $< --force

# TODO: cluster/upgrade, etc...

.PHONY: cluster/clean
cluster/clean:
	rm -rf $(CLUSTER_K0SCTL_YAML) $(CLUSTER_KUBECONFIG)
