prefix = /usr
bindir = $(prefix)/bin
sharedir = $(prefix)/share
mydir = $(sharedir)/lyx2rfc

all: 

clean:
	rm -f $(DESTDIR)$(bindir)/lyx2rfc
	rm -rf $(DESTDIR)$(mydir)

install: all
	install src/lyx2rfc $(DESTDIR)$(bindir)
	install -d $(DESTDIR)$(mydir)
	install -m 0444 data/* $(DESTDIR)$(mydir)
