#!/usr/bin/python
#
#  ets - An Easy Template System
#
#                               Ryoicho KATO <Ryoichi.Kato@jp.sony.com>
#                               Last Change: 2008/11/27 21:30:51.
#
# USAGE: ets [OPTIONS] CONFIG [TEMPLATE]
#    Use '--help' option for more detail.
#
# DESCRIPTION
#    Easy Template System (ets) is a tiny python template engine with shell
#    script like syntax.  It takes two input files: config and template, and
#    substitute all variable symbols in template file like "${VAR}" with the
#    value defined in config file.
#
#    Config:
#        | WHO = brown fox
#        | WHOM =    " the lazy dog"
#        | HEREDOC = <<EOL
#        | This is
#        | multi line
#        | definition using heredoc syntax.
#        | EOL
#
#    Template:
#        | Quick ${WHO} jumped over${WHOM}.
#        | Heredoc sample: ${HEREDOC}
#
#    Output:
#        | Quick brown fox jumped over the lazy dog.
#        | Heredoc sample: This is
#        | multi line
#        | definition using heredoc syntax.
#
# SYNTAX (Incomplete)
#    LINE   := COMMENT | ASSIGN | HEREDOC_ASSIGN | HEREDOC_EOL | HEREDOC_CONTENT
#    ASSIGN := VAR '=' VAL [COMMENT]
#    VAR    := [A-Z][A-Z0-9_]*
#    VAL    := ".*" | .*
#
# HISTORY
#    ---- v0.1 ----
#
# ROADMAP
#    ---- v0.2 ----
#    * Basic test cases
#    * Heredoc support (basic)
#    * Heredoc support (smart newline handling)
#    * Line-end comment support
#    ---- v0.3 ----
#    * Error test cases
#    * Single-quote support
#    * BNF syntax and documentation
#    ---- v0.4 ----
#    * Oneline config support
#    * Sophisticated error handling and report
#

VERSION=(0,1)

import optparse
import sys
import re
import string



REGEX_VALID_HEREDOC = re.compile('^\s*[A-Za-z][A-Za-z0-9_]*\s*<<\s*[A-Z][A-Za-z0-9_]*\s*$')
REGEX_VALID_ASSIGN = re.compile('^\s*[A-Za-z][A-Za-z0-9_]*\s*=\s*(".*[^\\\\]"|[^"].*[^"]|.*\\\\")\s*$')



class InvalidFormatException(Exception):
    def __init__(self, message):
        self.message = message

class ConfigLines:
    def __init__(self, filedes):
        self.config_lines = filedes.readlines()
        self.lineno=0

    def pop_one_line(self):
        if len(self.config_lines) == 0:
            return ( self.lineno, None )
        else:
            self.lineno += 1
            line = self.config_lines.pop(0)
            return ( self.lineno, line )

    def peek_one_line(self):
        if len(self.config_lines) == 0:
            return ( lineno, None )
        else:
            line = self.config_lines[0]
            return ( self.lineno, line )


def read_values(filedes):
    defined_variables = dict()
    config = ConfigLines(filedes)

    while True:
        lineno, line = config.pop_one_line()

        if line == None:
            break

        if re.search("(^$|^#)", line):
            continue

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
        elif re.search(REGEX_VALID_HEREDOC, line):
            name, eof_mark= line.split('<<', 1)
            name = name.strip()
            eof_mark = eof_mark.strip()
            heredoc = ""
            while True:
                lineno, line = config.pop_one_line()
                if line == None:
                    InvalidFormatException("line %d: end of heredoc not found for %s." % (lineno, eof_mark))
                    break
                if re.search("^%s$" % eof_mark, line):
                    break
                else:
                    heredoc += line
                defined_variables[name] = heredoc
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

    #parser.add_option("-i", "--ignore-undef",
    #                        action="store_true",
    #                        help="(NIY) Ignore undefined variables in template")
    #parser.add_option("-o", "--overwrite",
    #                        action="store_true",
    #                        help="(NIY) Overwrite existing output file")

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

