#!/bin/sh
set -e

github_url="git@github.com:NetworkGradeLinux"

repos="
    meta-mion
    meta-mion-bsp
    meta-mion-backports
    meta-mion-sde
    mion-docs
    mion-testing
"

for r in $repos; do
    git clone "${github_url}/${r}.git" || exit 1
    echo
done
