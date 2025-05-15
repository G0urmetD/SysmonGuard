#######################################################################################################
# Script:    SysmonGuard.ps1
# Author:    g_ourmet
# Version:   2.0
# Purpose:   Installation, uninstallation and configuration update of Sysmon on Windows 10/11 clients
#######################################################################################################

param (
    [switch]$DebugMode,
    [switch]$CleanTemp,
    [switch]$Uninstall,
    [switch]$UpdateConfig,
    [switch]$silent,
    [switch]$force,

    [string]$Proxy = "",
    [string]$ConfigFile = "",
    [string]$SysmonZipFile = "",
    [string]$LogPath = "",
    [ValidateSet("en", "de")]
    [string]$Language = "en",
    
    [Alias("h")][switch]$Help,

    [switch]$version
)

# Exit codes:
# 0 - Success
# 1 - General Error
# 2 - Already Installed
# 3 - Download Failed
# 4 - Config Update Failed
# 5 - Not Installed

# Exit codes definition
enum ExitCode {
    Success = 0
    GeneralError = 1
    AlreadyInstalled = 2
    DownloadFailed = 3
    ConfigUpdateFailed = 4
    NotInstalled = 5
}

$ScriptVersion = "2.0"
$SysmonUrl = "https://download.sysinternals.com/files/Sysmon.zip"
$DefaultConfigUrl = "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/refs/heads/master/sysmonconfig-export.xml"

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
        "TempCleanupDone" = "Temporary files cleaned up."
        "TempCleanupFailed" = "Failed to clean up temporary files."
        "CustomLogPathUsed" = "Using custom log path: {0}"
        "ShowingVersion" = "SysmonGuard version: {0}"
        "Reinstalling"       = "Sysmon is already installed. Force flag is set, proceeding with reinstallation."
        "SilentMode"         = "Silent mode active. Suppressing output."
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
  -h / --help           Show help screen.
  -DebugMode            Enable debug mode.
  -Uninstall            Uninstall Sysmon.
  -UpdateConfig         Update Sysmon configuration.
  -Proxy <URL>          Proxy for web requests.
  -ConfigFile <Path>    Local Sysmon config file path.
  -SysmonZipFile <Path> Local Sysmon.zip path.
  -LogPath <Path>       Custom log directory.
  -Language <en|de>     Script language (default: en).
  -CleanTemp            Clean temp directory after install.
  -version              Show version and exit.
  -silent               Supresses all outputs, especially for SCCM installations.

Examples:
  .\SysmonGuard.ps1
  .\SysmonGuard.ps1 -DebugMode
  .\SysmonGuard.ps1 -Uninstall
  .\SysmonGuard.ps1 -UpdateConfig
  .\SysmonGuard.ps1 -ConfigFile .\sysmonconfig.xml
  .\SysmonGuard.ps1 -SysmonZipFile sysmon.zip
  .\SysmonGuard.ps1 -LogPath "C:\Logs"
  .\SysmonGuard.ps1 -CleanTemp
  .\SysmonGuard.ps1 -version
  .\SysmonGuard.ps1 -silent
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
        "TempCleanupDone" = "Temporäre Dateien wurden entfernt."
        "TempCleanupFailed" = "Fehler beim Entfernen der temporären Dateien."
        "CustomLogPathUsed" = "Benutzerdefinierter Log-Pfad wird verwendet: {0}"
        "ShowingVersion" = "SysmonGuard Version: {0}"
        "Reinstalling"       = "Sysmon ist bereits installiert. Der Force-Parameter ist gesetzt, starte Neuinstallation."
        "SilentMode"         = "Silent-Modus aktiv. Ausgaben werden unterdrückt."
        "HelpText" = @'
 _______  __   __  _______  __   __  _______  __    _  _______  __   __  _______  ______    ______  
|       ||  | |  ||       ||  |_|  ||       ||  |  | ||       ||  | |  ||   _   ||    _ |  |      | 
|  _____||  |_|  ||  _____||       ||   _   ||   |_| ||    ___||  | |  ||  |_|  ||   | ||  |  _    |
| |_____ |       || |_____ |       ||  | |  ||       ||   | __ |  |_|  ||       ||   |_||_ | | |   |
|_____  ||_     _||_____  ||       ||  |_|  ||  _    ||   ||  ||       ||       ||    __  || |_|   |
 _____| |  |   |   _____| || ||_|| ||       || | |   ||   |_| ||       ||   _   ||   |  | ||       |
|_______|  |___|  |_______||_|   |_||_______||_|  |__||_______||_______||__| |__||___|  |_||______|  
                                      
        Sysmon Installations-Tool

