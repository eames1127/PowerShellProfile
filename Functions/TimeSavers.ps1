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
    Copy-Item -Path "$psProfileLoc\Functions" -Destination "$codingLoc\PowerShellProfile\Functions" -Recurse
}

# Copy PowerShell profile from code repository to system location
function copyPSProfileFromCode() {
    Write-Host "Copying to $psProfileLoc"
    Copy-Item -Path "$codingLoc\PowerShellProfile\Microsoft.PowerShell_profile.ps1" -Destination $psProfileLoc
    Copy-Item -Path "$codingLoc\PowerShellProfile\Functions" -Destination $psProfileLoc -Recurse
}

<#
.DESCRIPTION
Find all local merged commits from specified branch to the last commit of your currently checked out branch.

.PARAMETER gitLoc
Your Git checkout location. e.g. c:/coding/git

.PARAMETER branchName
Name of comparison branch

.PARAMETER update
Optional: "y" to pull latest changes before comparison
#>
function getChangesInBranch {
    param(
        [Parameter(Mandatory=$true)]
        [String]$gitLoc,
        [Parameter(Mandatory=$true)]
        [String]$branchName,
        [Parameter(Mandatory=$false)]
        [String]$update
    )

    Set-Location $gitLoc

    if ($update -eq "y") {
        git pull
    }
    $lastCommitHash = git log -n 1 $branchName --pretty=format:"%H"
    $branch = git branch --show-current

    Write-Host "`nWarning: you are currently on $branch branch." -ForegroundColor Yellow
    Write-Host "`nFetching all commits since $lastCommitHash. Press enter to view all commits until you see (END) then press q.`n" -ForegroundColor Green
    git log $lastCommitHash..Head --oneline --merges | Where-Object {$_ -Like "*Merged in Jira*"} | Format-Table

    Write-Host "`nScript Completed." -ForegroundColor Green
}