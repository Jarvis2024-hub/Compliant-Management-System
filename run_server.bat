@echo off
echo Starting Local PHP Server...
echo Access via: http://localhost:8000/backend/
cd /d "%~dp0"
"C:\xampp\php\php.exe" -S 0.0.0.0:8000
pause
