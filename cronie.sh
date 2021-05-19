#!/bin/bash
# SPDX-License-Identifier: MIT
set -e

error() { echo "ERROR: $1" >&2; exit 1; }

usage(){
    cat <<EOF
$(basename $0) [options] image_name -or- bitbake_command

options:
    -e (optional emit bitbake line. Doesn't run a build, just emits what would run.)
    -m machine
    -k continue as much as possible after an error
    -v vendor (optional. Some machines we can extract vendor from the name. Some we can't)
EOF
    exit
}

[ -z "$BBPATH" ] && error "Please source ./openembedded-core/oe-init-build-env before running this script"
[ $# -eq 0 ] && usage

while getopts "em:kv:" opt; do
    case ${opt} in
        e ) EMIT=true ;;
        m ) MACHINE=${OPTARG} ;;
        k ) CONTINUE="--continue" ;;
        v ) VENDOR=${OPTARG} ;;
        * ) echo && usage 
    esac
done

[ -z "$MACHINE" ] && error "Missing MACHINE configuration (-m)"
[ -z "$VENDOR" ] && VENDOR=$(echo "$MACHINE" | cut -d'-' -f1)

shift $((OPTIND-1))
BITBAKE_ARGS="$*"
[ -z "$BITBAKE_ARGS" ] && error "Missing bitbake command"

if [ "${EMIT}" = "true" ]; then 
    cat <<EOF
BB_ENV_EXTRAWHITE="$BB_ENV_EXTRAWHITE VENDOR" VENDOR="$VENDOR" MACHINE="$MACHINE" bitbake ${CONTINUE} "${BITBAKE_ARGS}"
EOF
    exit
fi

exec env BB_ENV_EXTRAWHITE="$BB_ENV_EXTRAWHITE VENDOR" VENDOR="$VENDOR" MACHINE="$MACHINE" bitbake ${CONTINUE} "${BITBAKE_ARGS}"
