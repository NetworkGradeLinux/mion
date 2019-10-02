.. _building_oryx_images:

==========================
Building Oryx Linux Images
==========================

Oryx Linux introduces two major new concepts to the OpenEmbedded build system:
these are `System Profiles`_ and `Application Profiles`_. This section will
also discuss how these concepts are integrated into the `OpenEmbedded
Recipes`_ in the ``meta-oryx`` layer.

.. _system_profiles:

System Profiles
===============

A system profile complements the OpenEmbedded machine selection and essentially
specifies how the image we are building will be deployed onto the selected
machine. Many platforms may be booted in multiple ways (local boot from flash
memory vs remote boot via tftp for instance) and a system profile may be used
to specify a boot mechanism. Additionally, an image may run under different
virtualisation methods on a given platform and a system profile may be used
to specify the chosen method. In each case the system profile will ensure
that the correct build artifacts are produced to match how the image will be
used. As system profiles are orthogonal to machine selection, consistent boot
or virtualisation methods may be enforced across multiple platforms.

The following system profiles are provided in this release:

* ``native``: This profile indicates that the image will run "bare metal" on
  the chosen platform. Build artifacts suitable for writing to an SD card,
  USB stick or embedded flash memory are produced and are then compressed to
  save space. When possible, u-boot is enabled to provide greater boot-time
  flexibility.

* ``guest``: This profile indicates that the image will run as a container
  guest under runc. No bootloader or kernel is compiled for this profile.
  Build artifacts are always compressed tar archives of a rootfs, ready for
  installation onto a host system.

The system profile is determined by the ``ORYX_SYSTEM_PROFILE`` variable.

Porting the native System Profile
---------------------------------

When porting Oryx Linux to new target platforms it is usually necessary to
modify the native system profile. The following variables need to be correctly
defined for each target platform:

* ``IMAGE_FSTYPES``: This variable determines the format of the rootfs image
  which is created. For physical devices this is usually a complete image,
  including kernel and bootloader, ready to be directly copied into flash
  memory or onto an SD Card or USB stick. However for emulated targets this
  may simply be a filesystem image. For officially supported platforms,
  ``xz`` compression is usually used to reduce the storage and bandwidth
  requirements on our servers.

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
If further customisation is needed, see the following section on `Writing
System Profiles`_.

Writing System Profiles
-----------------------

The existing ``native`` and ``guest`` system profiles are suitable for most use
cases but it may occasionally be necessary to create new profiles.

The key variables in a system profile are as follows:

* ``ORYX_SYSTEM_PROFILE_PACKAGES``: This is the list of additional packages to
  install into the rootfs for this system profile.

* ``ORYX_SYSTEM_PROFILE_OUTPUT_DEPENDS``: This is the list of bitbake tasks to
  be completed before collecting artifacts for output to the images directory,
  in addition to building ``oryx-image``.

* ``ORYX_SYSTEM_PROFILE_OUTPUT_FILES``: This is the list of files to output to
  the images directory, in addition to the image json file. It typically
  contains the rootfs image and any supporting files (such as a kernel image,
  bootloader image, etc).

* ``ORYX_SYSTEM_PROFILE_TYPE``: This selects how the resulting image will be
  used and must be set to one of the following options. These match the two
  core system profiles included with Oryx, allowing additional customised
  native and guest system profiles to be defined with different names.

    * ``native``: The resulting image will run directly on the target hardware.

    * ``guest``: The resulting image will run as a container managed by
      ``oryxcmd``.

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

An Oryx Linux image is built with only one application profile. The expected
use case is to deploy the ``host`` application profile using the ``native``
system profile onto a device and build additional images using the ``guest``
system profile for each required application profile. With this method each
application profile corresponds to a separate container within the host
system resulting in a more secure and manageable device.

The following application profiles are provided in this release:

* ``full-cmdline``: This profile simply includes the OpenEmbedded full-cmdline
  packagegroup along with the SSH server. It is a good demonstration
  container as it has a user-friendly set of command line tools installed
  with documentation.

