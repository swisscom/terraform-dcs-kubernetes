.PHONY: plan terraform-plan helm-plan hplan

plan: terraform-plan helm-plan

terraform-plan:
	terraform plan

hplan: helm-plan

helm-plan:
	scripts/helm-plan.sh