Verwendung:
  -h / --help           Zeigt diese Hilfe.
  -DebugMode            Aktiviert Debug-Modus.
  -Uninstall            Deinstalliert Sysmon.
  -UpdateConfig         Aktualisiert Sysmon-Konfiguration.
  -Proxy <URL>          Proxy-Server für Webanfragen.
  -ConfigFile <Pfad>    Lokale Konfigurationsdatei verwenden.
  -SysmonZipFile <Pfad> Lokale Sysmon.zip-Datei verwenden.
  -LogPath <Pfad>       Benutzerdefinierter Log-Pfad.
  -Language <en|de>     Sprache des Skripts (Standard: en).
  -CleanTemp            Temporäre Dateien nach der Installation löschen.
  -version              Zeigt die Versionsnummer und beendet.
  -silent               Unterdrückt jegliche Ausgaben für SCCM Installationen.

Beispiele:
  .\SysmonGuard.ps1
  .\SysmonGuard.ps1 -DebugMode
  .\SysmonGuard.ps1 -Uninstall
  .\SysmonGuard.ps1 -UpdateConfig
  .\SysmonGuard.ps1 -ConfigFile .\sysmonconfig.xml
  .\SysmonGuard.ps1 -SysmonZipFile sysmon.zip
  .\SysmonGuard.ps1 -LogPath "C:\Logs"
  .\SysmonGuard.ps1 -CleanTemp
  .\SysmonGuard.ps1 -version
  .\SysmonGuard.ps1 -silent
'@
}}[$Language]

# Validate user-provided paths
if ($ConfigFile -and -not (Test-Path -Path $ConfigFile)) {
    Write-Host "[ERROR] Provided configuration file not found: $ConfigFile" -ForegroundColor Red
    exit [int][ExitCode]::GeneralError
}

if ($SysmonZipFile -and -not (Test-Path -Path $SysmonZipFile)) {
    Write-Host "[ERROR] Provided Sysmon ZIP file not found: $SysmonZipFile" -ForegroundColor Red
    exit [int][ExitCode]::GeneralError
}

if ($Help) {
    if (-not $silent) {
        Write-Host $Text.HelpText -ForegroundColor Cyan
    }
    exit [int][ExitCode]::Success
}

