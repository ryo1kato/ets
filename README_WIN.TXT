README_WIN.TXT - a tips to use ETS on windows


INTRODUCTION

    "ets.bat" is a sample batch file for Windows users.
    It assumes you always supply __TEMPLATE_FILE__ and __OUTPUT_FILE__
    variable in config file (-t and -o options are enabled in ets.bat)

    You can drag-and-drop ets-configration file (sample.ets) to ets.bat
    and will get an output file "sample-out.txt"

    Optionally, you can submit extention ".ets" to be handled by "ets.bat"
    so that you just have to double-click "ets.bat", instead of drag-and-drop.


INSTALL COMMON
    1. Install Python 2.5 or later for Windows (Python3000 is not supported)
        http://www.python.org/ftp/python/2.5.4/python-2.5.4.msi


INSTALL A: Using .bat file
    2. Copy "ets.py" and "ets.bat" somewhere.
       (put the two files in  the same directory)

    3. Drag-and-drop sample.ets file to ets.bat.


INSTALL B: File Association.
    2. Copy "ets.py" somewhere. Say it's "C:\Programs\ets\ets.ets"

    3. You can associate ".ets" extention to "pythonw.exe" like this(one line)

        "C:\Python25\pythonw.exe" "C:\Programs\ets\ets.py" --gui
        --outfile-in-config --template-in-config "%1"

      (Tips: Control Panel -> Folder Options -> File Types )
