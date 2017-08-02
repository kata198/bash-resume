#!/bin/bash

# Support calling like   ./install.sh DESTDIR="${pkgdir}"

for arg in "$@";
do
    if ( echo "${arg}" | grep -q '^PREFIX=' );
    then
        export "${arg}"
    elif ( echo "${arg}" | grep -q '^DESTDIR=' );
    then
        export "${arg}"
    elif ( echo "${arg}" | grep -q '^INSTALL_DIR=' );
    then
        export "${arg}"
    fi
done

if [ ! -z "${INSTALL_DIR}" ];
then
    if [ -z "${PREFIX}" ];
    then
        PREFIX="usr"
    else
        if [ "${PREFIX}" != "/" ];
        then
            PREFIX="$(echo "${PREFIX}" | sed 's|[/][/]*$||g')"
            PREFIX="$(echo "${PREFIX}" | sed 's|//|/|g')"
        fi
    fi
    if [ -z "${DESTDIR}" ];
    then
        DESTDIR=""
    else
        if [ "${DESTDIR}" != "/" ];
        then
            DESTDIR="$(echo "${DESTDIR}" | sed 's|[/][/]*$||g')"
            DESTDIR="$(echo "${DESTDIR}" | sed 's|//|/|g')"
        else
            DESTDIR="${DESTDIR}"
        fi
    fi

    export DESTDIR
    export PREFIX
    if ! ( ! ( echo "${DESTDIR}" | grep -E '/$' || ! echo "${PREFIX}" | grep -E '^/' ) ); then
        # Check if combining DESTDIR and PREFIX is not going to naturally have a slash
        #   and if we need to, nuture it.
        DESTDIR="${DESTDIR}/"
    fi
    FINALDIR="${INSTALL_DIR}"
else
    FINALDIR="${DESTDIR}${PREFIX}/etc"
fi   
# Remove any double-slashes
FINALDIR="$(echo "${FINALDIR}" | sed 's|//|/|g')"

mkdir -p ${FINALDIR}

install -v -m 755 bash-resume.sh ${FINALDIR}/
