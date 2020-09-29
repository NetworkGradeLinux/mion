*mion: mion infrastructure operating system for networks*

# About mion
[mion](mion.io) provides an embedded Linux OS where container based solutions
allow for easy updates, added functionality, and improved security, done in
alignment with the Yocto Project, with a focus on Network Grade Linux.

mion tracks dunfell and dunfell-next branches, with Dunfell as the main 
(formerly titled "master") branch. Dunfell is the Yocto Project's 3.1 
[LTS](https://www.yoctoproject.org/yocto-project-long-term-support-announced/)
branch.

If you're interested in contributing to the project, check out
[CONTRIBUTING.md](#contributing.md) and our
[code of conduct](#code-_-of-_-conduct)

mion is provided under a MIT License. See [COPYING](#copying) for copyright
and license information. 

## Quickstart
Reference information for building Mion OS. Not familiar with 
the Yocto Project and OpenEmbedded? Want to know more about mion? 
Our main documentation has the in-depth information and resources to help 
get you started.

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
git clone git@github.com:APS-Networks/meta-mion-stordis.git
```

## Basic Usage
To begin, set up the build environment using the OpenEmbedded init script.
Afterwords you can use our build script. Running `./mc_build.sh` without
arguments displays basic usage. **In general:**

```shell
source openembedded-core/oe-init-build-env
./mc_build.sh -m <machine> -c <container config>:<container image> -h <host config>:<host_image>
```

To do a "dry run" without running a build, add `-e` which emits bitbake. 
Want to disable autostart for a container? Prefix the container image with `-d`.

## Examples:
```shell
# Builds an ONLPV1 Guest and autostarts
../mc_build.sh -m stordis-bf2556x-1t -c guest:mion-guest-onlpv1 -h host-mender:mion-host
# Builds an ONLPV1 ONIE image
../mc_build.sh -m stordis-bf2556x-1t -h host-onie:mion-onie-image-onlpv1
# Builds an image with ONLPV2 and ONLPV1 guests but disables ONLPV1 guest
../mc_build.sh -m stordis-bf2556x-1t -c guest:mion-guest-onlpv1,guest:mion-guest-onlpv2 -h host-mender:mion-host -d mion-guest-onlpv1
# Emits the commandline to build an image with ONLPV2 and ONLPV1 guests but disables ONLPV1 guest
../mc_build.sh -e -m stordis-bf2556x-1t -c guest:mion-guest-onlpv1,guest:mion-guest-onlpv2 -h host-mender:mion-host -d mion-guest-onlpv1
```

