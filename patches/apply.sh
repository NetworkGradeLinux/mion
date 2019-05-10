#! /bin/bash

set -e
shopt -s nullglob

REPOLIST="bitbake openembedded-core meta-openembedded meta-raspberrypi meta-virtualization"
PATCHES_DIR="$(realpath $(dirname $0))"

for repo in $REPOLIST; do
    gitdir="$(git -C $repo rev-parse --git-dir)"
    if [[ -e "$gitdir/rebase-apply" ]]; then
        echo "Aborting previous patch application"
        rm -rf "$gitdir/rebase-apply"
    fi
    for p in "$PATCHES_DIR/$repo"/*; do
        echo "Applying $p"
        git -C $repo am "$p"
    done
done
