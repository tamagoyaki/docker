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

# for apache
run apt-get update
run apt-get install -y apache2
run apt-get install -y openssh-server

#
# PREFERENCE
#
# run apt-get install -y etckeeper
# run sed 's/#\(AVOID_DAILY_AUTOCOMMITS=1\)/\1/' -i /etc/etckeeper/etckeeper.conf

# ja_JP for apache LANG
run { \
    echo ""; \
    echo "# Japanese settings"; \
    echo "export LANG=ja_JP.utf-8"; \
    echo "export LC_ALL=ja_JP.utf-8"; \
} >> /etc/apache2/envvars

#
# In this case, the processes is like these.
#
#  > # ps ax
#  >   PID TTY      STAT   TIME COMMAND
#  >     1 pts/0    Ss+    0:00 bash
#  >    28 pts/1    Ss     0:00 /bin/bash
#  >    42 pts/1    R+     0:00 ps ax
#

#
# start apache2
#
entrypoint apachectl -D FOREGROUND

#
# now you can access to "Apache2 Default Page" by below.
#
#    > $ w3m 172.17.0.3
#
