CURRENT_DIR := $(shell pwd)

.PHONY: help
help: ## Display help message
	@grep -E '^[0-9a-zA-Z_-]+\.*[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: containerlab
containerlab: ## Deploy ceos lab
	cd ${CURRENT_DIR}/avd; ansible-playbook playbooks/build-containerlab.yml

.PHONY: start
start: ## Deploy ceos lab
	sudo containerlab deploy --debug --topo $(CURRENT_DIR)/avd/intended/containerlab/CLAB_topology.yml --max-workers 10 --timeout 5m --reconfigure

.PHONY: stop
stop: ## Destroy ceos lab
	sudo containerlab destroy --debug --topo $(CURRENT_DIR)/avd/intended/containerlab/CLAB_topology.yml --cleanup

.PHONY: check-lab
check-lab: ## check lab parameters
	sudo containerlab inspect --name AVD

.PHONY: graph-lab
graph-lab: ## check lab parameters
	sudo containerlab graph --topo $(CURRENT_DIR)/avd/intended/containerlab/CLAB_topology.yml

.PHONY: build
build: ## Generate AVD configs
	cd ${CURRENT_DIR}/avd; ansible-playbook playbooks/build.yml

.PHONY: deploy-eapi
deploy-eapi: ## Deploy AVD configs using eAPI
	cd ${CURRENT_DIR}/avd; ansible-playbook playbooks/deploy.yml

.PHONY: deploy-cvp
deploy-cvp: ## Deploy AVD configs using eAPI
	cd ${CURRENT_DIR}/avd; ansible-playbook playbooks/deploy-cvp.yml

.PHONY: test
test: ## Test Topology
	cd ${CURRENT_DIR}/avd; ansible-playbook playbooks/anta.yml

.PHONY: test-api
test-api: ## Test API to device
	curl --user ansible:ansible --data "$(COMMAND)" --insecure https://$(DEVICE):443/command-api