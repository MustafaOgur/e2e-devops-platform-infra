# Run on the control machine (WSL, Linux or macOS).
# VMs are managed with Vagrant on the Windows side; see README.

SHELL := /bin/bash
.DEFAULT_GOAL := help

ANSIBLE_DIR := ansible
# Ansible ignores ansible.cfg in world-writable directories such as /mnt/c
export ANSIBLE_CONFIG := $(CURDIR)/$(ANSIBLE_DIR)/ansible.cfg

PLAYBOOKS := site.yml k3s.yml kubeconfig.yml

.PHONY: help ping check kubeadm kubeadm-kubeconfig k3s nodes pods

help: ## List available commands
	@grep -E '^[a-zA-Z0-9_-]+:.*## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

ping: ## Test Ansible connectivity to all nodes
	cd $(ANSIBLE_DIR) && ansible all -m ping

check: ## Check playbook syntax
	cd $(ANSIBLE_DIR) && for p in $(PLAYBOOKS); do ansible-playbook "$$p" --syntax-check || exit 1; done

kubeadm: ## Full install with kubeadm, containerd and Cilium
	cd $(ANSIBLE_DIR) && ansible-playbook site.yml

kubeadm-kubeconfig: ## Set up kubeconfig and kubectl for the kubeadm cluster
	cd $(ANSIBLE_DIR) && ansible-playbook kubeconfig.yml

k3s: ## Lightweight install with k3s and Flannel (includes kubeconfig)
	cd $(ANSIBLE_DIR) && ansible-playbook k3s.yml

nodes: ## List nodes
	kubectl get nodes -o wide

pods: ## List all pods
	kubectl get pods -A -o wide