* ``minimal``: This profile provides the minimal software needed to boot and
  run a system along with the SSH server. It is a good starting point for
  developing new application profiles.

* ``host``: This profile includes runc and other tools needed to setup Linux
  containers. It provides a host environment for images built using the guest
  system profile described above.

* ``host-test``: This profile includes everything in the ``host`` application
  profile plus additional testing and debug tools. It is primarily used in the
  development of Oryx itself.

It's expected that Oryx will be enhanced by the addition of many more
application profiles in future releases.

The application profile is determined by the ``ORYX_APPLICATION_PROFILE``
variable.

Writing Application Profiles
----------------------------

A new application profile is typically written for each application or service
which is to be deployed in Oryx Linux.

The key variables in an application profile are as follows:

* ``ORYX_APPLICATION_PROFILE_PACKAGES``: This is the list of additional
  packages to install into the rootfs for this application profile.

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

Preconfiguration and the Local Image Feed
=========================================

Oryx Linux supports the preconfiguration of sources and guests defined at build
time so that these do not need to be created by manually invoking oryxcmd at
runtime. This is done by writing recipes which install preconfiguration files
into ``/usr/share/oryx/preconfig.d`` where the oryxcmd will process them on
first boot. These files are parsed in alphanumeric sort order so it's
recommended to use a 2 digit prefix on all file names to enfore the desired
processing order. Once parsed, the options creating sources are handled first
followed by the options creating guests.

The syntax of preconfiguration files is based on the INI configuration file
format with sections for each source or guest that should be created on first
boot.

Preconfiguring Sources
----------------------

A section with a heading of the format ``[source:NAME]`` defines a source with
the given name.

The following options are required to preconfigure a source:

* ``url``: This is equivalent to the ``URL`` argument to the
  :ref:`oryxcmd_add_source` oryxcmd action.

Preconfiguring Guests
---------------------

A section with a heading of the format ``[guest:NAME]`` defines a guest with
the given name.

The following options are required to preconfigure a guest:

* ``image``: This is equivalent to the ``IMAGE`` argument to the
  :ref:`oryxcmd_add_guest` oryxcmd action.

The following options may also be set as desired:

* ``enable``: If this option is true then the guest in enabled after creation
  so that it starts automatically on boot. This is equivalent to running
  ``oryxcmd enable_guest`` after the guest is created.

Preconfiguration Example
------------------------

The following example illustrates how sources and guests can be preconfigured.
If this text is placed in a file under ``/usr/share/oryx/preconfig.d`` by a
recipe then on first boot on the target the defined items will be created::

    [source:onsite]
    url = http://192.168.1.10/oryx/qemux86

    [guest:test]
    image = onsite:minimal
    enable = True

This is equivalent to running the following commands on the target on the first
boot::

    oryxcmd add_source onsite http://192.168.1.10/oryx/qemux86
    oryxcmd add_guest test onsite:minimal
    oryxcmd enable_guest test

Using the Local Feed
--------------------

The recipe ``oryx-local-feed`` builds on the preconfiguration support to define
a local feed with images stored in ``/usr/share/oryx/local-feed``. This allows
guests to be created on the first boot of a device without requiring any
network access to a remote source. The preconfiguration file to define the
``local`` source is installed as part of this recipe and so it is not
necessary to implement this yourself.

All images which will be placed in the local feed must have already been built
before the final native image is built.

The local feed is configured by setting the following variables, typically in
the application profile which will be used to build the final image:

* ``ORYX_LOCAL_FEED_IMAGE``: A whitespace separated list of images to include
  in the local feed. Each entry is of the form
  ``SYSTEM_PROFILE:APPLICATION_PROFILE``, for example ``guest:minimal`` to
  include the image built from the ``guest`` system profile and the
  ``minimal`` application profile. These images will be copied into the local
  feed directory in the final image.

For an example of how the local feed is used, see the ``host-test`` application
profile.

OpenEmbedded Recipes
====================

.. _oryx-image:

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

