#!/bin/bash


if [[ $@ =~ -u\ ([^ ]+).* ]]; then
    usr=${BASH_REMATCH[1]}
fi

if [[ $@ =~ -g\ ([^ ]+).* ]]; then
    grp=${BASH_REMATCH[1]}
fi

if [[ $@ =~ -p\ ([^ ]+).* ]]; then
    pas=${BASH_REMATCH[1]}
fi

if [ -z $usr ]; then
    echo ""
    echo "Add user to linux and samba."
    echo ""
    echo "  Password would be updated if the user exists already."
    echo ""
    echo "USAGE"
    echo ""
    echo "  $ $0 -u user -g group -p password"
    echo ""
    echo "      -u : required."
    echo "      -p : required."
    echo "      -g : optional. (default sambashare)"
    echo ""
    echo "NOTE"
    echo ""
    echo "  The same password is used for both linux and samba"
    echo ""
    exit 1
fi

DEFGRP='sambashare'
if [ -z $grp ]; then
        grp=$DEFGRP
fi

#echo 'user: ' $usr 'group: ' $grp 'pass: ' $pas
#exit 0

adduser --shell=/sbin/nologin $usr --disabled-login --gecos ""
gpasswd -a $usr $grp
echo $usr:$pas | chpasswd
echo -e $pas"\n"$pas | pdbedit -a -u $usr -t
