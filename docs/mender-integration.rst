.. _mender_integration:

==================
Mender Integration
==================

With version 0.5.0 of Oryx Linux we have added integration with the Mender.io
Over-The-Air (OTA) update system. Further Mender documentation can be found at
https://docs.mender.io.

Building Native Mender Images
=============================

Native Mender images can be built using the ``native-mender`` system profile.
These images include redundant rootfs partitions as well as a data partition as
required by the Mender update system. To use this system profile, the
``--enable-mender`` argument must be passed to the build script to enable use
of the Mender layers.

For example, to build a native Mender image for the Raspberry Pi 3 device using
the ``host`` application profile::

    ./scripts/build.py --enable-mender -M raspberrypi3 -S native-mender -A host

When using the ``native-mender`` system profile, the image filename extension
is typically ``.sdimg.xz`` or ``.uefiimg.xz`` instead of the usual
``.wic.xz`` used by Oryx Linux. The ``sdimg`` format images may be directly
written to an SD card in the same was as ``wic`` images.

Additionally, update artifacts with the filename extension ``.mender`` are
produced for each image. These artifacts are suitable for upload to a Mender
server instance to be pushed out as updates to a fleet of devices.
Alternatively, they can be used directly with ``mender`` on the command line
on a target device to install the updated rootfs image.

Testing With The Mender Demo Server
-----------------------------------

Testing with the Mender demo server requires the default HTTPS certificates
and the demo server IP to be baked into an image at build time. These
modifications are performed when the ``meta-mender-demo`` layer is included in
``BBLAYERS``. Therefore this extra layer must be disabled for normal builds and
enabled for demo builds.

Enabling the ``meta-mender-demo`` layer is currently a manual process,
requiring minor additions to both the ``bblayers.conf`` and ``local.conf``
files in the ``build/conf`` directory. Once these additions have been made,
follow the instructions above to build a native Mender image for the desired
target device.

To enable the required layer, add the following line to ``bblayers.conf``::

    BBLAYERS += "${ORYX_BASE}/meta-mender/meta-mender-demo"

Assuming the demo server IP address is 192.168.0.100, add the following line to
``local.conf``::

    MENDER_DEMO_HOST_IP_ADDRESS = "192.168.0.100"

The IP address in the above assignment should obviously be changed to match
your local test environment.

After building and booting and image with these changes, the target device
should contact the demo server automatically.

Building a Host Image For Use With Mender Update Modules
========================================================

To update guest images using the Mender Update Modules support, the host
image must be built with the ``host-mender-update-modules`` application
profile. To use this application profile, the ``--enable-mender`` argument
must be passed to the build script to enable use of the Mender layers.

For example, to build a host image for the Raspberry Pi 3 supporting both
Mender integration for rootfs updates and Mender Update Modules integration
for guest updates::

    ./scripts/build.py --enable-mender -M raspberrypi3 -S native-mender -A host-mender-update-modules

Building Guest Images For Use With Mender Update Modules
========================================================

For guest images to be updated using the Mender Update Modules support, they
need to be packaged correctly into ``.mender`` artifacts. This packaging is
provided by the ``oryx-mender-update-module`` recipe used by the
``guest-mender-update-module`` system profile. To use this system profile,
the ``--enable-mender`` argument must be passed to the build script to enable
use of the Mender layers.

For example, to build a minimal guest image for the Raspberry Pi 3 for use
with Mender Update Modules::

    ./scripts/build.py --enable-mender -M raspberrypi3 -S guest-mender-update-module -A minimal
