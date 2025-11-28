# Changelog

All notable changes to SysmonGuard will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1] - 2025-11-28

### Added
- **`-CheckStatus`** parameter to check Sysmon installation status, version, and service state
- **`-ConfigUrl`** parameter for custom configuration file URLs
- **32-bit/64-bit auto-detection** - Script now automatically detects system architecture and uses appropriate Sysmon executable
- **TLS 1.2 enforcement** for secure downloads
- **`#Requires` directives** for PowerShell 5.1 and Administrator privileges
- New exit codes: `ExtractionFailed (6)` and `InstallationFailed (7)`
- Dynamic Sysmon path detection via `Get-SysmonPath` function
- Sysmon version detection via `Get-SysmonVersion` function
- Exit codes documentation in help text (EN/DE)

### Changed
- Version bumped to 2.1
- Renamed `Cleanup-TempFiles` to `Clear-TempFiles` (PowerShell naming convention)
- Improved error handling with try-catch blocks for critical operations
- Fixed duplicate `$TempPath` variable definition
- Uninstall now returns `NotInstalled (5)` exit code when Sysmon is not installed
- UpdateConfig now returns `NotInstalled (5)` exit code when Sysmon is not installed
- Removed hardcoded `C:\Windows\Sysmon64.exe` paths - now uses dynamic detection
- Improved German and English help text with version info and new parameters

### Fixed
- Incorrect exit code on uninstall when Sysmon not installed (was Success, now NotInstalled)
- Hardcoded 64-bit paths that would fail on 32-bit systems
- Missing error handling for `Expand-Archive` operation
- Missing error handling for `Start-Process` operations

## [2.0] - Previous Release

### Features
- Initial public release
- Installation, uninstallation, and configuration update of Sysmon
- Multi-language support (English, German)
- Proxy support for web requests
- Silent mode for SCCM deployments
- Force reinstallation option
- Log rotation
- Custom log path support
