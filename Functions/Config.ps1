# Install and configure terminal with oh-my-posh theme and required modules
function installTerminalconfig {
    # Install posh-git module for Git integration
    Install-Module posh-git
    
    # Install Oh My Posh via winget
    winget install JanDeDobbeleer.OhMyPosh -s winget

    # Restart PowerShell session to load Oh My Posh
    Powershell

    # Import Git module
    Import-Module posh-git
    
    # Install Meslo font for proper icon display
    oh-my-posh font install meslo
    
    # Restart PowerShell session to apply font changes
    Powershell
    
    # Set terminal font to Meslo
    $host.ui.RawUI.font = "MesloLGM NF"

    # Initialize oh-my-posh with custom theme
    oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\stelbent-compact.minimal.omp.json" | invoke-expression
    
    Write-Host "Close and reopen the terminal for changes to apply."
}