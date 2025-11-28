#######################################################################################################
# Script:    SysmonGuard.ps1
# Author:    g_ourmet
# Version:   2.1
# Purpose:   Installation, uninstallation and configuration update of Sysmon on Windows 10/11 clients
#######################################################################################################

#Requires -Version 5.1
#Requires -RunAsAdministrator

param (
    [switch]$DebugMode,
    [switch]$CleanTemp,
    [switch]$Uninstall,
    [switch]$UpdateConfig,
    [switch]$CheckStatus,
    [switch]$silent,
    [switch]$force,

    [string]$Proxy = "",
    [string]$ConfigFile = "",
    [string]$ConfigUrl = "",
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
# 6 - Extraction Failed
# 7 - Installation Failed

# Exit codes definition
enum ExitCode {
    Success = 0
    GeneralError = 1
    AlreadyInstalled = 2
    DownloadFailed = 3
    ConfigUpdateFailed = 4
    NotInstalled = 5
    ExtractionFailed = 6
    InstallationFailed = 7
}

$ScriptVersion = "2.1"
$SysmonUrl = "https://download.sysinternals.com/files/Sysmon.zip"
$DefaultConfigUrl = "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/refs/heads/master/sysmonconfig-export.xml"

# Enforce TLS 1.2 for secure downloads
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Detect system architecture (32-bit or 64-bit)
$Is64Bit = [Environment]::Is64BitOperatingSystem
$SysmonExeName = if ($Is64Bit) { "Sysmon64.exe" } else { "Sysmon.exe" }
$SysmonServiceName = if ($Is64Bit) { "Sysmon64" } else { "Sysmon" }

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
        "NotInstalled" = "Sysmon is not installed."
        "NotInstalledUninstall" = "Sysmon is not installed. No uninstallation necessary."
        "DownloadError" = "Failed to download required files."
        "UpdateConfig" = "Updating Sysmon configuration..."
        "UpdateDone" = "Sysmon configuration update complete."
        "TempCleanupDone" = "Temporary files cleaned up."
        "TempCleanupFailed" = "Failed to clean up temporary files."
        "CustomLogPathUsed" = "Using custom log path: {0}"
        "ShowingVersion" = "SysmonGuard version: {0}"
        "Reinstalling" = "Sysmon is already installed. Force flag is set, proceeding with reinstallation."
        "SilentMode" = "Silent mode active. Suppressing output."
        "ExtractionError" = "Failed to extract Sysmon archive."
        "InstallationError" = "Failed to install Sysmon."
        "Finished" = "SysmonGuard finished successfully."
        "StatusInstalled" = "Sysmon is installed."
        "StatusNotInstalled" = "Sysmon is not installed."
        "StatusVersion" = "Sysmon version: {0}"
        "StatusServiceRunning" = "Sysmon service is running."
        "StatusServiceStopped" = "Sysmon service is stopped."
        "StatusPath" = "Sysmon path: {0}"
        "StatusArch" = "System architecture: {0}"
        "HelpText" = @'
 _______  __   __  _______  __   __  _______  __    _  _______  __   __  _______  ______    ______  
|       ||  | |  ||       ||  |_|  ||       ||  |  | ||       ||  | |  ||   _   ||    _ |  |      | 
|  _____||  |_|  ||  _____||       ||   _   ||   |_| ||    ___||  | |  ||  |_|  ||   | ||  |  _    |
| |_____ |       || |_____ |       ||  | |  ||       ||   | __ |  |_|  ||       ||   |_||_ | | |   |
|_____  ||_     _||_____  ||       ||  |_|  ||  _    ||   ||  ||       ||       ||    __  || |_|   |
 _____| |  |   |   _____| || ||_|| ||       || | |   ||   |_| ||       ||   _   ||   |  | ||       |
|_______|  |___|  |_______||_|   |_||_______||_|  |__||_______||_______||__| |__||___|  |_||______| 
                                      
        Install Sysmon Tool (v2.1)

Usage:
  -h / --help           Show help screen.
  -DebugMode            Enable debug mode.
  -Uninstall            Uninstall Sysmon.
  -UpdateConfig         Update Sysmon configuration.
  -CheckStatus          Check Sysmon installation status.
  -Proxy <URL>          Proxy for web requests.
  -ConfigFile <Path>    Local Sysmon config file path.
  -ConfigUrl <URL>      Custom Sysmon config URL.
  -SysmonZipFile <Path> Local Sysmon.zip path.
  -LogPath <Path>       Custom log directory.
  -Language <en|de>     Script language (default: en).
  -CleanTemp            Clean temp directory after install.
  -version              Show version and exit.
  -silent               Supresses all outputs, especially for SCCM installations.
  -force                Sysmon is already installed, proceeding with reinstallation.

Exit Codes:
  0 - Success
  1 - General Error
  2 - Already Installed
  3 - Download Failed
  4 - Config Update Failed
  5 - Not Installed
  6 - Extraction Failed
  7 - Installation Failed

Examples:
  .\SysmonGuard.ps1
  .\SysmonGuard.ps1 -DebugMode
  .\SysmonGuard.ps1 -Uninstall
  .\SysmonGuard.ps1 -UpdateConfig
  .\SysmonGuard.ps1 -CheckStatus
  .\SysmonGuard.ps1 -ConfigFile .\sysmonconfig.xml
  .\SysmonGuard.ps1 -ConfigUrl "https://example.com/config.xml"
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
        "NotInstalled" = "Sysmon ist nicht installiert."
        "NotInstalledUninstall" = "Sysmon ist nicht installiert. Keine Deinstallation notwendig."
        "DownloadError" = "Fehler beim Herunterladen der benötigten Dateien."
        "UpdateConfig" = "Aktualisiere Sysmon-Konfiguration..."
        "UpdateDone" = "Sysmon-Konfigurationsupdate abgeschlossen."
        "TempCleanupDone" = "Temporäre Dateien wurden entfernt."
        "TempCleanupFailed" = "Fehler beim Entfernen der temporären Dateien."
        "CustomLogPathUsed" = "Benutzerdefinierter Log-Pfad wird verwendet: {0}"
        "ShowingVersion" = "SysmonGuard Version: {0}"
        "Reinstalling" = "Sysmon ist bereits installiert. Der Force-Parameter ist gesetzt, starte Neuinstallation."
        "SilentMode" = "Silent-Modus aktiv. Ausgaben werden unterdrückt."
        "ExtractionError" = "Fehler beim Entpacken des Sysmon-Archivs."
        "InstallationError" = "Fehler bei der Sysmon-Installation."
        "Finished" = "SysmonGuard erfolgreich abgeschlossen."
        "StatusInstalled" = "Sysmon ist installiert."
        "StatusNotInstalled" = "Sysmon ist nicht installiert."
        "StatusVersion" = "Sysmon Version: {0}"
        "StatusServiceRunning" = "Sysmon-Dienst läuft."
        "StatusServiceStopped" = "Sysmon-Dienst ist gestoppt."
        "StatusPath" = "Sysmon-Pfad: {0}"
        "StatusArch" = "Systemarchitektur: {0}"
        "HelpText" = @'
 _______  __   __  _______  __   __  _______  __    _  _______  __   __  _______  ______    ______  
|       ||  | |  ||       ||  |_|  ||       ||  |  | ||       ||  | |  ||   _   ||    _ |  |      | 
|  _____||  |_|  ||  _____||       ||   _   ||   |_| ||    ___||  | |  ||  |_|  ||   | ||  |  _    |
| |_____ |       || |_____ |       ||  | |  ||       ||   | __ |  |_|  ||       ||   |_||_ | | |   |
|_____  ||_     _||_____  ||       ||  |_|  ||  _    ||   ||  ||       ||       ||    __  || |_|   |
 _____| |  |   |   _____| || ||_|| ||       || | |   ||   |_| ||       ||   _   ||   |  | ||       |
|_______|  |___|  |_______||_|   |_||_______||_|  |__||_______||_______||__| |__||___|  |_||______|  
                                      
        Sysmon Installations-Tool (v2.1)

Verwendung:
  -h / --help           Zeigt diese Hilfe.
  -DebugMode            Aktiviert Debug-Modus.
  -Uninstall            Deinstalliert Sysmon.
  -UpdateConfig         Aktualisiert Sysmon-Konfiguration.
  -CheckStatus          Prüft den Sysmon-Installationsstatus.
  -Proxy <URL>          Proxy-Server für Webanfragen.
  -ConfigFile <Pfad>    Lokale Konfigurationsdatei verwenden.
  -ConfigUrl <URL>      Benutzerdefinierte Konfigurations-URL.
  -SysmonZipFile <Pfad> Lokale Sysmon.zip-Datei verwenden.
  -LogPath <Pfad>       Benutzerdefinierter Log-Pfad.
  -Language <en|de>     Sprache des Skripts (Standard: en).
  -CleanTemp            Temporäre Dateien nach der Installation löschen.
  -version              Zeigt die Versionsnummer und beendet.
  -silent               Unterdrückt jegliche Ausgaben für SCCM Installationen.
  -force                Sysmon ist bereits installiert, mit Neuinstallation weitermachen.

Exit-Codes:
  0 - Erfolg
  1 - Allgemeiner Fehler
  2 - Bereits installiert
  3 - Download fehlgeschlagen
  4 - Konfigurationsupdate fehlgeschlagen
  5 - Nicht installiert
  6 - Entpacken fehlgeschlagen
  7 - Installation fehlgeschlagen

Beispiele:
  .\SysmonGuard.ps1
  .\SysmonGuard.ps1 -DebugMode
  .\SysmonGuard.ps1 -Uninstall
  .\SysmonGuard.ps1 -UpdateConfig
  .\SysmonGuard.ps1 -CheckStatus
  .\SysmonGuard.ps1 -ConfigFile .\sysmonconfig.xml
  .\SysmonGuard.ps1 -ConfigUrl "https://example.com/config.xml"
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

Write-DebugLog "Parameters - DebugMode: $DebugMode, CleanTemp: $CleanTemp, Uninstall: $Uninstall, UpdateConfig: $UpdateConfig, CheckStatus: $CheckStatus, Silent: $silent, Force: $force, Proxy: $Proxy, ConfigFile: $ConfigFile, ConfigUrl: $ConfigUrl, SysmonZipFile: $SysmonZipFile, LogPath: $LogPath"

# Gets the installed Sysmon executable path dynamically
function Get-SysmonPath {
    # Try to get from running process first
    $process = Get-Process -Name $SysmonServiceName -ErrorAction SilentlyContinue
    if ($process -and $process.Path) {
        return $process.Path
    }
    
    # Try common installation paths
    $possiblePaths = @(
        "$env:SystemRoot\$SysmonExeName",
        "$env:ProgramFiles\Sysmon\$SysmonExeName",
        "${env:ProgramFiles(x86)}\Sysmon\$SysmonExeName"
    )
    
    foreach ($path in $possiblePaths) {
        if (Test-Path -Path $path) {
            return $path
        }
    }
    
    # Fallback to Windows directory
    return "$env:SystemRoot\$SysmonExeName"
}

# Gets Sysmon version from the installed executable
function Get-SysmonVersion {
    $sysmonPath = Get-SysmonPath
    if (Test-Path -Path $sysmonPath) {
        try {
            $versionInfo = (Get-Item $sysmonPath).VersionInfo
            return $versionInfo.FileVersion
        } catch {
            return "Unknown"
        }
    }
    return $null
}

# Deletes temporary files used during installation if they exist
function Clear-TempFiles {
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

# Define temp directory
$UserTempPath = [System.IO.Path]::GetTempPath()
$TempPath = Join-Path -Path $UserTempPath -ChildPath "SysmonInstall"

Write-Log -Message $Text.Start -Level "INFO"

# Check whether Sysmon is installed (check both service names for compatibility)
# Note: Some installations may use 'Sysmon' even on 64-bit systems, or vice versa
$sysmonCheck = Get-CimInstance -ClassName Win32_Service -Filter "Name='Sysmon64' OR Name='Sysmon'" -ErrorAction SilentlyContinue

# Check Status operation
if ($CheckStatus) {
    $arch = if ($Is64Bit) { "64-bit" } else { "32-bit" }
    if (-not $silent) {
        Write-Host ""
        Write-Host "=== Sysmon Status ===" -ForegroundColor Cyan
        Write-Host ($Text.StatusArch -f $arch) -ForegroundColor White
    }
    
    if ($sysmonCheck) {
        $sysmonPath = Get-SysmonPath
        $sysmonVersion = Get-SysmonVersion
        $serviceStatus = $sysmonCheck.State
        
        if (-not $silent) {
            Write-Host $Text.StatusInstalled -ForegroundColor Green
            if ($sysmonVersion) {
                Write-Host ($Text.StatusVersion -f $sysmonVersion) -ForegroundColor White
            }
            Write-Host ($Text.StatusPath -f $sysmonPath) -ForegroundColor White
            if ($serviceStatus -eq "Running") {
                Write-Host $Text.StatusServiceRunning -ForegroundColor Green
            } else {
                Write-Host $Text.StatusServiceStopped -ForegroundColor Yellow
            }
        }
        Write-Log -Message "Status check: Sysmon installed, version $sysmonVersion, service $serviceStatus" -Level "INFO"
        exit [int][ExitCode]::Success
    } else {
        if (-not $silent) {
            Write-Host $Text.StatusNotInstalled -ForegroundColor Yellow
        }
        Write-Log -Message "Status check: Sysmon not installed" -Level "INFO"
        exit [int][ExitCode]::NotInstalled
    }
}

# Configuration update
if ($UpdateConfig) {
    if (-not $sysmonCheck) {
        Write-Log -Message $Text.NotInstalled -Level "ERROR"
        exit [int][ExitCode]::NotInstalled
    }
    Write-Log -Message $Text.UpdateConfig -Level "INFO"
    
    $sysmonPath = Get-SysmonPath
    
    if (-not $ConfigFile) {
        $effectiveConfigUrl = if ($ConfigUrl) { $ConfigUrl } else { $DefaultConfigUrl }
        $ConfigFile = "$env:TEMP\sysmonconfig.xml"
        if (!(Download-File -Url $effectiveConfigUrl -Destination $ConfigFile)) { 
            exit [int][ExitCode]::DownloadFailed 
        }
    }
    
    try {
        $process = Start-Process -FilePath $sysmonPath -ArgumentList "-c `"$ConfigFile`"" -Wait -NoNewWindow -PassThru
        if ($process.ExitCode -ne 0) {
            Write-Log -Message "Config update failed with exit code: $($process.ExitCode)" -Level "ERROR"
            exit [int][ExitCode]::ConfigUpdateFailed
        }
        Write-Log -Message $Text.UpdateDone -Level "INFO"
        exit [int][ExitCode]::Success
    } catch {
        Write-Log -Message "$($Text.UpdateConfig) failed: $($_.Exception.Message)" -Level "ERROR"
        exit [int][ExitCode]::ConfigUpdateFailed
    }
}

# Uninstallation
if ($Uninstall) {
    if ($sysmonCheck) {
        $sysmonPath = Get-SysmonPath
        Write-Log -Message $Text.Uninstalling -Level "INFO"
        try {
            $process = Start-Process -FilePath $sysmonPath -ArgumentList "-u" -Wait -NoNewWindow -PassThru
            if ($process.ExitCode -eq 0) {
                Write-Log -Message $Text.Uninstalled -Level "INFO"
                exit [int][ExitCode]::Success
            } else {
                Write-Log -Message "Uninstall returned exit code: $($process.ExitCode)" -Level "WARN"
                exit [int][ExitCode]::GeneralError
            }
        } catch {
            Write-Log -Message "Uninstall failed: $($_.Exception.Message)" -Level "ERROR"
            exit [int][ExitCode]::GeneralError
        }
    } else {
        Write-Log -Message $Text.NotInstalledUninstall -Level "WARN"
        exit [int][ExitCode]::NotInstalled
    }
}

# Installation
if ($sysmonCheck) {
    if ($force) {
        Write-Log -Message $Text.Reinstalling -Level "WARN"
        $sysmonPath = Get-SysmonPath
        try {
            $process = Start-Process -FilePath $sysmonPath -ArgumentList "-u" -Wait -NoNewWindow -PassThru
            if ($process.ExitCode -eq 0) {
                Write-Log -Message "Existing Sysmon uninstalled successfully." -Level "INFO"
            } else {
                Write-Log -Message "Uninstall during reinstall returned exit code: $($process.ExitCode)" -Level "WARN"
            }
        } catch {
            Write-Log -Message "Failed to uninstall existing Sysmon: $($_.Exception.Message)" -Level "ERROR"
            exit [int][ExitCode]::GeneralError
        }
    } else {
        Write-Log -Message $Text.AlreadyInstalled -Level "WARN"
        exit [int][ExitCode]::AlreadyInstalled
    }
}

# Setup paths for installation
$SysmonZip = "$TempPath\Sysmon.zip"
$SysmonExe = "$TempPath\$SysmonExeName"

# Determine config URL to use
$effectiveConfigUrl = if ($ConfigUrl) { $ConfigUrl } else { $DefaultConfigUrl }

if (-not $ConfigFile) {
    $ConfigFile = "$TempPath\sysmonconfig.xml"
}

if (!(Test-Path -Path $TempPath)) {
    New-Item -ItemType Directory -Path $TempPath -Force | Out-Null
}

if (-not $SysmonZipFile) {
    Write-Log -Message $Text.DownloadingSysmon -Level "INFO"
    if (!(Download-File -Url $SysmonUrl -Destination $SysmonZip)) { 
        exit [int][ExitCode]::DownloadFailed 
    }
} else {
    Write-Log -Message "Using local Sysmon zip: $SysmonZipFile" -Level "INFO"
    Copy-Item -Path $SysmonZipFile -Destination $SysmonZip -Force
}

Write-Log -Message $Text.Extracting -Level "INFO"
try {
    Expand-Archive -Path $SysmonZip -DestinationPath $TempPath -Force
} catch {
    Write-Log -Message "$($Text.ExtractionError): $($_.Exception.Message)" -Level "ERROR"
    exit [int][ExitCode]::ExtractionFailed
}

if (-not (Test-Path -Path $ConfigFile)) {
    Write-Log -Message $Text.DownloadingConfig -Level "INFO"
    if (!(Download-File -Url $effectiveConfigUrl -Destination $ConfigFile)) { 
        exit [int][ExitCode]::DownloadFailed 
    }
}

if (!(Test-Path -Path $SysmonExe)) {
    Write-Log -Message "$($Text.DownloadError) - $SysmonExeName not found in archive" -Level "ERROR"
    exit [int][ExitCode]::DownloadFailed
}

Write-Log -Message $Text.Installing -Level "INFO"
try {
    $process = Start-Process -FilePath $SysmonExe -ArgumentList "-accepteula -i `"$ConfigFile`"" -Wait -NoNewWindow -PassThru
    if ($process.ExitCode -ne 0) {
        Write-Log -Message "$($Text.InstallationError) - Exit code: $($process.ExitCode)" -Level "ERROR"
        exit [int][ExitCode]::InstallationFailed
    }
    Write-Log -Message $Text.Done -Level "INFO"
} catch {
    Write-Log -Message "$($Text.InstallationError): $($_.Exception.Message)" -Level "ERROR"
    exit [int][ExitCode]::InstallationFailed
}

if ($CleanTemp) {
    Clear-TempFiles
}

if (-not $silent) {
    Write-Output $Text.Finished
}

exit [int][ExitCode]::Success
