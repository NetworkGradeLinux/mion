================
Using Oryx Linux
================

This section describes how to install and use Oryx Linux on an embedded device.

.. _supported_platforms:

Supported Platforms
===================

This release of Oryx Linux supports all features on the following demonstration
platforms:

* Emulated x86 systems using QEMU:

    * ``qemux86``: 32-bit emulated x86 system.

    * ``qemux86-64``: 64-bit emulated x86-64 system.

* Raspberry Pi 32-bit ARM based systems:

    * ``raspberrypi``: The original Raspberry Pi Model.

    * ``raspberrypi2``: Raspberry Pi 2.

    * ``raspberrypi3``: Raspberry Pi 3 in 32-bit mode.

    * ``raspberrypi3-64``: Raspberry Pi 3 in 64-bit mode.

* Beaglebone Black ARM based system:

    * ``beaglebone-yocto``: Beaglebone Black.

Installation and Getting Started
================================

qemux86
-------

Download the appropriate kernel and rootfs images for the desired QEMU platform
from the v0.4.0 release:

* `Kernel image [32-bit x86]
  <https://downloads.toganlabs.com/oryx/distro/0.4.0/qemux86/native/host/bzImage-qemux86.bin>`_

* `Kernel image [64-bit x86-64]
  <https://downloads.toganlabs.com/oryx/distro/0.4.0/qemux86-64/native/host/bzImage-qemux86-64.bin>`_

* `Rootfs image [32-bit x86]
  <https://downloads.toganlabs.com/oryx/distro/0.4.0/qemux86/native/host/oryx-native-host-qemux86.ext4.xz>`_

* `Rootfs image [64-bit x86-64]
  <https://downloads.toganlabs.com/oryx/distro/0.4.0/qemux86-64/native/host/oryx-native-host-qemux86-64.ext4.xz>`_

The rootfs image must first be decompressed::

    unxz oryx-native-host-qemux86.ext4.xz

To launch qemu::

    qemu-system-i386 -kernel bzImage-qemux86.bin -hda oryx-native-host-qemux86.ext4 \
        -append "root=/dev/hda"

For further details on the configuration and use of qemu, see the qemu
documentation.

Raspberry Pi
------------

Download the appropriate SD card image for the desired Raspberry Pi model from
the v0.4.0 release:

* `SD card image [raspberrypi]
  <https://downloads.toganlabs.com/oryx/distro/0.4.0/raspberrypi/native/host/oryx-native-host-raspberrypi.rpi-sdimg.xz>`_

* `SD card image [raspberrypi2]
  <https://downloads.toganlabs.com/oryx/distro/0.4.0/raspberrypi2/native/host/oryx-native-host-raspberrypi2.rpi-sdimg.xz>`_

* `SD card image [raspberrypi3]
  <https://downloads.toganlabs.com/oryx/distro/0.4.0/raspberrypi3/native/host/oryx-native-host-raspberrypi3.rpi-sdimg.xz>`_

* `SD card image [raspberrypi3-64]
  <https://downloads.toganlabs.com/oryx/distro/0.4.0/raspberrypi3-64/native/host/oryx-native-host-raspberrypi3-64.rpi-sdimg.xz>`_

Once the appropriate SD card image has been downloaded, it must first be
decompressed::

    unxz oryx-native-host-raspberrypi.rpi-sdimg.xz

The uncompressed SD card image should then be written to an appropriate SD card
(in this example the target SD card appears in the system as ``/dev/sdb`` but
this should be replaced by the correct path for the system in use)::

    dd if=oryx-native-host-raspberrypi.rpi-sdimg of=/dev/sdb bs=1M

The SD card may then be removed and placed into the Raspberry Pi device itself.

Beaglebone Black
----------------

Download the SD card image for the Beaglebone Black from the v0.4.0 release:

* `SD card image
  <https://downloads.toganlabs.com/oryx/distro/0.4.0/beaglebone-yocto/native/host/oryx-native-host-beaglebone-yocto.wic.xz>`_

Once the appropriate SD card image has been downloaded, it must first be
decompressed::

    unxz oryx-native-host-beaglebone-yocto.wic.xz

The uncompressed SD card image should then be written to an appropriate SD card
(in this example the target SD card appears in the system as ``/dev/sdb`` but
this should be replaced by the correct path for the system in use)::

    dd if=oryx-native-host-beaglebone-yocto.wic of=/dev/sdb bs=1M

The SD card may then be removed and placed into the Beaglebone Black device
itself.

Logging In
==========

After installation you can login as ``root`` with the default password ``oryx``.


Adding Guest Containers
=======================

One the Oryx Linux host system has been set up, the :ref:`oryxcmd` tool may be
used to create guest containers.

Firstly, the appropriate official source for this release should be configured:

* qemux86::

    oryxcmd add_source oryx \
        http://downloads.toganlabs.com/oryx/distro/0.4.0/qemux86

* raspberrypi::

    oryxcmd add_source oryx \
        http://downloads.toganlabs.com/oryx/distro/0.4.0/raspberrypi

* raspberrypi2::

    oryxcmd add_source oryx \
        http://downloads.toganlabs.com/oryx/distro/0.4.0/raspberrypi2

* raspberrypi3::

    oryxcmd add_source oryx \
        http://downloads.toganlabs.com/oryx/distro/0.4.0/raspberrypi3

* raspberrypi3-64::

    oryxcmd add_source oryx \
        http://downloads.toganlabs.com/oryx/distro/0.4.0/raspberrypi3-64

* beaglebone-yocto::

    oryxcmd add_source oryx \
        http://downloads.toganlabs.com/oryx/distro/0.4.0/beaglebone-yocto

Once this source is configured, a guest container can be created from one of the
following images:

* ``minimal`` image::

    oryxcmd add_guest test oryx:minimal

* ``full-cmdline`` image::

    oryxcmd add_guest test oryx:full-cmdline

The guest image may then be booted using ``runc`` as follows::

    oryxcmd runc test run test

For further details, see the full documentation for the :ref:`oryxcmd` tool.
