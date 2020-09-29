*mion: mion infrastructure operating system for networks*

# About mion
[mion](mion.io) is a Linux distro and image builder designed for operation in 
high-risk environments such as Critical National Infrastructure. mion is 
designed to run mainly on programmable network switches, although, due to it 
being based on the Yocto Project and OpenEmbedded, it is not limited to that use case.

mion provides both container based solutions or an ONIE compatible installer. By using containers, mion allows for easy updates and installs, as well as the ability to isolate applications requiring access to specialized hardware from those which use ‘normal’ Linux interfaces like the network and filesystems.

mion tracks the Yocto Project's dunfell and dunfell-next branches. Dunfell is the Yocto Project's 3.1 [Long Term Support](https://www.yoctoproject.org/yocto-project-long-term-support-announced/) branch.

If you're interested in contributing to the project, check out
[CONTRIBUTING.md](#contributing.md) and our
[code of conduct](#code-_-of-_-conduct)

mion is provided under a MIT License. See [COPYING](#copying) for copyright
and license information. 

## Quickstart
Reference information for building mion. 

Getting familiar with the [Yocto Project and OpenEmbedded](https://www.yoctoproject.org/docs/). 

Want to know more about mion? Our [main documentation](https://docs.mion.io) has the in-depth information and resources to help get you started.

### Table of Contents
[About](#about-mion)

[Obtaining mion](#obtaining-mion-sources)

[Basic Usage](#basic-usage)

[Examples](#examples)

## Obtaining mion sources
```shell
git clone --recursive git@github.com:APS-Networks/mion.git
cd mion
# To obtain related mion layers:
git clone git@github.com:APS-Networks/meta-mion.git
# Obtain the relevant hardware layer, i.e. git clone git@github.com:APS-Networks/meta-mion-stordis.git
git clone git@github.com:APS-Networks/meta-mion-<ONL_VENDOR>.git
# Add Bitbake Layer to bblayers.conf
```

## Basic Usage
To begin, set up the build environment using the OpenEmbedded init script.
Afterwords you can use our build script. Running `../mc_build.sh` without
arguments displays basic usage. **In general:**

```shell
source openembedded-core/oe-init-build-env
../mc_build.sh -m <machine> -c <container config>:<container image> -h <host config>:<host_image> -d container_image
```

To do a "dry run" without running a build, add `-e` which emits what would have run if you ran this from bitbake. 
If you want to disable the autostarting of the container, use -d with a comma delineated list of the container image name.

If you are familiar with Yocto Project development and multiconfig and wish to use bitbake directly, see the local.conf for variables that need to be set.

## Examples:
```shell
# Builds an ONLPV1 Guest, installs it on a mender updatable host and autostarts
../mc_build.sh -m stordis-bf2556x-1t -c guest:mion-guest-onlpv1 -h host-mender:mion-host

# Builds just an ONLPV1 Guest. Useful for creating update artifacts.
../mc_build.sh -m stordis-bf2556x-1t -c guest:mion-guest-onlpv1

# Builds an ONLPV1 ONIE image
../mc_build.sh -m stordis-bf2556x-1t -h host-onie:mion-onie-image-onlpv1

# Builds an image with ONLPV2 and ONLPV1 guests but disables ONLPV1 guest
../mc_build.sh -m stordis-bf2556x-1t -c guest:mion-guest-onlpv1,guest:mion-guest-onlpv2 -h host-mender:mion-host -d mion-guest-onlpv1

# Emits the commandline to build an image with ONLPV2 and ONLPV1 guests but disables ONLPV1 guest
../mc_build.sh -e -m stordis-bf2556x-1t -c guest:mion-guest-onlpv1,guest:mion-guest-onlpv2 -h host-mender:mion-host -d mion-guest-onlpv1
```

