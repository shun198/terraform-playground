RUN_TERRAFORM = docker-compose -f infra/docker-compose.yml run --rm terraform

init:
	$(RUN_TERRAFORM) init
	-@ $(RUN_TERRAFORM) workspace new prd
	-@ $(RUN_TERRAFORM) workspace new stg
	-@ $(RUN_TERRAFORM) workspace new dev

workspace:
	$(RUN_TERRAFORM) workspace list

fmt:
	$(RUN_TERRAFORM) fmt

validate:
	$(RUN_TERRAFORM) validate

show:
	$(RUN_TERRAFORM) show

plan:
	$(RUN_TERRAFORM) plan

apply:
	$(RUN_TERRAFORM) apply -auto-approve

graph:
	$(RUN_TERRAFORM) graph | dot -Tsvg > graph.svg

destroy:
	$(RUN_TERRAFORM) destroy
