.. _oryxcmd:

=============
Using oryxcmd
=============

``oryxcmd`` is the core of the "host" application profile within Oryx Linux.
It is responsible for the management of guest containers and the sources from
which container images may be obtained. As a command-line application it has
both an interactive mode and a non-interactive mode.

Interactive Mode
================

In the interactive mode, ``oryxcmd`` is started without specifying a command::

    $ oryxcmd
    Welcome to oryxcmd (oryx-apps v0.3.0)
    oryxcmd>

At the ``oryxcmd`` prompt, any of the supported `Commands`_ may be executed.
For example::

    oryxcmd> list_sources
    oryx

To leave interactive mode, use the ``exit`` command::

    oryxcmd> exit

Non-interactive Mode
====================

In the non-interactive mode, ``oryxcmd`` is executed with a command specified
as an argument. The specified command will be executed and then ``oryxcmd``
will exit. For example::

    $ oryxcmd list_sources
    oryx

Any of the supported `Commands`_ may be executed in this way.

Command Line Arguments
======================

The following command line arguments are supported by ``oryxcmd``:

* ``-v``, ``--verbose``: Print verbose debug messages during operation. This
  argument is usable for both interactive and non-interactive mode.

* ``-h``, ``--help``: Print help messages and exit.

* ``-V``, ``--version``: Print version string and exit.

Commands
========

.. _oryxcmd_add_source:

add_source
----------

Register a new source from which images may be fetched.

Usage::

    add_source NAME URL

Arguments:

* ``NAME``: An identifier which may be used to reference this source in future
  commands.

* ``URL``: The root URL under which image archives may be found.

Example::

    oryxcmd> add_source oryx http://downloads.toganlabs.com/oryx/distro/0.5.0/raspberrypi3
    Added source "oryx" with URL "http://downloads.toganlabs.com/oryx/distro/0.5.0/raspberrypi3"

remove_source
-------------

Remove a previously registered source.

Usage::

    remove_source NAME

Arguments:

* ``NAME``: The identifier of the source to remove.

Example::

    oryxcmd> remove_source oryx
    Removed source "oryx"

list_sources
------------

List all currently registered sources.

Usage::

    list_sources

This command has no arguments.

Example::

    oryxcmd> list_sources
    oryx

show_source
-----------

Show details of a previously registered source in JSON format.

Usage::

    show_source NAME

Arguments:

* ``NAME``: The identifier of the source to show.

Example::

    oryxcmd> show_source oryx
    {
        "url": "http://downloads.toganlabs.com/oryx/distro/0.5.0/raspberrypi3"
    }

.. _oryxcmd_add_guest:

add_guest
---------

Create a new guest container from an image.

Usage::

    add_guest NAME IMAGE

Arguments:

* ``NAME``: An identifier which may be used to reference this source in future
  commands.

* ``IMAGE``: A fully-qualified reference to an image which is available from
  one of the sources which has been configured. The format of this reference
  is ``<source>:<image_name>``:

    - ``source``: The identifier of a registered source.

    - ``image_name``: The name of an image which is available within the
      identified source. The image name typically matches the name of an
      :ref:`Application Profile<application_profiles>` which has been built for
      the system on which ``oryxcmd`` is running.

Example::

    oryxcmd> add_guest test oryx:minimal
    Added guest "test" from image "oryx:minimal"

remove_guest
------------

Delete an existing guest container.

Usage::

    remove_guest NAME

Arguments:

* ``NAME``: The identifier of the guest container to remove.

Example::

    oryxcmd> remove_guest test
    Removed guest "test"

list_guests
-----------

List all currently registered guests.

Usage::

    list_guests

This command has no arguments.

Example::

    oryxcmd> list_guests
    test

show_guest
----------

Show details of a previously registered guest in JSON format.

Usage::

    show_guest NAME

Arguments:

* ``NAME``: The identifier of the guest to show.

