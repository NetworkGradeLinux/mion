#!/bin/bash
# SPDX-License-Identifier: MIT
set -e

error() { echo "ERROR: $1" >&2; exit 1; }

info() { echo "INFO: $1"; }

usage(){
    cat <<EOF
onie-only-build.sh
    -e (optional emit bitbake line. Doesn't run a build, just emits what would run.)
    -m machine
    -k continue as much as possible after an error
    -v vendor (optional. Some machines we can extract vendor from the name. Some we can't)
    image_name/bitbake command (e.g. core-image-minimal; os-release -f -c cleanall; etc)
EOF
    exit
}

parse_args(){
    [ $# -eq 0 ] && usage

    while getopts ":em:kv:" opt; do
        case ${opt} in
            e ) EMIT="1" ;;
	    m ) MACHINE=$OPTARG ;;
	    k ) CONTINUE="--continue" ;;
	    v ) VENDOR=$OPTARG ;;
            \? ) error "Unknown option -$OPTARG" ;;
            : ) error "Missing option argument for -$OPTARG" ;;
            * ) error "Unimplemented option: -$OPTARG"
        esac
    done

    shift $(expr $OPTIND - 1 )

    BITBAKE_ARGS=""

    while test $# -gt 0; do
        BITBAKE_ARGS="$BITBAKE_ARGS $1"
        shift
    done

    if [ -z "$MACHINE" ]; then
        error "Missing MACHINE configuration (-m)"
    fi
}

build(){

    if [ -z "$VENDOR" ]; then
	    local VENDOR=$(echo "$MACHINE"|cut -d'-' -f1)
    fi

    if [ ! -z "$EMIT" ]; then
        cat <<EOF
    The bitbake command we would have run is:
    BB_ENV_EXTRAWHITE="$BB_ENV_EXTRAWHITE VENDOR" VENDOR="$VENDOR" MACHINE="$MACHINE" bitbake ${CONTINUE} ${BITBAKE_ARGS}
EOF
        exit 0
    fi

    exec env BB_ENV_EXTRAWHITE="$BB_ENV_EXTRAWHITE VENDOR" VENDOR="$VENDOR" MACHINE="$MACHINE" bitbake ${CONTINUE} ${BITBAKE_ARGS}

}

parse_args "$@"

[ -z "$BBPATH" ] && error "Please source ./openembedded-core/oe-init-build-env first"

build

echo "onie-only-build.sh - Done."
