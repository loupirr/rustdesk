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
$toml_unique = @"
rendezvous_server = '185.81.55.61:21116'
nat_type = 1
serial = 0
unlock_pin = ''
trusted_devices = ''
password = 'Pa55word'

[options]
key = 'CyX3Yjb1RXtIhYjaAAQoZuUnuUeiWg7pZwuHvSwVv4Q='
custom-rendezvous-server = '185.81.55.61'
av1-test = 'Y'
verification-method = 'use-permanent-password'
direct-server = 'Y'
"@

if (-not (Test-Path $userConfigDir)) {
    New-Item -ItemType Directory -Path $userConfigDir -Force | Out-Null
    Write-Output "Dossier de configuration créé : $userConfigDir"
}

# On applique TOUT dans le fichier officiel RustDesk.toml
Set-Content -Path $userConfigPath -Value $toml_unique -Encoding UTF8
Write-Output "Configuration TOML écrite dans : $userConfigPath"


# ==== 4) Lancement de RustDesk sans installation ====
Write-Output "Lancement de RustDesk portable..."

# Plus besoin de passer l'argument --config qui sème la confusion, RustDesk va lire RustDesk.toml tout seul
Start-Process -FilePath $installTempPath

Write-Output "RustDesk lancé avec la configuration personnalisée."
Write-Output "==== Script End ===="


C:\temp\rustdesk.exe



