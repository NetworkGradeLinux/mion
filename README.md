# About mion

mion is a Linux distro and image builder designed for operation in
high-risk environments such as Critical National Infrastructure. mion is
designed to run mainly on programmable network switches, although, due to it
being based on the Yocto Project and OpenEmbedded, it is not limited to that
use case.

mion provides both container based solutions or an ONIE compatible installer.
By using containers, mion allows for easy updates and installs, as well as the
ability to isolate applications requiring access to specialized hardware from
those which use ‘normal’ Linux interfaces like the network and filesystems.

mion tracks the Yocto Project's dunfell and dunfell-next branches. Dunfell is
the Yocto Project's 3.1 [Long Term Support](https://www.yoctoproject.org/yocto-project-long-term-support-announced/)
branch.

> mion is provided under a MIT License. See [COPYING](#copying) for copyright and
license information.

## Quickstart

Reference information for building mion.

Getting familiar with the [Yocto Project and OpenEmbedded](https://www.yoctoproject.org/docs/).

Want to know more about mion? Our [main documentation](https://docs.mion.io)
has the in-depth information and resources to help get you started.

### Table of Contents

[About](#about-mion)

[Obtaining mion](#obtaining-mion-sources)

[Basic Usage](#basic-usage)

[Examples](#examples)

## Obtaining mion sources

```shell
git clone --recursive https://github.com/NetworkGradeLinux/mion.git
cd mion
# To obtain related mion layers:
git clone https://github.com/NetworkGradeLinux/meta-mion.git
# Obtain the mion hardware layer
git clone https://github.com/NetworkGradeLinux/meta-mion-bsp.git
git clone https://github.com/NetworkGradeLinux/meta-mion-sde.git
```

## Basic Usage

To begin, set up the build environment using the OpenEmbedded init script.
Afterwords you can use our build script. Running `../mc_build.sh` without
arguments displays basic usage. **In general:**

```shell
source openembedded-core/oe-init-build-env
../mc_build.sh -m <machine> -c <container config>:<container image> -h <host config>:<host_image> -d container_image
```

To do a "dry run" without running a build, add `-e` which emits what would have
run if you ran this from bitbake.
If you want to disable the autostarting of the container, use -d with a comma
delineated list of the container image name.

If you are familiar with Yocto Project development and multiconfig and wish to
use bitbake directly, see the local.conf for variables that need to be set. For
running bitbake commands, including outside of building, such as
`bitbake-layers show-layers`, run `../mc_build.sh` as you otherwise would with
the `-e` flag from the build directory and prepend the `BB_ENV_EXTRAWHITE`
output to the bitbake command.

Example:

```shell
BB_ENV_EXTRAWHITE="ALL_PROXY BBPATH_EXTRA BB_LOGCONFIG BB_NO_NETWORK BB_NUMBER_THREADS BB_SETSCENE_ENFORCE BB_SRCREV_POLICY DISTRO FTPS_PROXY FTP_PROXY GIT_PROXY_COMMAND HTTPS_PROXY HTTP_PROXY MACHINE NO_PROXY PARALLEL_MAKE SCREENDIR SDKMACHINE SOCKS5_PASSWD SOCKS5_USER SSH_AGENT_PID SSH_AUTH_SOCK STAMPS_DIR TCLIBC TCMODE all_proxy ftp_proxy ftps_proxy http_proxy https_proxy no_proxy  BUILD_ARGS CONTAINER_NAMES CONTAINER_DEPENDS BBMULTICONFIG MION_CONT_DISABLE VENDOR" BUILD_ARGS=" host-onie:mion-image-onlpv1" BBMULTICONFIG=" host-onie" CONTAINER_NAMES="" CONTAINER_DEPENDS="" VENDOR="stordis" MACHINE="stordis-bf2556x-1t" MION_CONT_DISABLE="" bitbake-layers show-layers
```

## Examples

```shell

# Builds just an ONLPV1 Guest. Useful for creating update artifacts.
../mc_build.sh -m stordis-bf2556x-1t -c guest:mion-guest-onlpv1

# Builds an ONLPV1 ONIE image
../mc_build.sh -m stordis-bf2556x-1t -h host-onie:mion-onie-image-onlpv1

# Builds an image with ONLPV2 and ONLPV1 guests but disables ONLPV1 guest
../mc_build.sh -m stordis-bf2556x-1t -c guest:mion-guest-onlpv1,guest:mion-guest-onlpv2 -h host-onie:mion-host -d mion-guest-onlpv1

# Emits the commandline to build an image with ONLPV2 and ONLPV1 guests but disables ONLPV1 guest
../mc_build.sh -e -m stordis-bf2556x-1t -c guest:mion-guest-onlpv1,guest:mion-guest-onlpv2 -h host-onie:mion-host -d mion-guest-onlpv1
```
