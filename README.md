# PowerShell Profile Collection

[![CI](https://github.com/eames1127/PowerShellProfile/actions/workflows/ci.yml/badge.svg)](https://github.com/eames1127/PowerShellProfile/actions/workflows/ci.yml)
[![Licence: MIT](https://img.shields.io/badge/Licence-MIT-blue.svg)](LICENSE)

🚀 **Community PowerShell profile** with productivity functions and terminal configuration for Windows developers and system administrators.

## 📥 Quick Start

**One-line install** (backs up your existing profile first):

```powershell
irm https://raw.githubusercontent.com/eames1127/PowerShellProfile/master/install.ps1 | iex
```

Or from a clone, also installing posh-git, oh-my-posh and the Meslo font:

```powershell
git clone https://github.com/eames1127/PowerShellProfile.git
cd PowerShellProfile
.\install.ps1 -InstallTerminal
```

Then edit `profile.config.psd1` (next to your `$PROFILE`) and open a new terminal.

## 📁 What's Included

- **Microsoft.PowerShell_profile.ps1** - Main profile that loads oh-my-posh theme and imports all functions
- **profile.config.example.psd1** - Template for your personal settings
- **install.ps1** - Installer with automatic backup
- **Functions/TimeSavers.ps1** - Development workflow shortcuts (GitHub, coding directories, git operations)
- **Functions/Config.ps1** - Terminal setup and configuration utilities  
- **Functions/FileUtils.ps1** - File system operations and utilities
- **Functions/SystemUtils.ps1** - System administration and monitoring tools
- **Functions/NetworkUtils.ps1** - Network diagnostics and connectivity tools

## ✨ Key Features

- 🔄 Automated function loading from Functions directory
- 🎨 Oh-my-posh integration with custom theme
- 📂 Quick navigation to coding projects and repositories
- 💾 PowerShell profile backup/sync functions
- 🔀 Git branch comparison tools
- 📦 File compression and archiving utilities
- 📊 Event log monitoring and reporting
- 🛠️ Windows service management tools
- 🌐 Network speed testing and IP information
- 🔍 Port usage checking and network diagnostics
- 📡 WiFi network management and connectivity tools

## 🔧 Requirements

- Windows PowerShell 5.1+ or PowerShell 7+
- Administrator privileges (for some system functions)
- Optional: [Oh My Posh](https://ohmyposh.dev/) for enhanced terminal theming

## 📚 Function Reference

### TimeSavers Functions
- `goToGitHubRepo [$username] $repo` - Open a repo on GitHub (username defaults to `GitHubUser` in config)
- `goToCoding()` - Navigate to coding directory and open VS Code
- `goToRepo($repo)` - Navigate to specific repository and show git status
- `initRepo($url)` - Clone repository to coding directory
- `psProfile()` - Open PowerShell profile directory in VS Code
- `copyPSProfileToCode()` - Backup profile to code repository
- `Update-Profile` (alias `copyPSProfileFromCode`) - Restore profile from code repository, keeping your config
- `getChangesInBranch -gitLoc $path -branchName $branch [-filter "*Jira*"] [-update]` - Compare branch merges

### FileUtils Functions
- `compressAndCopy -fileName $name -loc $source -dest $destination` - Create dated archive
- `validateFiles -path $directory -fileList @("file1", "file2")` - Verify required files exist
- `copyByExtension -copyFrom $source -copyTo $dest -extFilter @("*.ps1")` - Copy files by extension

### SystemUtils Functions
- `checkEventLogs -servers @("server1") -days 10` - Check event logs and export to PDF
- `manageServices -serviceID 1 -machine "server"` - Restart services locally or remotely

### NetworkUtils Functions
- `speedTest` - Test network download speed
- `myIP` - Display private IP, public IP, and gateway
- `wifiList` - List WiFi networks or connect to network
- `checkPort $port` - Show what process is using a port
- `netDiag $target` - Complete network diagnostics (ping, DNS, traceroute)
- `netAdapters` - Show active network adapter information
- `pingTest $target` - Quick boolean ping test

### Config Functions
- `installTerminalconfig` - Install and configure oh-my-posh with required modules

## 🛠️ Troubleshooting

### Common Issues

**Profile not loading functions:**
- Ensure Functions folder is in the same directory as your profile
- Check execution policy: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
- Verify file paths in error messages

**Oh-my-posh not working:**
- Install: `winget install JanDeDobbeleer.OhMyPosh`
- Install font: `oh-my-posh font install meslo`
- Set terminal font to "MesloLGM NF"

**Git functions failing:**
- Install posh-git: `Install-Module posh-git`
- Ensure Git is installed and in PATH

**Network functions not working:**
- Run PowerShell as Administrator for some network commands
- Check Windows Firewall settings
- Verify network connectivity

**Slow profile loading:**
- Use `Update-Profile` function to get latest optimisations
- Remove unused functions from Functions directory

## ⚙️ Customisation Guide

### Personal Configuration

1. **Edit `profile.config.psd1`** (created next to `$PROFILE` by the installer). It's never overwritten by `Update-Profile` or re-running the installer:
   ```powershell
   @{
       CodingPath   = 'D:\Dev'          # where your repos live
       GitHubUser   = 'your-username'   # used by goToGitHubRepo
       Theme        = 'jandedobbeleer'  # any oh-my-posh theme name
       ClearOnStart = $false
       ShowLoadTime = $true
   }
   ```

2. **Add custom aliases in profile:**
   ```powershell
   Set-Alias -Name "myalias" -Value "My-Function"
   ```

3. **Customise oh-my-posh theme:**
   - Browse themes: `Get-PoshThemes`
   - Set `Theme` in `profile.config.psd1`

4. **Add personal functions:**
   - Create new .ps1 files in Functions directory
   - Functions are automatically loaded on profile startup

### Environment Variables
```powershell
# Add to profile for persistent environment variables
$env:MY_VARIABLE = "value"
```

## 🚀 Performance Tips

### Best Practices

- **Profile Loading:** Keep functions modular in separate files for faster loading
- **Error Handling:** Use `-ErrorAction SilentlyContinue` for non-critical operations
- **Aliases:** Create short aliases for frequently used commands
- **Module Loading:** Only import modules you actually use
- **Function Scope:** Use local variables in functions to avoid conflicts

## 🤝 Contributing

Ideas and PRs welcome - see [CONTRIBUTING.md](CONTRIBUTING.md), or open a **Function request** issue.

## 📄 Licence

[MIT](LICENSE)