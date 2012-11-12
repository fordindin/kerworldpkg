#!/bin/sh


# $Id: pre_mk.sh 482279 2009-12-04 18:23:11Z dindin $
args=$(getopt fp: $*)
forse=""
prefix=""

set -- $args
for a; do
    case "$a"
    in
        -f) 
            force="yes";
            shift;;
        -p) 
            prefix="$2";
            shift; shift;;
        --) 
            shift; break;;
   esac
done

set PATH="/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin"
export PATH
export TMPDIR=/opt/tmp
mkdir -p ${TMPDIR}
tmpdir="$(mktemp -d -t pse)"
mkdir -p ${tmpdir}
numstrings="$(($(cat $0 | wc -l)-1))"
sum="$(cat $0 | head -n ${numstrings} | md5)"
rsum="$(/usr/bin/tail -n 1 $0)"
arch=$(uname -m)
march=%%ARCH%%
rel=$(uname -r)
mrel=%%RELEASE%%

[ -n "${prefix}" ] && { printf "Using prefix: $prefix\n"; mkdir -p ${prefix}/boot/; }

if [ "x${arch}" != "x${march}" -a -z "$force"  ]; then
    printf "!!!  This package for ${march} !!!\n"
    printf "!!!      you running ${arch}   !!!\n"
    printf "!!!         install failed      !!!\n"
    exit 1
fi
if [ "x${sum}" != "x${rsum}" ]; then
    printf "!!!  Checksum mismatch !!!\n"
    printf "!!!    install failed  !!!\n"
    exit 1
fi
cat > ${tmpdir}/int.uu <<"EOFEOFEOF"

