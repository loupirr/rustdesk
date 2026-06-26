# ==== Error Handling and Global Variables ====
$ErrorActionPreference = 'SilentlyContinue'  # Suppress non-terminating errors
$logFile = "C:\Temp\rustdesk_script.log"

# ==== Required Version and Paths ====
try {
    $lien = Invoke-WebRequest -Uri "https://github.com/rustdesk/rustdesk/releases/latest" -UseBasicParsing
}
catch {
    Write-Host "ERREUR : LE LIEN N'EST PLUS D'ACTUALITÉ    (lien) "
    Exit
}

$lien = (Invoke-WebRequest -Uri "https://github.com/rustdesk/rustdesk/releases/latest" -MaximumRedirection 0 -ErrorAction SilentlyContinue -UseBasicParsing).Headers["Location"]

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

$rustdeskDownload    = $fin +"/rustdesk-"+ $requiredVersion +"-x86_64.exe"
Write-Host $rustdeskDownload

$installTempPath    = "C:\Temp\rustdesk.exe"
$rustdeskExePath    = "C:\Program Files\RustDesk\rustdesk.exe"
$rustdeskLogDir     = "$env:APPDATA\RustDesk\log"

# Chemins des fichiers de configuration (Réseau d'un côté, Sécurité de l'autre)
$userConfigPath2      = "C:\Users\$env:USERNAME\AppData\Roaming\RustDesk\config\RustDesk2.toml"
$serviceConfigPath2   = "C:\Windows\ServiceProfiles\LocalService\AppData\Roaming\RustDesk\config\RustDesk2.toml"
[byte[]]$AES_Key = @(237,54,246,139,216,69,197,5,192,223,11,127,2,138,159,9) # Exemple de clé
$SecretPassword  = "76492d1116743f0423413b16050a5345MgB8AGgAagBqAHUATgAwAEgAdABoAFIASgA3AFEATgBTAGMAbwBKAGwAcQBJAHcAPQA9AHwANgA0ADkAYgBlADQAYQA5ADMANQAzADgAYwA2ADEAYQAzADAANwAxADMANQA5ADYANQA5ADkAYgA5ADkAMgAyADAAYQAyADQAMwA1A
GQAOAAzAGIAMgBlAGEAYwAzADcAMAA2AGEAOQAyAGUANQA5AGYAZgAyADUAZgAwAGYAMAA=" # Exemple de texte chiffré

# ==== Logging Function ====
function Write-Log {
    param([string]$message)
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$ts - $message" | Out-File -Append -FilePath $logFile
}

Write-Log "==== Script Start ===="

# ==== 0) Check Installed Version ====
$skipInstall = $false
if (Test-Path $rustdeskExePath) {
    try {
        $versionInfo = (Get-Command $rustdeskExePath).FileVersionInfo
        $installedVersion = $versionInfo.ProductVersion
        Write-Log "RustDesk detected. Installed version: $installedVersion"
        if ([version]$installedVersion -ge [version]$requiredVersion) {
            Write-Log "RustDesk is already at the required version ($requiredVersion) or higher. Skipping installation."
            $skipInstall = $true
        } else {
            Write-Log "Installed version ($installedVersion) is lower than required ($requiredVersion). Updating."
        }
    } catch {
        Write-Log "Failed to retrieve installed version. Proceeding with installation."
    }
} else {
    Write-Log "RustDesk is not installed. Proceeding with installation."
}

# ==== 1) Create Temporary Directory ====
if (-not (Test-Path "C:\Temp")) {
    New-Item -ItemType Directory -Path "C:\Temp" -Force | Out-Null
    Write-Log "Temporary directory created."
}

if (-not $skipInstall) {
    # ==== 2) Download and Install RustDesk ====
    Write-Log "Downloading RustDesk $requiredVersion..."
    Invoke-WebRequest -Uri $rustdeskDownload -OutFile $installTempPath -UseBasicParsing
    Write-Log "Download completed."

    Write-Log "Installing RustDesk..."
    Start-Process -FilePath $installTempPath -ArgumentList "--silent-install" -PassThru | Wait-Process
    Write-Log "Installation completed."
    Start-Sleep -Seconds 5

    # ==== 3) Stop RustDesk Service and Processes ====
    Write-Log "Stopping RustDesk service..."
    net stop rustdesk | Out-Null
    Get-Process rustdesk -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
}

# ==== 4) Generate and Apply TOML Configuration ====
$toml_network = @"
rendezvous_server = '185.81.55.61:21116'
nat_type = 1
serial = 0
unlock_pin = ''

[options]
api-server = 'http://185.81.55.61'
direct-server = 'Y'
relay-server = '185.81.55.61'
direct-access-port = '21118'
av1-test = 'Y'
verification-method = 'use-permanent-password'
key = 'EbE2XPrHtzDDYDo1dciBmCMlG5fP+xVX1PLJDZlDsZE='
custom-rendezvous-server = '185.81.55.61'
"@

# Ajout du bloc sécurité contenant ton mot de passe et son sel hachés
$toml_security = @"
password = '01AeX/Ao5O8kJig8WRUEkP3y0eT/7YBvnYnvKtNa7LKh//VsHNWwlnUbasgv2rJLjoFlHzf/mipLMSgB8W+WS7uCFa+Z52a9MMdZH49Hsni4rsfzWYBrCY'
salt = '5ggkmmh2qyajdhf5u75k65ts4p5eptuu'
"@

# Écriture des fichiers de configuration Réseau (RustDesk2.toml)
foreach ($path in @($userConfigPath2, $serviceConfigPath2)) {
    $dir = Split-Path $path
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Log "Directory $dir created."
    }
    Set-Content -Path $path -Value $toml_network -Encoding UTF8
    Write-Log "Network TOML configuration written to $path."
}

# Écriture des fichiers de configuration Sécurité (RustDesk.toml)
foreach ($path in @($userConfigPath, $serviceConfigPath)) {
    $dir = Split-Path $path
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    Set-Content -Path $path -Value $toml_security -Encoding UTF8
    Write-Log "Security TOML configuration (Hashed Password) written to $path."
}

# ==== 5) Start RustDesk Service ====
Write-Log "Starting RustDesk service..."
net start rustdesk | Out-Null
Start-Sleep -Seconds 5

# ==== 6) Set Access Password ====
# Note : Cette étape n'est plus strictement obligatoire car le mot de passe est déjà injecté haché 
# dans le fichier RustDesk.toml. On laisse le démarrage propre du service valider la configuration.

Write-Log "==== Script End ===="
Write-Output "Script completed. Check $logFile for more details."
