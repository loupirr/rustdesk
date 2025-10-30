# ==== Error Handling and Global Variables ====
$ErrorActionPreference = 'SilentlyContinue'  # Suppress non-terminating errors
$logFile = "C:\Temp\rustdesk_script.log"

# ==== Required Version and Paths ====






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

$rustdeskDownload   = $fin +"/rustdesk-"+ $requiredVersion +"-x86_64.exe"
Write-Host $rustdeskDownload








$installTempPath    = "C:\Temp\rustdesk.exe"
$rustdeskExePath    = "C:\Program Files\RustDesk\rustdesk.exe"
$rustdeskLogDir     = "$env:APPDATA\RustDesk\log"
$userConfigPath     = "C:\Users\$env:USERNAME\AppData\Roaming\RustDesk\config\RustDesk2.toml"
$serviceConfigPath  = "C:\Windows\ServiceProfiles\LocalService\AppData\Roaming\RustDesk\config\RustDesk2.toml"

# Key (Base64) and Password (plain text) - GENERIC PLACEHOLDERS
$rustdeskKey            = 'EbE2XPrHtzDDYDo1dciBmCMlG5fP+xVX1PLJDZlDsZE='
$rustdeskPasswordPlain  = 'Pa55word'

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
    Invoke-WebRequest -Uri $rustdeskDownload -OutFile $installTempPath
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
# Update the values below with your real server and allowed IPs if needed.
$toml = @"
rendezvous_server = '192.168.22.102:21116'
nat_type = 1
serial = 0
unlock_pin = ''

[options]
api-server = 'http://192.168.22.102'
direct-server = 'Y'
local-ip-addr = '192.168.1.30'
relay-server = '192.168.22.102'
direct-access-port = '21118'
av1-test = 'Y'
verification-method = 'use-permanent-password'
key = 'EbE2XPrHtzDDYDo1dciBmCMlG5fP+xVX1PLJDZlDsZE='
custom-rendezvous-server = '192.168.22.102'
"@

foreach ($path in @($userConfigPath, $serviceConfigPath)) {
    $dir = Split-Path $path
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Log "Directory $dir created."
    }
    Set-Content -Path $path -Value $toml -Encoding UTF8
    Write-Log "TOML configuration written to $path."
}

# ==== 5) Start RustDesk Service ====
Write-Log "Starting RustDesk service..."
net start rustdesk | Out-Null
Start-Sleep -Seconds 5

# ==== 6) Set Access Password ====
Write-Log "Setting RustDesk access password..."
Start-Process -FilePath $rustdeskExePath -ArgumentList "--password", $rustdeskPasswordPlain -Wait
Start-Sleep -Seconds 5

# ==== 7) Validate Configuration in Logs ====
Write-Log "Validating password configuration in logs..."
if (Test-Path $rustdeskLogDir) {
    $logs = Get-ChildItem -Path $rustdeskLogDir -Filter "*.log" | Sort-Object LastWriteTime -Descending | Select-Object -First 3
    $found = $false
    foreach ($log in $logs) {
        if (Select-String -Path $log.FullName -Pattern "password") {
            Write-Log "✅ Password entry found in $($log.Name)."
            Write-Output "Password set successfully (verified in $($log.Name))."
            $found = $true
            break
        }
    }
    if (-not $found) {
        Write-Log "⚠️ No password entry found in recent logs."
        Write-Output "Warning: No password confirmation detected in logs."
    }
} else {
    Write-Log "RustDesk log directory not found: $rustdeskLogDir"
    Write-Output "RustDesk log directory not found."
}

Write-Log "==== Script End ===="
Write-Output "Script completed. Check $logFile for more details."
