<#
.SYNOPSIS
Install posh-git, oh-my-posh and the Meslo Nerd Font for the terminal theme.

.EXAMPLE
installTerminalconfig
#>
function installTerminalconfig {
    # Install posh-git module for Git integration
    Write-Host "Installing posh-git..." -ForegroundColor Yellow
    Install-Module posh-git -Scope CurrentUser -Force

    # Install Oh My Posh via winget
    Write-Host "Installing oh-my-posh..." -ForegroundColor Yellow
    winget install JanDeDobbeleer.OhMyPosh -s winget --accept-source-agreements --accept-package-agreements

    # winget updates PATH for new sessions only - refresh it for this one so oh-my-posh can be found
    $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
                [Environment]::GetEnvironmentVariable("Path", "User")

    # Install Meslo font for proper icon display
    if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
        Write-Host "Installing Meslo Nerd Font..." -ForegroundColor Yellow
        oh-my-posh font install meslo
    } else {
        Write-Warning "oh-my-posh not on PATH yet - open a new terminal and run: oh-my-posh font install meslo"
    }

    # The terminal font can't be set from PowerShell - it's a Windows Terminal setting
    Write-Host "`nLast step (manual): Windows Terminal > Settings > Profiles > Defaults > Appearance > Font face > 'MesloLGM Nerd Font'" -ForegroundColor Cyan
    Write-Host "Then close and reopen the terminal for changes to apply." -ForegroundColor Green
}