To simplify deployment of Oryx images and prevent artifacts being overwritten
by subsequent builds for different machine, system profile or application
profile settings, the output files are collected into an images directory
(usually placed in ``build/images``). Within this images directory, a
hierarchy of subdirectories is created for each machine, system profile and
application profile. As only those files required by the boot or installation
method used with a given system profile are copied into the new directory,
there is no clutter or confusion.

In normal usage, the top-level bitbake recipe used to build an Oryx image will
therefore be ``oryx-image``.

image-json-file
---------------

The ``image-json-file`` recipe creates a JSON formatted data file for the
current image which is used by :ref:`oryxcmd` when downloading the image onto a
host system.

Using Integrated Sources
========================

The recommended way to build Oryx Linux images is to use the integrated source
tree which combines the ``meta-oryx`` layer and a pre-configured build
environment with the OpenEmbedded build system. This is the method which is
used for Oryx Linux releases and is regularly tested as part of the
Continuous Integration (CI) system.

The full contents of the integrated Oryx Linux sources is as follows:

* The base ``openembedded-core`` layer.

* The corresponding version of ``bitbake``.

* Additional supporting layers: ``meta-openembedded`` and
  ``meta-virtualisation``.

* Additional BSP layers: ``meta-raspberrypi``.

* The Oryx Linux distro layer: ``meta-oryx``.

* Pre-configured build environment consisting of ``build/conf/local.conf`` and
  ``build/conf/bblayers.conf`` files which typically do not require further
  modification.

* Build script ``scripts/build.py``.

Fetching and Updating Sources
-----------------------------

Integrated sources may be obtained either from a source release in ``.tar.xz``
format, or from git.

Using a Source Release
++++++++++++++++++++++

Each point release of Oryx Linux includes a source tarball alongside the
compiled images. This integrated source release contains all OpenEmbedded
layers needed to build Oryx Linux images and is essentially a point-in-time
snapshot of the sources which may be obtained from git.

For the v0.5.0 release, this source release may be obtained from
https://downloads.toganlabs.com/oryx/distro/0.5.0/oryx-0.5.0.tar.xz.

Once a source release has been downloaded, it simply needs to be extracted
before using the `Build Script`_.

Using git
+++++++++

The Oryx git repository uses submodues to download and track the other git
repositories that it depends on so it must be cloned using the
``--recurse-submodues`` flag.

* To use the ``master`` branch of Oryx Linux::

    git clone --recurse-submodules https://gitlab.com/oryx/oryx.git

  The ``master`` branch is the active development branch and so may incorporate
  breaking changes at any time. Follow the ``master`` branch at your own risk!

* To use a formal release of Oryx Linux, such as the v0.5.0 release::

    git clone --recurse-submodules https://gitlab.com/oryx/oryx.git \
      -b v0.5.0

The git submodules should be periodically updated with the following command::

    git submodule update

Build Script
------------

Once you have the Oryx sources, you can use the build script
``scripts/build.py`` to build images. This script uses bitbake to build the
recipe specified by :ref:`oryx-image` and so places output files into the
images directory.

Building Single Images
++++++++++++++++++++++

The build script can be used most straightforwardly to build a single Oryx
Linux image along with any associated collateral (such as the
``image_native.json`` or ``image_guest.json`` file as appropriate).

The build script defaults to selecting the ``qemux86`` machine, the ``native``
system profile and the ``host`` application profile when building images. To
build an image for this combination, simply invoke the build script with no
arguments::

    ./scripts/build.py

Additional arguments may be passed to the build script to change the selected
machine (``-M`` or ``--machine`` argument), system profile (``-S`` or
``--system-profile`` argument) and application profile (``-A`` or
``--application-profile`` argument). For example, to build an image for the
Raspberry Pi 3 device using the ``guest`` system profile and the ``minimal``
application profile::

    ./scripts/build.py -M raspberrypi3 -S guest -A minimal

As an alternative to the above form, the ``-T`` argument can be used with a
colon-separated system profile and application profile pair such as
``native:host`` or ``guest:minimal``. For example, the above build can also be
performed using the following command::

    ./scripts/build.py -M raspberrypi3 -T guest:minimal

