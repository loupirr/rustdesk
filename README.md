# rustdesk

@echo off
powershell -NoProfile -ExecutionPolicy Bypass -Command "iex (New-Object Net.WebClient).DownloadString('https://exemple.com/Install_rustdesk.ps1')"
pause
