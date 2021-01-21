#!/bin/bash
# SPDX-License-Identifier: MIT
set -e

error() { echo "ERROR: $1" >&2; exit 1; }

info() { echo "INFO: $1"; }

usage(){
    cat <<EOF
build.sh
    -e (optional emit bitbake line. Doesn't run a build, just emits what would run.)
    -m machine
    -k continue as much as possible after an error
    -v vendor (optional. Some machines we can extract vendor from the name. Some we can't)
    -c container_mc_config:container_image[,container_mc_config:container_image,...]
    -h host_mc_config:host_image
    -d container_image[,container_image]    (optional disable autostart for specified containers)
EOF
    exit
}

parse_args(){
    [ $# -eq 0 ] && usage

    while getopts ":em:kh:c:v:d:" opt; do
        case ${opt} in
            e ) EMIT="1" ;;		
            m ) MACHINE=$OPTARG ;;
	    k ) CONTINUE="--continue" ;;
            h ) HOST=$OPTARG ;;
            c ) CONTAINERS=$OPTARG ;;
	    v ) VENDOR=$OPTARG ;;
            d ) DISABLE=$OPTARG ;;
            \? ) error "Unknown option -$OPTARG" ;;
            : ) error "Missing option argument for -$OPTARG" ;;
            * ) error "Unimplemented option: -$OPTARG"
        esac
    done

    if [ -z "$MACHINE" ]; then
        error "Missing MACHINE configuration (-m)"
    fi
}

build(){
    local MC_CONTAINERS=""
    local BBMULTICONFIG=""
    local CONTAINER_NAMES=""
    local CONTAINER_DEPENDS=""
    local BUILD_ARGS=""
    local MC_HOST=""

    declare -a GUESTS

    if [ -z "$VENDOR" ]; then
	    local VENDOR=$(echo "$MACHINE"|cut -d'-' -f1)
    fi

    if [ ! -z "$HOST" ]; then
        HOSTCONFIG=$(echo "$HOST" | cut -d':' -f1)
        BBMULTICONFIG="$BBMULTICONFIG $HOSTCONFIG"
    fi 

    IFS=","
    if [ ! -z "$CONTAINERS" ]; then
        guest_count=0
        for container in $CONTAINERS; do
            CONFIG=$(echo "$container" | cut -d':' -f1)
            IMAGE=$(echo "$container" | cut -d':' -f2)

            CONTAINER_NAMES="$CONTAINER_NAMES $IMAGE"
            MC_CONTAINERS="$CONFIG:$IMAGE $MC_CONTAINERS"

            GUESTS[guest_count]="mc:${CONFIG}:${IMAGE}"
            guest_count=$((guest_count+1))

            BBMULTICONFIG="$BBMULTICONFIG $CONFIG"

            [ ! -z "$HOST" ] && CONTAINER_DEPENDS="$CONTAINER_DEPENDS $IMAGE-pkg"
        done
    fi 

    [ ! -z "$HOST" ] && MC_HOST="mc:$HOST"

    BUILD_ARGS="$MC_CONTAINERS $HOST"

    if [ ! -z "$EMIT" ]; then
        cat <<EOF
    The bitbake command we would have run is:
    BB_ENV_EXTRAWHITE="$BB_ENV_EXTRAWHITE BUILD_ARGS CONTAINER_NAMES CONTAINER_DEPENDS BBMULTICONFIG MION_CONT_DISABLE VENDOR" BUILD_ARGS="$BUILD_ARGS" BBMULTICONFIG="$BBMULTICONFIG" CONTAINER_NAMES="$CONTAINER_NAMES" CONTAINER_DEPENDS="$CONTAINER_DEPENDS" VENDOR="$VENDOR" MACHINE="$MACHINE" MION_CONT_DISABLE="$DISABLE" bitbake ${CONTINUE} ${GUESTS[@]} ${MC_HOST}
EOF
        exit 0
    fi

    exec env BB_ENV_EXTRAWHITE="$BB_ENV_EXTRAWHITE BUILD_ARGS CONTAINER_NAMES CONTAINER_DEPENDS BBMULTICONFIG MION_CONT_DISABLE VENDOR" BUILD_ARGS="$BUILD_ARGS" BBMULTICONFIG="$BBMULTICONFIG" CONTAINER_NAMES="$CONTAINER_NAMES" CONTAINER_DEPENDS="$CONTAINER_DEPENDS" VENDOR="$VENDOR" MACHINE="$MACHINE" MION_CONT_DISABLE="$DISABLE" bitbake ${CONTINUE} ${GUESTS[@]} ${MC_HOST}
}

parse_args "$@"

[ -z "$BBPATH" ] && error "Please source ./openembedded-core/oe-init-build-env first"

build

echo "mc_build.sh - Done."
