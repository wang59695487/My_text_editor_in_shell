PREFIX = ${HOME}

all: myed

myed: myed.sh
	cat myed.sh > myed
	chmod +x myed
	
install:
	mkdir -p $(PREFIX)/bin
	mv myed $(PREFIX)/bin

uninstall:
	rm -rf $(PREFIX)/bin/myed 
