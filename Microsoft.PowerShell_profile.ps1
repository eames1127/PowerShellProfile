# Profile load timing
$profileStart = Get-Date

# Clear terminal on startup
Clear-Host

# Import Git integration module with error handling
try {
    Import-Module posh-git -ErrorAction Stop
} catch {
    Write-Warning "posh-git module not found. Install with: Install-Module posh-git"
}

# Initialize oh-my-posh with custom theme and error handling
try {
    if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
        oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\stelbent-compact.minimal.omp.json" | invoke-expression
    } else {
        Write-Warning "oh-my-posh not found. Install with: winget install JanDeDobbeleer.OhMyPosh"
    }
} catch {
    Write-Warning "Failed to initialize oh-my-posh: $($_.Exception.Message)"
}

# Set terminal appearance
$Host.UI.RawUI.BackgroundColor = "black"
$host.ui.RawUI.WindowTitle = "PowerShell Admin"

# Get Functions directory path
$funcRepo = "$(Split-Path -Parent $profile)\Functions"

# Load functions with error handling
if (Test-Path $funcRepo) {
    $files = Get-ChildItem -Path $funcRepo -Filter "*.ps1" -Recurse
    $loadedFunctions = 0
    
    foreach($file in $files) {
        try {
            . $file.FullName
            $loadedFunctions++
        } catch {
            Write-Warning "Failed to load $($file.Name): $($_.Exception.Message)"
        }
    }
    Write-Host "Loaded $loadedFunctions functions from $($files.Count) files" -ForegroundColor Green
} else {
    Write-Warning "Functions directory not found: $funcRepo"
}

# Custom aliases
Set-Alias -Name "ll" -Value "Get-ChildItem"
Set-Alias -Name "grep" -Value "Select-String"
Set-Alias -Name "which" -Value "Get-Command"
# Skip curl alias - conflicts with built-in PowerShell alias

# Profile update checker
function Update-Profile {
    $profileDir = Split-Path -Parent $profile
    $profileRepo = Join-Path (Split-Path -Parent $profileDir) "PowerShellProfile"
    
    if (Test-Path $profileRepo) {
        Write-Host "Updating PowerShell profile..." -ForegroundColor Yellow
        Copy-Item (Join-Path $profileRepo "Microsoft.PowerShell_profile.ps1") -Destination $profile -Force
        $functionsSource = Join-Path $profileRepo "Functions"
        $functionsTarget = Join-Path $profileDir "Functions"
        
        if (Test-Path $functionsSource) {
            Copy-Item $functionsSource -Destination $profileDir -Recurse -Force
        }
        Write-Host "Profile updated. Restart PowerShell to apply changes." -ForegroundColor Green
    } else {
        Write-Host "Profile repository not found at $profileRepo" -ForegroundColor Red
    }
}

# Display profile load time and location
$profileEnd = Get-Date
$loadTime = ($profileEnd - $profileStart).TotalMilliseconds
Write-Host "Profile loaded in $([math]::Round($loadTime, 2))ms from $profile" -ForegroundColor Cyan