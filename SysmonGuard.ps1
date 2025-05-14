#######################################################################################################
# Script:    SysmonGuard.ps1
# Author:    g_ourmet
# Version:   1.7-beta
# Purpose:   Installation, uninstallation and configuration update of Sysmon on Windows 10/11 clients
#######################################################################################################

param (
    [switch]$DebugMode,
    [switch]$Uninstall,
    [switch]$UpdateConfig,
    [string]$Proxy = "",
    [string]$ConfigFile = "",
    [string]$SysmonZipFile = "",
    [ValidateSet("en", "de")]
    [string]$Language = "en",
    [Alias("h")][switch]$Help
)

# Language texts
$Text = @{
    "en" = @{
        "Start" = "Sysmon installation script started."
        "AlreadyInstalled" = "Sysmon is already installed. Skipping installation."
        "DownloadingSysmon" = "Downloading Sysmon..."
        "Extracting" = "Extracting Sysmon..."
        "DownloadingConfig" = "Downloading configuration file..."
        "Installing" = "Installing Sysmon with configuration..."
        "Done" = "Sysmon installation complete."
        "Uninstalling" = "Uninstalling Sysmon..."
        "Uninstalled" = "Sysmon has been uninstalled."
        "NotInstalled" = "Sysmon is not installed. No uninstallation necessary."
        "DownloadError" = "Failed to download required files."
        "UpdateConfig" = "Updating Sysmon configuration..."
        "UpdateDone" = "Sysmon configuration update complete."
        "HelpText" = @'
 _______  __   __  _______  __   __  _______  __    _  _______  __   __  _______  ______    ______  
|       ||  | |  ||       ||  |_|  ||       ||  |  | ||       ||  | |  ||   _   ||    _ |  |      | 
|  _____||  |_|  ||  _____||       ||   _   ||   |_| ||    ___||  | |  ||  |_|  ||   | ||  |  _    |
| |_____ |       || |_____ |       ||  | |  ||       ||   | __ |  |_|  ||       ||   |_||_ | | |   |
|_____  ||_     _||_____  ||       ||  |_|  ||  _    ||   ||  ||       ||       ||    __  || |_|   |
 _____| |  |   |   _____| || ||_|| ||       || | |   ||   |_| ||       ||   _   ||   |  | ||       |
|_______|  |___|  |_______||_|   |_||_______||_|  |__||_______||_______||__| |__||___|  |_||______| 
                                      
        Install Sysmon Tool

Usage:
  -h / --help          Call help function.
  -DebugMode           Call debug mode.
  -Uninstall           Uninstall Sysmon.
  -UpdateConfig        Update Sysmon configuration.
  -Proxy <URL>         Specify proxy server for web requests.
  -ConfigFile <Path>   Use local configuration file instead of downloading.
  -SysmonZipFile       Use local sysmon.zip directory instead of downloading.
  -Language <en|de>    Choose script language (default: en).

Examples:
  .\SysmonGuard.ps1
  .\SysmonGuard.ps1 -DebugMode
  .\SysmonGuard.ps1 -Uninstall
  .\SysmonGuard.ps1 -UpdateConfig
  .\SysmonGuard.ps1 -ConfigFile .\sysmonconfig.xml
  .\SysmonGuard.ps1 -SysmonZipFile sysmon.zip
  .\SysmonGuard.ps1 -SysmonZipFile sysmon.zip -ConfigFile .\sysmonconfig.xml
  .\SysmonGuard.ps1 -Proxy http://proxy.local:8080
  .\SysmonGuard.ps1 -Language de
'@
    }
    "de" = @{
        "Start" = "Sysmon Installationsskript gestartet."
        "AlreadyInstalled" = "Sysmon ist bereits installiert. Überspringe Installation."
        "DownloadingSysmon" = "Lade Sysmon herunter..."
        "Extracting" = "Entpacke Sysmon..."
        "DownloadingConfig" = "Lade Konfigurationsdatei herunter..."
        "Installing" = "Installiere Sysmon mit Konfiguration..."
        "Done" = "Sysmon Installation abgeschlossen."
        "Uninstalling" = "Deinstalliere Sysmon..."
        "Uninstalled" = "Sysmon wurde deinstalliert."
        "NotInstalled" = "Sysmon ist nicht installiert. Keine Deinstallation notwendig."
        "DownloadError" = "Fehler beim Herunterladen der benötigten Dateien."
        "UpdateConfig" = "Aktualisiere Sysmon-Konfiguration..."
        "UpdateDone" = "Sysmon-Konfigurationsupdate abgeschlossen."
        "HelpText" = @'
 _______  __   __  _______  __   __  _______  __    _  _______  __   __  _______  ______    ______  
|       ||  | |  ||       ||  |_|  ||       ||  |  | ||       ||  | |  ||   _   ||    _ |  |      | 
|  _____||  |_|  ||  _____||       ||   _   ||   |_| ||    ___||  | |  ||  |_|  ||   | ||  |  _    |
| |_____ |       || |_____ |       ||  | |  ||       ||   | __ |  |_|  ||       ||   |_||_ | | |   |
|_____  ||_     _||_____  ||       ||  |_|  ||  _    ||   ||  ||       ||       ||    __  || |_|   |
 _____| |  |   |   _____| || ||_|| ||       || | |   ||   |_| ||       ||   _   ||   |  | ||       |
|_______|  |___|  |_______||_|   |_||_______||_|  |__||_______||_______||__| |__||___|  |_||______|  
                                      
        Install Sysmon Tool

Verwendung:
  -h / --help          Zeigt diese Hilfe.
  -DebugMode           Aktiviert Debug-Modus.
  -Uninstall           Deinstalliert Sysmon.
  -UpdateConfig        Aktualisiert Sysmon-Konfiguration.
  -Proxy <URL>         Proxy-Server für Webanfragen angeben.
  -ConfigFile <Pfad>   Lokale Konfigurationsdatei angeben.
  -SysmonZipFile       Lokales sysmon.zip Verzeichnis.
  -Language <en|de>    Sprache des Skripts wählen (Standard: en).

Beispiele:
  .\SysmonGuard.ps1
  .\SysmonGuard.ps1 -DebugMode
  .\SysmonGuard.ps1 -Uninstall
  .\SysmonGuard.ps1 -UpdateConfig
  .\SysmonGuard.ps1 -ConfigFile .\sysmonconfig.xml
  .\SysmonGuard.ps1 -SysmonZipFile sysmon.zip
  .\SysmonGuard.ps1 -SysmonZipFile sysmon.zip -ConfigFile .\sysmonconfig.xml
  .\SysmonGuard.ps1 -Proxy http://proxy.local:8080
  .\SysmonGuard.ps1 -Language de
'@
    }
}[$Language]

