===============
Release History
===============

Oryx Linux
==========

Release series status
+++++++++++++++++++++

==============  ====================  ===============  ==================
Release Series  Yocto Project Branch  Release Date     End-of-life Date
==============  ====================  ===============  ==================
v0.6.x          zeus                  Target Jan 2020  TBC
v0.5.x          warrior               Target Oct 2019  2020-04-30
v0.4.x          sumo                  2018-05-22       2019-05-31
v0.3.x          rocko                 2017-11-13       2018-11-30
v0.2.x          pyro                  2017-06-18       2018-05-31
v0.1.x          N/A                   2016-12-26       Alpha release only
==============  ====================  ===============  ==================

v0.5.0
++++++

Changes since v0.4.0:

* Updated to OpenEmbedded "warrior" stable release.

* Updated to oryx-apps v0.3.0. See the oryx-apps release notes for further
  details.

* Updated to the Linux LTS release series 4.19.y for all supported platforms.

* Switched to a new ``oryx`` repository using git submodules instead of the
  repo tool to pull together all the required components. The ``oryx-build``
  and ``documentation`` repositories are retired and their contents is merged
  into the new top level. Local patches to the submodules are staged in the
  ``patches`` directory.

* Updated the list of supported machines.

* Moved the build script to ``scripts/build.py``, overhaul and expand. It is no
  longer necessary to source ``build/conf/setenv`` before running the build
  script. Support for capturing task logs and running clean builds has been
  dropped. Support for several new arguments was added to the build script,
  see the command reference for details.

* Support creation of a mirror archive containing all open source components
  downloaded during the build. This may be used as part of the copyleft license
  compliance process as well as allowing images to be re-built from source
  without needing to re-download these components from their original location.

* It's now possible to build multiple images in one run of the build script by
  passing multiple ``-M`` and ``-T`` arguments. Each listed system profile and
  application profile pair will be built for each listed machine.

* Added contribution guidelines.

* Switched to a Buildbot CI instance at https://bb.oryx-linux.org instead of
  using GitLab CI.

* Switched to the systemd init system and the glibc C library.

* Added a new ``host-test`` application profile which extends the ``host``
  profile with various testing utilities.

* Added support for the creation of a local feed of guest images within the
  root file system of a native image. This allows offline creation of guests on
  the target device.

* Enabled security flags when building Oryx images to improve our security.

The following platforms are supported in this release:

* ``qemux86``

* ``qemux86-64``

* ``qemuarm``

* ``qemuarm64``

* ``raspberrypi3``

* ``raspberrypi3-64``

This release is available in the following forms:

* Source code via git: See tag "v0.5.0" in the repository at
  https://gitlab.com/oryx/oryx.git.

* Source code tarball: See
  https://www.toganlabs.com/downloads/oryx/distro/0.5.0/oryx-0.5.0.tar.xz.

* Various compiled images: See files under
  https://www.toganlabs.com/downloads/oryx/distro/0.5.0/.


v0.4.0
++++++

Changes since v0.3.1:

* Updated to OpenEmbedded "sumo" stable release.

* Updated to oryx-apps v0.2.4. See the oryx-apps release notes for further
  details: http://downloads.toganlabs.com/oryx/oryx-apps/0.2.4/RELEASE_NOTES.txt.

* Use the Linux LTS release series 4.14.y for all supported platforms.

The following platforms are supported in this release:

* ``qemux86``

* ``qemux86-64``

* ``raspberrypi``

* ``raspberrypi2``

* ``raspberrypi3``

* ``raspberrypi3-64``

* ``beaglebone-yocto``

This release is available in the following forms:

* Source code using ``repo`` tool: See tag "v0.4.0" in the git repository at
  https://gitlab.com/oryx/oryx-manifest.git.

* Source code tarball: See
  https://www.toganlabs.com/downloads/oryx/distro/0.4.0/oryx-0.4.0.tar.xz.

* Various compiled images: See files under
  https://www.toganlabs.com/downloads/oryx/distro/0.4.0/.

v0.3.1
++++++

Changes since v0.3.0:

* Incorporated bugfixes and security patches accumulated on the "rocko" branch
  of Yocto Project.

* Updated to oryx-apps v0.2.2. See the oryx-apps release notes for further
  details:

    * https://downloads.toganlabs.com/oryx/oryx-apps/0.2.2/RELEASE_NOTES.txt

    * https://downloads.toganlabs.com/oryx/oryx-apps/0.2.1/RELEASE_NOTES.txt

* Added support for Beaglebone Black devices using the ``meta-yocto-bsp``
  layer.

* Added oryx-guests initscript to auto-start all enabled guests at boot and
  stop all guests at shutdown.

