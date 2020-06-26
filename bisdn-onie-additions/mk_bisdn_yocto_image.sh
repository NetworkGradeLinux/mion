#!/bin/bash
#
#  Copyright (C) 2013,2014,2015 Curt Brune <curt@cumulusnetworks.com>
#  Copyright (C) 2015 david_yang <david_yang@accton.com>
#  Copyright (C) 2016 Pankaj Bansal <pankajbansal3073@gmail.com>
#
#  SPDX-License-Identifier:     GPL-2.0

#defaults if not set; overridden by platform.conf
[ -z "$BISDN_ARCH" ] && export BISDN_ARCH=x86_64

[ -z "$BISDN_ONIE_PLATFORM" ] && export BISDN_ONIE_PLATFORM="unknown_platform"

MACHINE=$1
shift

platform_conf="./bisdn/machine/${PLATFORM_VENDOR}/${MACHINE}/platform.conf"
output_file="onie-bisdn-${MACHINE}.bin"

if  [ ! -d ./bisdn/installer ] || \
    [ ! -r ./bisdn/installer/sharch_body.sh ] ; then
    echo "Error: Invalid installer script directory: ./bisdn/installer"
    exit 1
fi

if  [ ! -d ./bisdn/installer/${BISDN_ARCH} ] || \
    [ ! -r ./bisdn/installer/${BISDN_ARCH}/install.sh ] ; then
    echo "Error: Invalid arch installer directory: ./bisdn/installer/${BISDN_ARCH}"
    exit 1
fi

[ -r "$platform_conf" ] || {
    echo "Error: Unable to read installer platform configuration file: $platform_conf"
    exit 1
}

[ $# -gt 0 ] || {
    echo "Error: No OS image files found"
    exit 1
}

tmp_dir=
clean_up()
{
    rm -rf $tmp_dir
    exit $1
}

# make the data archive
# contents:
#   - kernel and initramfs
#   - install.sh
#   - $platform_conf

echo -n "Building self-extracting install image ."
tmp_dir=$(mktemp --directory)
tmp_installdir="$tmp_dir/installer"
mkdir $tmp_installdir || clean_up 1

cp ./bisdn/installer/${BISDN_ARCH}/install.sh $tmp_installdir/platform.sh || clean_up 1
cp ./bisdn/installer/install.sh $tmp_installdir || clean_up 1

cp $* $tmp_installdir || clean_up 1
echo -n "."
cp $platform_conf $tmp_installdir || clean_up 1
echo "platform=${BISDN_ONIE_PLATFORM}" >> $tmp_installdir/machine.conf
echo -n "."

sharch="$tmp_dir/sharch.tar"
tar -C $tmp_dir -cf $sharch installer || {
    echo "Error: Problems creating $sharch archive"
    clean_up 1
}
echo -n "."

[ -f "$sharch" ] || {
    echo "Error: $sharch not found"
    clean_up 1
}
sha1=$(cat $sharch | sha1sum | awk '{print $1}')
echo -n "."
cp ./bisdn/installer/sharch_body.sh $output_file || {
    echo "Error: Problems copying sharch_body.sh"
    clean_up 1
}

# Replace variables in the sharch template
build_date=`date +%Y-%m-%d`
sed -i -e "s/%%BUILD_DATE%%/$build_date/" $output_file
sed -i -e "s/%%IMAGE_SHA1%%/$sha1/" $output_file
echo -n "."
cat $sharch >> $output_file
rm -rf $tmp_dir
echo " Done."

echo "Success:  BISDN Linux install image is ready in ${output_file}:"
ls -l ${output_file}

clean_up 0
