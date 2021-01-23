SCRIPTS=./bin/installer \
src/plugins/file.sh \
src/plugins/git.sh \
src/plugins/local.sh \
src/plugins/svn.sh \
src/plugins/symlink.sh \
src/plugins/tar.sh \
src/plugins/zip.sh \
src/mulle-domain-archive.sh \
src/mulle-domain-commands.sh \
src/mulle-domain-curl.sh \
src/mulle-domain-git.sh \
src/mulle-domain-operation.sh \
src/mulle-domain-plugin.sh \
src/mulle-domain-source.sh \
src/mulle-domain-url.sh

CHECKSTAMPS=$(SCRIPTS:.sh=.chk)

#
# catch some more glaring problems, the rest is done with sublime
#
SHELLFLAGS=-x -e SC2016,SC2034,SC2086,SC2164,SC2166,SC2006,SC1091,SC2039,SC2181,SC2059,SC2196,SC2197 -s sh

.PHONY: all
.PHONY: clean
.PHONY: shellcheck_check

%.chk:	%.sh
	- shellcheck $(SHELLFLAGS) $<
	(shellcheck -f json $(SHELLFLAGS) $< | jq '.[].level' | grep -w error > /dev/null ) && exit 1 || touch $@

all:	$(CHECKSTAMPS) mulle-domain.chk shellcheck_check jq_check

mulle-domain.chk:	mulle-domain
	- shellcheck $(SHELLFLAGS) $<
	(shellcheck -f json $(SHELLFLAGS) $< | jq '.[].level' | grep -w error > /dev/null ) && exit 1 || touch $@

installer:
	@ ./bin/installer

clean:
	@- rm src/*.chk
	@- rm src/plugins/*.chk

shellcheck_check:
	which shellcheck || brew install shellcheck

jq_check:
	which shellcheck || brew install shellcheck
