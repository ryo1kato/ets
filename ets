#!/usr/bin/python
#
#  ets - The Easy Template System
#

import sys
import re
import string


REGEX_VALID_VARVAL = re.compile('^\s*[A-Z][A-Z0-9_]*\s*=\s*(".*[^\\\\]"|[^"].*[^"]|.*\\\\")\s*$')


class InvalidFormatException(Exception):
    def __init__(self, message):
        self.message = message


def read_values(filedes):
    lineno=0
    defined_variables = dict()
    for line in filedes.readlines():
        lineno += 1
        if re.search("(^$|^#)", line):
            continue
        ## This makes parsing of config file complex.
        ## Acctually, properly handle quote and comment is beyond regex...
        #line = re.sub("#.*$","",line)
        if re.search(REGEX_VALID_VARVAL, line):
            ## str.partition is after Python2.5
            #name, separator, value = line.partition('=')
            ## ...and using split instead to be Python2.4-friendly.
            name, value = line.split('=', 1)
            name = name.strip()
            value = value.strip()
            if re.match('^".*[^\\\\]"$', value):
                value = re.sub("^\"|\"$", "", value)
            value = re.sub('\\\\"', '"', value)
            if name not in defined_variables:
                defined_variables[name] = value
            else:
                raise InvalidFormatException(
                    "line %d: valiable %s already defined at %d"
                    % (lineno, name, defined_variables[name]) )
        else:
            raise InvalidFormatException("line %d: invalid syntax for var=val assignment." % lineno)

    return defined_variables



if __name__ == "__main__":
    if len(sys.argv) < 2:
        sys.stderr.write("Usage: %s CONFIG [INFILE]\n" % sys.argv[0])
        sys.exit(1)
    else:
        configfd = open(sys.argv[1], 'r')
        try:
            variables = read_values(configfd)
        except InvalidFormatException, e:
            sys.stderr.write(sys.argv[0] + ": ERROR: " + e.message + "\n")
            sys.exit(1)
        configfd.close()

        if len(variables.keys()) is 0:
            sys.stderr.write(sys.argv[0] + ": ERROR: no variables defined in config file: "\
                             + sys.argv[1] + "\n");
            sys.exit(1)

        if len(sys.argv) == 3 and sys.argv[2] != '-':
            infd = open(sys.argv[2], 'r')
        else:
            infd = sys.stdin

        templ = string.Template(infd.read())
        sys.stdout.write( templ.substitute(variables) )

