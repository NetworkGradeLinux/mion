#! /usr/bin/env python3

import argparse
import shutil
import subprocess
import sys

BUILDS = (
    # SYSTEM_PROFILE        APPLICATION_PROFILE
    ( 'native'            , 'host-test'         ),
    ( 'guest'             , 'minimal'           ),
    )

N_BUILDS = len(BUILDS)

def msg(message):
    print(message, flush=True)

def parse_args():
    parser = argparse.ArgumentParser(
            description='CI script for Oryx Embedded Linux')

    parser.add_argument('version', help='Version string used to identify this build')
    parser.add_argument('machine', help='Machine to test')

    return parser.parse_args()

def prepare():
    msg('>>> Copying CI configuration')
    shutil.copyfile('ci/auto.conf', 'build/conf/auto.conf')

def run_build(version, machine, sys_profile, app_profile):
    script = './scripts/run-build.py -k -V %s -M %s -S %s -A %s' % (
        version, machine, sys_profile, app_profile)
    cp = subprocess.run(script, shell=True, executable='/bin/bash')
    return cp.returncode

def run_all_builds(version, machine):
    failures = 0
    for i, (sys_profile, app_profile) in enumerate(BUILDS, 1):
        msg('>>> Running build %d of %d' % (i, N_BUILDS))
        rc = run_build(version, machine, sys_profile, app_profile)
        if rc == 0:
            msg('>>> Build succeeded')
        else:
            msg('>>> Build failed')
            failures += 1
    msg('>>> Completed %d builds with %d failures' % (N_BUILDS, failures))
    if failures > 0:
        return 1
    else:
        return 0

def cleanup():
    msg('>>> Removing tmp & cache directories')
    shutil.rmtree('build/tmp')
    shutil.rmtree('build/cache')

def main():
    args = parse_args()
    prepare()
    rc = run_all_builds(args.version, args.machine)
    cleanup()
    sys.exit(rc)

if __name__ == '__main__':
    main()
