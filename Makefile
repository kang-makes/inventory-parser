SHELL := /bin/bash

all: check

check: check_hostvars check_group_vars

check_hostvars: prepare_virtualenv
	@for file in inventory/host_vars/*.y*ml; do \
	    echo Testing file $$file...; \
	    poetry run jsonschema host_vars.schema.json -i <(yq -o=json $$file) && echo PASSED; \
	    echo; \
	  done

check_groupvars: prepare_virtualenv
	@for file in inventory/group_vars/*.y*ml; do \
	    echo Testing file $$file...; \
	    poetry run jsonschema group_vars.schema.json -i <(yq -o=json $$file) && echo PASSED; \
	    echo; \
	  done

prepare_virtualenv:
	@poetry install

