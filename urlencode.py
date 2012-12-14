#!/usr/bin/env python
# Angel Olivera <aolivera@gmail.com>
# License: GPL v2 or later

def urlencode(url):
    '''Escape unsafe characters in URL.'''
    import urllib

    start = url.find('://')
    start = url.find('/', start+3)
    start += 1
    server = url[:start]
    path = url[start:]

    return server + urllib.quote(path)

def main():
    import sys

    if len(sys.argv) < 2:
        print urlencode.__doc__
        sys.exit(1)

    sys.argv.pop(0) # script path
    print urlencode(''.join(sys.argv))

if __name__ == "__main__":
    main()

