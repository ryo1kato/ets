@echo off
REM -- If you use absolute path
REM -- In this sample, it's directly under C:
REM -- (dummy echo so that ets.py don't wait stdin forever
REM -- when you forget to feed __TEMPLATE_FILE__)
REM echo __TEMPLATE_FILE__ not defined | C:\Python25\python C:\ets.py "%1"


REM -- If you put ets.py in the same directory as ets.bat:
set ets_bat=%0
C:\Python25\python %ets_bat:ets.bat=ets.py% --outfile-in-config --template-in-config %1


REM -- Stop and show error message on console only for error.
REM -- NOTE: 'if ERRORLEVEL 1' means "if ERRORLEVEL is GREATHER THAN OR EQUAL TO 1"
REM -- What a messy bat syntax!
if ERRORLEVEL 1 pause
