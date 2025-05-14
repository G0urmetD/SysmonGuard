# SysmonGuard
```bash
 _______  __   __  _______  __   __  _______  __    _  _______  __   __  _______  ______    ______  
|       ||  | |  ||       ||  |_|  ||       ||  |  | ||       ||  | |  ||   _   ||    _ |  |      |
|  _____||  |_|  ||  _____||       ||   _   ||   |_| ||    ___||  | |  ||  |_|  ||   | ||  |  _    |
| |_____ |       || |_____ |       ||  | |  ||       ||   | __ |  |_|  ||       ||   |_||_ | | |   |
|_____  ||_     _||_____  ||       ||  |_|  ||  _    ||   ||  ||       ||       ||    __  || |_|   |
 _____| |  |   |   _____| || ||_|| ||       || | |   ||   |_| ||       ||   _   ||   |  | ||       |
|_______|  |___|  |_______||_|   |_||_______||_|  |__||_______||_______||__| |__||___|  |_||______|

        Version 1.7-beta

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

