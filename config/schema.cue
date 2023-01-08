package config

#Config

#Config: {
	cluster: #ClusterConfig
	nodes: [...#NodeConfig]
}

#ClusterConfig: name: string

#NodeConfig: {
	name: =~"node-.+"
	qemu: #QEMUConfig & {_nodeRole: role}
	role: #Role
	ssh:  #SSHConfig & {_nodeName: name}
}

#Role: "controller" | "controller+worker" | "single" | "worker"

#QEMUConfig: {
	_nodeRole: "controller" | "controller+worker" | "single"
	disk:      int & >=2Gi | *2Gi
	memory:    int & >=1Gi | *1Gi
	vcpus:     int & >=1 | *1
} | {
	_nodeRole: "worker"
	disk:      int & >=2Gi | *2Gi
	memory:    int & >=0.5Gi | *0.5Gi
	vcpus:     int & >=1 | *1
}

#SSHConfig: {
	_nodeName: string
	host:      _nodeName
	keyPath:   string | *"~/.ssh/id_rsa"
	proxy: {
		host: string | *"libvirt"
		user: string | *"libvirt"
	}
	user: string | *"node"
}
