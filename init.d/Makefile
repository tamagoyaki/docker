CMD = smbreloader
SRC = $(CMD).c
INITD = ./smbreloaderd


help:
	@echo ""
	@echo "make start  -  service start"
	@echo "make stop   -  service stop"
	@echo "make build  -  compile"
	@echo "make clean"
	@echo ""
start stop: $(CMD)
	$(INITD) $@

build: $(CMD)
$(CMD): $(SRC)
	gcc -o $@ $^

clean:
	$(RM) $(CMD)
