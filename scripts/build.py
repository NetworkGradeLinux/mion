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
    return "%s/%s/%s/%s/" % (args.version, args.machine, args.system_profile, args.application_profile)

def run_build(args):
    """Run a build using the configuration given in the args namespace"""

    msg(">>> Building Oryx with ORYX_VERSION=%s MACHINE=%s SYSTEM_PROFILE=%s APPLICATION_PROFILE=%s"
            % (args.version, args.machine, args.system_profile, args.application_profile))

    os.environ['ORYX_VERSION'] = args.version
    os.environ['MACHINE'] = args.machine
    os.environ['ORYX_SYSTEM_PROFILE'] = args.system_profile
    os.environ['ORYX_APPLICATION_PROFILE'] = args.application_profile

    subfolder = get_subfolder(args)

    bitbake_args = ""
    if args.bitbake_continue:
        bitbake_args += " -k"

    bitbake_status = subprocess.call("bitbake %s oryx-publish" % (bitbake_args), shell=True)

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
            description="Build script for Oryx Embedded Linux"
            )

    parser.add_argument("-V", dest="version", metavar="VERSION", default="dev",
            help="Version string used to identify this build")

    parser.add_argument("-S", dest="system_profile", metavar="SYSTEM_PROFILE", default="native",
            help="System profile selection")

    parser.add_argument("-A", dest="application_profile", metavar="APPLICATION_PROFILE", default="minimal",
            help="Application profile selection")

    parser.add_argument("-M", dest="machine", metavar="MACHINE", default="qemux86",
            help="Machine selection")

    parser.add_argument("-C", "--clean", help="Performs a clean build", action="store_true")

    parser.add_argument("-L", "--logs", help="Captures and archives log files", action="store_true")

    parser.add_argument("-k", "--continue", dest="bitbake_continue", action="store_true",
            help="Continue as much as possible after an error")

    return parser.parse_args()

def main():
    args = parse_args()

    if args.clean and os.path.exists("tmp"):
        msg(">>> Cleaning")
        shutil.rmtree("tmp")

    exitcode = run_build(args)

    if args.logs:
        msg(">>> Capturing logs")
        capture_logs(args)

    sys.exit(exitcode)

main()
