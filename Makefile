# canna's case for example
NAME = canna
DOCKERFILE = dockerfile
IMAGE= $(NAME)-i
CONTAINER = $(NAME)-c
RESTART = --restart always
#PORT = -p 22:22/tcp

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
	@echo ''
	@echo '  See IMPORTANT section in dockerfile to setup the cannaserver'
	@echo '  and the client'
	@echo ''

# build
BINSRC = binsrc
TXTDIC = txtdic
$(IMAGE): $(BINSRC) $(TXTDIC)
	DOCKER_BUILDKIT=1 docker build -f $(DOCKERFILE)  -t $(IMAGE) .

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
#
# canna-c's main process is /bin/bash. see wrapper.sh on dockerfile.
#
bash attach:
	docker attach $(CONTAINER)


#
# cannaserver ip
#
#   This also work
#
#     export CANNAHOST=172.17.0.2
#
CONTAINERIP = 172.17.0.2



#
# skkaplha dictionary for cannaserver
#
#   http://hp.vector.co.jp/authors/VA013241/editor/canna-alphabetdic.html
#
#   REQUIREMENT
#
#     canna
#     GNU Make
#     Jcode  -  do 'apt-get install libjcode-pm-perl' on ubuntu 22.04
#
SKKALPBZ2 = canna-alphabetdic-20040210.tar.bz2
SKKALPDIR = $(SKKALPBZ2:.tar.bz2=)
SKKALPCTD = $(SKKALPDIR)/skkalpha.ctd
JCODE = /usr/share/perl5/Jcode.pm
skkalpha: $(SKKALPCTD)
#	mkdic -cs $(CONTAINERIP) $@
#	addwords -cs $(CONTAINERIP) $@ < $(SKKALPCTD)
$(SKKALPCTD): $(SKKALPBZ2) $(JCODE)
	tar xjvf $<
	cd $(SKKALPBZ2:.tar.bz2=); make
$(SKKALPBZ2):
	wget http://hp.vector.co.jp/authors/VA013241/editor/$(SKKALPBZ2)
$(JCODE):
	sudo apt-get install libjcode-pm-perl


#
# cannadic dictionary for cannaserver
#
#   https://ja.osdn.net/projects/alt-cannadic/
#
#   NOTE
#
#     Using some text dictionaries, cuz the Makefile didn't work.
#
CANNADICBZ2 = alt-cannadic-110208.tar.bz2
CANNADICDIR = $(CANNADICBZ2:.tar.bz2=)
GFNAME = g_fname
GCANNA = gcanna
GCANNAF = gcannaf
GTOKURI = gt_okuri
GTANKAN = gtankan
GFNAMECTD = $(CANNADICDIR)/$(GFNAME).ctd
$(GFNAMECTD): $(CANNADICDIR)
GCANNACTD = $(CANNADICDIR)/$(GCANNA).ctd
GCANNAFCTD = $(CANNADICDIR)/$(GCANNAF).ctd
GTOKURICTD = $(CANNADICDIR)/$(GTOKURI).ctd
GTANKANCTD = $(CANNADICDIR)/$(GTANKAN).ctd
cannadic: $(CANNADICDIR)
	-mkdic -cs $(CONTAINERIP) $(GCANNAF)
	-addwords -cs $(CONTAINERIP) $(GCANNAF) < $(GCANNAFCTD)
	-mkdic -cs $(CONTAINERIP) $(GTANKAN)
	-addwords -cs $(CONTAINERIP) $(GTANKAN) < $(GTANKANCTD)
$(CANNADICDIR): $(CANNADICBZ2)
	tar xjvf $<
$(CANNADICBZ2):
	wget https://ja.osdn.net/dl/alt-cannadic/$(CANNADICBZ2)


#
# gskk dictionary for cannaserver
#
#   http://www.ohnolab.org/~kimoto/canna.html
#
GSKKGZ = gskk-20041208.t.gz
GSKKDIR = $(GSKKGZ:.t.gz=)
GSKKT = $(GSKKDIR)/gskk.t
gskk: $(GSKKT)
$(GSKKT): $(GSKKGZ)
	mkdir $(GSKKDIR)
	gunzip $< -c > $@
$(GSKKGZ):
	wget http://www.ohnolab.org/~kimoto/$(GSKKGZ)

#
# canna-dictionary for cannaserver
#
#   https://github.com/mt819/Canna-Dictionary
#
#   NOTE
#
#     This dictionaries are the same cannaserver already has. (maybe...)
#     So this method is for examples or memo.
#
CANNADICTIONAYDIR = Canna-Dictionary
CC0DIC = $(CANNADICTIONAYDIR)/CC0_CannaDic
CC0JISYOT = $(CANNADICTIONAYDIR)/cc0jisyo.t
$(CC0JISYOT): $(CC0DIC)/cc0jisyo.t
	cat $< | nkf -W -e > $@
$(CC0DIC)/cc0jisyo.t: $(CANNADICTIONAYDIR)
CC0YUBINCTD = $(CANNADICTIONAYDIR)/yubin7.ctd
$(CC0YUBINCTD): $(CC0DIC)/yubin7.ctd $(CANNADICTIONAYDIR)
	cat $< | nkf -W -e > $@
CANNADIR = $(CANNADICTIONAYDIR)/canna
BUSHUT = $(CANNADICTIONAYDIR)/bushu.t
$(BUSHUT): $(CANNADIR)/bushu.t $(CANNADICTIONAYDIR)
	cat $< | nkf -W -e > $@
