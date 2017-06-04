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
    fi
done

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
        DESTDIR=''
    fi
fi

ETCDIR="${DESTDIR}${PREFIX}/etc"
# Remove any double-slashes
ETCDIR="$(echo "${ETCDIR}" | sed 's|//|/|g')"

mkdir -p $DESTDIR/etc

install -v -m 755 bash-resume.sh $DESTDIR/etc/
