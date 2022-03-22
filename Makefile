# Managed by terraform-modules/terraform-modules-modulesync

.PHONY: all docs test

all: test

docs:
	@terraform-docs md . > DOC.md

test:
	@echo "Running terraform validate test"
	@terraform validate
	@echo "Running terraform fmt test"
	@terraform fmt -check=true -list=true -diff=true -write=false
	@echo "Running tflint test"
	@tflint
