MAKEFLAGS += --no-print-directory

UNAME := $(shell uname -s)
SCRIPT_DIR := $(shell sed "s@$$HOME@~@" <<<$$(pwd))

.PHONY: all
all: $(TARGETS)
	@printf "\033[1m%s\033[0m\n" "Please specify additional targets"

.PHONY: help
help: ## Show this help.
	@echo "Please use \`make <target>' where <target> is one of"
	@grep '^[a-zA-Z]' $(MAKEFILE_LIST) | \
    sort | \
    awk -F ':.*?## ' 'NF==2 {printf "\033[36m  %-26s\033[0m %s\n", $$1, $$2}'

.list-targets:
	@LC_ALL=C $(MAKE) -pRrq -f $(firstword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/(^|\n)# Files(\n|$$)/,/(^|\n)# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort

.PHONY: list
list: ## List public targets
	@LC_ALL=C $(MAKE) .list-targets | grep -E -v -e '^[^[:alnum:]]' -e '^$@$$' | xargs -n3 printf "%-26s%-26s%-26s%s\n"

.PHONY: debug
debug: ## Debug
	@printf "\033[4mShowing Vars\033[0m\n%s\t= %s\n" "SCRIPT_DIR" "$(SCRIPT_DIR)"

.PHONY: build
build: ## Build docker image
	@docker/bin/build.sh

.PHONY: run
run: ## Run docker image
	@docker/bin/run.sh