* Allow configuration of Linux capabilities granted to guest containers.
  Example application profiles intended for usage as guests (``minimal`` and
  ``full-cmdline`` profiles) select the capabilites needed to run sshd.

* Add a ``start-sshd`` script, used in ``minimal`` and ``full-cmdline`` example
  application profiles to launch sshd with necessary initialisation and output
  logging.

* Drop obsolete ``demo`` application profile.

The following platforms are supported in this release:

* ``beaglebone``

* ``qemux86``

* ``qemux86-64``

* ``raspberrypi``

* ``raspberrypi2``

* ``raspberrypi3``

* ``raspberrypi3-64``

This release is available in the following forms:

* Source code using ``repo`` tool: See tag “v0.3.1” in the git repository at
  https://gitlab.com/oryx/oryx-manifest.git

* Source code tarball: See
  https://www.toganlabs.com/downloads/oryx/distro/0.3.1/oryx-0.3.1.tar.xz

* Various compiled images: See files under
  https://www.toganlabs.com/downloads/oryx/distro/0.3.1/

v0.3.0
++++++

Changes since v0.2.0:

* Updated to OpenEmbedded "rocko" stable release

* Updated to oryx-apps v0.2.0. See the oryx-apps release notes for further
  details: http://downloads.toganlabs.com/oryx/oryx-apps/0.2.0/RELEASE_NOTES.txt.

* Added support for 64-bit demo platforms: ``qemux86-64`` and
  ``raspberrypi3-64``.

* Dropped support for the ``arduino-yun`` platform and Oryx Lite. This was
  holding back further integration of the core features we want to include in
  Oryx so we had to let it go.

* Use the Linux LTS release series 4.9.y for all supported platforms.

* Switch guest image init system from ``oryx-guest-init`` to ``dumb-init``.
  This is a more widely deployed and better tested tiny init system written
  in C.

* Add ``ca-certificates`` into the host application profile to support the use
  of https source URLs.

* Allow the main service which runs when a guest image is started to be
  specified via the ``ORYX_APPLICATION_COMMAND`` variable in an application
  profile.

* Provide ``image.json`` file with all images including more detailed
  information to support development of an image index.

The following platforms are supported in this release:

* ``qemux86``

* ``qemux86-64``

* ``raspberrypi``

* ``raspberrypi2``

* ``raspberrypi3``

* ``raspberrypi3-64``

This release is available in the following forms:

* Source code using ``repo`` tool: See tag "v0.3.0" in the git repository at
  https://gitlab.com/oryx/oryx-manifest.git.

* Source code tarball: See
  https://www.toganlabs.com/downloads/oryx/distro/0.3.0/oryx-0.3.0.tar.xz.

* Various compiled images: See files under
  https://www.toganlabs.com/downloads/oryx/distro/0.3.0/.

v0.2.0
++++++

This release incorporates the following components:

* OpenEmbedded "pyro" stable release

* meta-oryx v0.2.0

* oryx-apps v0.1.1

The following platforms are supported in this release:

* ``qemux86``

* ``raspberrypi``

* ``raspberrypi3``

* ``arduino-yun``

This release is available in the following forms:

* Source code using ``repo`` tool: See tag "v0.2.0" in the git repository at
  https://gitlab.com/oryx/oryx-manifest.git.

* Source code tarball: See
  https://www.toganlabs.com/downloads/oryx/distro/0.2.0/oryx-0.2.0.tar.xz.

* Various compiled images: See files under
  https://www.toganlabs.com/downloads/oryx/distro/0.2.0/.

v0.1.0
++++++

This was an initial alpha-quality release and is now only of historical
interest.

oryx-apps
=========

v0.3.0
++++++

This is a feature release of the oryx-apps project. The following changes were
made since v0.2.5:

* Added ``preconfigure`` command which parses preconfiguration data from the
  ``/usr/share/oryx/preconfig.d`` directory and sets up sources and guests
  accordingly.

* Added ``startup`` and ``shutdown`` commands for the convenience of the
  systemd service files.

* Ensured that the oryxcmd state file is always created with valid json data.

This release is available in the following forms:

* Source code via git: See tag "v0.3.0" in the git repository at
  https://gitlab.com/oryx/oryx-apps.git

* Source code tarball: See
  https://www.toganlabs.com/downloads/oryx/oryx-apps/0.3.0/oryx-apps-0.3.0.tar.xz

v0.2.5
++++++

This is a feature release of the oryx-apps project. The following features are
added:

* Support switch to systemd.

This release is available in the following forms:

* Source code via git: See tag "v0.2.5" in the git repository at
  https://gitlab.com/oryx/oryx-apps.git

