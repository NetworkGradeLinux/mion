# Mion Quickstart Guide
Reference information for building Mion OS. Not familiar with 
the Yocto Project and Open Embedded? Our main documentation has in-depth 
information and resources for help getting started.

### Table of Contents
[Obtaining Mion](#obtaining-mion)

[System Profiles](#system-profiles)

[Application Profiles](#application-profiles)

[Platform Profiles](#platform-profiles)

[ONIE Platform](#onie-platform)

[Basic Commands](#basic-commands)

## Obtaining Mion

```shell
git clone --recursive git@github.com:APS-Networks/mion.git
cd mion
# Apply out of tree patches not yet upstreamed:
./patches/apply.sh
```

*TODO: meta-mion and meta-mion stordis are not within mion. If this is
intentional, add git commands to fetch those layers.*

## System Profiles
System profiles set how images, including containers, get deployed and
booted in Mion. More details on system profiles is available in the Oryx 
documentation, [here](https://oryx.readthedocs.io/en/latest/building-images.html#system-profiles).
See [Basic Commands](#basic-commands) below on how to select a system profile
for a Mion build.

### meta-mion:

| System Profile             | Purpose                                       |
|----------------------------|-----------------------------------------------|
| mion-native                | Base operating system for running containers. |
| mion-native-onie           | Mion configured for running ONIE.             |
| mion-native-mender         | Mion with mender updater support.             |
| guest                      | Basic guest container.                        |
| guest-mender-update-module | Guest container with mender updater support.  |

> system profiles can be found in `meta-mion/conf/system-profiles`.

## Application Profiles
Application profiles cover specific use-cases, which often correlate to a 
host:guest relationship. Application profiles specify package and package 
groups, and package customization.

| Application Profile   | Purpose                                           |
|-----------------------|---------------------------------------------------|
| mion-host-onie-onlpv1 | Mion OS for onlpv1, pair with mion-guest-onlpv1   |
| mion-guest-onlpv1     | Guest container supporting the ONLPv1 platform.   |
| mion-host-onie-onlpv2 | Mion OS for onlpv2, pair with mion-guest onlpv2   |
| mion-guest-onlpv2     | Guest container supporting the ONLPv2 platform.   |
| mion-guest-test       | Guest container with testing and debugging tools. |
| mion-host-dev         | Mion OS for development, for creating the sdk.    |
| mion-host-prod        | Host OS for production build.                     |
| mion-host-prod-mender | Host OS with mender support for production        |
| mion-host-test        | Host OS for testing, pair with mion-guest-test    |

> Application profiles can be found in `meta-mion/conf/application-profiles`.

## Platform Profiles
Platform profiles support Open Linux Networking Platforms(ONLP), which provides 
an interface for network switch hardware. The platform profiles provide support 
for stordis-bf2556c-1t under both ONLP version 1 and version 2 specifications.

The platform profiles are included into a build for the first four mion 
application profiles in the table above.  

## ONIE Platform

ONIE is the Open Network Installer environment, which runs on the switch 
hardware and allows for switching between network operating systems.

The ONIE profiles cover a machine and ONLP version.

> The ONIE profiles are found in `meta-mion-stordis/conf/onie-profiles/,<MACHINE>/`.

## Basic Commands
The following commands uses the `-T` argument which allows for multiple
pairs of `System Profile:Application Profile`.

### Example:

`/scripts/build.py -M stordis-bf2556x-1t -T guest:mion-guest-onlpv2 -T mion-native-mender:mion-host-prod-mender`
`-M stordis-bf2556-1t` specifies the machine, the first set specified with `-T` 
builds a guest container with support for ONLPv2. The second builds a mion OS
running on the machine, and an application profile with mender support.

#### To Build host filesystem with ONLPv1 Guest:

`./scripts/build.py -M stordis-bf2556x-1t -T guest:mion-guest-onlpv1 -T mion-native-onie-new:mion-host-prod`

#### To Build host filesystem with ONLPv2 Guest:

`./scripts/build.py -M stordis-bf2556x-1t -T guest:mion-guest-onlpv2 -T mion-native-onie-new:mion-host-prod`

#### To Build ONIE installer for ONLPv1:

`./scripts/build.py -M stordis-bf2556x-1t -T guest:mion-guest-onlpv1 -T mion-native-onie:mion-host-onie-onlpv1`

#### To Build ONIE installer for ONLPv2:

`./scripts/build.py -M stordis-bf2556x-1t -T guest:mion-guest-onlpv2 -T mion-native-onie:mion-host-onie-onlpv2`

#### To drop into a development shell and use bitbake directly:
`./scripts/build.py --shell`
> You can also specify machine with `-M`, system profiles with `-S` and
application profiles with `-A`. The '`-T` option can still be used, but can
only be used for one machine, system profile, and application profile at a time.
