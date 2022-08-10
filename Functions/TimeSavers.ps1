$codingLoc = "C:\Coding";
$psProfileLoc = "C:\Users\Daniel\Documents\WindowsPowerShell\Microsoft.PowerShell";
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