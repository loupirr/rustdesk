# ==== Variables de base ====
$ErrorActionPreference = 'SilentlyContinue'
$logFile = "C:\Temp\rustdesk_script.log"
$installTempPath = "C:\Temp\rustdesk.exe"
$userConfigDir = "$env:APPDATA\RustDesk\config"
$userConfigPath2 = "$userConfigDir\RustDesk2.toml"
$userConfigPath = "$userConfigDir\RustDesk.toml"


Write-Log "==== Script Start ===="

# ==== 1) Récupération du lien de la dernière version ====


try {
    $lien = Invoke-WebRequest -Uri "https://github.com/rustdesk/rustdesk/releases/latest"
}
catch {
    Write-Host "ERREUR : LE LIEN N'EST PLUS D'ACTUALITÉ    (lien) "
    Exit
}


$lien = (Invoke-WebRequest -Uri "https://github.com/rustdesk/rustdesk/releases/latest" -MaximumRedirection 0 -ErrorAction SilentlyContinue).Headers["Location"]

if ($lien -like ""){
    Write-Host "ERREUR : LE LIEN N'EST PLUS D'ACTUALITÉ  (header)"
    Exit
}


$split = $lien.split("/")
$bou = -1
$requiredVersion = $split[-1]
foreach ($item in $split){
    $bou +=1
    if ($item -eq "tag"){
        $split[$bou] = "download"
    }
   
}

$fin = $split -join "/"
Write-Host $fin
Write-Host $requiredVersion

$downloadUrl   = $fin +"/rustdesk-"+ $requiredVersion +"-x86_64.exe"
Write-Host $downloadUrl

# ==== 2) Téléchargement de RustDesk portable ====
if (-not (Test-Path "C:\Temp")) {
    New-Item -ItemType Directory -Path "C:\Temp" -Force | Out-Null
    Write-Log "Création du dossier C:\temp"
    }
Write-Log "Téléchargement de RustDesk..."
Invoke-WebRequest -Uri $downloadUrl -OutFile $installTempPath -UseBasicParsing
Write-Log "Téléchargement terminé."

# ==== 3) Création de la configuration TOML ====
$toml = @"
rendezvous_server = '192.168.22.102:21116'
nat_type = 1
serial = 0
unlock_pin = ''
trusted_devices = ''

[options]
local-ip-addr = '192.168.22.196'
key = 'EbE2XPrHtzDDYDo1dciBmCMlG5fP+xVX1PLJDZlDsZE='
api-server = 'http://192.168.22.102'
direct-access-port = '21118'
custom-rendezvous-server = '192.168.22.102'
av1-test = 'Y'
verification-method = 'use-permanent-password'
direct-server = 'Y'
relay-server = '192.168.22.102'
"@

$toml2 = @"
password = '00lQeHebBjpGg1pvuEaiU8AILLBSnK1fHj'
"@

if (-not (Test-Path $userConfigDir)) {
    New-Item -ItemType Directory -Path $userConfigDir -Force | Out-Null
    Write-Output "Dossier de configuration créé : $userConfigDir"
}
Set-Content -Path $userConfigPath2 -Value $toml -Encoding UTF8
Write-Output "Configuration TOML écrite dans : $userConfigPath2"

Set-Content -Path $userConfigPath -Value $toml2 -Encoding UTF8
Write-Output "Configuration TOML écrite dans : $userConfigPath"


# ==== 4) Lancement de RustDesk sans installation ====
Write-Output "Lancement de RustDesk portable..."
Start-Process -FilePath $installTempPath -ArgumentList "--config", $userConfigPath2

Write-Output "RustDesk lancé avec la configuration personnalisée."

Write-Output "==== Script End ===="
Write-Output "RustDesk lancé temporairement avec la configuration."


C:\temp\rustdesk.exe


