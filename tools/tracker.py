#!/usr/bin/env python3
import os, sys
import hashlib
import json
from pathlib import Path
from json import JSONEncoder, JSONDecoder

def md5sum(f):
    h = hashlib.md5()
    for block in iter(lambda: f.read(65536), b''):
        h.update(block)
    return h.hexdigest()

def tracker_version():
    print('0.1.0-alpha1')

def tracker_help():
    print('help')

def tracker_summary(md5sum_dict):
    total = len(md5sum_dict.keys())
    files = len(tuple(filter(lambda x: not x.startswith('l:'), md5sum_dict.values())))
    links = len(tuple(filter(lambda x: x.startswith('l:'), md5sum_dict.values())))
    print('files: {}'.format(files))
    print('links: {}'.format(links))
    assert(total == files + links)
    print('total: {}'.format(total))

def tracker_add(md5sum_dict, *args, relative_to=''):
    for path in args:
        try:
            rpath = Path(path).relative_to(relative_to)
        except ValueError:
            rpath = path
        if os.path.isfile(path):
            with open(path, 'rb') as f:
                key = os.path.join('/', os.path.relpath(str(rpath)))
                value = md5sum(f)
                if md5sum_dict.get(key) is None:
                    print('new file:\t{}'.format(key))
                elif md5sum_dict.get(key) != value:
                    print('modified:\t{}'.format(key))
                md5sum_dict[key] = value
        elif os.path.islink(path):
            key = os.path.join('/', os.path.relpath(str(rpath)))
            value = os.readlink(path)
            if md5sum_dict.get(key) is None:
                print('new file:\t{}'.format(key))
            elif md5sum_dict.get(key) != value:
                print('modified:\t{}'.format(key))
            md5sum_dict[key] = value
        elif os.path.isdir(path):
            key = os.path.join('/', os.path.relpath(path)) + '/'
            value = 'd:'
            children = list(map(
                lambda x: os.path.join(path, x),
                os.listdir(path)
            ))
            tracker_add(md5sum_dict, *children, relative_to=relative_to)
        else:
            print('no such file or directory.', file=sys.stderr)
            exit(1)

if __name__ == '__main__':
    try:
        f = open('md5sum.json', 'r')
    except FileNotFoundError:
        print('md5sum.json file not found.', file=sys.stderr)
        exit(1)

    dec = JSONDecoder()
    md5sum_dict = dec.decode(f.read())
    f.close()

    if '--version' in sys.argv:
        tracker_version()
        exit(0)
    elif '--help' in sys.argv:
        tracker_help()
        exit(0)
    elif sys.argv[1] == 'add':
        if len(sys.argv) < 3:
            print('file not specified.', file=sys.stderr)
            exit(1)
        arg_from = 2
        rel = ''
        if sys.argv[2] == '-r':
            rel = sys.argv[3]
            arg_from = 4
        if sys.argv[2].startswith('--relative-to'):
            rel = sys.argv[2].replace('--relative-to=', '')
            arg_from = 3

        # Check files
        for path in sys.argv[arg_from:]:
            if not os.path.exists(path):
                print('no such file or directory: {}'.format(path), file=sys.stderr)
                exit(1)
        tracker_add(md5sum_dict, *sys.argv[arg_from:], relative_to=rel)
        with open('md5sum.json', 'w') as f:
            f.write(json.dumps(md5sum_dict, indent=2, sort_keys=True))
    else:
        tracker_summary(md5sum_dict)
        exit(0)
