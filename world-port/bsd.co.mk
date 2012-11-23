# $Id: bsd.co.mk 482190 2009-11-19 17:34:54Z dindin $
.if defined(USE_SVN)
NO_CHECKSUM= yes
DISTFILES=	${PKGNAME}.src.tgz
IGNOREFILES= ${PKGNAME}.src.tgz
ALLFILES?=	${_DISTFILES} ${_PATCHFILES} ${PKGNAME}/

#MASTER_SITE_OVERRIDE= ${MASTER_SITES}

FETCH_DEPENDS+= ${LOCALBASE}/bin/svn:${PORTSDIR}/devel/subversion
SVN= ${LOCALBASE}/bin/svn
CHECKSUM_ALGORITHMS=sha256dir
#SVN_USER?= anonimous

do-fetch:
	@${MKDIR} ${_DISTDIR}
	@cd ${_DISTDIR} && \
			if [ ! -f "${_DISTDIR}/${PKGNAME}.src.tgz" ]; then \
					for s in ${MASTER_SITES}; do \
							${PRINTF} "Trying to checkout sources from $${s}/${MASTER_SITE_SUBDIR}..."; \
							echo ${SVN} checkout -q -r${PORTVERSION} $${s}/${MASTER_SITE_SUBDIR} ${_DISTDIR}/${PKGNAME} && cp -Rf /home/dindin/workspace/space/${PKGNAME} ${_DISTDIR}/${PKGNAME} &&  break; \
					done && cd ${PKGNAME} \
					${TAR} cfz ../${PKGNAME}.src.tgz . && ${RM} -R ${PKGNAME}; \
					printf " Done\n"; \
			fi

