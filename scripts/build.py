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

        # Oryx configuration
        'MACHINE',
        'ORYX_BASE',
        'ORYX_SYSTEM_PROFILE',
        'ORYX_APPLICATION_PROFILE',
        'ORYX_VERSION',
        'ORYX_OUTPUT_DIR'
        ])

    os.environ['ORYX_VERSION'] = args.build_version
    os.environ['ORYX_SYSTEM_PROFILE'] = args.system_profile
    os.environ['ORYX_APPLICATION_PROFILE'] = args.application_profile
    os.environ['ORYX_BASE'] = args.oryx_base
    os.environ['ORYX_OUTPUT_DIR'] = args.output_dir
    os.environ['BUILDDIR'] = os.path.join(args.oryx_base, 'build')
    os.environ['BB_ENV_EXTRAWHITE'] = env_whitelist
    os.environ['PATH'] = '%s:%s:%s' % (
        os.path.join(args.oryx_base, 'openembedded-core', 'scripts'),
        os.path.join(args.oryx_base, 'bitbake', 'bin'),
        os.environ['PATH']
        )

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

    return subprocess.call("bitbake %s oryx-publish" % (bitbake_args), shell=True, cwd=os.environ['BUILDDIR'])

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
        return exitcode

exitcode = main()
sys.exit(exitcode)
