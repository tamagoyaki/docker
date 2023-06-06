from ubuntu:latest

# Timezone to Tokyo
run ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

#
# install basics
#
# TIPS:
#
#    To avoid "WARNING: apt does not have a stable CLI interface. Use with
#    caution in scripts." use apt-get instead of apt.
#
#    "run apt-get install -y apt-utils" doesn't resolve WARNING that
#    describes "debconf: delaying package configuration, since apt-utils
#    is not installed". So leave it alone it's just a warning. (^^;
#
run apt-get update
#run apt-get install -y vim
#run apt-get install -y git
#run apt-get install -y sudo
#run apt-get install -y tzdata
#run apt-get install -y iproute2
#run apt-get install -y openssh-server
run apt-get install -y canna

#
# PREFERENCE
#
# run apt-get install -y etckeeper
# run sed 's/#\(AVOID_DAILY_AUTOCOMMITS=1\)/\1/' -i /etc/etckeeper/etckeeper.conf

#
# dictionaries
#
#   if you use gcannaf.ctd and gtankan.ctd, do below as client.
#   See Makefile's cannadic target for more info.
#
#     $ mkdir -cs 172.17.0.2 gcannaf
#     $ addwords -cs 172.17.0.2 gcannaf < gcannaf.ctd
#
arg CANNADIC=/var/lib/canna/dic/canna
copy --chmod=644 --chown=canna:canna dictionary/* ${CANNADIC}/
run { \
    echo "" ;\
    echo "# additional dictionaries." ;\
    echo "gcanna.cbd(gcanna.mwd)  -gcanna---" ; \
    echo "gcanna.cld(gcanna.mwd)  -gcanna---" ; \
    echo "gcannaf.ctd(gcannaf.swd)  -gcannaf---" ; \
    echo "gtankan.ctd(gtankan.swd)  -gtankan---" ; \
    echo "g_fname.cbd(g_fname.mwd)  -g_fname---" ; \
    echo "g_fname.cld(g_fname.mwd)  -g_fname---" ; \
    echo "gskk.cbd(gskk.mwd)  -gskk---" ; \
    echo "gskk.cld(gskk.mwd)  -gskk---" ; \
    echo "gt_okuri.cbd(gt_okuri.mwd)  -gt_okuri---" ; \
    echo "gt_okuri.cld(gt_okuri.mwd)  -gt_okuri---" ; \
    echo "skkalpha.cbd(skkalpha.mwd)  -skkalpha---" ; \
    echo "skkalpha.cld(skkalpha.mwd)  -skkalpha---" ; \
    } >> ${CANNADIC}/dics.dir

#
# register acceptable client.
#
#   See IMPORTANT section below. This setting is somewhat example.
#
run { \
    echo "172.17.0.1"; \
    } >> /etc/hosts.canna

#
# In this case, the processes is like these.
#
#  > # ps ax
#  >   PID TTY      STAT   TIME COMMAND
#  >     1 pts/0    Ss+    0:00 bash
#  >    28 pts/1    Ss     0:00 /bin/bash
#  >    42 pts/1    R+     0:00 ps ax
#

arg WRAPPER=wrapper.sh
run { \
    echo "#!/bin/bash"; \
    echo "rm /tmp/.iroha_unix/IROHA"; \
    echo "/usr/sbin/cannaserver -inet"; \
    echo "/bin/bash"; \
    } > ~/${WRAPPER}
run chmod u+x ~/${WRAPPER}


# WARNING: entrypoint didn't accept variable, I don't know why.
entrypoint ~/wrapper.sh

#
# IMPORTANT
#
# 1. cannaserver needs acceptable ip that is described on /etc/hosts.canna
#    in container.
#
# 2. canna client must do "export CANNAHOST=cannaserver's IP"
#
# EXAMPLE
#
#   On samba-c container
#
#     # echo 172.17.0.1 >> /etc/hosts.canna
#     # cat /etc/hosts.canna
#     unix
#     172.17.0.1
#
#   On host (canna client)
#
#     $ export CANNAHOST=172.17.0.2
#
