============
Introduction
============

.. _motivation:

Motivation
==========

The Oryx Linux project is primarily motivated by a desire to incorporate a
lightweight Linux container implementation into the OpenEmbedded build system
whilst maintaining the benefits of both systems. The key word here is
‘lightweight’: we’re avoiding fully-integrated systems such as Docker which are
targeted at cloud computing deployments rather than embedded deployments.
Instead we’re using ``runc``, the lightweight container runtime which sits at
the heart of Docker, without any of the surrounding tools such as
``containerd`` and ``docker`` itself. This gives us the flexibility to address
the needs of the embedded use-case.

One of the main aims of this project is to provide a developer workflow which
is familiar to existing OpenEmbedded users. You should not be required to learn
a new build system or method of creating images (such as Docker and its
corresponding Dockerfile syntax) in order to incorporate the benefits of
containers into an embedded Linux product. Keeping the focus on the
OpenEmbedded workflow ensures that we retain all the benefits of this system,
such as the excellent license compliance tooling, the extensible SDK and a
proper cross-compilation environment. Other methods of creating container-based
Linux systems are typically targeted at cloud computing deployments and don’t
address these issues that crop up when shipping an embedded Linux product.

The benefits of Linux containers have been discussed at length elsewhere so we
won’t cover the general benefits here. However, it’s worth mentioning the
additional benefits that we get in the embedded world:

* The ability to isolate applications requiring access to specialised hardware
  from those which just use ‘normal’ Linux interfaces such as the network and
  filesystems.

* The ability to mix legacy software which is dependent on specific older
  versions of system libraries with an up-to-date and secure base system. This
  is especially relevant in the embedded space where legacy applications abound.

* The ability to update and restart a full application stack cleanly and
  quickly by restarting a container guest instead of rebooting the whole device.
  For devices with long startup times there can be significant benefit here.

Support
=======

Please report any bugs, feature requests or other feedback via the
`Oryx issue tracker <https://gitlab.com/groups/oryx/-/issues>`_.

Discussion about Oryx usage and development also occurs on the
`Oryx mailing list <https://oryx.groups.io/g/devel>`_.

Notation
========

The following notation is used for arguments:

* ``ARGUMENT``: A required argument.

* ``[ARGUMENT]``: An optional argument.

* ``ARGUMENTS...``: One or more required arguments which are not parsed
  further, typically used when these are passed through to another
  application.

Glossary
========

Application Profile
  An application profile defines the software to be installed into an Oryx
  image along with any required configuration. For more details see
  :ref:`application_profiles`.

System Profile
  A system profile defines the way that an Oryx image is deployed on a target,
  which artifacts are needed for deployment and how the image is started on the
  target device. For more details see :ref:`system_profiles`.

System Profile Type
  System profiles are grouped into two types: ``native`` and ``guest``. This
  determines the type of Oryx image that will be built as defined below.

Image Type
  Oryx images are grouped into two types, matching the corresponding system
  profile types. These are defined below.

Guest Image
  A guest image is esstentially the template for an Oryx guest. It defines the
  initial state of the rootfs within the guest, the Linux capabilities to be
  assigned and the commands to run when the guest is started.

Native Image
  A native image is installed directly onto a target device and so includes
  components like the kernel and bootloader which are not needed in a guest
  image.

Source
  In the context of ``oryxcmd``, a source is the location from which guest
  images can be obtained. This can be a directory on the local filesystem, a
  website accessible over HTTP/HTTPS, or any other supported type of location.

Guest
  An Oryx guest is an application or service running within a Linux container
  on an Oryx host system. The container isolation separates guests from each
  other, from the host system and from hardware resources that they haven't
  been given explicit permission to access.

Host
  An Oryx host system is typically built as a native image using the ``host``
  application profile. This system includes the ``oryxcmd`` application and the
  ``runc`` lightweight container engine, allowing guests to be deployed and
  managed within the system.

Copyright and Trademark notices
===============================

.. image:: cc_by.png
   :alt: Creative Commons Attribution 4.0 International License
   :align: center

This work is licensed under a `Creative Commons Attribution 4.0 International
License <https://creativecommons.org/licenses/by/4.0/>`_.

Linux® is the registered trademark of Linus Torvalds in the U.S. and other
countries.