.if !target(checksum)
checksum: fetch check-checksum-algorithms
	@${checksum_init} \
	if [ -f ${DISTINFO_FILE} ]; then \
		cd ${DISTDIR}; OK="";\
		for file in ${_CKSUMFILES}; do \
			ignored="true"; \
			_file=$${file#${DIST_SUBDIR}/*}; \
			for alg in ${CHECKSUM_ALGORITHMS:U}; do \
				ignore="false"; \
				eval alg_executable=\$$$$alg; \
				\
				if [ $$alg_executable != "NO" ]; then \
					MKSUM=`$$alg_executable $$file`; \
					CKSUM=`file=$$_file; ${DISTINFO_DATA}`; \
				else \
					ignore="true"; \
				fi; \
				\
				if [ $$ignore = "false" -a -z "$$CKSUM" ]; then \
					${ECHO_MSG} "=> No $$alg checksum recorded for $$file."; \
					ignore="true"; \
				fi; \
				\
				if [ "$$CKSUM" = "IGNORE" ]; then \
					${ECHO_MSG} "=> $$alg Checksum for $$file is set to IGNORE in distinfo file even though"; \
					${ECHO_MSG} "   the file is not in the "'$$'"{IGNOREFILES} list."; \
					ignore="true"; \
					OK=${FALSE}; \
				fi; \
				\
				if [ $$ignore = "false" ]; then \
					match="false"; \
					for chksum in $$CKSUM; do \
						if [ "$$chksum" = "$$MKSUM" ]; then \
							match="true"; \
							break; \
						fi; \
					done; \
					if [ $$match = "true" ]; then \
						${ECHO_MSG} "=> $$alg Checksum OK for $$file."; \
						ignored="false"; \
					else \
						${ECHO_MSG} "=> $$alg Checksum mismatch for $$file."; \
						refetchlist="$$refetchlist$$file "; \
						OK="$${OK:-retry}"; \
						ignored="false"; \
					fi; \
				fi; \
			done; \
			\
			if [ $$ignored = "true" ]; then \
				${ECHO_MSG} "=> No suitable checksum found for $$file."; \
				OK="${FALSE}"; \
			fi; \
			\
		done; \
		\
		for file in ${_IGNOREFILES}; do \
			_file=$${file#${DIST_SUBDIR}/*};	\
			ignored="true"; \
			alreadymatched="false"; \
			for alg in ${CHECKSUM_ALGORITHMS:U}; do \
				ignore="false"; \
				eval alg_executable=\$$$$alg; \
				\
				if [ $$alg_executable != "NO" ]; then \
					CKSUM=`file=$$_file; ${DISTINFO_DATA}`; \
				else \
					ignore="true"; \
				fi; \
				\
				if [ $$ignore = "false" ]; then \
					if [ -z "$$CKSUM" ]; then \
						${ECHO_MSG} "=> No $$alg checksum for $$file recorded (expected IGNORE)"; \
						OK="$$alreadymatched"; \
					elif [ $$CKSUM != "IGNORE" ]; then \
						${ECHO_MSG} "=> $$alg Checksum for $$file is not set to IGNORE in distinfo file even though"; \
						${ECHO_MSG} "   the file is in the "'$$'"{IGNOREFILES} list."; \
						OK="false"; \
					else \
						ignored="false"; \
						alreadymatched="true"; \
					fi; \
				fi; \
			done; \
			\
			if ( [ $$ignored = "true" ]) ; then \
				${ECHO_MSG} "=> No suitable checksum found for $$file."; \
				OK="false"; \
			fi; \
			\
		done; \
		\
		if [ "$${OK:=true}" = "retry" ] && [ ${FETCH_REGET} -gt 0 ]; then \
			${ECHO_MSG} "===>  Refetch for ${FETCH_REGET} more times files: $$refetchlist"; \
			if ( cd ${.CURDIR} && \
			    ${MAKE} ${.MAKEFLAGS} FORCE_FETCH="$$refetchlist" FETCH_REGET="`${EXPR} ${FETCH_REGET} - 1`" fetch); then \
				  if ( cd ${.CURDIR} && \
			        ${MAKE} ${.MAKEFLAGS} FETCH_REGET="`${EXPR} ${FETCH_REGET} - 1`" checksum ); then \
				      OK="true"; \
				  fi; \
			fi; \
		fi; \
		\
		if [ "$$OK" != "true" -a ${FETCH_REGET} -eq 0 ]; then \
			${ECHO_MSG} "===>  Giving up on fetching files: $$refetchlist"; \
			${ECHO_MSG} "Make sure the Makefile and distinfo file (${DISTINFO_FILE})"; \
			${ECHO_MSG} "are up to date.  If you are absolutely sure you want to override this"; \
			${ECHO_MSG} "check, type \"make NO_CHECKSUM=yes [other args]\"."; \
			exit 1; \
		fi; \
		if [ "$$OK" != "true" ]; then \
			exit 1; \
		fi; \
	elif [ -n "${_CKSUMFILES:M*}" ]; then \
		${ECHO_MSG} "=> No checksum file (${DISTINFO_FILE})."; \
	fi
.endif

.if !target(makesum)
SHA256DIR=${.CURDIR}/sha256dir
makesum: check-checksum-algorithms
	echo ${SHA256DIR}; \
	@cd ${.CURDIR} && ${MAKE} fetch NO_CHECKSUM=yes \
		DISABLE_SIZE=yes
	@if [ -f ${DISTINFO_FILE} ]; then ${CAT} /dev/null > ${DISTINFO_FILE}; fi
	@( \
		cd ${DISTDIR}; \
		\
		${checksum_init} \
		\
		for file in ${_CKSUMFILES}; do \
			for alg in ${CHECKSUM_ALGORITHMS:U}; do \
				eval alg_executable=\$$$$alg; \
				\
				if [ $$alg_executable != "NO" ]; then \
					$$alg_executable $$file >> ${DISTINFO_FILE}; \
				fi; \
			done; \
			${ECHO_CMD} "SIZE ($$file) = `${STAT} -f \"%z\" $$file`" >> ${DISTINFO_FILE}; \
		done \
	)
	@for file in ${_IGNOREFILES}; do \
		for alg in ${CHECKSUM_ALGORITHMS:U}; do \
			${ECHO_CMD} "$$alg ($$file) = IGNORE" >> ${DISTINFO_FILE}; \
		done; \
	done
.endif

.endif #.if defined(USE_SVN)
