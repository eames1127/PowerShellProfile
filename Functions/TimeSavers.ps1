$codingLoc = "C:\Coding";
$psProfileLoc = "C:\Users\Daniel\Documents\WindowsPowerShell";
function goToGitHubRepo($loc)
{
    Write-Host "Heading to GitHub repo for" $loc;
    $url = "https://github.com/eames1127/"+ $loc;
    Start-Process "chrome.exe" $url;
}

function goToCoding()
{
    Write-Host "Heading to " $codingLoc;
    Set-Location $codingLoc;
    code .;
}

function initRepo($loc)
{
    Write-Host "Heading to " $codingLoc;
    Set-Location $codingLoc;
    Write-Host "Cloning into " $loc
    git clone $loc;
}

function goToRepo($repo){
    $codingRepo = $codingLoc + "\" + $repo;
    Set-Location $codingRepo;
    git status;
}

function psProfile()
{
    Write-Host "Heading to "  $psProfileLoc;
    Set-Location $psProfileLoc;
    code .
}

function copyPSProfileToCode(){
    Write-Host "Copying from" $psProfileLoc;
    Copy-Item -Path "$psProfileLoc\Microsoft.PowerShell_profile.ps1" -Destination "C:\Coding\PowerShellProfile" -Recurse;
    Copy-Item -Path "$psProfileLoc\Functions" -Destination "C:\Coding\PowerShellProfile\Functions" -Recurse;
}

function copyPSProfileFromCode(){
    Write-Host "Copying from" $psProfileLoc;
    Copy-Item -Path "$psProfileLoc\Microsoft.PowerShell_profile.ps1" -Destination "C:\Coding\PowerShellProfile" -Recurse;
    Copy-Item -Path "$psProfileLoc\Functions" -Destination "C:\Coding\PowerShellProfile\Functions" -Recurse;
}

<#
.DESCRIPTION
Find all local merged commits from specified branch to the last commit of your currently checked out branch.

.PARAMETER gitLoc
Your Git checkout location. e.g. c:/coding/git

.PARAMETER branchName
Name of comparision branch
#>
function getChangesInBranch{
 
    param(
        [Parameter(Mandatory=$true)]
        [String]$gitLoc,
        [Parameter(Mandatory=$true)]
        [String]$branchName,
        [Parameter(Mandatory=$false)]
        [String]$update
    )

    Set-Location $gitLoc

    if ($update -eq "y"){
        git pull
    }
    $lastCommitHash = git log -n 1 $branchName --pretty=format:"%H"

    #must be using Git version 2.2 or above for this to work.
    $branch = git branch --show-current 

    Write-Host "`n Warning you are currently on $branch branch." -ForegroundColor Yellow
    Write-Host "`nFetching all commits since $lastCommitHash. Ensure you press enter to view all commits until you see (END) then press q.`n" -ForegroundColor Green
    git log $lastCommitHash..Head --oneline --merges|Where-Object {$_ -Like "*Merged in Jira*"} | Format-Table

    Write-Host "`nScript Completed." -ForegroundColor Green
}