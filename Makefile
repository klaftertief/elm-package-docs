.PHONY: install help all publish package-docs all-packages new-packages

JQ_VERSION := 1.5
OS := $(shell uname)

DOWNLOAD_DIR = dist

ELM_PACKAGE_URL = http://package.elm-lang.org

INSTALL_TARGETS := bin bin/jq

PACKAGE_DOCS_TARGETS = $(shell <$(DOWNLOAD_DIR)/all-packages.json bin/jq -r '.[] | "$(DOWNLOAD_DIR)/packages/" + .name + "/" + .versions[0] + "/documentation.json"')

ifeq ($(OS),Darwin)
	JQ_URL := "https://github.com/stedolan/jq/releases/download/jq-${JQ_VERSION}/jq-osx-amd64"
else
	JQ_URL := "https://github.com/stedolan/jq/releases/download/jq-${JQ_VERSION}/jq-linux64"
endif


install: $(INSTALL_TARGETS) ## Installs prerequisites and generates file/folder structure

help: ## Prints a help guide
	@echo "Available tasks:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

all: all-packages new-packages package-docs ## Downloads everything

publish: all ## Downloads updated packages, makes a new commit int the `gh-pages` branch and pushes it to GitHub
	(cd $(DOWNLOAD_DIR); git commit -am "Update dosumentation"; git push origin gh-pages)

package-docs: all-packages
	@$(MAKE) $(PACKAGE_DOCS_TARGETS)

%-packages:
	curl $(ELM_PACKAGE_URL)/$@ -o $(DOWNLOAD_DIR)/$@.json -f --retry 2 --create-dirs

$(DOWNLOAD_DIR)/packages/%/documentation.json:
	curl $(ELM_PACKAGE_URL)/$(subst $(DOWNLOAD_DIR)/,,$@) -o $@ -f --retry 2 --create-dirs -L

bin:
	mkdir -p $@

bin/jq: bin
	curl ${JQ_URL} -o bin/jq -f --retry 2 --create-dirs -L
	chmod +x bin/jq
