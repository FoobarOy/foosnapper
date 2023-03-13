.PHONY: all test clean distclean install release tar rpm

all: test

test:
	flake8-3 src/foosnapper
	pycodestyle-3 src/foosnapper
	pylint-3 src/foosnapper

clean distclean:
	rm -rf foosnapper-*.tar.gz foosnapper-*.src.rpm tmp/

install:
	mkdir -p $(PREFIX)/etc/foosnapper/
	cp etc/foosnapper.conf $(PREFIX)/etc/foosnapper/
	mkdir -p $(PREFIX)/usr/bin/
	cp src/foosnapper $(PREFIX)/usr/bin/
	mkdir -p $(PREFIX)/usr/lib/systemd/system/
	cp systemd/foosnapper.service $(PREFIX)/usr/lib/systemd/system/
	cp systemd/foosnapper.timer $(PREFIX)/usr/lib/systemd/system/

### Release

release:
	@if [ -z "$(VERSION)" ]; then \
		echo "make release VERSION=x.xx"; \
		exit 1; \
	fi
	git diff --exit-code
	git diff --cached --exit-code
	sed -i -e "s@^\(VERSION = '\).*@\1$(VERSION)'@" src/foosnapper
	sed -i -e "s@^\(Version:        \).*@\1$(VERSION)@" foosnapper.spec
	git add src/foosnapper foosnapper.spec
	git commit --message="v$(VERSION)"
	git tag "v$(VERSION)"

### Build tar/rpm locally

SPEC_VERSION ?= $(lastword $(shell grep ^Version: foosnapper.spec))

tar: clean
	tar cavf foosnapper-$(SPEC_VERSION).tar.gz --transform=s,,foosnapper-$(SPEC_VERSION)/, --show-transformed .gitignore *

rpm: tar
	rpmbuild -ba --define="_topdir $(CURDIR)/tmp" --define="_sourcedir $(CURDIR)" foosnapper.spec
