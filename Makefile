up:
	docker-compose up \
		--detach \
		--build

down:
	docker-compose down \
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

WORKSPACE:=default
workspace:
	terraform workspace select -or-create "$(WORKSPACE)"

plan: workspace
	terraform init \
		&& terraform plan
.PHONY: plan
