@echo off
REM -- If you use absolute path. In this sample, it's directly under C:
REM -- Stop and show error message on console only for error.
REM -- NOTE: 'if ERRORLEVEL 1' means "if ERRORLEVEL is GREATHER THAN OR EQUAL TO 1"
REM -- (...What a messy bat syntax!, sigh)
REM C:\Python25\python $:\ets.py --outfile-in-config --template-in-config %1
REM if ERRORLEVEL 1 pause


REM -- If you put ets.py in the same directory as ets.bat:
REM set ets_bat=%0
REM C:\Python25\python %ets_bat:ets.bat=ets.py% --outfile-in-config --template-in-config %1
REM if ERRORLEVEL 1 pause


REM -- Almost same as above, but use GUI messaging if you have Tkinter.
REM -- (You almost certainly have Tkinter with Python's default installation
REM -- So this is the default.)
set ets_bat=%0
C:\Python25\pythonw.exe %ets_bat:ets.bat=ets.py% --gui --outfile-in-config --template-in-config %1

