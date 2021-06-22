#!/bin/sh
set -e

# Sinple script to update all mion repos - must be run from the top level mion
# repo and assumes that all repos are on the relevant branch

repos=" 
    meta-mion 
    meta-mion-backports 
    meta-mion-bsp 
    meta-mion-sde 
    mion-ci
    mion-docs
    mion-testing
"

printf "mion -> " && git rev-parse --abbrev-ref HEAD
git pull || exit 1
echo

for r in $repos; do 
    ( 
        [ -d "$r" ] && cd "$r"
        printf "%s -> " "$r" && git rev-parse --abbrev-ref HEAD
        git pull --ff-only || exit 1
        echo
    )
done
