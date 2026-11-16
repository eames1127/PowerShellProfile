# Configuration - set these in profile.config.psd1 rather than editing this file
$codingLoc = if ($profileConfig.CodingPath) { $profileConfig.CodingPath } else { "C:\Coding" }
# Works for both Windows PowerShell 5.1 and PowerShell 7 profile folders
$psProfileLoc = Split-Path -Parent $PROFILE

<#
.SYNOPSIS
Open a GitHub repository in the browser.

.PARAMETER username
GitHub user (or the repo name if only one argument is given - GitHubUser from config is then used)

.PARAMETER loc
Repository name

.EXAMPLE
goToGitHubRepo PowerShellProfile

.EXAMPLE
goToGitHubRepo someUser someRepo
#>
function goToGitHubRepo($username, $loc) {
    if (-not $loc) {
        $loc = $username
        $username = $profileConfig.GitHubUser
    }
    if (-not $username) {
        Write-Host "No GitHub username given - pass one or set GitHubUser in profile.config.psd1" -ForegroundColor Red
        return
    }
    Write-Host "Heading to GitHub repo for $loc"
    $url = "https://github.com/$username/$loc"
    Start-Process $url
}

<#
.SYNOPSIS
Go to your coding folder (CodingPath) and open it in VS Code.

.EXAMPLE
goToCoding
#>
function goToCoding() {
    Write-Host "Heading to $codingLoc"
    Set-Location $codingLoc
    code .
}

<#
.SYNOPSIS
Clone a git repository into your coding folder.

.PARAMETER loc
Git repository URL

.EXAMPLE
initRepo https://github.com/user/repo.git
#>
function initRepo($loc) {
    Write-Host "Heading to $codingLoc"
    Set-Location $codingLoc
    Write-Host "Cloning into $loc"
    git clone $loc
}

<#
.SYNOPSIS
Go to a repository in your coding folder and show git status.

.PARAMETER repo
Repository folder name under CodingPath

.EXAMPLE
goToRepo PowerShellProfile
#>
function goToRepo($repo) {
    $codingRepo = "$codingLoc\$repo"
    Set-Location $codingRepo
    git status
}

<#
.SYNOPSIS
Go to your PowerShell profile folder and open it in VS Code.

.EXAMPLE
psProfile
#>
function psProfile() {
    Write-Host "Heading to $psProfileLoc"
    Set-Location $psProfileLoc
    code .
}

<#
.SYNOPSIS
Copy your live profile and Functions back into the code repository.

.EXAMPLE
copyPSProfileToCode
#>
function copyPSProfileToCode() {
    Write-Host "Copying from $psProfileLoc"
    Copy-Item -Path "$psProfileLoc\Microsoft.PowerShell_profile.ps1" -Destination "$codingLoc\PowerShellProfile"
    # Destination is the repo root (not ...\Functions) so a second run doesn't create Functions\Functions
    Copy-Item -Path "$psProfileLoc\Functions" -Destination "$codingLoc\PowerShellProfile" -Recurse -Force
}

# copyPSProfileFromCode is now an alias for Update-Profile (defined in the main profile)

<#
.SYNOPSIS
List merge commits on your current branch since the tip of another branch.

.DESCRIPTION
Find all local merged commits from specified branch to the last commit of your currently checked out branch.

.PARAMETER gitLoc
Your Git checkout location. e.g. c:/coding/git

.PARAMETER branchName
Name of comparison branch

.PARAMETER filter
Optional: wildcard filter applied to merge commit messages. Defaults to "*" (all merges).
e.g. "*Merged in Jira*" to only show Jira-linked merges.

.PARAMETER update
Optional: pull latest changes before comparison

.EXAMPLE
getChangesInBranch -gitLoc C:\Coding\myRepo -branchName release -filter "*Merged in Jira*" -update
#>
function getChangesInBranch {
    param(
        [Parameter(Mandatory=$true)]
        [String]$gitLoc,
        [Parameter(Mandatory=$true)]
        [String]$branchName,
        [Parameter(Mandatory=$false)]
        [String]$filter = "*",
        [switch]$update
    )

    Set-Location $gitLoc

    if ($update) {
        git pull
    }
    $lastCommitHash = git log -n 1 $branchName --pretty=format:"%H"
    $branch = git branch --show-current

    Write-Host "`nWarning: you are currently on $branch branch." -ForegroundColor Yellow
    Write-Host "`nFetching all merge commits since $lastCommitHash matching '$filter'.`n" -ForegroundColor Green
    git log "$lastCommitHash..HEAD" --oneline --merges | Where-Object { $_ -like $filter }

    Write-Host "`nScript Completed." -ForegroundColor Green
}
