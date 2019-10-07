===============
Getting Started
===============

This section describes how to install and use Oryx Linux on an embedded device.

.. _supported_platforms:

Supported Platforms
===================

This release of Oryx Linux supports all features on the following demonstration
platforms:

* Emulated QEMU systems:

    * ``qemuarm``: 32-bit emulated ARM system.

    * ``qemuarm64``: 64-bit emulated ARM system.

    * ``qemux86``: 32-bit emulated x86 system.

    * ``qemux86-64``: 64-bit emulated x86-64 system.

* Raspberry Pi 3 ARM based systems:

    * ``raspberrypi3``: Raspberry Pi 3 in 32-bit mode.

    * ``raspberrypi3-64``: Raspberry Pi 3 in 64-bit mode.

Installation
============

QEMU Systems
------------

Download the appropriate rootfs and kernel images for the desired QEMU platform
from the v0.5.0 release:

* x86:
  `Rootfs image <https://downloads.toganlabs.com/oryx/distro/0.5.0/qemux86/native/host/oryx-native-host-qemux86.ext4.xz>`__,
  `Kernel image <https://downloads.toganlabs.com/oryx/distro/0.5.0/qemux86/native/host/bzImage-qemux86.bin>`__

* x86-64:
  `Rootfs image <https://downloads.toganlabs.com/oryx/distro/0.5.0/qemux86-64/native/host/oryx-native-host-qemux86-64.ext4.xz>`__,
  `Kernel image <https://downloads.toganlabs.com/oryx/distro/0.5.0/qemux86-64/native/host/bzImage-qemux86-64.bin>`__

* 32-bit ARM:
  `Rootfs image <https://downloads.toganlabs.com/oryx/distro/0.5.0/qemuarm/native/host/oryx-native-host-qemuarm.ext4.xz>`__,
  `Kernel image <https://downloads.toganlabs.com/oryx/distro/0.5.0/qemuarm/native/host/zImage-qemuarm.bin>`__

* 64-bit ARM:
  `Rootfs image <https://downloads.toganlabs.com/oryx/distro/0.5.0/qemuarm64/native/host/oryx-native-host-qemuarm64.ext4.xz>`__,
  `Kernel image <https://downloads.toganlabs.com/oryx/distro/0.5.0/qemuarm64/native/host/Image-qemuarm64.bin>`__

The rootfs image must first be decompressed::

    unxz oryx-native-host-qemux86.ext4.xz

To launch qemu (example for qemux86 target)::

    qemu-system-i386 -kernel bzImage-qemux86.bin -hda oryx-native-host-qemux86.ext4 \
        -append "root=/dev/hda"

For further details on the configuration and use of qemu, see the qemu
documentation.

Raspberry Pi 3
--------------

Download the appropriate SD card image and BMAP file for the Raspberry Pi 3
from the v0.5.0 release:

* 32-bit:
  `SD card image <https://downloads.toganlabs.com/oryx/distro/0.5.0/raspberrypi3/native/host/oryx-native-host-raspberrypi3.wic.xz>`__,
  `BMAP file <https://downloads.toganlabs.com/oryx/distro/0.5.0/raspberrypi3/native/host/oryx-native-host-raspberrypi3.wic.bmap>`__

* 64-bit:
  `SD card image <https://downloads.toganlabs.com/oryx/distro/0.5.0/raspberrypi3-64/native/host/oryx-native-host-raspberrypi3-64.wic.xz>`__,
  `BMAP file <https://downloads.toganlabs.com/oryx/distro/0.5.0/raspberrypi3-64/native/host/oryx-native-host-raspberrypi3-64.wic.bmap>`__

Once the appropriate SD card image has been downloaded, it may be written to
an SD card using bmaptool (in this example the target SD card appears in the
system as ``/dev/sdb`` but this should be replaced by the correct path for
the system in use)::

    bmaptool copy oryx-native-host-raspberrypi3.wic.xz /dev/sdb

The SD card may then be removed and placed into the Raspberry Pi device itself.

Logging In
==========

After installation you can login as ``root`` with the default password
``oryx``.

Adding Guest Containers
=======================

One the Oryx Linux host system has been set up, the ``oryxcmd`` tool may be
used to create guest containers.

Firstly, the appropriate official source for this release should be configured:

* qemux86::

    oryxcmd add_source oryx \
        http://downloads.toganlabs.com/oryx/distro/0.5.0/qemux86

* qemux86-64::

    oryxcmd add_source oryx \
        http://downloads.toganlabs.com/oryx/distro/0.5.0/qemux86-64

* qemuarm::

    oryxcmd add_source oryx \
        http://downloads.toganlabs.com/oryx/distro/0.5.0/qemuarm

* qemuarm64::

    oryxcmd add_source oryx \
        http://downloads.toganlabs.com/oryx/distro/0.5.0/qemuarm64

* raspberrypi3::

    oryxcmd add_source oryx \
        http://downloads.toganlabs.com/oryx/distro/0.5.0/raspberrypi3

* raspberrypi3-64::

    oryxcmd add_source oryx \
        http://downloads.toganlabs.com/oryx/distro/0.5.0/raspberrypi3-64

Once this source is configured, a guest container can be created from one of
the following images:

* ``minimal`` image::

    oryxcmd add_guest test oryx:minimal

* ``full-cmdline`` image::

    oryxcmd add_guest test oryx:full-cmdline

The guest image may then be booted using ``runc`` as follows::

    oryxcmd start_guest test

For further details, see the :ref:`oryxcmd` section.
