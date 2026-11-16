# Personal settings for the PowerShell profile.
# install.ps1 copies this to profile.config.psd1 next to your $PROFILE - edit that copy, not this one.
# Any setting you remove falls back to the default shown here.
@{
    # Folder that holds your git repositories (used by goToCoding, goToRepo, initRepo, Update-Profile)
    CodingPath   = 'C:\Coding'

    # Your GitHub username (used by goToGitHubRepo when no username is given)
    GitHubUser   = ''

    # oh-my-posh theme name from $env:POSH_THEMES_PATH (browse with Get-PoshThemes)
    Theme        = 'stelbent-compact.minimal'

    # Clear the terminal when the profile loads
    ClearOnStart = $true

    # Print function count and load time on startup
    ShowLoadTime = $true
}