if ($Version) {
    if (-not $silent) {
        Write-Host "SysmonGuard version: $ScriptVersion" -ForegroundColor Cyan
    }
    exit [int][ExitCode]::Success
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

if (-not $silent) {
    Write-Host $banner -ForegroundColor Cyan
    Write-Host ("Version: " + $ScriptVersion) -ForegroundColor Cyan
}

# Logging Setup
if ($LogPath) {
    $LogFolder = $LogPath
} else {
    $ScriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Definition
    $LogFolder = Join-Path -Path $ScriptDirectory -ChildPath "Log"
}

$ScriptName = "Install-Sysmon"
$LogFile = Join-Path -Path $LogFolder -ChildPath "$ScriptName.log"

# Rotates the log file if it exceeds 10MB by renaming it and preserving up to 5 old versions
function Rotate-LogFile {
    $maxSizeMB = 10
    $maxFiles = 5
    if (Test-Path $LogFile) {
        $fileInfo = Get-Item $LogFile
        if ($fileInfo.Length -gt ($maxSizeMB * 1MB)) {
            for ($i = $maxFiles - 1; $i -ge 1; $i--) {
                $older = "$LogFile.$i"
                $newer = "$LogFile." + ($i + 1)
                if (Test-Path $older) {
                    Rename-Item -Path $older -NewName $newer -Force
                }
            }
            Rename-Item -Path $LogFile -NewName "$LogFile.1" -Force
        }
    }
}

# Logs messages to file and optionally to console with color-coded severity (INFO, WARN, ERROR)
function Write-Log {
    param (
        [string]$Message,
        [ValidateSet("INFO", "WARN", "ERROR")]
        [string]$Level = "INFO"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $formattedMessage = "[$timestamp] [$Level] $Message"

    if (!(Test-Path -Path $LogFolder)) {
        New-Item -ItemType Directory -Path $LogFolder -Force | Out-Null
    }

    Rotate-LogFile
    Add-Content -Path $LogFile -Value $formattedMessage

    if (-not $silent) {
        switch ($Level) {
            "INFO"  { Write-Host "[INFO]  $Message" -ForegroundColor Green }
            "WARN"  { Write-Host "[WARN]  $Message" -ForegroundColor Yellow }
            "ERROR" { Write-Host "[ERROR] $Message" -ForegroundColor Red }
        }
    }
}

# Outputs debug messages to the console when DebugMode is enabled and logs them as INFO
function Write-DebugLog {
    param ([string]$Message)
    if ($DebugMode -and -not $silent) {
        Write-Host "[DEBUG] $Message" -ForegroundColor DarkGray
    }
    Write-Log -Message $Message -Level "INFO"
}

Write-DebugLog "Parameters - DebugMode: $DebugMode, CleanTemp: $CleanTemp, Uninstall: $Uninstall, UpdateConfig: $UpdateConfig, Silent: $silent, Force: $force, Proxy: $Proxy, ConfigFile: $ConfigFile, SysmonZipFile: $SysmonZipFile, LogPath: $LogPath"

# Deletes temporary files used during installation if they exist
function Cleanup-TempFiles {
    if (Test-Path -Path $TempPath) {
        try {
            Remove-Item -Path $TempPath -Recurse -Force -ErrorAction Stop
            Write-Log -Message "Temporary files at ${TempPath} removed." -Level "INFO"
        } catch {
            Write-Log -Message "Failed to remove temporary files at ${TempPath}: $($_.Exception.Message)" -Level "WARN"
        }
    }
}

# Downloads a file from a specified URL to a destination path, supports proxy configuration and logs the result
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
$sysmonCheck = Get-CimInstance -ClassName Win32_Service -Filter "Name='Sysmon64' OR Name='Sysmon'" -ErrorAction SilentlyContinue

# Configuration update
if ($UpdateConfig) {
    if (-not $sysmonCheck) {
        Write-Log -Message $Text.NotInstalled -Level "ERROR"
        exit [int][ExitCode]::GeneralError
    }
    Write-Log -Message $Text.UpdateConfig -Level "INFO"
    if (-not $ConfigFile) {
        $ConfigUrl = $DefaultConfigUrl
        $ConfigFile = "$env:TEMP\sysmonconfig.xml"
        if (!(Download-File -Url $ConfigUrl -Destination $ConfigFile)) { exit [int][ExitCode]::DownloadFailed }
    }
    Start-Process -FilePath "C:\\Windows\\Sysmon64.exe" -ArgumentList "-c `"$ConfigFile`"" -Wait -NoNewWindow
    Write-Log -Message $Text.UpdateDone -Level "INFO"
    exit [int][ExitCode]::Success
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
    exit [int][ExitCode]::Success
}

# Installation
if ($sysmonCheck) {
    if ($force) {
        Write-Log -Message "Sysmon is already installed. Force flag is set, proceeding with reinstallation." -Level "WARN"
        $SysmonExePath = (Get-Process -Name Sysmon64 -ErrorAction SilentlyContinue).Path
        if (!$SysmonExePath) {
            $SysmonExePath = "C:\\Windows\\Sysmon64.exe"
        }
        Start-Process -FilePath $SysmonExePath -ArgumentList "-u" -Wait -NoNewWindow
        Write-Log -Message "Existing Sysmon uninstalled successfully." -Level "INFO"
    } else {
        Write-Log -Message $Text.AlreadyInstalled -Level "WARN"
        exit [int][ExitCode]::AlreadyInstalled
    }
}

$TempPath = "$env:TEMP\SysmonInstall"
$SysmonZip = "$TempPath\Sysmon.zip"
$SysmonExe = "$TempPath\Sysmon64.exe"
if (-not $ConfigFile) {
    $ConfigFile = "$TempPath\sysmonconfig.xml"
    $ConfigUrl = $DefaultConfigUrl
}

if (!(Test-Path -Path $TempPath)) {
    New-Item -ItemType Directory -Path $TempPath -Force | Out-Null
}

if (-not $SysmonZipFile) {
    Write-Log -Message $Text.DownloadingSysmon -Level "INFO"
    if (!(Download-File -Url $SysmonUrl -Destination $SysmonZip)) { exit [int][ExitCode]::DownloadFailed }
} else {
    Write-Log -Message "Using local Sysmon zip: $SysmonZipFile" -Level "INFO"
    Copy-Item -Path $SysmonZipFile -Destination $SysmonZip -Force
}

Write-Log -Message $Text.Extracting -Level "INFO"
Expand-Archive -Path $SysmonZip -DestinationPath $TempPath -Force

if (-not (Test-Path -Path $ConfigFile)) {
    Write-Log -Message $Text.DownloadingConfig -Level "INFO"
    if (!(Download-File -Url $ConfigUrl -Destination $ConfigFile)) { exit [int][ExitCode]::DownloadFailed }
}

if (!(Test-Path -Path $SysmonExe)) {
    Write-Log -Message $Text.DownloadError -Level "ERROR"
    exit [int][ExitCode]::DownloadFailed
}

Write-Log -Message $Text.Installing -Level "INFO"
Start-Process -FilePath $SysmonExe -ArgumentList "-accepteula -i `"$ConfigFile`"" -Wait -NoNewWindow
Write-Log -Message $Text.Done -Level "INFO"

if ($CleanTemp) {
    Cleanup-TempFiles
}

if (-not $silent) {
    Write-Output "SysmonGuard finished with ExitCode: $LASTEXITCODE"
}

exit [int][ExitCode]::Success
