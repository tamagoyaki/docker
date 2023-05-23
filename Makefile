# samba's case for example
DAEMON = smbreloader
NAME = samba
DOCKERFILE = dockerfile
IMAGE= $(NAME)-i
CONTAINER = $(NAME)-c
RESTART = --restart always
PORT = -p 445:445/tcp -p 137:137/udp -p 138:138/udp

help:
	@echo ''
	@echo '  USAGE'
	@echo ''
	@echo '    make $(IMAGE) - create an image'
	@echo '    make $(CONTAINER) - create a container'
	@echo '    make status -  status of container'
	@echo '    make start  -  start a container'
	@echo '    make stop   -  stop a container'
	@echo '    make bash   -  connect to bash on container'
	@echo '    make attach -  attach to main process on container'
	@echo ''

# build
$(IMAGE): $(DAEMON)
	docker build -f $(DOCKERFILE)  -t $(IMAGE) .

# run
$(CONTAINER):
	docker run --name $(CONTAINER) -it -d $(RESTART) $(PORT) $(IMAGE)

# play with container
start:
	docker start $(CONTAINER)
stop:
	docker stop $(CONTAINER)
status:
	docker ps -a
attach:
	docker attach $(CONTAINER)
bash:
	docker exec -it $(CONTAINER) /bin/bash

# build some utils
$(DAEMON):
	@cd init.d; make -s $@
