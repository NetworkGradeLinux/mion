============
Introduction
============

Summary
=======

This documentation covers the |version| version of Oryx Linux.

Oryx Linux is a Linux® distribution targeted at embedded applications and based
on the work of `The Yocto Project <https://www.yoctoproject.org/>`_ and
`OpenEmbedded <https://www.openembedded.org/>`_.

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

For support requests, bug reports or other feedback please open an issue in the
`Togán Labs bug tracker <https://bugs.toganlabs.com/>`_ or contact us at
`support@toganlabs.com <support@toganlabs.com>`_.

Notation
========

The following notation is used for arguments:

* ``ARGUMENT``: A required argument.

* ``[ARGUMENT]``: An optional argument.

* ``ARGUMENTS...``: One or more required arguments which are not parsed
  further by ``oryxcmd``. This is typically used for arguments which are
  passed through to another application.

Copyright and Trademark notices
===============================

.. image:: cc_by.png
   :alt: Creative Commons Attribution 4.0 International License
   :align: center

This work is licensed under a `Creative Commons Attribution 4.0 International
License <https://creativecommons.org/licenses/by/4.0/>`_.

Linux® is the registered trademark of Linus Torvalds in the U.S. and other
countries.
