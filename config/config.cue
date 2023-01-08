package config

cluster: name: "k0s-hands-on"
nodes: [
	{name: "node-1", role: "controller"},
	{name: "node-2", role: "worker", qemu: {disk: 8Gi}},
	{name: "node-3", role: "worker", qemu: {disk: 8Gi}},
]
