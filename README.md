# About mion

mion is a Linux distro and image builder designed for operation in
high-risk environments such as Critical National Infrastructure. mion is
designed to run mainly on programmable network switches, although, due to it
being based on the Yocto Project and OpenEmbedded, it is not limited to that
use case.

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
git clone https://github.com/NetworkGradeLinux/meta-mion-backports.git
```

## Basic Usage

To begin, set up the build environment using the OpenEmbedded init script.
Afterwords you can use our build script. Running `../cronie.sh` without
arguments displays basic usage. **In general:**

```shell
source openembedded-core/oe-init-build-env
../cronie.sh -m <machine> <image>
```

**NOTE: The \<image\> argument must be provided last**

To do a "dry run" without running a build, add `-e` which emits what would have
run if you ran this from bitbake.

If you are familiar with Yocto Project development and wish to
use bitbake directly, see the local.conf for variables that need to be set. For
running bitbake commands, including outside of building, such as
`bitbake-layers show-layers`, run `../cronie.sh` as you otherwise would with
the `-e` flag from the build directory and prepend the `BB_ENV_EXTRAWHITE`
output to the bitbake command.

Example:

```shell
BB_ENV_EXTRAWHITE="ALL_PROXY BBPATH_EXTRA BB_LOGCONFIG BB_NO_NETWORK BB_NUMBER_THREADS BB_SETSCENE_ENFORCE BB_SRCREV_POLICY DISTRO FTPS_PROXY FTP_PROXY GIT_PROXY_COMMAND HTTPS_PROXY HTTP_PROXY MACHINE NO_PROXY PARALLEL_MAKE SCREENDIR SDKMACHINE SOCKS5_PASSWD SOCKS5_USER SSH_AGENT_PID SSH_AUTH_SOCK STAMPS_DIR TCLIBC TCMODE all_proxy ftp_proxy ftps_proxy http_proxy https_proxy no_proxy  VENDOR" VENDOR="stordis" MACHINE="stordis-bf6064x-t" bitbake  "mion-onie-image-onlpv1"
```

### Example

```shell
# Builds an ONLPV1 ONIE image
../cronie.sh -m stordis-bf2556x-1t mion-onie-image-onlpv1
```
