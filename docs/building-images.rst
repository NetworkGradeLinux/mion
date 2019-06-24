.. _building_oryx_images:

==========================
Building Oryx Linux Images
==========================

Oryx Linux introduces two major new concepts to the OpenEmbedded build system:
these are `System Profiles`_ and `Application Profiles`_. This section will also
discuss how these concepts are integrated into the `OpenEmbedded Recipes`_ in
the ``meta-oryx`` layer.

.. _system_profiles:

System Profiles
===============

A system profile complements the OpenEmbedded machine selection and essentially
specifies how the image we are building will be deployed onto the selected
machine. Many platforms may be booted in multiple ways (local boot from flash
memory vs remote boot via tftp for instance) and a system profile may be used to
specify a boot mechanism. Additionally, an image may run under different
virtualisation methods on a given platform and a system profile may be used to
specify the chosen method. In each case the system profile will ensure that the
correct build artifacts are produced to match how the image will be used. As
system profiles are orthogonal to machine selection, consistent boot or
virtualisation methods may be enforced across multiple platforms.

Two system profiles are provided in this release:

* ``native``: This profile indicates that the image will run "bare metal" on the
  chosen platform. Build artifacts suitable for writing to an SD card, USB stick
  or embedded flash memory are produced and are then compressed to save space.
  When possible, u-boot is enabled to provide greater boot-time flexibility.

* ``guest``: This profile indicates that the image will run as a container guest
  under runc. No bootloader or kernel is compiled for this profile. Build
  artifacts are always compressed tar archives of a rootfs, ready for
  installation onto a host system.

The system profile is determined by the ``ORYX_SYSTEM_PROFILE`` variable.

Porting the native System Profile
---------------------------------

When porting Oryx Linux to new target platforms it is usually necessary to
modify the native system profile. The following variables need to be correctly
defined for each target platform:

* ``IMAGE_FSTYPES``: This variable determines the format of the rootfs image
  which is created. For physical devices this is usually a complete image,
  including kernel and bootloader, ready to be directly copied into flash memory
  or onto an SD Card or USB stick. However for emulated targets this may simply
  be a filesystem image. For officially supported platforms, ``xz`` compression
  is usually used to reduce the storage and bandwidth requirements on our
  servers.

* ``ORYX_ROOTFS_IMAGE``: This is the filename of the main rootfs image as
  produced by bitbake for the target platform. The existing values
  for supported platforms may be used for reference as the filename typically
  only differs in the extension (which is determined by the value of
  ``IMAGE_FSTYPES``). However, the filename can be changed completely if the
  rootfs artifact for the target platform is not named in the usual way.

* ``ORYX_KERNEL_IMAGE``: The is the filename of the kernel image as produced by
  bitbake for the target platforms. Where the rootfs image contains the kernel
  and bootloader this is usually left empty.

Most platforms can be supported with modification of just the above variables.
If further customisation is needed, see the following section on `Writing System
Profiles`_.

Writing System Profiles
-----------------------

The existing ``native`` and ``guest`` system profiles are suitable for most use
cases but it may occasionally be necessary to create new profiles.

The key variables in a system profile are as follows:

* ``ORYX_SYSTEM_PROFILE_PACKAGES``: This is the list of additional packages to
  install into the rootfs for this system profile.

* ``ORYX_SYSTEM_PROFILE_PUBLISH_DEPENDS``: This is the list of bitbake tasks
  which must be completed before attempting to publish artifacts. Typically it
  will contain the ``oryx-image:do_build`` task which will create the rootfs
  image and all its dependencies. Additional tasks may be added if needed.

* ``ORYX_SYSTEM_PROFILE_PUBLISH_FILES``: This is the list of files to publish
  into the ``pub`` directory. It typically contains the rootfs image and any
  supporting files (such as a kernel image, bootloader image, etc).

.. _application_profiles:

Application Profiles
====================

An application profile specifies the use-case of a given image and typically
corresponds to a particular software package or package group. The
configurability here is greater than a traditional OpenEmbedded image recipe
though, as the application profile may set ``PACKAGECONFIG`` values and other
options to be applied to all components within an image. So it's possible to
build a lightweight configuration of a library for one application profile but
then enable additional options when building for a different application
profile.

An Oryx Linux image is built with only one application profile. The expected use
case is to deploy the ``host`` application profile using the ``native`` system
profile onto a device and build additional images using the ``guest`` system
profile for each required application profile. With this method each application
profile corresponds to a separate container within the host system resulting in
a more secure and manageable device.

Three major system profiles are provided in this release:

* ``full-cmdline``: This profile simply includes the OpenEmbedded full-cmdline
  packagegroup. It is a good demonstration container as it has a user-friendly
  set of command line tools installed with documentation.