Example::

    oryxcmd> show_guest test
    {
        "autostart_enabled": 0,
        "image": {
            "APPLICATION_PROFILE": "minimal",
            "CAPABILITIES": [
                "CAP_AUDIT_WRITE",
                "CAP_KILL",
                "CAP_NET_BIND_SERVICE",
                "CAP_SYS_CHROOT",
                "CAP_SETGID",
                "CAP_SETUID"
            ],
            "COMMAND": "/sbin/start-sshd",
            "DISTRO": "oryx",
            "MACHINE": "raspberrypi3",
            "ROOTFS": "oryx-guest-minimal-raspberrypi3.tar.xz",
            "SYSTEM_PROFILE": "guest",
            "SYSTEM_PROFILE_TYPE": "guest",
            "VERSION": "0.5.0"
        },
        "image_name": "minimal",
        "path": "/var/lib/oryx-guests/test",
        "source": {
            "url": "http://downloads.toganlabs.com/oryx/distro/0.5.0/raspberrypi3"
        },
        "source_name": "oryx"
    }

enable_guest
------------

Enable auto-start of a previously registered guest during system boot.

Usage::

    enable_guest NAME

Arguments:

* ``NAME``: The identifier of the guest to enable.

Example::

    oryxcmd> enable_guest test
    Enabled guest "test"

disable_guest
-------------

Disable auto-start of a previously registered guest during system boot.

Usage::

    disable_guest NAME

Arguments:

* ``NAME``: The identifier of the guest to disable.

Example::

    oryxcmd> disable_guest test
    Disabled guest "test"

start_guest
-----------

Start an existing guest container. The container is launched in the background,
without access to the terminal where start_guest was executed.

Usage::

    start_guest NAME

Arguments:

* ``NAME``: The identifier of the guest container to start.

Example::

    oryxcmd> start_guest test
    Started guest "test"

stop_guest
----------

Stop a running guest container. SIGTERM is sent to the container so that it can
shutdown cleanly. After 10 seconds, the container is halted.

Usage::

    stop_guest NAME

Arguments:

* ``NAME``: The identifier of the guest container to stop.

Example::

    oryxcmd> stop_guest test
    Stopped guest "test"

autostart_all
-------------

Start all containers which have autostart enabled.

Usage::

    autostart_all

This command has no arguments.

Example::

    oryxcmd> autostart_all
    Started guest "test"
    Started 1 of 1 enabled guests

autostop_all
------------

Stop all currently running containers.

Usage::

    autostop_all

This command has no arguments.

Example::

    oryxcmd> autostop_all
    Stopped guest "test"
    Stopped 1 of 1 guests

preconfigure
------------

Read pre-configuration data from `/usr/share/oryx/preconfig.d` and add the
listed sources and guests.

Usage::

    preconfigure

This command has no arguments.

Example::

    oryxcmd> preconfigure
    Added source "local" with URL "file:///usr/share/oryx/local-feed"
    Added guest "preconfig-test" from image "local:minimal"
    Enabled guest "preconfig-test"

startup
-------

Convenience function for use in systemd service file. Runs 'preconfigure'
then 'autostart_all'.

Usage::

    startup

This command has no arguments.

Example::

    oryxcmd> startup
    Started guest "preconfig-test"
    Started 1 of 1 enabled guests

shutdown
--------

Convenience function for use in systemd service file. Runs 'autostop_all'.

Usage::

    shutdown

This command has no arguments.

Example::

    oryxcmd> shutdown
    Stopped guest "preconfig-test"
    Stopped 1 of 1 guests

runc
----

Execute ``runc`` for an existing guest container. See the documentation of
``runc`` for further details.

Usage::

    runc NAME ARGS...

Arguments:

* ``NAME``: The identifier of the guest container for which 'runc' will be
  executed.

* ``ARGS...``: Command line arguments passed through to the 'runc' application.

help
----

List available commands with "help" or detailed help with "help cmd".

Usage::

    help [CMD]

Arguments:

* ``CMD``: The name of a supported command. If this argument is given, detailed
  help for the chosen command is printed.

Example::

    oryxcmd> help

    Documented commands (type help <topic>):
    ========================================
    add_guest      disable_guest  list_guests   remove_source  shutdown     version
    add_source     enable_guest   list_sources  runc           start_guest
    autostart_all  exit           preconfigure  show_guest     startup
    autostop_all   help           remove_guest  show_source    stop_guest

    Miscellaneous help topics:
    ==========================
    arguments

version
-------

Display version information.

Usage::

    version

This command has no arguments.

Example::

    oryxcmd> version
    oryxcmd (oryx-apps v0.3.0)

exit
----

Exit the interactive oryxcmd shell.

Usage::

    exit

This command has no arguments.

Example::

    oryxcmd> exit
