RUN_TERRAFORM = docker-compose -f infra/docker-compose.yml run --rm terraform
IAM_USER = shun198
DURATION = 12h

vault:
	aws-vault exec $(IAM_USER) --duration=$(DURATION)

init:
	$(RUN_TERRAFORM) init

fmt:
	$(RUN_TERRAFORM) fmt

validate:
	$(RUN_TERRAFORM) validate

show:
	$(RUN_TERRAFORM) show

apply:
	$(RUN_TERRAFORM) apply -auto-approve

graph:
	$(RUN_TERRAFORM) graph | dot -Tsvg > graph.svg

destroy:
	$(RUN_TERRAFORM) destroy