* ``minimal``: This profile provides the minimal software needed to boot and run
  a system. It is a good starting point for developing new application profiles.

* ``host``: This profile includes runc and other tools needed to setup Linux
  containers. It provides a host environment for images built using the guest
  system profile described above.

It's expected that Oryx will be enhanced by the addition of many more
application profiles in future releases.

The application profile is determined by the ``ORYX_APPLICATION_PROFILE``
variable.

Writing Application Profiles
----------------------------

A new application profile is typically written for each application or service
which is to be deployed in Oryx Linux.

The key variables in an application profile are as follows:

* ``ORYX_APPLICATION_PROFILE_PACKAGES``: This is the list of additional packages
  to install into the rootfs for this application profile.

When the ``guest`` system profile is selected, the following additional
variables are used to configure the guest container:

* ``ORYX_GUEST_CAPABILITIES``: This is the list of Linux capabilities to grant
  to the container. It defaults to the minimal capability set of
  ``CAP_AUDIT_WRITE``, ``CAP_KILL`` and ``CAP_NET_BIND_SERVICE`` and typically
  you will just need to extend this list with any additional capabilities
  needed. For details on the available capabilities, see the Linux
  ``capabilities(8)`` manual page.

* ``ORYX_APPLICATION_COMMAND``: This is the main application command to execute
  when the guest container is started. The command line is tokenised into
  separate arguments however no further parsing is performed (so for example
  environment variables cannot be used). The best practice is to create a start
  script which performs any necessary initialisation and then starts the main
  service or application. For an example of a start script see the
  ``start-sshd`` script and recipe in the ``meta-oryx`` layer.

OpenEmbedded Recipes
====================

oryx-image
----------

The concept of an application profile effectively supersedes the OpenEmbedded
concept of an image recipe. Therefore we only make use of one image recipe
within Oryx and this is the ``oryx-image`` recipe. This recipe pulls in the
packages needed by the chosen application and system profiles.

The ``oryx-image`` recipe also ensures that an extended ``os-release`` file is
included in the image. This ``os-release`` file includes the usual information
such as the distro name, version and home URL as well as Oryx-specific
information such as the selected system profile, application profile and
machine.

image-json-file
---------------

The ``image-json-file`` recipe creates a JSON formatted data file for the
current image which is used by :ref:`oryxcmd` when downloading the image onto a
host system.

.. _oryx-publish:

oryx-publish
------------

To simplify deployment of Oryx images we also have a top-level ``oryx-publish``
recipe. This recipe copies files specified by the chosen system profile from the
OpenEmbedded ``deploy/images`` directory to a new ``deploy/oryx`` directory. This
may seem trivial but it gives two benefits. As only those files required by the
boot or installation method used with a given system profile are copied into the
new directory, there is no clutter or confusion.  Also, the ``deploy/oryx``
directory has sub-directories for the current version, selected system profile
and selected application profile and this ensures that an image produced for one
configuration is not accidentally overwritten by a subsequent build for a
different configuration.

In normal usage, the top-level bitbake recipe used to build an Oryx image will
therefore be ``oryx-publish``.

Using Integrated Sources
========================

The recommended way to build Oryx Linux images is to use the integrated source
tree which combines the ``meta-oryx`` layer and a pre-configured build
environment with the OpenEmbedded build system. This is the method which is used
for Oryx Linux releases and is regularly tested as part of the Continuous
Integration (CI) system.

The full contents of the integrated Oryx Linux sources is as follows:

* The base ``openembedded-core`` layer.

* The corresponding version of ``bitbake``.

* Additional supporting layers: ``meta-openembedded`` and
  ``meta-virtualisation``.

* Additional BSP layers: ``meta-raspberrypi`` and ``meta-yocto``.

* The Oryx Linux distro layer: ``meta-oryx``.

* Pre-configured build environment consisting of ``build/conf/local.conf`` and
  ``build/conf/bblayers.conf`` files which typically do not require further
  modification.

* The ``build/conf/setenv`` environment setup script.

* Build scripts and other supporting scripts under ``build/scripts/``.

Fetching and Updating Sources
-----------------------------

Integrated sources may be obtained either from a source release in ``.tar.xz``
format, or from git using the ``repo`` tool.

Using a Source Release
++++++++++++++++++++++

Each point release of Oryx Linux includes a source tarball alongside the
compiled images. This integrated source release contains all OpenEmbedded layers
needed to build Oryx Linux images and is essentially a point-in-time snapshot of
the sources which may be obtained from git using the ``repo`` tool.

For the v0.4.0 release, this source release may be obtained from
https://downloads.toganlabs.com/oryx/distro/0.4.0/oryx-0.4.0.tar.xz.

Once a source release has been downloaded, it simply needs to be extracted
before following the steps in the `Preparing the Environment`_ section.

Using git
+++++++++

