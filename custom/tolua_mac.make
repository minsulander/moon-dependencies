CPPFLAGS = -arch i386 -arch ppc -I./include -I$(PREFIX)/include
LDFLAGS = -arch i386 -arch ppc -L. -L$(PREFIX)/lib
CC = g++

LIB_OBJS = src/lib/tolua_event.o\
	src/lib/tolua_is.o\
	src/lib/tolua_map.o\
	src/lib/tolua_push.o\
	src/lib/tolua_to.o
LIBTARGET = libtolua.dylib

BIN_OBJS = src/bin/tolua.o\
	src/bin/toluabind.o

BINTARGET = tolua

all:	$(BINTARGET) $(LIBTARGET)

rebind: src/bin/tolua.pkg $(shell find src/bin/lua/*.lua)
	cd src/bin ; $(MAKE)

$(LIBTARGET): $(LIB_OBJS)
	$(CC) -dynamiclib -o $@ $^ $(LDFLAGS) -llua -lm

$(BINTARGET): $(BIN_OBJS) $(LIBTARGET)
	$(CC) -o $@ $(BIN_OBJS) $(LDFLAGS) -ltolua -llua -lm

install: $(LIBTARGET) $(BINTARGET)  
	cp $(BINTARGET) $(PREFIX)/bin/
	cp $(LIBTARGET) $(PREFIX)/lib/
	cp include/*.h $(PREFIX)/include

clean:
	-rm *~ *.core $(BINTARGET) $(BINTARGET) $(LIBTARGET) $(BIN_OBJS) $(LIB_OBJS)
	cd src/tests ; $(MAKE) clean

distclean: clean