Building Multiple Images in One Step
++++++++++++++++++++++++++++++++++++

The build script is also capable of building multiple images in a single
execution, running bitbake more than once as necessary.

Repeating the ``-S`` and ``-A`` arguments with different system profile or
application profile selections would be ambiguous as it would not be clear how
to pair up entries in the list of system profiles with entries in the list of
application profiles. Instead, the ``-T`` argument must be used to specify
multiple system profile and application profile pairs. The build script adds
these pairs to an ordered list in the order that they are specified on the
command line and this determines the order in which these builds are performed.
This ordering may be important where one build depends on the results of
another, such as when building the ``host-test`` application profile which
requires a minimal guest image to have already been built for the same machine.
For example, the following command can be used to successfully build this
test image for the Raspberry Pi 3 device::

    ./scripts/build.py -M raspberrypi3 -T guest:minimal -T native:host-test

Note that this build may fail if ``-T native:host-test`` appeared first on the
command line as the required guest image would not have been built.

It is also possible to build images for multiple target machines by using the
``-M`` argument more than once. Alternatively, the ``--all-machines`` argument
may be passed to build images for all officially supported machines. For
example, the following command can be used to build the native host image for
both x86 and x86-64 QEMU machines::

    ./scripts/build.py -M qemux86 -M qemux86-64 -S native -A host

If both multiple machines and multiple system profile and application profile
pairs are provided, each profile pair is built for each machine listed on the
command line. For example, the following command can be used to build the
minimal and full-cmdline guest images for both the 32-bit and 64-bit ARM QEMU
machines::

    ./scripts/build.py -M qemuarm -M qemuarm64 -T guest:minimal \
        -T guest:full-cmdline

As a futher example, the following command can be used to build the host and
host-test native images, along with the minimal guest image required by the
host-test application profile, for all supported machines::

    ./scripts/build.py --all-machines -T guest:minimal -T native:host \
        -T native:host-test

Building Documentation
++++++++++++++++++++++

The sources for this documentation are included in the Oryx repository under
the ``docs`` directory. The `Sphinx documentation generator
<http://www.sphinx-doc.org/en/master/>`_ is used to build HTML and PDF output
from the reStructuredText and Markdown source files.

Sphinx requires Python version 3.5 or later along with the ``pip`` tool. To
install Sphinx and the required modules for building the Oryx documentation
the ``requirements.txt`` file included with the documentation sources may be
used as follows::

    pip install -r docs/requirements.txt

The following command may then be used to build the documentation::

    ./scripts/build.py --docs --no-bitbake

The resulting HTML and PDF artifacts are placed in the ``docs`` directory
within the output directory.

Starting a Development Shell
++++++++++++++++++++++++++++

During development it may be desirable to use bitbake directly, for example to
build a particular recipe rather than a whole image. This can be achieved by
starting a development shell using the build script with the ``--shell``
argument. The ``-M``, ``-S``, ``-A`` and ``-T`` arguments can be used to
select the machine, system profile and application profile that will be used
for the build. However, note that it is not possible to invoke a development
shell for more than one machine or more than one system profile and
application profile pair at a time. In this mode of operation the build
script will setup the required environment variables for an Oryx build and
then start the bash shell.

For example, to start a development shell with the ``raspberrypi3`` machine,
``native`` system profile and ``host-test`` application profile selected::

    ./scripts/build.py -M raspberrypi3 -S native -A host-test --shell

Please note that the user and system bashrc files will be parsed by the new
shell instance and this may interfere with the required environment variables
set by the build script. If problems are observed when using the development
shell but not when bitbake is directly invoked by the build script then the
appropriate bashrc files should be examined.

When the development shell is no longer needed, remember to end the session by
using ``exit``.

Argument Reference
++++++++++++++++++

The build script understands the following arguments:

* ``-V VERSION``, ``--build-version VERSION``: Sets the version string used to
  identify this build. The default value is ``dev``.

