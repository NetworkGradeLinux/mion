#!/bin/sh

#  Copyright (C) 2020 Jonas Gorski <jonas.gorski@bisdn.de>
#
#  SPDX-License-Identifier:     GPL-2.0

BISDN_LINUX_VOLUME_LABEL="BISDN-Linux"

set -e

part_blk_dev() {
    case "$1" in
        *mmcblk*|*nvme*)
            echo "${1}p${2}"
            ;;
        *)
            echo "${1}${2}"
            ;;
    esac
}

# Creates a backup of current network configuration files
#
# arg $1 -- block device
#
# arg $2 -- partition number
#
# sets flag 'DO_RESTORE' to true to enable config restoration at the end

SYSTEMD_NETWORK_CONFDIR="etc/systemd/network"

backup_cfg()
{
    local bisdn_linux_old
    local dev_old
    local file

    echo "Existing installation found!" >&2

    backup_tmp_dir=$(mktemp -d)|| {
        echo "Error: Unable to create temporary configuration storage" >&2
        exit 1
    }
    mkdir -p $backup_tmp_dir/$SYSTEMD_NETWORK_CONFDIR

    bisdn_linux_old=$(mktemp -d) || {
        echo "Error: Unable to create old installation file system mount point" >&2
        exit 1
    }

    dev_old=$(part_blk_dev $1 $2)
    mount $dev_old $bisdn_linux_old || {
        echo "Error: Unable to mount $dev_old on $bisdn_linux_old" >&2
        exit 1
    }

    if [ -d "$bisdn_linux_old/$SYSTEMD_NETWORK_CONFDIR" ] && grep -q -r "^Name=enp" $bisdn_linux_old/$SYSTEMD_NETWORK_CONFDIR; then
        echo "Creating backup of existing management interface configuration"
        for file in $(grep -l -r "^Name=enp" $bisdn_linux_old/$SYSTEMD_NETWORK_CONFDIR); do
            case "$file" in
                *.network)
                    [ -n "$DEBUG" ] && echo "Backing up $file" >&2
                    cp $file $backup_tmp_dir/$SYSTEMD_NETWORK_CONFDIR
                    DO_RESTORE=true
                    ;;
            esac
        done
    fi

    umount $bisdn_linux_old
}
# Restores a backup of current network configuration files
#
# arg $1 -- backup directory
#
# arg $2 -- new installation mount path

