LUA_PLATFORM = ansi
LUA_VERSION = 5.2.3
LUA_DIR = lua-$(LUA_VERSION)
LUA_SRC_DIR = $(LUA_DIR)/src

PREFIX = /usr/local
BINDIR = $(PREFIX)/bin
MANDIR = $(PREFIX)/man
INFODIR = $(PREFIX)/info
LOCAL_ROOT = /usr/share/polipo/www
DISK_CACHE_ROOT = /var/cache/polipo
SRCDIR = src
OBJDIR = obj
VENDORDIR = vendor

BUILD_LUA = make clean ansi CFLAGS='-ULUA_DL_DLOPEN'

# To compile with Unix CC:

# CDEBUGFLAGS=-O

# To compile with GCC:

# CC = gcc
CDEBUGFLAGS = -Os -ggdb -Wall -fno-strict-aliasing \
  -I$(LUA_SRC_DIR)

LDFLAGS = $(LUA_SRC_DIR)/liblua.a
# To compile on a pure POSIX system:

# CC = c89
# CC = c99
# CDEBUGFLAGS=-O

# To compile with icc 7, you need -restrict.  (Their bug.)

# CC=icc
# CDEBUGFLAGS = -O -restrict

# On System V (Solaris, HP/UX) you need the following:

# PLATFORM_DEFINES = -DSVR4

# On Solaris, you need the following:

# LDLIBS = -lsocket -lnsl -lresolv

# On mingw, you need

# EXE=.exe
# LDLIBS = -lws2_32

FILE_DEFINES = -DLOCAL_ROOT=\"$(LOCAL_ROOT)/\" \
               -DDISK_CACHE_ROOT=\"$(DISK_CACHE_ROOT)/\"

# You may optionally also add any of the following to DEFINES:
#
#  -DNO_DISK_CACHE to compile out the on-disk cache and local web server;
#  -DNO_IPv6 to avoid using the RFC 3493 API and stick to stock
#      Berkeley sockets;
#  -DHAVE_IPv6 to force the use of the RFC 3493 API on systems other
#      than GNU/Linux and BSD (let me know if it works);
#  -DNO_FANCY_RESOLVER to compile out the asynchronous name resolution
#      code;
#  -DNO_STANDARD_RESOLVER to compile out the code that falls back to
#      gethostbyname/getaddrinfo when DNS requests fail;
#  -DNO_TUNNEL to compile out the code that handles CONNECT requests;
#  -DNO_SOCKS to compile out the SOCKS gateway code.
#  -DNO_FORBIDDEN to compile out the all of the forbidden URL code
#  -DNO_REDIRECTOR to compile out the Squid-style redirector code
#  -DNO_SYSLOG to compile out logging to syslog

DEFINES = $(FILE_DEFINES) $(PLATFORM_DEFINES)

CFLAGS = $(MD5INCLUDES) $(CDEBUGFLAGS) $(DEFINES) $(EXTRA_DEFINES)

SRCS := $(shell find $(SRCDIR) -name '*.c')
OBJS := $(patsubst $(SRCDIR)/%.c,$(OBJDIR)/%.o,$(SRCS))
VENDOR_OBJS = $(VENDORDIR)/fts/ftsimport.o $(VENDORDIR)/md5/md5import.o

polipo$(EXE): lua $(OBJS) $(VENDOR_OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o polipo$(EXE) $(OBJS) $(VENDOR_OBJS) $(MD5LIBS) $(LDLIBS)

$(OBJS): | obj

obj:
	@mkdir -p $@

$(OBJDIR)/%.o : $(SRCDIR)/%.c
	@echo $(SRCS)
	@echo $<
	@$(CC) $(CFLAGS) -c $< -o $@ $(MD5LIBS)

ftsimport.o: $(VENDORDIR)/fts/%.c

md5import.o: $(VENDORDIR)/md5/%.c

.PHONY: all install install.binary install.man

all: polipo$(EXE) polipo.info html/index.html localindex.html

install: install.binary install.man

install.binary: all
	mkdir -p $(TARGET)$(BINDIR)
	mkdir -p $(TARGET)$(LOCAL_ROOT)
	mkdir -p $(TARGET)$(LOCAL_ROOT)/doc
	rm -f $(TARGET)$(BINDIR)/polipo
	cp -f polipo $(TARGET)$(BINDIR)/
	cp -f html/* $(TARGET)$(LOCAL_ROOT)/doc
	cp -f localindex.html $(TARGET)$(LOCAL_ROOT)/index.html

install.man: all
	mkdir -p $(TARGET)$(MANDIR)/man1
	mkdir -p $(TARGET)$(INFODIR)
	cp -f polipo.man $(TARGET)$(MANDIR)/man1/polipo.1
	cp polipo.info $(TARGET)$(INFODIR)/
	install-info --info-dir=$(TARGET)$(INFODIR) polipo.info


polipo.info: polipo.texi
	makeinfo polipo.texi

html/index.html: polipo.texi
	mkdir -p html
	makeinfo --html -o html polipo.texi

polipo.html: polipo.texi
	makeinfo --html --no-split --no-headers -o polipo.html polipo.texi

polipo.pdf: polipo.texi
	texi2pdf polipo.texi

polipo.ps.gz: polipo.ps
	gzip -c polipo.ps > polipo.ps.gz

polipo.ps: polipo.dvi
	dvips -Pwww -o polipo.ps polipo.dvi

polipo.dvi: polipo.texi
	texi2dvi polipo.texi

polipo.man.html: polipo.man
	rman -f html polipo.man > polipo.man.html

.PHONY: lua lua_clean clean

lua:
	cd $(LUA_DIR) && $(MAKE) $(LUA_PLATFORM)

lua_clean:
	cd $(LUA_DIR) && $(MAKE) clean

clean: lua_clean
	-rm -f polipo$(EXE) $(OBJDIR)/*.o *~ core TAGS gmon.out
	-rm -f polipo.cp polipo.fn polipo.log polipo.vr
	-rm -f polipo.cps polipo.info* polipo.pg polipo.toc polipo.vrs
	-rm -f polipo.aux polipo.dvi polipo.ky polipo.ps polipo.tp
	-rm -f polipo.dvi polipo.ps polipo.ps.gz polipo.pdf polipo.html
	-rm -rf ./html/
	-rm -f polipo.man.html