* ``-S SYSTEM_PROFILE``, ``--system-profile SYSTEM_PROFILE``: Sets the system
  profile to be built. See the :ref:`system_profiles` section for details on
  how system profiles work, and what options are available. The default value
  is ``native``.

* ``-A APPLICATION_PROFILE``, ``--application-profile APPLICATION_PROFILE``:
  Sets the application profile to be built. See the :ref:`application_profiles`
  section for details on application profiles, as well as the options
  available. The default value is ``host``.

* ``-M MACHINE``, ``--machine MACHINE``: Sets the target machine for which the
  image will be built. Supported machines are: ``qemux86``, ``qemux86-64``,
  ``qemuarm``, ``qemuarm64, ``raspberrypi3`` and ``raspberrypi3-64``. The
  default value is "qemux86". This argument may be specified more than once
  to build multiple images in one invocation of the build script.

* ``-T SYSTEM_PROFILE:APPLICATION_PROFILE``,
  ``--target-pair SYSTEM_PROFILE:APPLICATION_PROFILE``: Sets the system profile
  and application profile to be built. This is an alternative to specifying the
  ``-S`` and ``-A`` arguments separately. This argument may be specified more
  than once to build multiple images in one invocation of the build script
  (which is not possible when using the ``-S`` and ``-A`` arguments). The
  images are built in the order that they are given on the command line and
  for each specified machine.

* ``-k``, ``--continue``: Continue as far as possible after an error. This is
  equivalent to the ``-k`` argument to bitbake.

* ``--oryx-base ORYX_BASE``: Set the base directory of the Oryx source tree.
  The default value is the current directory so this argument is only useful
  in special cases.

* ``--shell``: Start a development shell instead of running bitbake directly.
  This allows more control over the invocation of bitbake and is typically
  useful in development and in debugging failed builds.

* ``-o OUTPUT_DIR``, ``--output-dir OUTPUT_DIR``: Set the output directory
  where build artifacts will be placed. The default value is
  ``build/images``.

* ``--all-machines``: Build images for all supported target machines. This is
  an alternative to manually specifying the full list with multiple ``-M``
  arguments. See the release notes for the current list of supported
  machines.

* ``--rm-work``: Remove temporary files after building each recipe to save disk
  space. This enables the ``rm_work`` bbclass.

* ``--mirror-archive``: Populate a download mirror for all open source
  components included in the image. This is placed in the ``mirror`` directory
  within the output directory. It can be published and used as a mirror or a
  premirror for subsequent builds.

* ``--dl-dir DL_DIR``: Set the path for the downloads directory. The default
  value is ``build/downloads``.

* ``--sstate-dir SSTATE_DIR``: Set the path for the sstate cache directory. The
  default value is ``build/sstate-cache``.

* ``--docs``: Build the documentation in HTML and PDF formats. The resulting
  artifacts are placed in the ``docs`` directory within the output directory.

* ``--source-archive``: Create an archive of the complete Oryx Project sources
  including Bitbake and all Yocto Project layers. The archive is placed in the
  output directory. This requires that the sources have been obtained from git
  and not from a previously made source archive.

* ``--checksum``: Create ``SHA256SUMS`` checksum files in each subdirectory
  within the output directory that contains files.

* ``--release``: Perform a full release of the Oryx Project. This is equivalent
  to passing the following arguments::

    -T guest:minimal -T guest:full-cmdline -T native:host -T native:host-test \
    --all-machines --docs --mirror-archive --source-archive --checksum

* ``--no-bitbake``: Disable bitbake invocation so that no images are built.
  This argument is useful if you only want to build the documentation, create
  a source archive or similar.

Using meta-oryx as a Standalone Layer
=====================================

Although the above method of `Using Integrated Sources`_ is preferred as this
is the tested and supported method, it's also possible to use the
``meta-oryx`` layer as a traditional OpenEmbedded layer. This layer may be
obtained from the git repository at https://gitlab.com/oryx/meta-oryx and
added into an OpenEmbedded build environment as normal.

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
command to build an Oryx Linux image is typically ``bitbake oryx-image``.
