#
# Makefile
#
# Version:	$Id$
#

HEADERS	= conf.h conffile.h detail.h dhcp.h event.h features.h hash.h heap.h \
	ident.h libradius.h md4.h md5.h missing.h modcall.h modules.h \
	packet.h rad_assert.h radius.h radiusd.h radpaths.h \
	radutmp.h realms.h sha1.h stats.h sysutmp.h token.h \
	udpfromto.h vmps.h vqp.h base64.h

TARGET := src/include/radpaths.h

src/include/radpaths.h: src/include/build-radpaths-h
	@cd src/include && /bin/sh build-radpaths-h

#
#  Build dynamic headers by substituting various values from autoconf.h, these
#  get installed with the library files, so external programs can tell what
#  the server library was built with.
#

HEADERS_DY = src/include/features.h src/include/missing.h src/include/tls.h

src/include/autoconf.sed: src/include/autoconf.h
	@grep ^#define $< | sed 's,/\*\*/,1,;' | awk '{print "\
	s,#[[:blank:]]*ifdef[[:blank:]]*" $$2 ",#if "$$3 ",g;\
	s,#[[:blank:]]*ifndef[[:blank:]]*" $$2 ",#if !"$$3 ",g;\
	s,defined(" $$2 ")," $$3 ",g;\
	s," $$2 ","$$3 ",g;"}' > $@

src/include/features.h: src/include/features-h src/include/autoconf.h
	@cp $< $@
	@grep "^\#define *WITH_.*" src/include/autoconf.h >> $@

src/include/missing.h: src/include/missing-h src/include/autoconf.sed
	@sed -f src/include/autoconf.sed < $< > $@

src/include/tls.h: src/include/tls-h src/include/autoconf.sed
	@sed -f src/include/autoconf.sed < $< > $@

all: $(HEADERS_DY)

#
#  Installation
#

# Add additional dependecies to the global targets
install: install.src.include
clean: clean.src.include
distclean: distclean.src.include

# define the installation directory
SRC_INCLUDE_DIR := ${R}${includedir}/freeradius

# the local rule depends on the installed headers
install.src.include: $(addprefix ${SRC_INCLUDE_DIR}/,${HEADERS})

# install the headers by re-writing the local files
${SRC_INCLUDE_DIR}/%.h: ${top_srcdir}/src/include/%.h
	@echo INSTALL $(notdir $<)
	@$(INSTALL) -d -m 755 $(dir $@)
	@sed 's/^#include <freeradius-devel/#include <freeradius/' < $< > $@
	@chmod 644 $@

#
#  Cleaning
#
.PHONY: clean.src.include distclean.src.include
clean.src.include:
	@rm -f $(HEADERS_DY)

distclean.src.include: clean.src.include
	@rm -f autoconf.sed
