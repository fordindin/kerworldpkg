#!/bin/sh -eu

. $(dirname $(realpath $0))/world.conf


ARCH=$(uname -m)
args=`getopt p:a:v:r:g:o: $*`
set -- $args
for i; do
    case "$i"
    in
        -p) PREFIX="${2%/}";PREFIX="${PREFIX%/src}";
            shift; shift;;
        -a) ARCH="$2";
            shift; shift;;
        -v) OSVERSION=$2;
            shift; shift;;
        -r) SVNREVISION=$2;
            shift; shift;;
        -g) ORIGIN=$2;
            shift; shift;;
        -o) OUTPUTDIR=$2;
            shift; shift;;

        --) shift; break;;
    esac
done


PKGVERSION="${OSVERSION}.${SVNREVISION}"
PKGORIGIN="${ORIGIN}"
PKGOSVERSION="${OSVERSION}"
PKGFLATSIZE="$((1024*$(du -k -d0 ${PREFIX} | cut -f1)))"
PKGPREFIX="/"
PKGARCH="$(uname):9:x86:64"

PKGNAME="${PKGNAME}-${ARCH}"


FILES=$(for f in `find ${PREFIX} -type f `; do
printf " ${f##${PREFIX}}: \'`sha256 -q "${f}"`\'\n"
done
)

LINKS=$(for f in `find ${PREFIX} -type l `; do
printf -- " ${f##${PREFIX}}: '-'\n"
done
)

DIRS=$(for f in `find ${PREFIX} -type d | tail +2`; do
printf -- " - ${f##${PREFIX}}\n"
done
)

MANIFESTDIR=$(mktemp -d -t manifest)
mkdir -p ${MANIFESTDIR}

CHFLAG_DIRS=$(find ${PREFIX} -flags schg | sed -e"s#${PREFIX%/}/#/#g" | tr '\n' ' ')

cat > ${MANIFESTDIR}/+MANIFEST <<EOB
name: ${PKGNAME}
version: ${PKGVERSION}
origin: ${PKGORIGIN}
comment: ${PKGCOMMENT}
desc: ${PKGDESC}
arch: ${PKGARCH}
osversion: ${PKGOSVERSION}
www: ${PKGOFFITIALSITE}
maintainer: ${PKGMAINTAINER}
prefix: ${PKGPREFIX}
flatsize: ${PKGFLATSIZE}
files:
${FILES}
${LINKS}
dirs:
${DIRS}
scripts:
 pre-deinstall:
  #!/bin/sh
  for f in ${CHFLAG_DIRS}; do
   chflags noschg \$f;
  done
EOB

pkg create -o ${OUTPUTDIR} -r ${PREFIX} -m ${MANIFESTDIR}

rm -Rf ${MANIFESTDIR}
