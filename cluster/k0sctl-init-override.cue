package cluster

import (
	"github.com/t13a/k0s-hands-on/config"
)

k0sctl: init: override: {
	metadata: name: config.cluster.name
	spec: {
		hosts: [
			for node in config.nodes {
				role: node.role
				ssh: {
					address: node.ssh.host
					keyPath: node.ssh.keyPath
					user:    node.ssh.user
					bastion: {
						address: node.ssh.proxy.host
						user:    node.ssh.proxy.user
					}
				}
			},
		]
	}
}
