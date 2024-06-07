# Foosnapper - Automatic filesystem snapshooter

.PHONY: all test clean distclean install sysupdate release tar rpm

CURRENT_VERSION		?= $(shell grep ^VERSION src/foosnapper | awk -F\' '{ print $$2 }')
SYSTEMD_SYSTEM_LOCATION	?= /usr/lib/systemd/system

# Default target is to run tests

all: test

# Check source

test:
	flake8 src/foosnapper
	pycodestyle src/foosnapper
	pylint src/foosnapper

# Delete created files

clean distclean:
	rm -rf foosnapper-*.tar.gz foosnapper-*.src.rpm tmp/

# Install current source to DESTDIR

install:
	mkdir -p $(DESTDIR)/etc/foosnapper/
	cp etc/foosnapper.conf $(DESTDIR)/etc/foosnapper/
	mkdir -p $(DESTDIR)/usr/bin/
	cp src/foosnapper $(DESTDIR)/usr/bin/
	mkdir -p $(DESTDIR)$(SYSTEMD_SYSTEM_LOCATION)/
	cp systemd/foosnapper.service $(DESTDIR)$(SYSTEMD_SYSTEM_LOCATION)/
	cp systemd/foosnapper.timer $(DESTDIR)$(SYSTEMD_SYSTEM_LOCATION)/

# Install current source to local system's root

sysupdate:
	make install DESTDIR=/
	systemctl daemon-reload

# Make new release

release:
	@if [ -z "$(VERSION)" ]; then \
		echo "Usage: make release VERSION=x.xx"; \
		echo; \
		echo "Current: $(CURRENT_VERSION)"; \
		exit 1; \
	fi
	git diff --exit-code
	git diff --cached --exit-code
	sed -i -e "s@^\(VERSION = '\).*@\1$(VERSION)'@" src/foosnapper
	sed -i -e "s@^\(Version:        \).*@\1$(VERSION)@" foosnapper.spec
	git add src/foosnapper foosnapper.spec
	git commit --message="v$(VERSION)"
	git tag "v$(VERSION)"
	@echo
	@echo "== TODO =="
	@echo "git push && git push --tags"
	@echo "GitHub release: https://github.com/FoobarOy/foosnapper/releases/new"

### Build tar/rpm locally

tar: clean
	tar cavf foosnapper-$(CURRENT_VERSION).tar.gz --transform=s,,foosnapper-$(CURRENT_VERSION)/, --show-transformed .gitignore *

rpm: tar
	rpmbuild -ba --define="_topdir $(CURDIR)/tmp" --define="_sourcedir $(CURDIR)" foosnapper.spec
