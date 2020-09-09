#!/bin/bash
#set -x
set -e

error() { echo "ERROR: $1" >&2; exit 1; }

info() { echo "INFO: $1"; }

usage(){
    cat <<EOF
build.sh
    -e (optional emit bitbake line. Doesn't run a build, just emits what would run.)
    -m machine
    -c container_mc_config:container_image[,container_mc_config:container_image,...]
    -h host_mc_config:host_image
    -d container_image[,container_image]    (optional disable autostart for specified containers)
EOF
    exit
}

parse_args(){
    [ $# -eq 0 ] && usage

    while getopts ":em:h:c:d:" opt; do
        case ${opt} in
            e ) EMIT="1" ;;		
            m ) MACHINE=$OPTARG ;;
            h ) HOST=$OPTARG ;;
            c ) CONTAINERS=$OPTARG ;;
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
    CONTAINER_DEPENDS=""
    BB_MC_CONTAINERS=""
    BBMULTICONFIG=""
    CONTAINER_NAMES="" 
    if [ ! -z "$HOST" ]; then
        HOSTCONFIG=$(echo "$HOST" | cut -d':' -f1)
	    BBMULTICONFIG="$BBMULTICONFIG $HOSTCONFIG"
    fi 

    IFS=","
    if [ ! -z "$CONTAINERS" ]; then
        for i in $CONTAINERS; do
            CONFIG=$(echo "$i" | cut -d':' -f1)
            IMAGE=$(echo "$i" | cut -d':' -f2)
            CONTAINER_NAMES="$CONTAINER_NAMES $IMAGE"
	    BBMULTICONFIG="$BBMULTICONFIG $CONFIG"
	    BB_MC_CONTAINERS="mc:$CONFIG:$IMAGE $BB_MC_CONTAINERS"
	    if [ ! -z "$HOST" ]; then
                CONTAINER_DEPENDS="$CONTAINER_DEPENDS $IMAGE-pkg"
            fi
        done
    fi 

    HOST_MC_LINE=""
    if [ ! -z "$HOST" ]; then
        HOST_MC_LINE="mc:$HOST"
    fi

    CD_LINE=""
    if [ ! -z "$HOST" ]; then
        CD_LINE="CONTAINER_DEPENDS=\"$CONTAINER_DEPENDS\""
    fi


    if [ -z "$EMIT" ]; then
	    exec env BB_ENV_EXTRAWHITE="$BB_ENV_EXTRAWHITE CONTAINER_NAMES CONTAINER_DEPENDS BBMULTICONFIG MION_CONT_DISABLE" BBMULTICONFIG="$BBMULTICONFIG" CONTAINER_NAMES="$CONTAINER_NAMES" "$CD_LINE" MACHINE="$MACHINE" MION_CONT_DISABLE="$DISABLE" bitbake $BB_MC_CONTAINERS $HOST_MC_LINE
    else
    cat <<EOF
    The bitbake command we would have run is:
    BB_ENV_EXTRAWHITE="$BB_ENV_EXTRAWHITE CONTAINER_NAMES CONTAINER_DEPENDS BBMULTICONFIG MION_CONT_DISABLE" BBMULTICONFIG="$BBMULTICONFIG" CONTAINER_NAMES="$CONTAINER_NAMES" "$CD_LINE" MACHINE="$MACHINE" MION_CONT_DISABLE="$DISABLE" bitbake $BB_MC_CONTAINERS $HOST_MC_LINE
EOF
fi
    }


parse_args "$@"

[ -z "$BBPATH" ] && error "You need to source ./openembedded-core/oe-init-build-env first"

build