The Oryx git repo uses submodues to download and track the other git repos that
it depends on so it must be cloned using the ``--recursive`` flag.

* To use the ``master`` branch of Oryx Linux::

    git clone --recursive https://gitlab.com/oryx/oryx.git

  The ``master`` branch is the active development branch and so may incorporate
  breaking changes at any time. Follow the ``master`` branch at your own risk!

* To use a stable branch of Oryx Linux, such as the ``sumo`` branch::

    FIXME

* To use a formal release of Oryx Linux, such as the v0.4.0 release::

    FIXME

The git submodules should be periodically updated with the following command::

    git submodule update

Preparing the Environment
-------------------------

Once the Oryx Linux source tree has been downloaded, simply source the
``build/conf/setenv`` script in a bash shell to prepare the environment for a
build::

    source build/conf/setenv

Build Script
------------

Once you have sourced the ``setenv`` script, you can use run-build::

    scripts/run-build.py [-C] [-L] [-V VERSION] [-M MACHINE] [-S SYSTEM_PROFILE] \
        [-A APPLICATION_PROFILE]

This script uses bitbake to build the recipe specified by :ref:`oryx-publish`.

Output files from run-build are saved in the pub directory, which is divided
into subdirectories by, respectively: version, machine, system profile, and
application profile. As well as the build output, this contains the log file
if you have chosen -L, and a ``FAILED`` file if the build itself has failed.

Customising a build
+++++++++++++++++++

There are a number of ways available to customise your build.

* ``-V VERSION``: Sets the ORYX_VERSION variable.

    * Allows you to specify the version string used to identify this build.
    * The default value is "dev".

* ``-S SYSTEM_PROFILE``: System profile selection.

    * This sets the ORYX_SYSTEM_PROFILE variable.
    * See the :ref:`system_profiles` section for details on how system profiles
      work, and what options are available.
    * The default value is "native".

* ``-A APPLICATION_PROFILE``: Application profile selection.

    * This sets the ORYX_APPLICATION_PROFILE variable.
    * See the :ref:`application_profiles` section for details on application
      profiles, as well as the options available.
    * The default value is "minimal".

* ``-M MACHINE``: Machine selection.

    * This sets the MACHINE variable.
    * Supported machines are: ``qemux86``, ``qemux86-64``, ``raspberrypi3``,
      ``raspberrypi3-64``
    * The default value is "qemux86".

* ``-C``: Performs a clean build.

    * Removes the contents of the tmp directory before running bitbake.
    * The default is not to perform a clean build, leaving the previous content
      of the tmp directory intact.

* ``-L``, ``--logs``: Captures and archives log files.

    * Log files are copied from the tmp directory into a ``logs.tar.gz`` file
      located in:
      ``pub/${ORYX_VERSION}/${MACHINE}/${ORYX_SYSTEM_PROFILE}/${ORYX_APPLICATION_PROFILE}``.
    * The default is not to capture log files.

For example::

    scripts/run-build.py -S native -A host -C

Performs a clean build using the ``native`` system profile and the ``host``
application profile.

Using Bitbake Directly
----------------------

During development it may be desirable to use bitbake directly, for example to
build a particular recipe rather than a whole image. First, source the
configuration script as described in `Preparing the Environment`_. Then it is
possible to invoke bitbake from the build directory in the usual way.

Typically the ``MACHINE`` value is selected on the command line when running
bitbake directly to avoid the need to modify ``local.conf``.

For example, to build just ``bash`` for the ``raspberrypi3`` device::

    MACHINE=raspberrypi3 bitbake bash

Using meta-oryx as a Standalone Layer
=====================================

Although the above method of `Using Integrated Sources`_ is preferred as this is
the tested and supported method, it's also possible to use the ``meta-oryx``
layer as a traditional OpenEmbedded layer. This layer may be obtained from the
git repository at https://gitlab.com/oryx/meta-oryx and added into an
OpenEmbedded build environment as normal.

Once the ``meta-oryx`` layer has been added to the OpenEmbedded build
environment, the following variables should be set in ``conf/local.conf`` or
another appropriate location to fully configure the Oryx Linux distribution:

* Set the distro: ``DISTRO = "oryx"``.

* Set the Oryx Linux version: ``ORYX_VERSION = "custom"``. Using a unique
  version string here will help identify this build.

* Choose a :ref:`System Profile <system_profiles>`:
  ``ORYX_SYSTEM_PROFILE = "native"``.

* Choose an :ref:`Application Profile <application_profiles>`:
  ``ORYX_APPLICATION_PROFILE = "minimal"``.

Once these variables are set appropriately, ``bitbake`` may be executed as
normal. As discussed in the section on `OpenEmbedded Recipes`, the top-level
command to build an Oryx Linux image is typically ``bitbake oryx-publish``.
