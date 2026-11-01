
@echo off
cd /d "%~dp0"

start "Python Model Service" cmd /k "python model\model_service.py"
start "Node.js Application" cmd /k "npm start"

exit