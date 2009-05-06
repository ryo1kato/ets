#!/usr/bin/python
#
#  ets - An Easy Template System
#
#                               Ryoicho KATO <Ryoichi.Kato@jp.sony.com>
#                               Last Change: 2009/05/06 12:44:53.
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
#    Template filename also could be specified by a special variable
#    __TEMPLATE_FILE__ defined in CONFIG, but superseded by command line
#    argument.
#
#    Config:
#        | WHO = brown fox
#        | WHOM =    " the lazy dog"
#        | HEREDOC =<< EOL
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
# HISTORY
#    ---- v0.1 ----
#    * Initial version, same as used for NV-U44(NA) release pages.
#
#    ---- v0.2 ----
#    * Basic test cases
#    * Heredoc support (basic)
#    * '-i' option for ignore error for undefined reference.
#
#    ---- v0.3 ----
#    * Embedded template filename in configuration file.
#    * Embedded output filename in configuration file.
#
# ROADMAP
#    ---- v0.3 ----
#    * Windows/Double-Click capable
#    * Heredoc support (smart newline handling)
#    * Line-end comment support
#    * Error test cases
#    * Config/Template composite file.
#
#    ---- v0.4 ----
#    * Single-quote support
#    * BNF syntax and documentation
#    * (Japanese) Char-code autodetect and conversion
#    * Heredoc support (indent support: <<-EOF )
#    * Multiple config files
#    * Oneline config support
#    * Sophisticated error handling and report
#

VERSION=(0,2)

import optparse
import sys
import re
import os
import string


REGEX_VALID_HEREDOC = re.compile('^\s*[A-Za-z][A-Za-z0-9_]*\s*=\s*<<\s*[A-Z][A-Za-z0-9_]*\s*$')
REGEX_VALID_ASSIGN = re.compile('^\s*([A-Za-z][A-Za-z0-9_]*|__TEMPLATE_FILE__|__OUTPUT_FILE__)\s*=\s*(".*[^\\\\]"|[^"].*[^"]|.*\\\\")\s*$')


##
## Exception object for invalid config-file format
##
class InvalidFormatException(Exception):
    def __init__(self, message):
        self.message = message

##
## A peek-able line-oriented file object.
## Supporting line-number counint used to parse config-file,
## to makes it easy to report syntax error in config with line number.
##
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

##
## Read configuration file and returns a key-value pair as dictionary.
##
def read_values(filedes):
    defined_variables = dict()
    config = ConfigLines(filedes)

    while True:
        lineno, line = config.pop_one_line()

        if line == None:
            break

        if re.search("(^$|^#)", line):
            continue

        if re.search(REGEX_VALID_HEREDOC, line):
            line = re.sub('=\s*<<', '=<<', line)
            name, eof_mark= line.split('=<<', 1)
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
        elif re.search(REGEX_VALID_ASSIGN, line):
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


##
## Messaging wrapper.
##
def DIE(msg):
    sys.stderr.write("%s: ERROR: %s\n" % (sys.argv[0], msg))
    sys.exit(1)

def WARNING(msg):
    sys.stderr.write("%s: WARNING: %s\n" % (sys.argv[0], msg))


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
    #parser.add_option("-o", "--overwrite",
    #                        action="store_true",
    #                        help="Overwrite existing output file")

    (opt, args) = parser.parse_args(sys.argv)

    if len(args) < 2:
        DIE("too few arguments")


    ##
    ## Read config file
    ##
    configpath = args[1]
    configfd = open(configpath, 'r')
    try:
        variables = read_values(configfd)
    except InvalidFormatException, e:
    #except InvalidFormatException as e:  #for Python3000
        DIE("Config file error: " + e.message);
    configfd.close()

    if len(variables.keys()) is 0:
        DIE("no variables defined in config file: %s" % sys.argv[1]);

    if len(args) == 3 and args[2] != '-':
        if "__TEMPLATE_FILE__" in variables:
            WARNING('__TEMPLATE_FILE__ is defined in %s' % configpath)
        infd = open(args[2], 'r')
    elif "__TEMPLATE_FILE__" in variables:
        template_path = ""
        template_name = variables['__TEMPLATE_FILE__']
        template_name_rel = os.path.join(os.path.dirname(configpath), template_name)
        if os.path.exists(template_name):
            template_path = template_name
        elif os.path.exists( template_name_rel ):
            template_path = template_name_rel
        else:
            template_path = template_name

        infd = open(template_path, 'r')
    else:
        infd = sys.stdin


    outfd = sys.stdout

    templ = string.Template(infd.read())
    if opt.ignore_undef:
        outfd.write( templ.safe_substitute(variables) )
    else:
        outfd.write( templ.substitute(variables) )

