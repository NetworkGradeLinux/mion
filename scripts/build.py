#! /usr/bin/env python3
#
# Oryx build script
#
# Copyright (C) 2017-2019 Togán Labs
# SPDX-License-Identifier: MIT
#

# pylint: disable=missing-docstring

import argparse
import collections
import os
import subprocess
import shutil
import sys
import tarfile
import termios

ALL_SUPPORTED_MACHINES = [
    'qemux86',
    'qemux86-64',
    'qemuarm',
    'qemuarm64',
    'raspberrypi3',
    'raspberrypi3-64'
]
DEFAULT_SYSTEM_PROFILE = 'native'
DEFAULT_APPLICATION_PROFILE = 'host'

TargetPair = collections.namedtuple('TargetPair', ['system_profile', 'application_profile'])

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
        'ORYX_RM_WORK',
        'ORYX_MIRROR_ARCHIVE',
        ])

    os.environ['ORYX_VERSION'] = args.build_version
    os.environ['ORYX_BASE'] = args.oryx_base
    os.environ['ORYX_OUTPUT_DIR'] = args.output_dir
    os.environ['ORYX_RM_WORK'] = args.rm_work
    os.environ['ORYX_MIRROR_ARCHIVE'] = args.mirror_archive
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

def do_shell(machine, system_profile, application_profile):
    """Start a shell where a user can run bitbake"""

    msg(">>> Entering Oryx development shell...")

    os.environ['MACHINE'] = machine
    os.environ['ORYX_SYSTEM_PROFILE'] = system_profile
    os.environ['ORYX_APPLICATION_PROFILE'] = application_profile

    return subprocess.call('bash', cwd=os.environ['BUILDDIR'])

def do_build(args, machine, system_profile, application_profile):
    """Run a build using the configuration given in the args namespace"""

    msg(">>> Building Oryx with ORYX_VERSION=%s MACHINE=%s SYSTEM_PROFILE=%s "
        "APPLICATION_PROFILE=%s"
        % (args.build_version, machine, system_profile, application_profile))

    bitbake_args = ""
    if args.bitbake_continue:
        bitbake_args += " -k"

    os.environ['MACHINE'] = machine
    os.environ['ORYX_SYSTEM_PROFILE'] = system_profile
    os.environ['ORYX_APPLICATION_PROFILE'] = application_profile

    if sys.stdin.isatty():
        tcattr = termios.tcgetattr(sys.stdin.fileno())

    retval = subprocess.call("bitbake %s oryx-image" % (bitbake_args), shell=True,
                             cwd=os.environ['BUILDDIR'])

    if sys.stdin.isatty():
        termios.tcsetattr(sys.stdin.fileno(), termios.TCSADRAIN, tcattr)

    return retval

def do_source_archive(args):
    # Confirm presence of `git archive-all` handler as it's not commonly
    # installed.
    if not shutil.which('git-archive-all'):
        msg("ERROR: Can't create a source archive without `git-archive-all`")
        msg('The command `git-archive-all` can be installed via pip, see '
            'https://pypi.org/project/git-archive-all/')
        sys.exit(1)

    archive_stem = 'oryx-%s' % (args.build_version)
    archive_fname = '%s.tar.xz' % (archive_stem)
    dest = os.path.join(args.output_dir, archive_fname)
    cmd = ['git', 'archive-all', '--prefix', archive_stem, dest]
    return subprocess.call(cmd)

def do_checksum(args):
    exitcode = 0

    for root, _, files in os.walk(args.output_dir):
        if 'SHA256SUMS' in files:
            files.remove('SHA256SUMS')
        if files:
            sha256sums_path = os.path.join(root, 'SHA256SUMS')
            with open(sha256sums_path, 'w') as sha256sums:
                cmd = ['sha256sum'] + files
                exitcode |= subprocess.call(cmd, cwd=root, stdout=sha256sums)

    return exitcode

def do_docs_html(docs_path, output_path):
    html_build_path = os.path.join(docs_path, '_build', 'html')
    html_output_path = os.path.join(output_path, 'oryx-docs-html.tar.gz')

    cmd = ['make', 'html']
    exitcode = subprocess.call(cmd, cwd=docs_path)
    if exitcode != 0:
        return exitcode

    with tarfile.open(html_output_path, 'w:gz') as tarball:
        tarball.add(html_build_path, arcname='oryx-docs-html')

    return 0

def do_docs_pdf(docs_path, output_path):
    pdf_build_path = os.path.join(docs_path, '_build', 'latex', 'oryx-docs.pdf')

    cmd = ['make', 'latexpdf']
    exitcode = subprocess.call(cmd, cwd=docs_path)
    if exitcode != 0:
        return exitcode

    shutil.copy(pdf_build_path, output_path)

    return 0

def do_docs(args):
    exitcode = 0

    docs_path = os.path.join(args.oryx_base, 'docs')
    output_path = os.path.join(args.output_dir, 'docs')

    os.makedirs(output_path, exist_ok=True)

    retval = do_docs_html(docs_path, output_path)
    exitcode |= retval
    retval = do_docs_pdf(docs_path, output_path)
    exitcode |= retval

    return exitcode

def handle_release(args):
    if args.release:
        if args.system_profile or args.application_profile or args.target_pair_list or \
                args.machine_list or args.shell:
            msg('ERROR: --release cannot be combined with --shell or specification of MACHINE, '
                'SYSTEM_PROFILE or APPLICATION_PROFILE values')
            sys.exit(1)

        args.target_pair_list = [
            'guest:minimal',
            'guest:full-cmdline',
            'native:host',
            'native:host-test'
            ]
        args.all_machines = True
        args.docs = True
        args.mirror_archive = '1'
        args.source_archive = True
        args.checksum = True

