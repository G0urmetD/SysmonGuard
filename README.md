# SysmonGuard
```bash
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
  .\SysmonGuard.ps1 -SysmonZipFile sysmon.zip -ConfigFile .\sysmonconfig.xml
  .\SysmonGuard.ps1 -LogPath "C:\Logs"
  .\SysmonGuard.ps1 -CleanTemp
  .\SysmonGuard.ps1 -version
  .\SysmonGuard.ps1 -silent
```

## Usage
Install sysmon with web downloads of sysmon.zip & sysmon-config.xml
```bash
.\SysmonGuard.ps1
```

Install sysmon with local sysmon.zip & sysmon-config.xml
```bash
.\SysmonGuard.ps1 -SysmonZipFile sysmon.zip -ConfigFile .\sysmongconfig.xml
```

Uninstall sysmon
```bash
.\SysmonGuard.ps1 -Uninstall
```

