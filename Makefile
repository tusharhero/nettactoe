PREFIX = /usr

all:
	@echo Run \'make install\' to install NetTacToe.

install:
	@mkdir -p $(DESTDIR)$(PREFIX)/bin
	@cp -p nettactoe $(DESTDIR)$(PREFIX)/bin/nettactoe
	@chmod 755 $(DESTDIR)$(PREFIX)/bin/nettactoe

uninstall:
	@rm -rf $(DESTDIR)$(PREFIX)/bin/nettactoe
