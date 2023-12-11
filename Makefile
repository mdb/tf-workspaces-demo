up:
	TERRAFORM_VERSION=$(shell cat .terraform-version) docker compose up \
		--detach \
		--build \
		--wait

start-localstack:
	docker compose up localstack \
		--detach \
		--build \
		--wait

down:
	TERRAFORM_VERSION=$(shell cat .terraform-version) docker compose down \
		--remove-orphans
.PHONY: down

bootstrap: tfenv
	# create tf-workspaces-demo S3 TF state bucket in localstack
	cd bootstrap \
		&& terraform init \
		&& terraform plan \
		&& terraform apply \
			-auto-approve
.PHONY: bootstrap

tfenv:
	TFENV_ARCH=amd64 tfenv install v$(shell cat .terraform-version)
.PHONY: tfenv

init: tfenv
	terraform init
.PHONY: init

WORKSPACE:=default
workspace: init
	terraform workspace select -or-create "$(WORKSPACE)"

plan: workspace
	terraform plan \
		-out "$(WORKSPACE).plan"
.PHONY: plan

PLAN:=$(WORKSPACE).plan
apply: workspace
	terraform apply "$(PLAN)"
.PHONY: plan

clean:
	rm -rf bootstrap/.terraform || true
	rm -rf bootstrap/*tfstate* || true
	rm -rf .terraform || true
	rm -rf localstack-data || true
.PHONY: clean
