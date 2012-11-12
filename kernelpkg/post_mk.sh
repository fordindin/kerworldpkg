#!/bin/sh

# $Id: post_mk.sh 481214 2009-05-02 12:44:05Z dindin $
cd ${tmpdir}
/usr/bin/uudecode -c < ${tmpdir}/int.uu
/usr/bin/tar xfz ${tmpdir}/kern.tgz
KERNFILES="$(find ${tmpdir}/boot/ -type f)"
KERNDIRS="$(find ${tmpdir}/boot/ -type d)"

export LANG="C"
for i in `jot 3 3 1 -1`; do
    mv ${prefix}/boot/kernel.prev${i} ${prefix}/boot/kernel.prev$(($i+1)) 2> /dev/null
done
mv ${prefix}/boot/kernel.prev ${prefix}/boot/kernel.prev1 2> /dev/null
mv ${prefix}/boot/kernel ${prefix}/boot/kernel.prev 2> /dev/null


for file in ${KERNFILES}; do
    fname="`basename ${file%.tmpl}`"
    dirname="`dirname ${file}`"
    dirname="${dirname#${tmpdir}}"
    if [ ! -d "${dirname}" ]; then
            mkdir -p ${dirname}
            dmode=$(stat -f %p $dirname | grep -o '...$');
            downer=$(stat -f %u $dirname);
            dgroup=$(stat -f %g $dirname);
            echo chmod ${dmode} ${dirname}
            chmod ${dmode} ${dirname}
            echo chown ${downer}:${dgroup} ${dirname}
            chown ${downer}:${dgroup} ${dirname}
    fi
    mode=`stat -f %p $file | grep -o '...$'`
    owner=`stat -f %u $file`
    group=`stat -f %g $file`
    fname="`basename ${file}`"
    [ ! -d "${prefix}${dirname}/" ] && mkdir -p ${prefix}${dirname}/
    echo install -m ${mode} -o ${owner} -g ${group} ${file} ${prefix}${dirname}/${fname}
    install -m ${mode} -o ${owner} -g ${group} ${file} ${prefix}${dirname}/${fname}
done
#mkdir /tmp/testdir/
#/bin/cp -Rf ${tmpdir} /tmp/testdir/
/bin/rm ${tmpdir}/int.uu ${tmpdir}/kern.tgz 
/bin/rm -Rf ${tmpdir}
exit 0
#MD5 checksum:


