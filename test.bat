@echo off
REM Lance le script PowerShell distant (raw) directement en mémoire.
REM Gère aussi le cas où le BAT est lancé depuis un chemin UNC.
pushd %~dp0 2>nul

powershell -NoProfile -ExecutionPolicy Bypass -Command "iex (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/loupirr/rustdesk/main/test.ps1')"

popd 2>nul
