#!/bin/sh

#  Copyright (C) 2014-2015 Curt Brune <curt@cumulusnetworks.com>
#  Copyright (C) 2014-2015 david_yang <david_yang@accton.com>
#
#  SPDX-License-Identifier:     GPL-2.0

set -e

DEBUG=1
BISDN_ENABLE_NOS_MODE=

# Install legacy BIOS GRUB for BISDN Linux OS
bisdn_linux_install_grub()
{
    local bisdn_linux_mnt="$1"
    local blk_dev="$2"

    # Pretend we are a major distro and install GRUB into the MBR of
    # $blk_dev.
    grub-install --boot-directory="$bisdn_linux_mnt" --recheck "$blk_dev" || {
        echo "ERROR: grub-install failed on: $blk_dev"
        exit 1
    }
}

# Install UEFI BIOS GRUB for BISDN Linux OS
bisdn_linux_install_uefi_grub()
{
    local bisdn_linux_mnt="$1"
    local blk_dev="$2"

    # Look for the EFI system partition UUID on the same block device as
    # the ONIE-BOOT partition.
    local uefi_part=0
    for p in $(seq 8) ; do
        if sgdisk -i $p $blk_dev | grep -q C12A7328-F81F-11D2-BA4B-00A0C93EC93B ; then
            uefi_part=$p
            break
        fi
    done

    [ $uefi_part -eq 0 ] && {
        echo "ERROR: Unable to determine UEFI system partition"
        exit 1
    }

    grub_install_log=$(mktemp)
    grub-install \
        --no-nvram \
        --bootloader-id="$BISDN_LINUX_VOLUME_LABEL" \
        --efi-directory="/boot/efi" \
        --boot-directory="$bisdn_linux_mnt" \
        --recheck \
        "$blk_dev" > /$grub_install_log 2>&1 || {
        echo "ERROR: grub-install failed on: $blk_dev"
        cat $grub_install_log && rm -f $grub_install_log
        exit 1
    }
    rm -f $grub_install_log

    # Configure EFI NVRAM Boot variables.  --create also sets the
    # new boot number as active.
    efibootmgr --quiet --create \
        --label "$BISDN_LINUX_VOLUME_LABEL" \
        --disk $blk_dev --part $uefi_part \
        --loader "/EFI/$BISDN_LINUX_VOLUME_LABEL/grubx64.efi" || {
        echo "ERROR: efibootmgr failed to create new boot variable on: $blk_dev"
        exit 1
    }

}

platform_detect_boot_device()
{
    # Install BISDN Linux on same block device as ONIE
    blk_dev=$(blkid | grep ONIE-BOOT | awk '{print $1}' |  sed -e 's/[1-9][0-9]*:.*$//' | sed -e 's/\([0-9]\)\(p\)/\1/' | head -n 1)

    [ -b "$blk_dev" ] || {
        echo "Error: Unable to determine block device of ONIE install"
        exit 1
    }

    echo "$blk_dev"
}

platform_get_firmware_type()
{
    local firmware

    # auto-detect whether BIOS or UEFI
    if [ -d "/sys/firmware/efi/efivars" ] ; then
        firmware="uefi"
    else
        firmware="bios"
    fi

    echo "$firmware"
}

platform_install_bootloader_entry()
{
    local blk_dev=$1
    local bisdn_linux_part=$2
    local bisdn_linux_mnt=$3
    local fs_type=$4

    bisdn_linux_part_uuid=$(blkid | grep 'LABEL="'$BISDN_LINUX_VOLUME_LABEL'"' | sed -e 's/^.*UUID="//' -e 's/".*//')

    [ -n $DEBUG ] && echo "DEBUG: bisdn_linux_part_uuid=${bisdn_linux_part_uuid}"
    [ -n $DEBUG ] && echo "DEBUG: bisdn_linux_part=${bisdn_linux_part}"

    if [ ! -f $bisdn_linux_mnt/boot/bzImage ] ; then
        echo "Error: No kernel image in root fs"
        exit 1
    fi
        if [ ! -f $bisdn_linux_mnt/lib/systemd/systemd ] ; then
        echo "Error: No systemd found in root fs"
        exit 1
    fi

    if [ "$onie_firmware_type" = "uefi" ] ; then
        bisdn_linux_install_uefi_grub "$bisdn_linux_mnt/boot" "$blk_dev"
    else
        bisdn_linux_install_grub "$bisdn_linux_mnt/boot" "$blk_dev"
    fi

    # Create a minimal grub.cfg that allows for:
    #   - configure the serial console
    #   - allows for grub-reboot to work
    #   - a menu entry for the BISDN Linux OS
    #   - menu entries for ONIE

    grub_cfg=$(mktemp)

    # Set a few GRUB_xxx environment variables that will be picked up and
    # used by the 50_onie_grub script.  This is similiar to what an OS
    # would specify in /etc/default/grub.
    #
    # GRUB_SERIAL_COMMAND
    # GRUB_CMDLINE_LINUX

    [ -r ./platform.conf ] && . ./platform.conf

    export GRUB_SERIAL_COMMAND
    export GRUB_CMDLINE_LINUX
    export EXTRA_CMDLINE_LINUX

    # Add common configuration, like the timeout and serial console.
    (cat <<EOF
$GRUB_SERIAL_COMMAND
terminal_input serial
terminal_output serial

set timeout=5

EOF
    ) > $grub_cfg

    # Add the logic to support grub-reboot
    (cat <<EOF
if [ -s \$prefix/grubenv ]; then
  load_env
fi
if [ "\${next_entry}" ] ; then
   set default="\${next_entry}"
   set next_entry=
   save_env next_entry
   set boot_once=true
else
   set default="\${saved_entry}"
fi

if [ "\${prev_saved_entry}" ]; then
  set saved_entry="\${prev_saved_entry}"
  save_env saved_entry
  set prev_saved_entry=
  save_env prev_saved_entry
  set boot_once=true
fi

EOF
    ) >> $grub_cfg

    (cat <<EOF
onie_partition_type=${onie_partition_type}
export onie_partition_type

function entry_start {
  insmod gzio
  insmod ext2
  if [ "\$onie_partition_type" = "gpt" ] ; then
    insmod part_gpt
    set root='(hd0,gpt${bisdn_linux_part})'
  else
    insmod part_msdos
    set root='(hd0,msdos${bisdn_linux_part})'
  fi
}

EOF
    ) >> $grub_cfg

    # Add a menu entry for the BISDN Linux OS
    bisdn_linux_grub_entry="BISDN Linux"
    part_unique_guid=$(sgdisk -i ${bisdn_linux_part} ${blk_dev} | grep 'Partition unique GUID' | cut -d\  -f 4)
    # XXX eventually s/rootwait/rootdelay/
    (cat <<EOF
menuentry '$bisdn_linux_grub_entry' {
        entry_start
        search --no-floppy --fs-uuid --set=root $bisdn_linux_part_uuid
        echo    'Loading BISDN Linux...'
        linux   /boot/bzImage $GRUB_CMDLINE_LINUX rootfstype=${fs_type} root=PARTUUID=${part_unique_guid} rootwait $EXTRA_CMDLINE_LINUX
}
EOF
    ) >> $grub_cfg

    # Add menu entries for ONIE -- use the grub fragment provided by the
    # ONIE distribution.
    /mnt/onie-boot/onie/grub.d/50_onie_grub >> $grub_cfg

    cp $grub_cfg $bisdn_linux_mnt/boot/grub/grub.cfg
}
