export NODE_DOM := debian
NODE_DOM_MEMORY := 1024
NODE_DOM_VCPUS := 1
NODE_DOM_OS_VARIANT := debian11

NODE_NET := default
NODE_NET_ADDRESS = $(shell net-address $(NODE_DOM))

NODE_POOL := $(NODE_DOM)
NODE_POOL_DIR := /var/lib/libvirt/images/$(NODE_POOL)

NODE_VOL_BOOT := $(NODE_DOM)-boot.qcow2
NODE_VOL_BOOT_QCOW2_URL := https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-genericcloud-amd64.qcow2
NODE_VOL_BOOT_QCOW2 := $(DEV_HOME)/$(notdir $(NODE_VOL_BOOT_QCOW2_URL))
NODE_VOL_BOOT_CAPACITY := $(shell expr 16 \* 1024 \* 1024 \* 1024)

NODE_VOL_SEED := $(NODE_DOM)-seed.iso
NODE_VOL_SEED_DIR := $(DEV_HOME)/$(NODE_DOM)-seed
NODE_VOL_SEED_ISO := $(NODE_VOL_SEED_DIR)/$(NODE_DOM)-seed.iso

NODE_SSH_USERNAME = $(shell ssh $(NODE_DOM) id -un)
export NODE_SSH_PUBLIC_KEY_FILE := $(DEV_HOME)/.ssh/id_rsa.pub

.PHONY: node/up
node/up: $(addprefix node/up/,pool vol dom wait)

.PHONY: node/up/pool
node/up/pool:
	is-pool $(NODE_POOL) --all --persistent || virsh pool-define-as $(NODE_POOL) dir --target $(NODE_POOL_DIR)
	is-pool $(NODE_POOL) --all --autostart || virsh pool-autostart $(NODE_POOL)
	is-pool $(NODE_POOL) || virsh pool-build $(NODE_POOL)
	is-pool $(NODE_POOL) || virsh pool-start $(NODE_POOL)

.PHONY: node/up/vol
node/up/vol: $(addprefix node/up/vol/,boot seed)

.PHONY: node/up/vol/boot
node/up/vol/boot: $(NODE_VOL_BOOT_QCOW2)
	[ $$(vol-capacity $(NODE_VOL_BOOT) $(NODE_POOL)) -ge 0 ] || virsh vol-create-as $(NODE_POOL) $(NODE_VOL_BOOT) 0
	[ $$(vol-capacity $(NODE_VOL_BOOT) $(NODE_POOL)) -gt 0 ] || virsh vol-upload $(NODE_VOL_BOOT) $(NODE_VOL_BOOT_QCOW2) --pool $(NODE_POOL)
	[ $$(vol-capacity $(NODE_VOL_BOOT) $(NODE_POOL)) -ge $(NODE_VOL_BOOT_CAPACITY) ] || virsh vol-resize $(NODE_VOL_BOOT) $(NODE_VOL_BOOT_CAPACITY) --pool $(NODE_POOL)

$(NODE_VOL_BOOT_QCOW2):
	curl -sSLo $@.tmp $(NODE_VOL_BOOT_QCOW2_URL)
	mv -f $@.tmp $@

.PHONY: node/up/vol/seed
node/up/vol/seed: $(NODE_VOL_SEED_ISO)
	[ $$(vol-capacity $(NODE_VOL_SEED) $(NODE_POOL)) -ge 0 ] || virsh vol-create-as $(NODE_POOL) $(NODE_VOL_SEED) 0
	[ $$(vol-capacity $(NODE_VOL_SEED) $(NODE_POOL)) -gt 0 ] || virsh vol-upload $(NODE_VOL_SEED) $(NODE_VOL_SEED_ISO) --pool $(NODE_POOL)

$(NODE_VOL_SEED_ISO): $(NODE_SSH_PUBLIC_KEY_FILE)
	mkdir -p $(NODE_VOL_SEED_DIR)
	eval "$$(printf 'cat << EOF\n%s\nEOF\n' "$$(cat node/templates/meta-data.template)")" > $(NODE_VOL_SEED_DIR)/meta-data
	eval "$$(printf 'cat << EOF\n%s\nEOF\n' "$$(cat node/templates/user-data.template)")" > $(NODE_VOL_SEED_DIR)/user-data
	mkisofs --output $@.tmp -volid cidata -joliet -rock $(NODE_VOL_SEED_DIR)/meta-data $(NODE_VOL_SEED_DIR)/user-data
	mv -f $@.tmp $@

$(NODE_SSH_PUBLIC_KEY_FILE):
	ssh-keygen -N '' -f $(patsubst %.pub,%,$@)

.PHONY: node/up/dom
node/up/dom:
	is-dom $(NODE_DOM) --all --persistent || virt-install \
		--name "${NODE_DOM}" \
		--memory "${NODE_DOM_MEMORY}" \
		--vcpus "${NODE_DOM_VCPUS}" \
		--cpu host \
		--import \
		--boot hd \
		--os-variant "${NODE_DOM_OS_VARIANT}" \
		--disk "vol=${NODE_POOL}/${NODE_VOL_BOOT},format=qcow2" \
		--disk "vol=${NODE_POOL}/${NODE_VOL_SEED},format=raw" \
		--network "network=${NODE_NET}" \
		--graphics none \
		--autoconsole none \
		--autostart \
		--print-xml | virsh define /dev/stdin
	is-dom $(NODE_DOM) || virsh start $(NODE_DOM)

.PHONY: node/up/wait
node/up/wait:
	while ! ssh -o ConnectTimeout=1 $(NODE_DOM) true; do sleep 1; done
	ssh $(NODE_DOM) uptime

.PHONY: node/exec
node/exec:
	@ssh $(NODE_DOM)

.PHONY: node/console
node/console:
	@virsh console $(NODE_DOM)

# TODO: node/upgrade, etc...

.PHONY: node/down
node/down:
	is-dom $(NODE_DOM) && virsh shutdown $(NODE_DOM) || true
	is-dom $(NODE_DOM) --all --persistent && virsh undefine $(NODE_DOM) || true

.PHONY: node/clean
node/clean:
	vol-capacity $(NODE_VOL_BOOT) $(NODE_POOL) && virsh vol-delete $(NODE_VOL_BOOT) $(NODE_POOL) || true
	vol-capacity $(NODE_VOL_SEED) $(NODE_POOL) && virsh vol-delete $(NODE_VOL_SEED) $(NODE_POOL) || true
	rm -rf $(NODE_VOL_SEED_DIR)
