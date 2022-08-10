function installTerminalconfig
{
    Install-module posh-git
    winget install JanDeDobbeleer.OhMyPosh -s winget

    Powershell

    Import-Module posh-git
    oh-my-posh font install meslo
    
    Powershell
    $host.ui.RawUI.font = "MesloLGM NF"

    oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\stelbent-compact.minimal.omp.json" | invoke-expression
}