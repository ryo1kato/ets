README_WIN.TXT - a tips to use ETS on windows


INTRODUCTION

    "ets.bat" is a sample batch file for windows users.
    It assumes you always supply __TEMPLATE_FILE__ and __OUTPUT_FILE__
    variable in config file (-t and -o options are enabled in ets.bat)

    You can drag-and-drop ets-configration file (sample.ets) to ets.bat
    and will get an output file "sample-out.txt"

    Optionally, you can submit extention ".ets" to be handled by "ets.bat"
    so that you just have to double-click "ets.bat", instead of drag-and-drop.

INSTALL

    1. Install Python 2.5 or later for windows (Python3000 is not supported)
        http://www.python.org/ftp/python/2.5.4/python-2.5.4.msi

    2. Copy "ets.py" and "ets.bat" somewhere.
       (put the two files in  the same directory)

    3. [OPTIONAL] You can associate ".ets" to something like "C:\Programs\ets.bat"
       (or anywhere you installed ets.bat) from  Control Panel >> Folder Options.

       Then all you have to do is double-click *.ets file.
       (Don't forget to define __TEMPLATE_FILE__ and __OUTPUT_FILE__ variable in it)
