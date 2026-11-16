# Configuration variables - Update these paths for your environment
$codingLoc = "C:\Coding"
$username = $env:USERNAME
$psProfileLoc = "C:\Users\$username\Documents\WindowsPowerShell"

# Opens GitHub repository in default browser
# Parameters: $username (GitHub username), $loc (repository name)
function goToGitHubRepo($username, $loc) {
    Write-Host "Heading to GitHub repo for $loc"
    $url = "https://github.com/$username/$loc"
    Start-Process $url
}

# Navigate to coding directory and open in VS Code
function goToCoding() {
    Write-Host "Heading to $codingLoc"
    Set-Location $codingLoc
    code .
}

# Clone repository to coding directory
# Parameters: $loc (git repository URL or path)
function initRepo($loc) {
    Write-Host "Heading to $codingLoc"
    Set-Location $codingLoc
    Write-Host "Cloning into $loc"
    git clone $loc
}

# Navigate to specific repository and show git status
# Parameters: $repo (repository folder name)
function goToRepo($repo) {
    $codingRepo = "$codingLoc\$repo"
    Set-Location $codingRepo
    git status
}

# Navigate to PowerShell profile directory and open in VS Code
function psProfile() {
    Write-Host "Heading to $psProfileLoc"
    Set-Location $psProfileLoc
    code .
}

# Copy PowerShell profile from system location to code repository
function copyPSProfileToCode() {
    Write-Host "Copying from $psProfileLoc"
    Copy-Item -Path "$psProfileLoc\Microsoft.PowerShell_profile.ps1" -Destination "$codingLoc\PowerShellProfile"
    # Destination is the repo root (not ...\Functions) so a second run doesn't create Functions\Functions
    Copy-Item -Path "$psProfileLoc\Functions" -Destination "$codingLoc\PowerShellProfile" -Recurse -Force
}

# copyPSProfileFromCode is now an alias for Update-Profile (defined in the main profile)

<#
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
