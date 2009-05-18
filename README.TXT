ets - an Easy Template System

                              Ryoicho KATO <Ryoichi.Kato@jp.sony.com>
                              Last Change: 2009/05/18 19:18:36.

USAGE: ets [OPTIONS] CONFIG [TEMPLATE]
    Use '--help' option for more detail.


DESCRIPTION
    Easy Template System (ets) is a tiny python template engine with shell-
    script like syntax.  It takes two input files: config and template, and
    substitute all variable symbols in template file like "${VAR}" with the
    value defined in config file.

    Template filename also could be specified by a special variable
    __TEMPLATE_FILE__ defined in CONFIG, but superseded by command line
    argument.

    If a variable __OUTPUT_FILE__ is defined, output is written to
    that file. Written to standard output otherwise.

    Config:
        | WHO = brown fox
        | WHOM =    " the lazy dog"
        | HEREDOC =<< EOL
        | This is
        | multi line
        | definition using heredoc syntax.
        | EOL

    Template:
        | Quick ${WHO} jumped over${WHOM}.
        | Heredoc sample: ${HEREDOC}

    Output:
        | Quick brown fox jumped over the lazy dog.
        | Heredoc sample: This is
        | multi line
        | definition using heredoc syntax.


HISTORY
    ---- v0.1 ----
    * Initial version, same as used for NV-U44(NA) release pages.

    ---- v0.2 ----
    * Basic test cases
    * Heredoc support (basic)
    * '-i' option for ignore error for undefined reference.

    ---- v0.3 ----
    * Embedded template filename in configuration file.
    * Embedded output filename in configuration file.
    * Windows double-click/drag-and-drop support (using ets.bat)
    * Error test cases

    ---- v0.4 ----
    * Don't overwrite output file by default.
    * --outfile and --overwrite option.
    * GUI message box for MS-Windows user.

    ---- v0.5 ----
    * Show error dialog for unknown exception (with traceback).

ROADMAP
    ---- v0.6 ----
    * Recursive variable expansion
    * Heredoc support (smart newline handling)
    * Line-end comment support
    * Config/Template composite file.

    ---- v0.7 ----
    * Single-quote support
    * BNF syntax and documentation
    * (Japanese) Char-code autodetect and conversion
    * Heredoc support (indent support: <<-EOF )
    * Multiple config files
    * Oneline config support
    * Sophisticated error handling and report


BUGS
    * An empty file left undeleted on error
      (when __OUTPUT_FILE__ or --outfile is specified)
