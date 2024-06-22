GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
WHITE  := $(shell tput -Txterm setaf 7)
CYAN   := $(shell tput -Txterm setaf 6)
RESET  := $(shell tput -Txterm sgr0)

all: help

## LXD VM Operations
create-ip-profiles: ## Create custom LXD profiles for static IP addresses
	@echo "Creating IP profile for ka01"
	-@lxc profile copy default ka01-static
	-@lxc profile device set ka01-static eth0 ipv4.address=10.196.3.10
	@echo "Creating IP profile for ka02"
	-@lxc profile copy default ka02-static
	-@lxc profile device set ka02-static eth0 ipv4.address=10.196.3.20

delete-ip-profiles: ## Delete custom LXD profiles for static IP addresses
	@echo "Deleting IP profiles"
	-@lxc profile delete ka01-static
	-@lxc profile delete ka02-static

deploy-vms: create-ip-profiles ## Deploy the LXD VMs
	@echo "Deploying VMs"
	@lxc launch ubuntu:22.04 ka01 --vm -c limits.cpu=2 -c limits.memory=4GB -p ka01-static --config=user.user-data="$$(cat cloud-init/user-data)"
	@lxc launch ubuntu:22.04 ka02 --vm -c limits.cpu=2 -c limits.memory=4GB -p ka02-static --config=user.user-data="$$(cat cloud-init/user-data)"
	@echo "Waiting for SSH to be available on ka01"
	@while ! nc -zv ka01 22; do sleep 1; done
	@echo "SSH is now available on ka01"
	@echo "Waiting for SSH to be available on ka02"
	@while ! nc -zv ka02 22; do sleep 1; done
	@echo "SSH is now available on ka02"

destroy-vms: ## Destroy the LXD VMs
	@echo "Destroying VMs"
	-@lxc stop ka01 ka02
	-@lxc delete ka01 ka02

reset-vms: destroy-vms delete-ip-profiles create-ip-profiles deploy-vms ## Delete and recreate all LXD objects for the VMs

## Ansible Operations
ansible-ping-host: ## Execute an ansible ping against the host
	@ansible -b -K -i ansible/inventory.yaml -m ping lxd_host

ansible-ping-vms: ## Execute an ansible ping against the LXD VMs
	@ansible -b -i ansible/inventory.yaml -m ping lxd_vms

ansible-host-prep: ## Prepare the host operating system
	@ansible-playbook -b -K -i ansible/inventory.yaml ansible/host-prep.yaml

ansible-docker-vm-install: ## Install docker and start a registry on each VM
	@ansible-playbook -b -i ansible/inventory.yaml ansible/docker.yaml

ansible-keepalived-apt: ## Install keepalived from apt repos
	@ansible-playbook -b -i ansible/inventory.yaml ansible/keepalived.yaml

ansible-keepalived-src: ## Install keepalived from source
	@ansible-playbook -b -i ansible/inventory.yaml -e install_method=source ansible/keepalived.yaml

ansible-vm-prep: ansible-docker-vm-install ansible-install-keepalived ## Install docker and keepalived

## Complete Build
complete-build: reset-vms ansible-docker-vm-install ansible-keepalived-apt ## Recreate VMs and then deploy docker and keepalived

## Help
help: ## Show this help.
	@echo ''
	@echo 'Keepalived Environment Setup'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} { \
		if (/^[a-zA-Z_-]+:.*?##.*$$/) {printf "    ${YELLOW}%-30s${GREEN}%s${RESET}\n", $$1, $$2} \
		else if (/^## .*$$/) {printf "  ${CYAN}%s${RESET}\n", substr($$1,4)} \
		}' $(MAKEFILE_LIST)