if ($Help) {
    Write-Host $Text.HelpText -ForegroundColor Cyan
    exit 0
}

# ASCII Banner
$banner = @'
 _______  __   __  _______  __   __  _______  __    _  _______  __   __  _______  ______    ______  
|       ||  | |  ||       ||  |_|  ||       ||  |  | ||       ||  | |  ||   _   ||    _ |  |      | 
|  _____||  |_|  ||  _____||       ||   _   ||   |_| ||    ___||  | |  ||  |_|  ||   | ||  |  _    |
| |_____ |       || |_____ |       ||  | |  ||       ||   | __ |  |_|  ||       ||   |_||_ | | |   |
|_____  ||_     _||_____  ||       ||  |_|  ||  _    ||   ||  ||       ||       ||    __  || |_|   |
 _____| |  |   |   _____| || ||_|| ||       || | |   ||   |_| ||       ||   _   ||   |  | ||       |
|_______|  |___|  |_______||_|   |_||_______||_|  |__||_______||_______||__| |__||___|  |_||______|  
                                      
        Install Sysmon Tool
'@
Write-Host $banner -ForegroundColor Cyan

# Logging Setup
$ScriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition
$LogFolder = Join-Path -Path $ScriptDirectory -ChildPath "Log"
$ScriptName = "Install-Sysmon"
$LogFile = Join-Path -Path $LogFolder -ChildPath "$ScriptName.log"

