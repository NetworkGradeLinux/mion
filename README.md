Welcome to Oryx Linux!
======================

This is the root directory of the Oryx Linux source tree. It is composed of
sub-repositories from both Oryx Linux itself and The Yocto Project.

Quickstart
----------

1) Follow the Yocto Project Quick Start guide (available from
   https://www.yoctoproject.org/docs/2.7/brief-yoctoprojectqs/brief-yoctoprojectqs.html)
   to ensure that your system is capable of building images using The Yocto
   Project.

2) Build a minimal guest image for a supported platform such as a Raspberry Pi 3
   as follows:

        ./scripts/build.py -M raspberrypi3 -S guest -A minimal

3) Build a host image for the same platform as follows:

        ./scripts/build.py -M raspberrypi3 -S native -A host

4) Start a shell to run bitbake commands directly if needed, for example to
   build just the Linux kernel for a Raspberry Pi device, as follows:

        ./scripts/build.py -M raspberrypi3 --shell
        bitbake linux-raspberrypi

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
