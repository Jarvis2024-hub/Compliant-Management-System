@echo off
echo Starting PHP Server for Complaint Management Backend...
echo.
echo URL: http://localhost:8000
echo.
echo Press Ctrl+C to stop the server.
echo.

"C:\xampp\php\php.exe" -S 0.0.0.0:8000 -t "%~dp0"

pause
