#!/usr/bin/env python3

import os, sys
import json

PACKAGES_DIR = '/usr/share/laniakea-installer/packages'

packages = {
    'make': os.getenv('MAKE_VERSION'),
    'libc6': os.getenv('LIBC_VERSION'),
    'util-linux': os.getenv('UTIL_LINUX_VERSION'),
}

if __name__ == '__main__':
    dec = json.JSONDecoder()
    f = open(PACKAGES_DIR + '/patches.json', 'r')
    patches_json = f.read()
    f.close()

    patches = dec.decode(patches_json)
    for name, patch in patches.items():
        package_name = patch['target']['package']
        if packages[package_name] in patch['target']['versions']:
            for cmd in patch['commands']:
                os.system('cd {}/patches/{} ; {}'.format(PACKAGES_DIR, name, cmd))
