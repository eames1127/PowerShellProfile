# PSReadLine setup: history-based suggestions, smarter history search and menu completion.
# Windows PowerShell 5.1 ships an older PSReadLine, so newer options are only enabled when supported.
# Update with: Install-Module PSReadLine -Force -Scope CurrentUser

# Only for interactive consoles - prediction settings throw when output is redirected (e.g. CI, scripts)
if ((Get-Module -ListAvailable -Name PSReadLine) -and $Host.Name -eq 'ConsoleHost' -and -not [Console]::IsOutputRedirected) {
    Import-Module PSReadLine -ErrorAction SilentlyContinue
    $psrlVersion = (Get-Module PSReadLine).Version

    # Up/Down search history for commands starting with what you've already typed
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

    # Tab shows a selectable menu of completions instead of cycling
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete

    # Ctrl+D exits like on Linux/macOS shells (only when the line is empty)
    Set-PSReadLineKeyHandler -Key Ctrl+d -Function DeleteCharOrExit

    # Don't fill history with repeated identical commands
    Set-PSReadLineOption -HistoryNoDuplicates

    # Inline suggestions from your history (PSReadLine 2.1+), shown as a list (2.2+). F2 switches view.
    try {
        if ($psrlVersion -ge [version]'2.1.0') {
            Set-PSReadLineOption -PredictionSource History
        }
        if ($psrlVersion -ge [version]'2.2.0') {
            Set-PSReadLineOption -PredictionViewStyle ListView
        }
    } catch {
        Write-Warning "PSReadLine suggestions unavailable: $($_.Exception.Message)"
    }
}
