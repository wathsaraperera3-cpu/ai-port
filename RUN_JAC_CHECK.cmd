@echo off
cd /d "%~dp0"
echo PortMind AI Colombo - checking all Jac files...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0check-jac-windows.ps1"
echo.
echo Check results and attach PortMind-Jac-Compiler-Logs.zip if there are errors.
pause
