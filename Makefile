VERSION := $(shell cat VERSION)
TAG := v$(VERSION)

.PHONY: version check-clean tag push-tag
version:
	@echo $(VERSION)

check-clean:
	@git diff --quiet || (echo "Commit your changes first"; exit 1)

tag: check-clean
	@git tag -a $(TAG) -m "Release $(TAG)"
	@echo "Created tag $(TAG)"

push-tag:
	@git push origin $(TAG)