restore_cfg()
{
    echo "Restoring backup of existing management configuration" >&2
    cp -r $1/$SYSTEMD_NETWORK_CONFDIR/* $2/$SYSTEMD_NETWORK_CONFDIR
}

detect_bisdn_linux_gpt_partition()
{
    local blk_dev="$1"
    local part

    part=$(sgdisk -p $blk_dev | grep "$BISDN_LINUX_VOLUME_LABEL" | awk '{print $1}')

    echo "$part"
}

delete_bisdn_linux_gpt_partition()
{
    local blk_dev="$1"
    local part_num="$2"

    sgdisk -d $part_num $blk_dev || {
        echo "Error: Unable to delete partition $part_num on $blk_dev" >&2
        exit 1
    }
    partprobe
}

# Creates a new partition for the BISDN Linux OS.
#
# arg $1 -- base block device
#
# arg $2 -- size of the partion
#
# Outputs the created partition number

create_bisdn_linux_gpt_partition()
{
    local blk_dev="$1"
    local size="$2"
    local last_part attr_bitmask part b

    # Find next available partition
    last_part=$(sgdisk -p $blk_dev | tail -n 1 | awk '{print $1}')
    # empty table will catch the header instead
    [ "$last_part" = "Number" ] && last_part=0
    part=$(( $last_part + 1 ))

    # Create new partition
    echo "Creating new BISDN Linux partition ${blk_dev}$part ..." >&2

    attr_bitmask="0x0"

    sgdisk --new=${part}::+${size}MB \
        --attributes=${part}:=:$attr_bitmask \
        --change-name=${part}:$BISDN_LINUX_VOLUME_LABEL $blk_dev > /dev/null || {
        echo "Error: Unable to create partition $part on $blk_dev" >&2
        exit 1
    }
    partprobe

    if [ "$onie_firmware_type" = "uefi" ] ; then
        # erase any related EFI BootOrder variables from NVRAM.
        for b in $(efibootmgr | grep "$BISDN_LINUX_VOLUME_LABEL" | awk '{ print $1 }') ; do
            local num=${b#Boot}
            # Remove trailing '*'
            num=${num%\*}
            efibootmgr -b $num -B > /dev/null 2>&1
        done
    fi

    echo "$part"
}

detect_bisdn_linux_msdos_partition()
{
    local blk_dev="$1"
    local label="$2"
    local bisdn_linux_part=""
    local part_info

    part_info="$(blkid | grep $label | awk -F: '{print $1}')"
    if [ -n "$part_info" ] ; then
        bisdn_linux_part="$(echo -n $part_info | sed -e s#${blk_dev}##)"
    fi

    echo "$bisdn_linux_part"
}

delete_bisdn_linux_msdos_partition()
{
    local blk_dev="$1"
    local part_num="$2"

    parted -s $blk_dev rm $part_num || {
        echo "Error: Unable to delete partition $part_num on $blk_dev" >&2
        exit 1
    }
    partprobe
}

# Creates a new partition for the BISDN Linux OS.
#
# arg $1 -- base block device
#
# arg $2 -- size of the partion
#
# Outputs the created partition number

create_bisdn_linux_msdos_partition()
{
    local blk_dev="$1"
    local label="$2"
    local size="$3"
    local sectors_per_mb last_part part part_info last_part_end part_start part_end

    # Find next available partition
    part_info="$(parted -s -m $blk_dev unit s print | tail -n 1)"
    last_part="$(echo -n $part_info | awk -F: '{print $1}')"
    last_part_end="$(echo -n $part_info | awk -F: '{print $3}')"
    # Remove trailing 's'
    last_part_end=${last_part_end%s}
    part=$(( $last_part + 1 ))
    part_start=$(( $last_part_end + 1 ))
    # sectors_per_mb = (1024 * 1024) / 512 = 2048
    sectors_per_mb=2048
    part_end=$(( $part_start + ( $size * $sectors_per_mb ) - 1 ))

    # Create new partition
    echo "Creating new BISDN Linux partition ${blk_dev}$bisdn_linux_part ..." >&2
    parted -s --align optimal $blk_dev unit s \
      mkpart primary $part_start $part_end set $part boot on || {
        echo "ERROR: Problems creating BISDN Linux msdos partition $part on: $blk_dev" >&2
        exit 1
    }
    partprobe

    echo "$part"
}

# default platform functions

platform_check()
{
    /bin/true
}

platform_detect_boot_device()
{
   /bin/true
}

platform_erase_disk()
{
    /bin/true
}

platform_install_bootloader_entry()
{
    /bin/true
}

cd $(dirname $0)
. ./machine.conf
. ./platform.sh

echo "BISDN Linux Installer: platform: $platform"

part_size=${BISDN_PART_SIZE:-4096}
fs_type="${BISDN_FS_TYPE:-ext4}"

platform_check

boot_dev=$(platform_detect_boot_device)
[ -n "$boot_dev" ] || {
    echo "ERROR: failed to detect boot device!" >&2
}
# determine ONIE partition type
onie_partition_type=$(onie-sysinfo -t)
# determine ONIE firmware type
onie_firmware_type=$(platform_get_firmware_type)

if [ "$onie_partition_type" = "gpt" ] ; then
    detect_bisdn_linux_partition="detect_bisdn_linux_gpt_partition"
    create_bisdn_linux_partition="create_bisdn_linux_gpt_partition"
    delete_bisdn_linux_partition="delete_bisdn_linux_gpt_partition"
elif [ "$onie_partition_type" = "msdos" ] ; then
    detect_bisdn_linux_partition="detect_bisdn_linux_msdos_partition"
    create_bisdn_linux_partition="create_bisdn_linux_msdos_partition"
    delete_bisdn_linux_partition="delete_bisdn_linux_msdos_partition"
else
    echo "ERROR: Unsupported partition type: $onie_partition_type" >&2
    exit 1
fi

[ -n $DEBUG ] && echo "DEBUG: onie_partition_type=${onie_partition_type}" >&2
[ -n $DEBUG ] && echo "DEBUG: firmware=${onie_firmware_type}" >&2

# do only restore if backup has been created
DO_RESTORE=false

# See if BISDN Linux partition already exists
old_part=$(eval $detect_bisdn_linux_partition $boot_dev)
if [ -n "$old_part" ]; then
    # backup existing config
    backup_cfg $boot_dev $old_part
    # delete existing partition
    eval $delete_bisdn_linux_partition $boot_dev $old_part
fi

platform_erase_disk

bisdn_linux_part=$(eval $create_bisdn_linux_partition $boot_dev $part_size)
bisdn_linux_dev=$(part_blk_dev $boot_dev $bisdn_linux_part)

[ -n $DEBUG ] && echo "DEBUG: bisdn_linux_dev=${bisdn_linux_dev}"
[ -n $DEBUG ] && echo "DEBUG: fs_type=${fs_type}"

# Mount BISDN Linux filesystem
bisdn_linux_mnt=$(mktemp -d) || {
    echo "Error: Unable to create BISDN Linux file system mount point" >&2
    exit 1
}

# Create filesystem on BISDN Linux partition with a label
mkfs.$fs_type -L $BISDN_LINUX_VOLUME_LABEL $bisdn_linux_dev || {
    echo "Error: Unable to create file system on $bisdn_linux_dev" >&2
    exit 1
}

mount -t $fs_type -o defaults,rw $bisdn_linux_dev $bisdn_linux_mnt || {
    echo "Error: Unable to mount $bisdn_linux_dev on $bisdn_linux_mnt" >&2
    exit 1
}

# install fs
if [ -f rootfs.cpio.gz ] ; then
    image_archive=$(realpath rootfs.cpio.gz)
    cd $bisdn_linux_mnt
    zcat $image_archive | cpio -i
    cd -
elif [ -f rootfs.tar.xz ] ; then
    xzcat rootfs.tar.xz | tar xf - -C $bisdn_linux_mnt
else
    echo "Error: Invalid root fs" >&2
    exit 1
fi

# store installation log in BISDN Linux file system
onie-support $bisdn_linux_mnt

# activate the installation
platform_install_bootloader_entry $boot_dev $bisdn_linux_part $bisdn_linux_mnt $fs_type

# Restore the network configuration from previous installation
if [ "${DO_RESTORE}" = true ]; then
    restore_cfg $backup_tmp_dir $bisdn_linux_mnt
fi;

# clean up
umount $bisdn_linux_mnt || {
    echo "Warning: Problems umounting $bisdn_linux_mnt" >&2
}

cd /

# Set NOS mode if available.  For manufacturing diag installers, you
# probably want to skip this step so that the system remains in ONIE
# "installer" mode for installing a true NOS later.
if [ "$BISDN_ENABLE_NOS_MODE" = "1" ] && [ -x /bin/onie-nos-mode ] ; then
    /bin/onie-nos-mode -s
fi
