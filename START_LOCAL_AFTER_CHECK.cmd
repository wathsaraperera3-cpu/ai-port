@echo off
cd /d "%~dp0"
echo WARNING: Start this only after Jac compiler checks pass.
echo Starting local frontend proxy at http://127.0.0.1:5500
python dev_server.py
pause
