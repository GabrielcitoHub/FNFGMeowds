@echo off
cd /d "%~dp0"
:loop
start /wait "" "PsychEngine.exe"
echo Game closed. Restarting in 3 seconds...
timeout /t 3 >nul
goto loop
