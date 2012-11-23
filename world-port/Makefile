# Created by: Denis Barov <dindin@dindin.ru>
# $FreeBSD$

PORTNAME=	FreeBSD-world
PORTVERSION=	236455
CATEGORIES=	sysutils
MASTER_SITES=	http://svn.freebsd.org
DIST_SUBDIR=	svn/${PORTNAME}
MASTER_SITES+=	${MASTER_SITE_LOCAL}
MASTER_SITE_SUBDIR=	base/stable/9

MAINTAINER=	dindin@dindin.ru
COMMENT=	FreeBSD world package

LICENSE=	BSD

MAKE_JOBS_SAFE=	yes
USE_SVN=	yes

.include "${.CURDIR}/bsd.co.mk"
.include <bsd.port.mk>
checksum_init=\
	SHA256DIR=${SHA256DIR};