* Source code tarball: See
  https://www.toganlabs.com/downloads/oryx/oryx-apps/0.2.5/oryx-apps-0.2.5.tar.xz

v0.2.4
++++++

This is a bugfix release of the oryx-apps project. The following bugs are
fixed:

* Version number was not updated correctly for previous release.

This release is available in the following forms:

* Source code via git: See tag “v0.2.4” in the git repository at
  https://gitlab.com/oryx/oryx-apps.git

* Source code tarball: See
  https://www.toganlabs.com/downloads/oryx/oryx-apps/0.2.4/oryx-apps-0.2.4.tar.xz

v0.2.3
++++++

This is a feature release of the oryx-apps project. The following features are
added:

* Add initial test suite.

This release is available in the following forms:

* Source code via git: See tag “v0.2.3” in the git repository at
  https://gitlab.com/oryx/oryx-apps.git

* Source code tarball: See
  https://www.toganlabs.com/downloads/oryx/oryx-apps/0.2.3/oryx-apps-0.2.3.tar.xz

v0.2.2
++++++

This is a feature release of the oryx-apps project. The following features are
added:

* Handle ``runc kill`` failure in ``oryxcmd stop_guest``

* Add tmpfs mounts for guest containers

* Allow configuration of guest capabilities

This release is available in the following forms:

* Source code via git: See tag “v0.2.2” in the git repository at
  https://gitlab.com/oryx/oryx-apps.git

* Source code tarball: See
  https://www.toganlabs.com/downloads/oryx/oryx-apps/0.2.2/oryx-apps-0.2.2.tar.xz

v0.2.1
++++++

This is a feature release of the oryx-apps project. The following features are
added:

* Add oryx-guests initscript to autostart enabled guests at boot and autostop
  guests at shutdown.

* Improve messages for autostart_all/autostop_all commands.

This release is available in the following forms:

* Source code via git: See tag “v0.2.1” in the git repository at
  https://gitlab.com/oryx/oryx-apps.git

* Source code tarball: See
  https://www.toganlabs.com/downloads/oryx/oryx-apps/0.2.1/oryx-apps-0.2.1.tar.xz

v0.2.0
++++++

This is a feature release of the oryx-apps project. The following features are
added:

* Drop ``oryx-guest-init``, switch to ``dumb-init``
  (https://github.com/Yelp/dumb-init) for PID 1 inside guests.

* Add ``start_guest`` and ``stop_guest`` commands, allowing simple container
  management without having to learn the exact arguments needed by runc. Guests
  started via ``start_guest`` receive no input from the terminal and write all
  output to a log file in the container's directory under
  ``/var/lib/oryx-guests``.

* Add ``enable_guest`` and ``disable_guest`` commands, allowing guests to be
  configured for automatic start on boot of the host system.

* Add ``autostart_all`` and ``autostop_all`` commands, intended for use within
  an initscript to start all enabled guests during system boot and stop all
  running guests during system shutdown.

* Allow the main command within a guest to be chosen during image creation.

This release is available in the following forms:

* Source code via git: See tag "v0.2.0" in the git repository at
  https://gitlab.com/oryx/oryx-apps.git.

* Source code tarball: See
  https://www.toganlabs.com/downloads/oryx/oryx-apps/0.2.0/oryx-apps-0.2.0.tar.xz.

v0.1.1
++++++

This is a bugfix release of the oryx-apps project. The following bugs are
fixed:

* ``oryxcmd`` failed to create the ``/var/lib/oryx-guests`` directory on the
  first command invocation.

This release is available in the following forms:

* Source code via git: See tag "v0.1.1" in the git repository at
  https://gitlab.com/oryx/oryx-apps.git.

* Source code tarball: See
  https://www.toganlabs.com/downloads/oryx/oryx-apps/0.1.1/oryx-apps-0.1.1.tar.xz.

v0.1.0
++++++

This initial release contains the following applications:

* ``oryx-guest-init``: A cut-down init system suitable for use in a guest
  container.

* ``oryxcmd``: A command-line tool for managing guest containers within an Oryx
  Linux host system. The following features are supported:

    * Add sources which define the locations where container images may be
      downloaded from.

    * Create new guest containers using images available from the defined
      sources.

    * Remove defined sources and guests.

    * List and show defined sources and guests.

    * Use runc to execute defined guests.

This release is available in the following forms:

* Source code via git: See tag "v0.1.0" in the git repository at
  https://gitlab.com/oryx/oryx-apps.git.

* Source code tarball: See
  https://www.toganlabs.com/downloads/oryx/oryx-apps/0.1.0/oryx-apps-0.1.0.tar.xz.
