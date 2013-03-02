OS=$(shell uname -s | tr A-Z a-z | sed -e 's/darwin/mac/' | sed -e 's/mingw32_nt.*/mingw/')
ARCH=$(shell uname -m)
BUILD=build-$(OS)-$(ARCH)
INTERMEDIATE=moon-dependencies-$(OS)-$(ARCH)
ARCHIVE = $(INTERMEDIATE).tar.bz2
DONEFILE = $(INTERMEDIATE)/.depsdone

$(INTERMEDIATE)/.depsdone:
	bash build_$(OS).sh $(ARGS)

archive: $(ARCHIVE)

$(ARCHIVE): $(DONEFILE)
	tar cfj $@ $(INTERMEDIATE)

install: $(DONEFILE)
ifeq ($(PREFIX),)
	@echo "usage: make install PREFIX=/path/to/moon"
else
	@echo "Installing MOON dependencies in $(PREFIX)"
	tar cf - -C $(INTERMEDIATE) . | ( cd $(PREFIX) && tar xf - )
endif

clean:
	rm -rf $(ARCHIVE) $(INTERMEDIATE) *~

distclean: clean
	rm -rf $(BUILD)
