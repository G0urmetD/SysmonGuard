# SysmonGuard

[![Version](https://img.shields.io/badge/version-2.1-blue.svg)](CHANGELOG.md)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue.svg)](https://docs.microsoft.com/en-us/powershell/)
[![License](https://img.shields.io/badge/license-GPL--3.0-green.svg)](LICENSE)

A PowerShell script for easy installation, uninstallation, and configuration management of [Sysmon](https://docs.microsoft.com/en-us/sysinternals/downloads/sysmon) on Windows 10/11 clients.

```
 _______  __   __  _______  __   __  _______  __    _  _______  __   __  _______  ______    ______  
|       ||  | |  ||       ||  |_|  ||       ||  |  | ||       ||  | |  ||   _   ||    _ |  |      | 
|  _____||  |_|  ||  _____||       ||   _   ||   |_| ||    ___||  | |  ||  |_|  ||   | ||  |  _    |
| |_____ |       || |_____ |       ||  | |  ||       ||   | __ |  |_|  ||       ||   |_||_ | | |   |
|_____  ||_     _||_____  ||       ||  |_|  ||  _    ||   ||  ||       ||       ||    __  || |_|   |
 _____| |  |   |   _____| || ||_|| ||       || | |   ||   |_| ||       ||   _   ||   |  | ||       |
|_______|  |___|  |_______||_|   |_||_______||_|  |__||_______||_______||__| |__||___|  |_||______| 
```

## Requirements

- **Windows 10/11** (32-bit or 64-bit)
- **PowerShell 5.1** or higher
- **Administrator privileges** (required for Sysmon installation)
- **Internet connection** (for downloading Sysmon and config, unless using local files)

## Features

- ✅ Automatic 32-bit/64-bit detection
- ✅ Multi-language support (English, German)
- ✅ Silent mode for SCCM/Intune deployments
- ✅ Custom configuration URL support
- ✅ Proxy support for corporate environments
- ✅ Log rotation (10MB max, 5 backups)
- ✅ Secure TLS 1.2 downloads
- ✅ Status checking with version info

## Parameters

| Parameter | Description |
|-----------|-------------|
| `-h / -Help` | Show help screen |
| `-DebugMode` | Enable debug mode |
| `-Uninstall` | Uninstall Sysmon |
| `-UpdateConfig` | Update Sysmon configuration |
| `-CheckStatus` | Check Sysmon installation status |
| `-Proxy <URL>` | Proxy for web requests |
| `-ConfigFile <Path>` | Local Sysmon config file path |
| `-ConfigUrl <URL>` | Custom Sysmon config URL |
| `-SysmonZipFile <Path>` | Local Sysmon.zip path |
| `-LogPath <Path>` | Custom log directory |
| `-Language <en\|de>` | Script language (default: en) |
| `-CleanTemp` | Clean temp directory after install |
| `-version` | Show version and exit |
| `-silent` | Suppress all outputs (for SCCM) |
| `-force` | Force reinstallation if already installed |

## Exit Codes

| Code | Name | Description |
|------|------|-------------|
| 0 | Success | Operation completed successfully |
| 1 | GeneralError | An unexpected error occurred |
| 2 | AlreadyInstalled | Sysmon is already installed (use -force to reinstall) |
| 3 | DownloadFailed | Failed to download required files |
| 4 | ConfigUpdateFailed | Configuration update failed |
| 5 | NotInstalled | Sysmon is not installed |
| 6 | ExtractionFailed | Failed to extract Sysmon archive |
| 7 | InstallationFailed | Sysmon installation failed |

## Usage Examples

### Install Sysmon (downloads from web)
```powershell
.\SysmonGuard.ps1
```

### Install with local files
```powershell
.\SysmonGuard.ps1 -SysmonZipFile .\sysmon.zip -ConfigFile .\sysmonconfig.xml
```

### Install with custom config URL
```powershell
.\SysmonGuard.ps1 -ConfigUrl "https://mycompany.com/sysmon-config.xml"
```

### Check Sysmon status
```powershell
.\SysmonGuard.ps1 -CheckStatus
```

### Update configuration
```powershell
.\SysmonGuard.ps1 -UpdateConfig
.\SysmonGuard.ps1 -UpdateConfig -ConfigFile .\new-config.xml
.\SysmonGuard.ps1 -UpdateConfig -ConfigUrl "https://mycompany.com/config.xml"
```

### Uninstall Sysmon
```powershell
.\SysmonGuard.ps1 -Uninstall
```

### Silent installation (SCCM/Intune)
```powershell
.\SysmonGuard.ps1 -silent
```

### Force reinstallation
```powershell
.\SysmonGuard.ps1 -force
```

### With proxy
```powershell
.\SysmonGuard.ps1 -Proxy "http://proxy.company.com:8080"
```

## Configuration

By default, SysmonGuard uses the [SwiftOnSecurity Sysmon config](https://github.com/SwiftOnSecurity/sysmon-config). You can specify a custom configuration using:

- `-ConfigFile` for local XML files
- `-ConfigUrl` for remote XML files

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and release notes.

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.