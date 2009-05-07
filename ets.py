#!/usr/bin/python
#
#  ets - An Easy Template System
#
#                               Ryoicho KATO <Ryoichi.Kato@jp.sony.com>
#                               Last Change: 2009/05/08 03:10:02.
#
# USAGE: ets [OPTIONS] CONFIG [TEMPLATE]
#    Use '--help' option for more detail.
#

VERSION=(0,4)

import optparse
import sys
import re
import os
import string

import Tkinter
import tkMessageBox


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
class MSG:
    def __init__(self, gui=False):
        self.gui=gui
        if gui:
            root = Tkinter.Tk()
            root.withdraw()

    def INFO(self, msg):
        if self.gui:
            tkMessageBox.showinfo('ets', msg)
        else:
            pass

    def WARNING(self, msg):
        if self.gui:
            tkMessageBox.showwarning('ets: WARNING', msg)
        else:
            sys.stderr.write("%s: WARNING: %s\n" % (sys.argv[0], msg))

    def ERROR(self, msg):
        if self.gui:
            tkMessageBox.showerror('ets: ERROR', msg)
        else:
            sys.stderr.write("%s: ERROR: %s\n" % (sys.argv[0], msg))

    def DIE(self, msg):
        self.ERROR(msg)
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
        help="Ignore undefined variables in template.")

    parser.add_option("-t", "--template-in-config",
        action="store_true",
        help="Assume __TEMPLATE_FILE__ is defined in config."
             "Report error otherwise.")

    parser.add_option("-o", "--outfile-in-config",
        action="store_true",
        help="Assume __OUTPUT_FILE__ is defined in config."
             "Report error otherwise.")

    parser.add_option("-O", "--outfile", dest="outfile",
        help="Write output to FILE. Overwriding __OUTPUT_FILE__"
             "and path is relative to current directory rather than config file.",
        metavar="FILE")

    parser.add_option("-g", "--gui",
        action="store_true",
        help="Show message and errors in GUI")

    parser.add_option("-W", "--overwrite",
        action="store_true",
        help="Overwrite existing output file.")

    (opt, args) = parser.parse_args(sys.argv)

    msg = MSG(opt.gui)

    if len(args) < 2:
        msg.DIE("too few arguments")

    if len(args) > 3:
        msg.DIE("too many arguments")


    ##
    ## Read config file
    ##
    configpath = args[1]
    configfd = open(configpath, 'r')
    try:
        variables = read_values(configfd)
    except InvalidFormatException, e:
    #except InvalidFormatException as e:  #for Python3000
        msg.DIE("Config file error: " + e.message);
    configfd.close()

    if len(variables.keys()) is 0:
        msg.DIE("no variables defined in config file: %s" % sys.argv[1]);


    ##
    ## Determine template filename.
    ##   If --template-in-config, force use of __TEMPLATE_FILE__.
    ##   Otherwise __TEMPLATE_FILE__ might be used, but superseded by 3rd
    ##   commandline argument (filename or '-').  Use stdin when no
    ##   __TEMPLATE_FILE__ definition nor commandline argument.
    ##

    if opt.template_in_config and "__TEMPLATE_FILE__" not in variables:
        msg.DIE("__TEMPLATE_FILE__ is not defined in %s" % configpath)

    if len(args) == 3:
        if opt.template_in_config:
            msg.DIE("Can't pass template filename(%s) in arugument when"
                "--template-in-config option is enabled" % args[2])
        else:
            if "__TEMPLATE_FILE__" in variables:
                msg.WARNING("Ignoring __TEMPLATE_FILE__ defined in %s" % configpath)
            if args[2] != '-':
                infd = open(args[2], 'r')
            else:
                infd = sys.stdin
    elif "__TEMPLATE_FILE__" in variables:
        template_name = variables['__TEMPLATE_FILE__']
        template_name_abs = os.path.join(os.path.dirname(configpath), template_name)
        template_path = ""
        if os.path.exists(template_name):
            # it's absolute path or relative path from current directory.
            template_path = template_name
        elif os.path.exists( template_name_abs ):
            template_path = template_name_abs
        else:
            msg.DIE("Can't open template file: %s" % template_name)

        infd = open(template_path, 'r')
    else:
        infd = sys.stdin


    ##
    ## Determine output filename (it's stdout unless __OUTPUT_FILE__ is defined).
    ##   if __OUTPUT_FILE__ is relative, it consider to be relative to the directory
    ##   in which configuration file resides.
    ##   If --outfile option is given, it supersedes __OUTPUT_FILE__, and consider to
    ##   relative to current directory.
    ##
    def check_overwrite_and_open(path, flags):
        if not opt.overwrite and os.path.exists(path):
            msg.DIE("output file %s already exists" % path)
        else:
            return open(path, flags)

    if "__OUTPUT_FILE__" in variables:
        if opt.outfile is not None:
            if opt.outfile_in_config:
                msg.DIE("Can't pass output filename(--outfile)"
                    "when --outfile-in-config option is enabled")
            else:
                msg.WARNING("__OUTPUT_FILE__ is overridden by --outfile option")
            outfd = check_overwrite_and_open(opt.outfile, 'w')
            outfile_used = opt.outfile
        else:
            output_file = variables['__OUTPUT_FILE__']
            if not os.path.isabs(output_file):
                output_file = os.path.join(os.path.dirname(configpath), output_file)
            outfd = check_overwrite_and_open(output_file, 'w')
            outfile_used = output_file
    elif opt.outfile_in_config:
        msg.DIE("__OUTPUT_FILE__ is not defined in %s" % configpath)
    else:
        outfd = sys.stdout
        outfile_used = "standard output"


    ##
    ## Read, substitute template and output result.
    ##

    templ = string.Template(infd.read())
    if opt.ignore_undef:
        outfd.write( templ.safe_substitute(variables) )
    else:
        outfd.write( templ.substitute(variables) )

    msg.INFO("Success.\n(Output: %s)" % outfile_used)
