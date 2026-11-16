# Profile load timing
$profileStart = Get-Date

# Load personal settings from profile.config.psd1 (next to $PROFILE), falling back to defaults
$profileConfig = @{
    CodingPath   = 'C:\Coding'
    GitHubUser   = ''
    Theme        = 'stelbent-compact.minimal'
    ClearOnStart = $true
    ShowLoadTime = $true
}
$profileConfigPath = Join-Path (Split-Path -Parent $PROFILE) "profile.config.psd1"
if (Test-Path $profileConfigPath) {
    try {
        $userConfig = Import-PowerShellDataFile -Path $profileConfigPath
        foreach ($key in $userConfig.Keys) { $profileConfig[$key] = $userConfig[$key] }
    } catch {
        Write-Warning "Could not read $($profileConfigPath): $($_.Exception.Message). Using defaults."
    }
}

if ($profileConfig.ClearOnStart) { Clear-Host }

# Import Git integration module with error handling
try {
    Import-Module posh-git -ErrorAction Stop
} catch {
    Write-Warning "posh-git module not found. Install with: Install-Module posh-git"
}

# Initialise oh-my-posh with custom theme and error handling
try {
    if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
        oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\$($profileConfig.Theme).omp.json" | Invoke-Expression
    } else {
        Write-Warning "oh-my-posh not found. Install with: winget install JanDeDobbeleer.OhMyPosh"
    }
} catch {
    Write-Warning "Failed to initialise oh-my-posh: $($_.Exception.Message)"
}

# Set terminal appearance - only label the window "Admin" when it really is elevated
$Host.UI.RawUI.BackgroundColor = "black"
$isElevated = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)
$Host.UI.RawUI.WindowTitle = if ($isElevated) { "PowerShell Admin" } else { "PowerShell" }

# Get Functions directory path
$funcRepo = Join-Path (Split-Path -Parent $PROFILE) "Functions"

# Records which file each function came from, for profileHelp
$profileFunctions = @{}

# Load functions with error handling
if (Test-Path $funcRepo) {
    $files = Get-ChildItem -Path $funcRepo -Filter "*.ps1" -Recurse
    $loadedFiles = 0

    foreach ($file in $files) {
        try {
            $before = @(Get-ChildItem Function:\ | Select-Object -ExpandProperty Name)
            . $file.FullName
            Get-ChildItem Function:\ | Where-Object { $before -notcontains $_.Name } | ForEach-Object {
                $profileFunctions[$_.Name] = $file.BaseName
            }
            $loadedFiles++
        } catch {
            Write-Warning "Failed to load $($file.Name): $($_.Exception.Message)"
        }
    }
    if ($profileConfig.ShowLoadTime) {
        Write-Host "Loaded $($profileFunctions.Count) functions from $loadedFiles of $($files.Count) files - run 'profileHelp' to list them" -ForegroundColor Green
    }
} else {
    Write-Warning "Functions directory not found: $funcRepo"
}

# Custom aliases
# ll is a function rather than an alias so it can include hidden files (-Force)
function ll {
    <#
    .SYNOPSIS
    List files including hidden ones (Get-ChildItem -Force).
    #>
    Get-ChildItem -Force @args
}
Set-Alias -Name "grep" -Value "Select-String"
Set-Alias -Name "which" -Value "Get-Command"
# Skip curl alias - conflicts with built-in PowerShell alias

<#
.SYNOPSIS
Copy the profile and Functions from CodingPath\PowerShellProfile into your live profile folder.

.DESCRIPTION
profile.config.psd1 is not touched, so personal settings survive updates.
#>
function Update-Profile {
    $profileDir = Split-Path -Parent $PROFILE
    $profileRepo = Join-Path $codingLoc "PowerShellProfile"

    if (Test-Path $profileRepo) {
        Write-Host "Updating PowerShell profile from $profileRepo..." -ForegroundColor Yellow
        Copy-Item (Join-Path $profileRepo "Microsoft.PowerShell_profile.ps1") -Destination $PROFILE -Force

        $functionsSource = Join-Path $profileRepo "Functions"
        if (Test-Path $functionsSource) {
            # Copy into the profile dir (not into Functions) so we don't create Functions\Functions
            Copy-Item $functionsSource -Destination $profileDir -Recurse -Force
        }
        Write-Host "Profile updated. Restart PowerShell to apply changes." -ForegroundColor Green
    } else {
        Write-Host "Profile repository not found at $profileRepo" -ForegroundColor Red
    }
}
# Backwards-compatible name for the old duplicate function
Set-Alias -Name "copyPSProfileFromCode" -Value "Update-Profile"

<#
.SYNOPSIS
List every function this profile provides, grouped by file, with a one-line description.

.PARAMETER filter
Only show functions whose name, file or description contains this text.

.EXAMPLE
profileHelp

.EXAMPLE
profileHelp net
#>
function profileHelp {
    param(
        [Parameter(Mandatory=$false, Position=0)]
        [string]$filter
    )

    $entries = @($profileFunctions.GetEnumerator() | ForEach-Object { [pscustomobject]@{ Name = $_.Key; File = $_.Value } })
    $entries += 'll', 'Update-Profile', 'profileHelp' | ForEach-Object { [pscustomobject]@{ Name = $_; File = 'Profile' } }

    $rows = foreach ($entry in $entries) {
        $synopsis = (Get-Help $entry.Name -ErrorAction SilentlyContinue).Synopsis
        # Get-Help falls back to the syntax line when a function has no help block
        if (-not $synopsis -or $synopsis -match "^\s*$([regex]::Escape($entry.Name))\b") { $synopsis = '' }
        [pscustomobject]@{ File = $entry.File; Name = $entry.Name; Synopsis = $synopsis.Trim() }
    }

    if ($filter) {
        $rows = $rows | Where-Object { $_.Name -like "*$filter*" -or $_.File -like "*$filter*" -or $_.Synopsis -like "*$filter*" }
    }

    $rows | Sort-Object File, Name | Format-Table Name, Synopsis -GroupBy File -AutoSize -Wrap
    Write-Host "Run 'Get-Help <name> -Examples' for usage." -ForegroundColor DarkGray
}

# Display profile load time and location
$loadTime = ((Get-Date) - $profileStart).TotalMilliseconds
if ($profileConfig.ShowLoadTime) {
    Write-Host "Profile loaded in $([math]::Round($loadTime, 2))ms from $PROFILE" -ForegroundColor Cyan
}
