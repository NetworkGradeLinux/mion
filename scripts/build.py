#! /usr/bin/env python3

import argparse
import glob
import os
import subprocess
import shutil
import sys
import tarfile

def msg(message):
    print(message, flush=True)

def get_subfolder(args):
    return "%s/%s/%s/%s/" % (args.build_version, args.machine, args.system_profile, args.application_profile)

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
        'ORYX_VERSION'
        ])

    os.environ['ORYX_VERSION'] = args.build_version
    os.environ['MACHINE'] = args.machine
    os.environ['ORYX_SYSTEM_PROFILE'] = args.system_profile
    os.environ['ORYX_APPLICATION_PROFILE'] = args.application_profile
    os.environ['ORYX_BASE'] = args.oryx_base
    os.environ['TOPDIR'] = os.path.join(args.oryx_base, 'build')
    os.environ['BUILDDIR'] = os.environ['TOPDIR']
    os.environ['BB_ENV_EXTRAWHITE'] = env_whitelist
    os.environ['PATH'] = '%s:%s:%s' % (
        os.path.join(args.oryx_base, 'openembedded-core', 'scripts'),
        os.path.join(args.oryx_base, 'bitbake', 'bin'),
        os.environ['PATH']
        )

def do_shell():
    """Start a shell where a user can run bitbake"""

    msg(">>> Entering Oryx development shell...")

    return subprocess.call('bash', cwd=os.environ['TOPDIR'])

def do_build(args):
    """Run a build using the configuration given in the args namespace"""

    msg(">>> Building Oryx with ORYX_VERSION=%s MACHINE=%s SYSTEM_PROFILE=%s APPLICATION_PROFILE=%s"
            % (args.build_version, args.machine, args.system_profile, args.application_profile))

    subfolder = get_subfolder(args)

    bitbake_args = ""
    if args.bitbake_continue:
        bitbake_args += " -k"

    bitbake_status = subprocess.call("bitbake %s oryx-publish" % (bitbake_args), shell=True, cwd=os.environ['TOPDIR'])

    # Copy the contents of the output files out of the tmp folder. The
    # destination folder must not already exist for copytree to work.
    folder = "tmp/deploy/oryx/" + subfolder
    newfolder = "pub/" + subfolder
    if os.path.exists(newfolder):
        shutil.rmtree(newfolder)
    if os.path.exists(folder):
        shutil.copytree(folder, newfolder)
    else:
        # At least create an empty folder in case we need to create a FAILED
        # file
        os.makedirs(newfolder)

    # Create FAILED file if bitbake failed
    if bitbake_status != 0:
        failedfile = "%s/FAILED" % (newfolder)
        open(failedfile,'w')

    return bitbake_status

def capture_logs(args):
    """Capture log files and archive them"""

    directorylist = ['tmp/work/*/*/*/temp/run.*', 'tmp/work/*/*/*/temp/log.*', 'tmp/log/*']
    globlist = []
    for directory in directorylist:
        for filename in glob.iglob(directory):
            globlist.append(filename)

    subfolder = get_subfolder(args)
    tarlocation = "pub/%s/logs.tar.gz" % (subfolder)
    tar = tarfile.open(tarlocation, "w:gz")
    for item in globlist:
        tar.add(item)
    tar.close()

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

    parser.add_argument('-M', '--machine', default='qemux86',
        help='Machine selection')

    parser.add_argument('-C', '--clean', action='store_true',
        help='Performs a clean build')

    parser.add_argument('-L', '--logs', action='store_true',
        help='Captures and archives log files')

    parser.add_argument('-k', '--continue', dest='bitbake_continue', action='store_true',
        help='Continue as much as possible after an error')

    parser.add_argument('--oryx-base', default=os.getcwd(),
        help='Base directory of the Oryx source tree, defaults to current working directory')

    parser.add_argument('--shell', action='store_true',
        help='Start a development shell instead of running bitbake directly')

    return parser.parse_args()

def main():
    args = parse_args()

    if args.clean and os.path.exists("tmp"):
        msg(">>> Cleaning")
        shutil.rmtree("tmp")

    setup_env(args)

    if args.shell:
        exitcode = do_shell()
    else:
        exitcode = do_build(args)

        if args.logs:
            msg(">>> Capturing logs")
            capture_logs(args)

    sys.exit(exitcode)

main()
