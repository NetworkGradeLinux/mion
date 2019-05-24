#! /usr/bin/env python3

import argparse
import glob
import os
import subprocess
import shutil
import sys
import tarfile

ALL_SUPPORTED_MACHINES = [
    'qemux86',
    'qemux86-64',
    'qemuarm',
    'qemuarm64',
    'raspberrypi3',
    'raspberrypi3-64'
]

def msg(message):
    print(message, flush=True)

def setup_env(args):
    """Setup the environment variables required to invoke bitbake"""

    env_whitelist = ' '.join([
        # Network access control
        'BB_NO_NETWORK',
        'BB_SRCREV_POLICY',

        # Parallelism
        'BB_NUMBER_THREADS',
        'PARALLEL_MAKE',

        # SSH
        'SSH_AGENT_PID',
        'SSH_AUTH_SOCK',

        # Proxy servers
        'ALL_PROXY',
        'FTPS_PROXY',
        'FTP_PROXY',
        'GIT_PROXY_COMMAND',
        'HTTPS_PROXY',
        'HTTP_PROXY',
        'NO_PROXY',
        'SOCKS5_PASSWD',
        'SOCKS5_USER',
        'all_proxy',
        'ftp_proxy',
        'ftps_proxy',
        'http_proxy',
        'https_proxy',
        'no_proxy',

        # Downloads and sstate locations
        'DL_DIR',
        'SSTATE_DIR',

        # Oryx configuration
        'MACHINE',
        'ORYX_BASE',
        'ORYX_SYSTEM_PROFILE',
        'ORYX_APPLICATION_PROFILE',
        'ORYX_VERSION',
        'ORYX_OUTPUT_DIR',
        'ORYX_RM_WORK'
        ])

    os.environ['ORYX_VERSION'] = args.build_version
    os.environ['ORYX_SYSTEM_PROFILE'] = args.system_profile
    os.environ['ORYX_APPLICATION_PROFILE'] = args.application_profile
    os.environ['ORYX_BASE'] = args.oryx_base
    os.environ['ORYX_OUTPUT_DIR'] = args.output_dir
    os.environ['ORYX_RM_WORK'] = args.rm_work
    os.environ['BUILDDIR'] = os.path.join(args.oryx_base, 'build')
    os.environ['BB_ENV_EXTRAWHITE'] = env_whitelist
    os.environ['PATH'] = '%s:%s:%s' % (
        os.path.join(args.oryx_base, 'openembedded-core', 'scripts'),
        os.path.join(args.oryx_base, 'bitbake', 'bin'),
        os.environ['PATH']
        )

    if args.dl_dir:
        os.environ['DL_DIR'] = args.dl_dir
    if args.sstate_dir:
        os.environ['SSTATE_DIR'] = args.sstate_dir

def do_shell(machine):
    """Start a shell where a user can run bitbake"""

    msg(">>> Entering Oryx development shell...")

    os.environ['MACHINE'] = machine

    return subprocess.call('bash', cwd=os.environ['BUILDDIR'])

def do_build(args, machine):
    """Run a build using the configuration given in the args namespace"""

    msg(">>> Building Oryx with ORYX_VERSION=%s MACHINE=%s SYSTEM_PROFILE=%s APPLICATION_PROFILE=%s"
            % (args.build_version, machine, args.system_profile, args.application_profile))

    bitbake_args = ""
    if args.bitbake_continue:
        bitbake_args += " -k"

    os.environ['MACHINE'] = machine

    return subprocess.call("bitbake %s oryx-image" % (bitbake_args), shell=True, cwd=os.environ['BUILDDIR'])

def do_source_archive(args):
    # Confirm presence of `git archive-all` handler as it's not commonly
    # installed.
    if not shutil.which('git-archive-all'):
        msg("ERROR: Can't create a source archive without `git-archive-all`")
        msg('The command `git-archive-all` can be installed via pip, see https://pypi.org/project/git-archive-all/')
        sys.exit(1)

    archive_stem = 'oryx-%s' % (args.build_version)
    archive_fname = '%s.tar.xz' % (archive_stem)
    dest = os.path.join(args.output_dir, archive_fname)
    cmd = ['git', 'archive-all', '--prefix', archive_stem, dest]
    return subprocess.call(cmd)

def do_checksum(args):
    exitcode = 0

    for root, dirs, files in os.walk(args.output_dir):
        if 'SHA256SUMS' in files:
            files.remove('SHA256SUMS')
        if len(files):
            sha256sums_path = os.path.join(root, 'SHA256SUMS')
            with open(sha256sums_path, 'w') as f:
                cmd = ['sha256sum'] + files
                exitcode |= subprocess.call(cmd, cwd=root, stdout=f)

    return exitcode

def parse_args():
    """Parse command line arguments into an args namespace"""

    parser = argparse.ArgumentParser(
        description='Build script for Oryx Embedded Linux'
        )

    parser.add_argument('-V', '--build-version', default='dev',
        help='Version string used to identify this build')

    parser.add_argument('-S', '--system-profile', default='native',
        help='System profile selection')

    parser.add_argument('-A', '--application-profile', default='minimal',
        help='Application profile selection')

    parser.add_argument('-M', '--machine', action='append', dest='machine_list',
        help='Machine selection')

    parser.add_argument('-k', '--continue', dest='bitbake_continue', action='store_true',
        help='Continue as much as possible after an error')

    parser.add_argument('--oryx-base', default=os.getcwd(),
        help='Base directory of the Oryx source tree, defaults to current working directory')

    parser.add_argument('--shell', action='store_true',
        help='Start a development shell instead of running bitbake directly')

    parser.add_argument('-o', '--output-dir',
        help='Output directory for final artifacts, defaults to `$BUILDDIR/images`')

    parser.add_argument('--all-machines', action='store_true',
        help='Build for all supported machines')

    parser.add_argument('--rm-work', action='store_const', const='1', default='0',
        help='Remove temporary files after building each recipe to save disk space')

    parser.add_argument('--dl-dir',
        help='Override path for downloads directory')

    parser.add_argument('--sstate-dir',
        help='Override path for sstate cache directory')

    parser.add_argument('--source-archive', action='store_true',
        help='Create an archive of the Oryx Project sources (bitbake, layers, build config & scripts)')

    parser.add_argument('--checksum', action='store_true',
        help='Create checksums for all build artifacts (used for Oryx releases)')

    args = parser.parse_args()

    # Handle --all-machines
    if args.machine_list and args.all_machines:
        msg("ERROR: Can't combine --all-machines and --machine options")
        sys.exit(1)
    if args.all_machines:
        args.machine_list = ALL_SUPPORTED_MACHINES

    # If we set a default value above for the machines list, argparse will add
    # any user specified machines to the list instead of replacing the default.
    # So instead let's set the default here if the user didn't give us any
    # machines.
    if not args.machine_list:
        args.machine_list = ['qemux86']

    # The default value for the output directory depends on the Oryx base
    # directory so we need to set it after arguments are parsed.
    if not args.output_dir:
        args.output_dir = os.path.join(args.oryx_base, 'build', 'images')

    return args

def main():
    args = parse_args()

    setup_env(args)

    if args.shell:
        if len(args.machine_list) > 1:
            msg("ERROR: Can't invoke a development shell for more than one machine")
            return 1
        return do_shell(args.machine_list[0])
    else:
        exitcode = 0
        for machine in args.machine_list:
            r = do_build(args, machine)
            exitcode |= r

        if args.source_archive:
            exitcode |= do_source_archive(args)

        if args.checksum:
            exitcode |= do_checksum(args)

        return exitcode

exitcode = main()
sys.exit(exitcode)
