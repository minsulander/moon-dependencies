CPPFLAGS := -I./include -I$(PREFIX)/include -DTOLUA_EXPORTS
LDFLAGS := -L. -L$(PREFIX)/lib
CC = g++

LIB_OBJS = src/lib/tolua_event.o\
	src/lib/tolua_is.o\
	src/lib/tolua_map.o\
	src/lib/tolua_push.o\
	src/lib/tolua_to.o
LIBTARGET = libtolua.dll
IMPLIBTARGET = libtolua.a
STATICLIBTARGET = libtolua.a

BIN_OBJS = src/bin/tolua.o\
	src/bin/toluabind.o

BINTARGET = tolua.exe

all:	$(BINTARGET) $(STATICLIBTARGET)

rebind: src/bin/tolua.pkg $(shell find src/bin/lua/*.lua)
	cd src/bin ; $(MAKE)

#$(LIBTARGET) $(IMPLIBTARGET): $(LIB_OBJS)
#	$(CC) -shared -o $(LIBTARGET) $^ $(LDFLAGS) -llua -lm -Wl,--out-implib,$(IMPLIBTARGET)

$(STATICLIBTARGET): $(LIB_OBJS)
	$(AR) cru $@ $^

$(BINTARGET): $(BIN_OBJS) $(STATICLIBTARGET)
	$(CC) -o $@ $(BIN_OBJS) $(LDFLAGS) $(STATICLIBTARGET) -llua

install: $(STATICLIBTARGET) $(BINTARGET)
	mkdir -p $(PREFIX)/bin $(PREFIX)/lib $(PREFIX)/include
	cp $(BINTARGET) $(PREFIX)/bin/
	cp $(STATICLIBTARGET) $(PREFIX)/lib/
	cp include/*.h $(PREFIX)/include

clean:
	-rm -f *~ *.core $(BINTARGET) $(BINTARGET) $(LIBTARGET) $(IMPLIBTARGET) $(STATICLIBTARGET) $(BIN_OBJS) $(LIB_OBJS)
	cd src/tests ; $(MAKE) clean

distclean: clean

