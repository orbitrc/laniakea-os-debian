#!/usr/bin/env python3
import sys

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print('arguments error')
        exit(1)

    f1 = open(sys.argv[1], 'r')
    f2 = open(sys.argv[2], 'r')

    text1 = f1.read()
    text2 = f2.read()

    f1.close()
    f2.close()

    d1 = {}
    d2 = {}

    for line in text1.split('\n'):
        if line.strip() == '':
            continue
        (k, v) = line.strip().split()
        d1[k] = v

    for line in text2.split('\n'):
        if line.strip() == '':
            continue
        (k, v) = line.strip().split()
        d2[k] = v

    for k in d1.keys():
        try:
            d1[k] == d2[k]
        except KeyError:
            print('{}: {}'.format(k, d1[k]))

    for k in d2.keys():
        try:
            d2[k] == d1[k]
        except KeyError:
            print('{}: {}'.format(k, d2[k]))
