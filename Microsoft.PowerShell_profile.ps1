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

# Load functions with error handling
if (Test-Path $funcRepo) {
    $files = Get-ChildItem -Path $funcRepo -Filter "*.ps1" -Recurse
    $loadedFiles = 0

    foreach ($file in $files) {
        try {
            . $file.FullName
            $loadedFiles++
        } catch {
            Write-Warning "Failed to load $($file.Name): $($_.Exception.Message)"
        }
    }
    if ($profileConfig.ShowLoadTime) {
        Write-Host "Loaded $loadedFiles of $($files.Count) function files" -ForegroundColor Green
    }
} else {
    Write-Warning "Functions directory not found: $funcRepo"
}

# Custom aliases
# ll is a function rather than an alias so it can include hidden files (-Force)
function ll { Get-ChildItem -Force @args }
Set-Alias -Name "grep" -Value "Select-String"
Set-Alias -Name "which" -Value "Get-Command"
# Skip curl alias - conflicts with built-in PowerShell alias

# Sync profile and Functions from the code repository (CodingPath\PowerShellProfile) into the live profile location.
# profile.config.psd1 is not touched, so personal settings survive updates.
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

# Display profile load time and location
$loadTime = ((Get-Date) - $profileStart).TotalMilliseconds
if ($profileConfig.ShowLoadTime) {
    Write-Host "Profile loaded in $([math]::Round($loadTime, 2))ms from $PROFILE" -ForegroundColor Cyan
}
