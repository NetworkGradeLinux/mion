#! /bin/bash

set -e
set -o pipefail

VERSION=$1

if [[ -z "$VERSION" ]]; then
    VERSION=snapshot
fi

# Run a really clean build to ensure that all necessary sources end up in the
# downloads directory
rm -rf downloads sstate-cache

do_oryx_full() {
    MACHINE=$1
    ./scripts/run-build.py -C -L -V $VERSION -M $MACHINE -A host
    ./scripts/run-build.py -C -L -V $VERSION -M $MACHINE -A host-test
    ./scripts/run-build.py -C -L -V $VERSION -M $MACHINE -S guest -A full-cmdline
    ./scripts/run-build.py -C -L -V $VERSION -M $MACHINE -S guest -A minimal
}

do_oryx_full qemux86
do_oryx_full raspberrypi3
do_oryx_full raspberrypi3-64
do_oryx_full beaglebone-yocto

# Sync the relevant files from the downloads directory into a "sources"
# directory
mkdir -p pub/$VERSION/downloads
find downloads -maxdepth 1 -type f -not -name *.done -exec ln -f {} pub/$VERSION/{} \;
mv pub/$VERSION/downloads pub/$VERSION/sources

# Capture bitbake and layers
git -C .. archive-all --prefix oryx-$VERSION/ build/pub/$VERSION/oryx-$VERSION.tar.xz
