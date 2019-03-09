#! /bin/bash

set -e
shopt -s nullglob

REPOLIST="bitbake openembedded-core meta-openembedded meta-raspberrypi meta-virtualization meta-yocto"
PATCHES_DIR=$(realpath $(dirname $0))

for repo in $REPOLIST; do
    for p in "$PATCHES_DIR/$repo"/*; do
        echo "Applying $p"
        git -C $repo am "$p"
    done
done
