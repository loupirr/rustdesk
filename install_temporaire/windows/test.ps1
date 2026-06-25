# ==== Variables de base ====
$ErrorActionPreference = 'SilentlyContinue'
$logFile = "C:\Temp\rustdesk_script.log"
$userConfigDir = "$env:APPDATA\RustDesk\config"

function Write-Log ($msg) {
    echo $msg
}

Write-Log "==== Script Start ===="

# ==== 1) Récupération du lien de la dernière version ====
try {
    $lien = (Invoke-WebRequest -Uri "https://github.com/rustdesk/rustdesk/releases/latest" -MaximumRedirection 0 -ErrorAction SilentlyContinue).Headers["Location"]
} catch {
    Write-Host "ERREUR : Impossible de joindre GitHub"
    Exit
}

$split = $lien.split("/")
$bou = -1
$requiredVersion = $split[-1]
foreach ($item in $split){
    $bou +=1
    if ($item -eq "tag"){ $split[$bou] = "download" }
}

$fin = $split -join "/"
$downloadUrl = $fin +"/rustdesk-"+ $requiredVersion +"-x86_64.exe"

# ==== 2) Nettoyage complet des anciens caches de configuration ====
Write-Log "Nettoyage du cache RustDesk..."
if (Test-Path $userConfigDir) {
    Remove-Item -Path "$userConfigDir\*" -Force -Recurse
}

# ==== 3) Le Secret : Forcer la config via le NOM du fichier ====
# RustDesk portable lit automatiquement son serveur et sa clé si on les écrit dans son propre nom d'exécutable !
if (-not (Test-Path "C:\Temp")) { New-Item -ItemType Directory -Path "C:\Temp" -Force | Out-Null }

$server = "185.81.55.61"
$key = "CyX3Yjb1RXtIhYjaAAQoZuUnuUeiWg7pZwuHvSwVv4Q="

# On génère le nom spécial requis par RustDesk
$customExeName = "rustdesk-host=$server,key=$key.exe"
$installTempPath = "C:\Temp\$customExeName"

Write-Log "Téléchargement de RustDesk dans : $installTempPath"
Invoke-WebRequest -Uri $downloadUrl -OutFile $installTempPath -UseBasicParsing

# ==== 4) Lancement et Forçage du Mot de Passe fixe ====
Write-Log "Lancement de RustDesk..."
# On le lance une première fois en arrière-plan pour qu'il s'initialise avec le nom du fichier
$process = Start-Process -FilePath $installTempPath -ArgumentList "--silent-install" -PassThru
Start-Sleep -Seconds 2

# On utilise la commande officielle RustDesk pour définir le mot de passe permanent
Write-Log "Configuration du mot de passe fixe..."
Start-Process -FilePath $installTempPath -ArgumentList "--password", "Pa55word" -Wait

# On ouvre l'interface visuelle pour le client
Start-Process -FilePath $installTempPath

Write-Log "==== Script End ===="