def handle_output_dir(args):
    # The default value for the output directory depends on the Oryx base
    # directory so we need to set it after arguments are parsed.
    if not args.output_dir:
        args.output_dir = os.path.join(args.oryx_base, 'build', 'images')

def handle_machine_list(args):
    # Handle --all-machines
    if args.machine_list and args.all_machines:
        msg("ERROR: Can't combine --all-machines and --machine options")
        sys.exit(1)
    if args.all_machines:
        args.machine_list = ALL_SUPPORTED_MACHINES

    if len(args.machine_list) != 1 and args.shell:
        msg('ERROR: --shell requires exactly one machine to be specified')
        sys.exit(1)

def handle_target_list(args):
    args.target_list = []

    # If only one of SYSTEM_PROFILE and APPLICATION_PROFILE is given, use the
    # default value for the other
    if args.application_profile and not args.system_profile:
        args.system_profile = DEFAULT_SYSTEM_PROFILE
    if args.system_profile and not args.application_profile:
        args.application_profile = DEFAULT_APPLICATION_PROFILE

    if args.system_profile:
        # args.application_profile must be set due to the above condition
        args.target_list.append(TargetPair(args.system_profile, args.application_profile))

    for target_pair in args.target_pair_list:
        (system_profile, application_profile) = target_pair.split(':')
        args.target_list.append(TargetPair(system_profile, application_profile))

    if not args.target_list:
        # Add the default target pair
        args.target_list.append(TargetPair(DEFAULT_SYSTEM_PROFILE, DEFAULT_APPLICATION_PROFILE))

    if len(args.target_list) != 1 and args.shell:
        msg('ERROR: --shell requires exactly one target pair (SYSTEM_PROFILE & '
            'APPLICATION_PROFILE) to be specified')
        sys.exit(1)

def handle_nothing_to_do(args):
    if not args.machine_list and not args.docs and not args.source_archive and not args.checksum:
        msg('ERROR: Nothing to do. Please specify at least one machine or one of --docs, '
            '--source-archive or --checksum')
        sys.exit(1)

def parse_args():
    """Parse command line arguments into an args namespace"""

    parser = argparse.ArgumentParser(description='Build script for Oryx Embedded Linux')

    parser.add_argument('-V', '--build-version', default='dev',
                        help='Version string used to identify this build')

    parser.add_argument('-S', '--system-profile',
                        help='System profile selection')

    parser.add_argument('-A', '--application-profile',
                        help='Application profile selection')

    parser.add_argument('-T', '--target-pair', action='append', dest='target_pair_list',
                        metavar='SYSTEM_PROFILE:APPLICATION_PROFILE', default=[],
                        help='Target pair selection (can be specified multiple times), '
                        'an alternative to passing \'-S\' & \'-A\'')

    parser.add_argument('-M', '--machine', action='append', dest='machine_list',
                        metavar='MACHINE', default=[],
                        help='Machine selection (can be specified multiple times)')

    parser.add_argument('-k', '--continue', dest='bitbake_continue', action='store_true',
                        help='Continue as much as possible after an error')

    parser.add_argument('--oryx-base', default=os.getcwd(),
                        help='Base directory of the Oryx source tree, defaults to current '
                        'working directory')

    parser.add_argument('--shell', action='store_true',
                        help='Start a development shell instead of running bitbake directly')

    parser.add_argument('-o', '--output-dir',
                        help='Output directory for final artifacts, defaults to `build/images`')

    parser.add_argument('--all-machines', action='store_true',
                        help='Build for all supported machines')

    parser.add_argument('--rm-work', action='store_const', const='1', default='0',
                        help='Remove temporary files after building each recipe to save disk space')

    parser.add_argument('--mirror-archive', action='store_const', const='1', default='0',
                        help='Populate a full source mirror')

    parser.add_argument('--dl-dir',
                        help='Override path for downloads directory')

    parser.add_argument('--sstate-dir',
                        help='Override path for sstate cache directory')

    parser.add_argument('--docs', action='store_true',
                        help='Build documentation')

    parser.add_argument('--source-archive', action='store_true',
                        help='Create an archive of the Oryx Project sources (bitbake, layers, '
                        'build config & scripts)')

    parser.add_argument('--checksum', action='store_true',
                        help='Create checksums for all build artifacts (used for Oryx releases)')

    parser.add_argument('--release', action='store_true',
                        help='Perform a full release build')

    args = parser.parse_args()

    # handle_release() must be called first as it pre-sets other arguments
    handle_release(args)
    handle_output_dir(args)
    handle_machine_list(args)
    handle_target_list(args)
    handle_nothing_to_do(args)

    return args

def main():
    args = parse_args()

    setup_env(args)

    if args.shell:
        machine = args.machine_list[0]
        target = args.target_list[0]
        exitcode = do_shell(machine, target.system_profile, target.application_profile)
    else:
        exitcode = 0
        for machine in args.machine_list:
            for target in args.target_list:
                retval = do_build(args, machine, target.system_profile, target.application_profile)
            exitcode |= retval

        if args.docs:
            retval = do_docs(args)
            exitcode |= retval

        if args.source_archive:
            retval = do_source_archive(args)
            exitcode |= retval

        if args.checksum:
            retval = do_checksum(args)
            exitcode |= retval

    sys.exit(exitcode)

if __name__ == "__main__":
    main()
