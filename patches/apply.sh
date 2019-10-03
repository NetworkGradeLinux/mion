#! /bin/bash
#
# Oryx patch script
#
# Copyright (C) 2019 Togán Labs
# SPDX-License-Identifier: MIT
#

set -e
shopt -s nullglob

REPOLIST=" \
    bitbake \
    openembedded-core \
    meta-openembedded \
    meta-raspberrypi \
    meta-virtualization \
    meta-mender \
    "
PATCHES_DIR="$(realpath $(dirname $0))"

for repo in $REPOLIST; do
    gitdir="$(git -C $repo rev-parse --git-dir)"
    if [[ -e "$gitdir/rebase-apply" ]]; then
        echo "Aborting previous patch application"
        rm -rf "$gitdir/rebase-apply"
    fi
    if [[ -e "$PATCHES_DIR/$repo" ]]; then
        echo "Patching $repo..."
        for p in "$PATCHES_DIR/$repo"/*; do
            git -C $repo am "$p"
        done
    fi
done

echo "Finished applying patches"
