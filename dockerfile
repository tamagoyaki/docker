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
run apt-get install -y vim
run apt-get install -y git
run apt-get install -y sudo
run apt-get install -y tzdata
run apt-get install -y iproute2
run apt-get install -y openssh-server

#
# PREFERENCE
#
# run apt-get install -y etckeeper
# run sed 's/#\(AVOID_DAILY_AUTOCOMMITS=1\)/\1/' -i /etc/etckeeper/etckeeper.conf

# install samba related
run apt-get install -y samba

# For WS-Discovery
#
#    As of 5/17/2023, I want to use it, but doesn't work yet. why is that?
#    So using NetBIOS instead for now.
#
# run apt-get install wsdd

# shared directory for guest
arg SAMBADIR=/opt/samba
arg SHAREDIR=${SAMBADIR}/share
arg SHAREOWN="nobody:nogroup"
arg SHAREPMT=770

# make shared dirctory
run mkdir -p ${SHAREDIR}
run chown ${SHAREOWN} ${SHAREDIR}
run chmod ${SHAREPMT} ${SHAREDIR}

# copy utils
copy addsmbusr.sh ${SAMBADIR}/
copy addsmbdir.sh ${SAMBADIR}/
run chmod u+x ${SAMBADIR}/*.sh

#
# OPTION
#
#   smbreloader daemon
#
#     call "service smbd reload" automatically if configure file in ${CONFDIR}
#     is modified.
#
arg WRAPPER=wrapper.sh
arg RELOADER=smbreloader
arg SERVICE=${RELOADER}d
arg INITDIR=${SAMBADIR}/init.d
arg CONFDIR=${SAMBADIR}/confdir
run mkdir -p ${INITDIR} ${CONFDIR}
copy init.d/${RELOADER} ${INITDIR}
copy init.d/${SERVICE} ${INITDIR}
run chmod u+x ${INITDIR}/${SERVICE}
run ln -s ${INITDIR}/${SERVICE} /etc/init.d/${SERVICE}
run { \
    echo "#!/bin/bash"; \
    echo "service ${SERVICE} start"; \
    echo "smbd --foreground"; \
    } > ${SAMBADIR}/${WRAPPER}
run chmod u+x ${SAMBADIR}/${WRAPPER}

# edit smb.conf to access as guest
run { \
    echo "[share]"; \
    echo "path = ${SHAREDIR}"; \
    echo "browsable = yes"; \
    echo "writable = yes"; \
    echo "guest ok = yes"; \
    echo "guest only = yes"; \
    echo "read only = no"; \
    } >> /etc/samba/smb.conf

#
# start samba
#
# TIPS:
#
#    If you want to start a nmbd and smbd, use wapper script.
#    See https://docs.docker.com/config/containers/multi-service_container/
#
#    example)
#
#        $ cat samba-wrapper.sh
#        #!/bin/bash
#        service nmbd start
#        smbd --foreground
#
#      Then write entrypoint like this.
#
#        entrypoint /someware/samba-wrapper.sh
#
#        instead of 'entrypoint smbd --foreground'
#
#      WARNING: entrypoint didn't accept variable, I don't know why.
#
#        entrypoint ${SOMEWARE}/${SCRIPT}
#

#entrypoint smbd --foreground
entrypoint /opt/samba/wrapper.sh



#
# now you can access to ${SHAREDIR} as guest from host computer by below
#
#    > # mount -t cifs //172.17.0.2/share /home/matsuda/tmp/test -o guest
#
#    If you specify "-o user=guest", password is required but empty password is
#    available.
#
#    You may need to do this on client side before mounting a samba.
#
#        > # apt install cifs-utils
#
