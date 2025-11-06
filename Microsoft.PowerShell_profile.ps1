# Clear terminal on startup
Clear-Host

# Import Git integration module
Import-Module posh-git

# Initialize oh-my-posh with custom theme
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\stelbent-compact.minimal.omp.json" | invoke-expression

# Set terminal appearance
$Host.UI.RawUI.BackgroundColor = "black"
$host.ui.RawUI.WindowTitle = "Powershell Admin"

# Display current profile location
Write-Host "The current profile in use is located at $profile"

# Get Functions directory path
$funcRepo = "$(Split-Path -Parent $profile)\Functions"

# Find all PowerShell files in Functions directory
$files = (Get-ChildItem -path $funcRepo -Recurse | Where-Object { $_.Extension -eq ".ps1" })

# Automatically load all functions from Functions directory
foreach($file in $files) { 
    # Read file contents and execute to load functions
    $fileContents = [string]::join([environment]::newline, (get-content -path $file.fullname))
    invoke-expression $fileContents
}