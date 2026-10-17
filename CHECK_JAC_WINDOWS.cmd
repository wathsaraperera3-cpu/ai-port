@echo off
setlocal
cd /d "%~dp0"
set "CHECKERR=0"
for %%F in (model seed engine agents operations audit api) do (
 echo.
 echo ===== jac check jac\%%F.jac =====
 jac check jac\%%F.jac > "jac-check-%%F.log" 2>&1
 if errorlevel 1 (
   echo FAIL: jac\%%F.jac ^(see jac-check-%%F.log^)
   set "CHECKERR=1"
 ) else (
   echo PASS: jac\%%F.jac
 )
)
echo.
if "%CHECKERR%"=="0" (
 echo All Jac files passed the installed Jac checker.
) else (
 echo One or more Jac files failed. DO NOT run the server yet.
 echo Zip logs with this PowerShell command:
 echo Compress-Archive -Path .\jac-check-*.log -DestinationPath .\PortMind-Compiler-Logs.zip -Force
)
pause
