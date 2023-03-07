.PHONY: all test clean distclean install tar rpm foopkg

all: test

test:
	flake8-3 src/foosnapper
	pycodestyle-3 src/foosnapper
	pylint-3 src/foosnapper

clean distclean:
	rm -rf foosnapper-*.tar.gz foosnapper-*.src.rpm foopkg.conf tmp/

install:
	mkdir -p $(PREFIX)/etc/foosnapper/
	cp etc/foosnapper.conf $(PREFIX)/etc/foosnapper/
	mkdir -p $(PREFIX)/usr/bin/
	cp src/foosnapper $(PREFIX)/usr/bin/
	mkdir -p $(PREFIX)/usr/lib/systemd/system/
	cp systemd/foosnapper.service $(PREFIX)/usr/lib/systemd/system/
	cp systemd/foosnapper.timer $(PREFIX)/usr/lib/systemd/system/

VERSION ?= $(lastword $(shell grep ^Version: foosnapper.spec))

tar: clean
	tar cavf foosnapper-$(VERSION).tar.gz --transform=s,,foosnapper-$(VERSION)/, --show-transformed .gitignore *

rpm: tar
	rpmbuild -ba --define="_topdir $(CURDIR)/tmp" --define="_sourcedir $(CURDIR)" foosnapper.spec

foopkg:
	rpmdev-spectool --get-files foosnapper.spec
	echo "[foopkg]" > foopkg.conf
	echo "buildrepo = foo9/foobar-testing" >> foopkg.conf
	foopkg build