function Write-Log {
    param (
        [string]$Message,
        [ValidateSet("INFO", "WARN", "ERROR")]
        [string]$Level = "INFO"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $formattedMessage = "[$timestamp] [$Level] $Message"

    switch ($Level) {
        "INFO"  { Write-Host "[INFO]  $Message" -ForegroundColor Green }
        "WARN"  { Write-Host "[WARN]  $Message" -ForegroundColor Yellow }
        "ERROR" { Write-Host "[ERROR] $Message" -ForegroundColor Red }
    }

    if (!(Test-Path -Path $LogFolder)) {
        New-Item -ItemType Directory -Path $LogFolder -Force | Out-Null
    }
    Add-Content -Path $LogFile -Value $formattedMessage
}

function Write-DebugLog {
    param ([string]$Message)
    if ($DebugMode) {
        Write-Host "[DEBUG] $Message" -ForegroundColor DarkGray
        Write-Log -Message $Message -Level "INFO"
    }
}

function Download-File {
    param (
        [string]$Url,
        [string]$Destination
    )
    try {
        Write-DebugLog "Attempting download from URL: $Url to destination: $Destination"
        if ($Proxy) {
            Write-DebugLog "Using proxy: $Proxy"
            Invoke-WebRequest -Uri $Url -OutFile $Destination -Proxy $Proxy -UseBasicParsing
        } else {
            Invoke-WebRequest -Uri $Url -OutFile $Destination -UseBasicParsing
        }
        Write-DebugLog "Download succeeded: $Destination"
        return $true
    } catch {
        Write-DebugLog "Exception Message: $($_.Exception.Message)"
        Write-DebugLog "Exception Type: $($_.Exception.GetType().FullName)"
        Write-DebugLog "Stack Trace: $($_.ScriptStackTrace)"
        Write-Log -Message "$($Text.DownloadError) - Exception: $($_.Exception.Message)" -Level "ERROR"
        return $false
    }
}

# Define temp directory more robustly
$UserTempPath = [System.IO.Path]::GetTempPath()
$TempPath = Join-Path -Path $UserTempPath -ChildPath "SysmonInstall"

Write-Log -Message $Text.Start -Level "INFO"

# Check whether Sysmon is installed
$sysmonCheck = Get-CimInstance -ClassName Win32_Service -Filter "Name='Sysmon64'" -ErrorAction SilentlyContinue

# Configuration update
if ($UpdateConfig) {
    if (-not $sysmonCheck) {
        Write-Log -Message $Text.NotInstalled -Level "ERROR"
        exit 1
    }
    Write-Log -Message $Text.UpdateConfig -Level "INFO"
    if (-not $ConfigFile) {
        $ConfigUrl = "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/refs/heads/master/sysmonconfig-export.xml"
        $ConfigFile = "$env:TEMP\sysmonconfig.xml"
        if (!(Download-File -Url $ConfigUrl -Destination $ConfigFile)) { exit 1 }
    }
    Start-Process -FilePath "C:\\Windows\\Sysmon64.exe" -ArgumentList "-c `"$ConfigFile`"" -Wait -NoNewWindow
    Write-Log -Message $Text.UpdateDone -Level "INFO"
    exit 0
}

# Uninstallation
if ($Uninstall) {
    if ($sysmonCheck) {
        $SysmonExePath = (Get-Process -Name Sysmon64 -ErrorAction SilentlyContinue).Path
        if (!$SysmonExePath) {
            $SysmonExePath = "C:\\Windows\\Sysmon64.exe"
        }
        Write-Log -Message $Text.Uninstalling -Level "INFO"
        Start-Process -FilePath $SysmonExePath -ArgumentList "-u" -Wait -NoNewWindow
        Write-Log -Message $Text.Uninstalled -Level "INFO"
    } else {
        Write-Log -Message $Text.NotInstalled -Level "WARN"
    }
    exit 0
}

# Installation
if ($sysmonCheck) {
    Write-Log -Message $Text.AlreadyInstalled -Level "WARN"
    exit 0
}

$SysmonUrl = "https://download.sysinternals.com/files/Sysmon.zip"
$TempPath = "$env:TEMP\SysmonInstall"
$SysmonZip = "$TempPath\Sysmon.zip"
$SysmonExe = "$TempPath\Sysmon64.exe"
if (-not $ConfigFile) {
    $ConfigFile = "$TempPath\sysmonconfig.xml"
    $ConfigUrl = "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/refs/heads/master/sysmonconfig-export.xml"
}

if (!(Test-Path -Path $TempPath)) {
    New-Item -ItemType Directory -Path $TempPath -Force | Out-Null
}

$SysmonZip = "$TempPath\Sysmon.zip"
$SysmonExe = "$TempPath\Sysmon64.exe"
if (-not $ConfigFile) {
    $ConfigFile = "$TempPath\sysmonconfig.xml"
    $ConfigUrl = "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/refs/heads/master/sysmonconfig-export.xml"
}

if (-not $SysmonZipFile) {
    Write-Log -Message $Text.DownloadingSysmon -Level "INFO"
    if (!(Download-File -Url "https://download.sysinternals.com/files/Sysmon.zip" -Destination $SysmonZip)) { exit 1 }
} else {
    Write-Log -Message "Using local Sysmon zip: $SysmonZipFile" -Level "INFO"
    Copy-Item -Path $SysmonZipFile -Destination $SysmonZip -Force
}

Write-Log -Message $Text.Extracting -Level "INFO"
Expand-Archive -Path $SysmonZip -DestinationPath $TempPath -Force

if (-not (Test-Path -Path $ConfigFile)) {
    Write-Log -Message $Text.DownloadingConfig -Level "INFO"
    if (!(Download-File -Url $ConfigUrl -Destination $ConfigFile)) { exit 1 }
}

if (!(Test-Path -Path $SysmonExe)) {
    Write-Log -Message $Text.DownloadError -Level "ERROR"
    exit 1
}

Write-Log -Message $Text.Installing -Level "INFO"
Start-Process -FilePath $SysmonExe -ArgumentList "-accepteula -i `"$ConfigFile`"" -Wait -NoNewWindow
Write-Log -Message $Text.Done -Level "INFO"
exit 0
