#!/usr/bin/python
#
#  ets - An Easy Template System
#
#      Ryoicho KATO <Ryoichi.Kato@jp.sony.com>
#
#
#  * Normal assignment cannot have newlines
#  * Newline code of heredoc must be converted to same as
#    that of template.
#
#    LINE   := COMMENT | ASSIGN | HEREDOC_ASSIGN | HEREDOC_EOL | HEREDOC_CONTENT
#    ASSIGN := VAR '=' VAL [COMMENT]
#    VAR    := [A-Z][A-Z0-9_]*
#    VAL    := ".*" | '.*' | .*
#
VERSION=(0,1)

import optparse
import sys
import re
import string



REGEX_VALID_HEREDOC = re.compile('^\s*[A-Za-z][A-Za-z0-9_]*\s*=\s*<<[A-Z0-9_]$')
REGEX_VALID_ASSIGN = re.compile('^\s*[A-Za-z][A-Za-z0-9_]*\s*=\s*(".*[^\\\\]"|[^"].*[^"]|.*\\\\")\s*$')



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
        if re.search(REGEX_VALID_ASSIGN, line):
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


def DIE(msg):
    sys.stderr.write("%s: ERROR: %s\n" % (sys.argv[0], msg))
    sys.exit(1)

if __name__ == "__main__":
    ##
    ## Option Parser
    ##
    parser = optparse.OptionParser(
        usage="%prog [OPTIONS] CONFIG [TEMPLATE]",
        version=("%%prog (Easy Template System) %d.%d" % VERSION) )

    parser.add_option("-i", "--ignore-undef",
                            action="store_true",
                            help="Ignore undefined variables in template")
    parser.add_option("-o", "--overwrite",
                            action="store_true",
                            help="Overwrite existing output file")

    (opt, args) = parser.parse_args(sys.argv)

    if len(sys.argv) < 2:
        DIE("too few arguments")


    ##
    ## Read config file
    ##
    configfd = open(sys.argv[1], 'r')
    try:
        variables = read_values(configfd)
    except InvalidFormatException, e:
        DIE(e.message);
    configfd.close()

    if len(variables.keys()) is 0:
        DIE("no variables defined in config file: %s" % sys.argv[1]);

    if len(sys.argv) == 3 and sys.argv[2] != '-':
        infd = open(sys.argv[2], 'r')
    else:
        infd = sys.stdin

    templ = string.Template(infd.read())
    sys.stdout.write( templ.substitute(variables) )

