#!/bin/bash


if [[ $@ =~ -s\ ([^ ]+).* ]]; then
    sn=${BASH_REMATCH[1]}
fi

if [[ $@ =~ -p\ ([^ ]+).* ]]; then
    pa=${BASH_REMATCH[1]}
fi

if [[ $@ =~ -vu\ ([^ ]+).* ]]; then
    vu=${BASH_REMATCH[1]}
fi

if [[ $@ =~ -wl\ ([^ ]+).* ]]; then
    wl=${BASH_REMATCH[1]}
fi

if [[ $@ =~ -rl\ ([^ ]+).* ]]; then
    rl=${BASH_REMATCH[1]}
fi

if [[ $@ =~ -ro ]]; then
    ro="yes"
else
    ro="no"
fi

if [[ $@ =~ -wb ]]; then
    wb="yes"
else
    wb="no"
fi

if [[ $@ =~ -gu ]]; then
    gu="yes"
else
    gu="no"
fi

if [[ $@ =~ -br ]]; then
    br="yes"
else
    br="no"
fi

if [ -z $sn ] || [ -z $pa ]; then
    echo ""
    echo "Create an entry of share directory"
    echo ""
    echo "  Add this entry to smb.conf"
    echo ""
    echo "USAGE"
    echo ""
    echo "  $ $0 -s sharename -p path [ ... ]"
    echo ""
    echo "  REQUIRED"
    echo ""
    echo "      -s : sharename"
    echo "      -p : path for shared directory"
    echo ""
    echo "  OPTIONAL"
    echo ""
    echo "      -vu : validusers (csv format)"
    echo "      -wl : writelist (csv format)"
    echo "      -rl : readlist (csv format)"
    echo "      -ro : readonly"
    echo "      -wb : writable"
    echo "      -gu : guest ok"
    echo "      -br : browserble"
    echo ""
    echo "EXAMPLE"
    echo ""
    echo "  For confirmation."
    echo ""
    echo "    $ $0 -s sharedoc -p /somewhere/doc -vu john,jane -wl john"
    echo "    [sharedoc]"
    echo "    path = /somewhere/doc"
    echo "    valid users = john,jane"
    echo "    8< -snip- >8"
    echo ""
    echo "  For settings."
    echo ""
    echo "    $ $0 -s ref -p /hoge/ref -vu john -wl john > ref.conf"
    echo "    # vi /etc/samba/smb.conf"
    echo "    include = /somewhere/ref.conf"
    echo ""
    exit 1
fi

echo ""
echo "[$sn]"
echo "path = $pa"
echo "read only = $ro"
echo "writable = $wb"
echo "guest ok = $gu"
echo "browsable = $br"

if [ -n "$vu" ]; then
    echo "valid users = $vu"
fi

if [ -n "$rl" ]; then
    echo "read list = $rl"
fi

if [ -n "$wl" ]; then
    echo "write list = $wl"
fi

# bye
echo -e "\nDon't forget to add \"include = /somewhere/some.conf to smb.conf\n\" " >&2
