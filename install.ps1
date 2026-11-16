<#
.SYNOPSIS
Installs this PowerShell profile and its Functions into your $PROFILE folder.

.DESCRIPTION
- Backs up any existing profile and Functions folder (timestamped .bak copies)
- Copies Microsoft.PowerShell_profile.ps1 and Functions\ into place
- Creates profile.config.psd1 from the example if you don't already have one
- Optionally installs posh-git, oh-my-posh and the Meslo Nerd Font

Run it from a clone of the repo, or straight from GitHub:
    irm https://raw.githubusercontent.com/eames1127/PowerShellProfile/master/install.ps1 | iex

.PARAMETER InstallTerminal
Also install posh-git, oh-my-posh and the Meslo font (runs installTerminalconfig).

.EXAMPLE
.\install.ps1 -InstallTerminal
#>
param(
    [switch]$InstallTerminal
)

$ErrorActionPreference = 'Stop'
$repoZip = 'https://github.com/eames1127/PowerShellProfile/archive/refs/heads/master.zip'

# Work out where the source files are - local clone, or download from GitHub when run via irm | iex
$source = $PSScriptRoot
$tempDir = $null
if (-not $source -or -not (Test-Path (Join-Path $source 'Functions'))) {
    Write-Host "Downloading PowerShellProfile from GitHub..." -ForegroundColor Yellow
    $tempDir = Join-Path ([IO.Path]::GetTempPath()) "PowerShellProfile-$(Get-Random)"
    New-Item -ItemType Directory -Path $tempDir | Out-Null
    $zip = Join-Path $tempDir 'profile.zip'
    Invoke-WebRequest -Uri $repoZip -OutFile $zip -UseBasicParsing
    Expand-Archive -Path $zip -DestinationPath $tempDir
    $source = (Get-ChildItem -Path $tempDir -Directory | Select-Object -First 1).FullName
}

$profileDir = Split-Path -Parent $PROFILE
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

# Back up anything we're about to overwrite
$stamp = Get-Date -Format 'dd-MM-yyyy_HHmmss'
if (Test-Path $PROFILE) {
    Copy-Item $PROFILE "$PROFILE.$stamp.bak"
    Write-Host "Backed up existing profile to $PROFILE.$stamp.bak" -ForegroundColor DarkYellow
}
$functionsTarget = Join-Path $profileDir 'Functions'
if (Test-Path $functionsTarget) {
    Copy-Item $functionsTarget "$functionsTarget.$stamp.bak" -Recurse
    Write-Host "Backed up existing Functions to $functionsTarget.$stamp.bak" -ForegroundColor DarkYellow
}

# Install profile and functions
Copy-Item (Join-Path $source 'Microsoft.PowerShell_profile.ps1') -Destination $PROFILE -Force
Copy-Item (Join-Path $source 'Functions') -Destination $profileDir -Recurse -Force
Write-Host "Installed profile to $PROFILE" -ForegroundColor Green

# Personal config - never overwrite an existing one
$configTarget = Join-Path $profileDir 'profile.config.psd1'
if (-not (Test-Path $configTarget)) {
    Copy-Item (Join-Path $source 'profile.config.example.psd1') -Destination $configTarget
    Write-Host "Created $configTarget - edit it to set your coding folder, GitHub user and theme" -ForegroundColor Cyan
} else {
    Write-Host "Kept your existing $configTarget" -ForegroundColor Cyan
}

if ($InstallTerminal) {
    . (Join-Path $source 'Functions\Config.ps1')
    installTerminalconfig
}

if ($tempDir) { Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue }

Write-Host "`nDone. Open a new PowerShell window to load the profile." -ForegroundColor Green
