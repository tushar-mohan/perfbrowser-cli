#! /usr/bin/env python
import sys
import os
import stat
import argparse
from subprocess import call
from dotmap import DotMap
from pbutils import login, logout, configure_logging, jobs_list, browse_job


def usage():
    return '''
pb is a command-line interface to PerfBrowser
'''

base_dir=os.path.dirname(os.path.abspath(__file__))

EXE_MAP = DotMap({
    'import' : {'exe' : 'pb-import.py', 'args':''},
    'rest' : {'exe' : 'pb-rest.py', 'args':''},
    'test' : {'exe' : '{0}/test/run'.format(base_dir), 'args':''}
})

def parse_args():
    p = argparse.ArgumentParser(description=usage(),
                                formatter_class=argparse.RawTextHelpFormatter)
    p.add_argument('-v', '--verbose', action='count', default=0, help='Increase logging level. Can be used multiple times')
    p.add_argument('command', choices = ['help', 'import', 'login', 'logout', 'rest', 'test', 'version'],
                   help = 'perfbrowser command to execute (required)')
    p.add_argument('arguments', nargs=argparse.REMAINDER, default = None,
                   help='any arguments to pass to command (optional)')

    args = p.parse_args()

    if 'help' in args.arguments:
        args.arguments = ['-h' if x == 'help' else x for x in args.arguments ]

    if args.command and (args.command in EXE_MAP):
        for c in range(args.verbose):
            args.arguments.insert(0, '-v')

    args.arguments = " ".join(args.arguments)

    if (args.command == 'help'):
        p.print_help()
        sys.exit(0)
    return args

if __name__ == "__main__":

    args = parse_args()
    # if (args.command == 'version'):
    #     try:
    #         version_f = open(os.path.dirname(os.path.abspath(__file__)) + "/../.version")
    #     except IOError:
    #         print "version unknown"
    #     else:
    #         print "perfminer ({0})".format(version_f.read().strip())
    #     sys.exit(0)

    if args.command in EXE_MAP:
        os.environ['PATH'] = "{0}:{1}".format(base_dir, os.environ['PATH'])
        c = EXE_MAP[args.command]
        cmd = "{exe} {default_args} {args}".format(exe=c.exe, default_args = c.args, args=args.arguments)

        cmd = cmd.rstrip() # remove trailing
        cmd = ' '.join(cmd.split()) # remove duplicates
        rc = call(cmd, shell=True)
        sys.exit(rc)
    else:
        configure_logging(verbose=args.verbose)
        if args.command == 'login':
            login()
        elif args.command == 'logout':
            logout()
    sys.exit(0)
