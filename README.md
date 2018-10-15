Welcome to Oryx Linux!
======================

This is the root directory of the Oryx Linux source tree. It is composed of
sub-repositories from both Oryx Linux itself and The Yocto Project.

Quickstart
----------

1) Follow the Yocto Project Quick Start guide (available from
   https://www.yoctoproject.org/docs/2.5.1/brief-yoctoprojectqs/brief-yoctoprojectqs.html)
   to ensure that your system is capable of building images using The Yocto
   Project.

2) Prepare the environment for an Oryx Linux build as follows:

    source build/conf/setenv

3) Build a minimal image for a supported platform such as a Raspberry Pi 3 as
   follows:

    ./scripts/run-build.py -M raspberrypi3

4) Run bitbake commands directly if needed, for example to build just the Linux
   kernel for a Raspberry Pi device, as follows:

    MACHINE=raspberrypi3 bitbake linux-raspberrypi

Documentation
-------------

Full documentation is available in the following locations:

* HTML (read online): https://downloads.toganlabs.com/oryx/docs/0.4.0/html/

* HTML (download): https://downloads.toganlabs.com/oryx/docs/0.4.0/oryx-linux-docs-html-0.4.0.tar.gz

* PDF: https://downloads.toganlabs.com/oryx/docs/0.4.0/pdf/OryxLinux-0.4.0.pdf

Support
-------

Oryx Linux is developed and maintained by Togán Labs.

For support requests, bug reports or other feedback please open an issue in the
Oryx issue tracker (https://gitlab.com/oryx/oryx/issues) or contact us at
support@toganlabs.com.

To submit patches, please see the README file in the appropriate sub-repository.

Sub-repositories
----------------

Each of the following directories found in the top-level of the Oryx Linux
source tree is a separate git repository. Consult the README files in each of
these directories for further information.

* bitbake: OpenEmbedded build tool.

* openembedded-core: Common OpenEmbedded metadata layer.

* meta-openembedded: Additional OpenEmbedded metadata layers.

* meta-virtualization: OpenEmbedded layer for virtualization components
  including runc.

* meta-raspberrypi: Raspberry Pi hardware support.

* meta-oryx: Oryx Linux distribution metadata.

* build: Build scripts and configuration.