HOJOMT = $(CANNADICTIONAYDIR)/hojomwd.t
$(HOJOMT): $(CANNADIR)/hojomwd.t $(CANNADICTIONAYDIR)
	cat $< | nkf -W -e > $@
HOJOST = $(CANNADICTIONAYDIR)/hojoswd.t
$(HOJOST): $(CANNADIR)/hojoswd.t $(CANNADICTIONAYDIR)
	cat $< | nkf -W -e > $@
KANAT = $(CANNADICTIONAYDIR)/kanasmpl.t
$(KANAT): $(CANNADIR)/kanasmpl.t $(CANNADICTIONAYDIR)
	cat $< | nkf -W -e > $@
KATAT = $(CANNADICTIONAYDIR)/katakana.t
$(KATAT): $(CANNADIR)/katakana.t $(CANNADICTIONAYDIR)
	cat $< | nkf -W -e > $@
KEIT = $(CANNADICTIONAYDIR)/keishiki.t
$(KEIT): $(CANNADIR)/keishiki.t $(CANNADICTIONAYDIR)
	cat $< | nkf -W -e > $@
NECT = $(CANNADICTIONAYDIR)/necgaiji.t
$(NECT): $(CANNADIR)/necgaiji.t $(CANNADICTIONAYDIR)
	cat $< | nkf -W -e > $@
NUMT = $(CANNADICTIONAYDIR)/number.t
$(NUMT): $(CANNADIR)/number.t $(CANNADICTIONAYDIR)
	cat $< | nkf -W -e > $@
SWT = $(CANNADICTIONAYDIR)/software.t
$(SWT): $(CANNADIR)/software.t $(CANNADICTIONAYDIR)
	cat $< | nkf -W -e > $@
SUFT = $(CANNADICTIONAYDIR)/suffix.t
$(SUFT): $(CANNADIR)/suffix.t $(CANNADICTIONAYDIR)
	cat $< | nkf -W -e > $@
CHIMEIT = $(CANNADICTIONAYDIR)/chimei.t
$(CHIMEIT): $(CANNADICTIONAYDIR) $(CANNADICTIONAYDIR)
	cat $(CANNADICTIONAYDIR)/chimei/*.t | nkf -W -e > $@
IROHAT = $(CANNADICTIONAYDIR)/iroha.t
$(IROHAT): $(CANNADICTIONAYDIR) $(CANNADICTIONAYDIR)
	cat $(CANNADICTIONAYDIR)iroha/*.t | nkf -W -e > $@
JINMEIT = $(CANNADICTIONAYDIR)/jinmei.t
$(JINMEIT): $(CANNADICTIONAYDIR)/jinmei/jinmei.t $(CANNADICTIONAYDIR)
	cat $< | nkf -W -e > $@
KAOT = $(CANNADICTIONAYDIR)/kaomoji.t
$(KAOT): $(CANNADICTIONAYDIR)/kao.t $(CANNADICTIONAYDIR)
	cat $< | nkf -W -e > $@
KOYUUT = $(CANNADICTIONAYDIR)/koyuu.t
$(KOYUUT): $(CANNADICTIONAYDIR)/koyuu/koyuu.t $(CANNADICTIONAYDIR)
	cat $< | nkf -W -e > $@
CANNADICTIONARIES = $(CC0JISYOT) $(CC0YUBINCTD) $(BUSHUT) $(HOJOMT) $(HOJOST) $(KANAT) $(KATAT) $(KEIT) $(NECT) $(NUMT) $(SWT) $(SUFT) $(CHIMEIT) $(IROHAT) $(JINMEIT) $(KOYUUT)
TEXTONLYCANNADICTIONARIES = $(GCANNAFCTD) $(GTANKANCTD) $(CC0JISYOT) $(KATAT) $(IROHAT) $(JINMEIT) $(KAOT)
$(CANNADICTIONAYDIR):
	git clone https://github.com/mt819/Canna-Dictionary.git

#
# binary dictionaries for docker container
#
#  canna can create binary dictionary from text dictionary by the mkbindic
#  command.
#
#  NOTE
#
#    text dictionaries can be added by client using mkdic and addwords
#    if client has these command.
#
#  WARNING
#
#    Ahh, client which want to use cannaserver on docker doesn't have mkbindic,
#    mkdic and addwords because these commands are bundled with cannaserver
#    itself. so the method below does not work. Do these commands in docker
#    container instead.
#
#      $(BINSRC): $(SKKALPCTD) $(GFNAMECTD) $(GCANNACTD) $(GTOKURICTD) $(GSKKT)
#          mkdir $@
#          cd $@; for src in $^; do mkbindic ../$$src; done
#
#    See also dockerfile.
#
$(BINSRC): $(SKKALPCTD) $(GFNAMECTD) $(GCANNACTD) $(GTOKURICTD) $(GSKKT)
	mkdir $@
	cp $^ $@

#
# text dictionaries for docker container
#
#    The mkdic and the mkaddwords have the same problem as binary dictionaries
#    above.
#
$(TXTDIC): $(GCANNAFCTD) $(GTANKANCTD)
	mkdir $@
	cp $^ $@
#
clean:
	$(RM) -r $(SKKALPBZ2) $(SKKALPDIR) $(CANNADICBZ2) $(CANNADICDIR) $(GSKKGZ) $(GSKKDIR) $(CANNADICTIONAYDIR) $(BINSRC) $(TXTDIC)
