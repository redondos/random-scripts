#!/usr/bin/env python
# Angel Olivera <aolivera@gmail.com>
# License: GPL v2 or later

def urlencode_json(url, query):

    """
    Return URL-encoded string.

    Arguments:
    url: htp://server.com/foo/script?
    query: list of 'key': 'value' pairs separated by commas

    """

    import urllib
    # TODO: use simplejson?

    params = {}
    for p in query:
        l = p.split(': ')
        params[l[0].strip("'")] = l[1].strip("'")

    return url + urllib.urlencode(params)

def main():
    import sys

    if len(sys.argv) < 2:
        print urlencode_json.__doc__
        sys.exit(1)

    sys.argv.pop(0) # script path
    url = sys.argv[0]
    sys.argv.pop(0) # url

    print urlencode_json(url, sys.argv[:])

if __name__ == '__main__':
    main()
