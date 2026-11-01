
@echo off
cd /d "%~dp0"

echo Installing Python dependencies globally...
python -m pip install --upgrade pip
if errorlevel 1 goto error

python -m pip install -r model\requirements.txt
if errorlevel 1 goto error

echo.
echo Setup completed successfully!
pause
exit /b 0

:error
echo.
echo Installation failed. Check the error above.
pause
exit /b 1