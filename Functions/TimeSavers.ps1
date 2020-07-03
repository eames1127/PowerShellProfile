$codingLoc = "C:\Coding";

function goToGitHubRepo($loc)
{
    $url = "https://github.com/eames1127/"+ $loc;
    Start-Process "chrome.exe" $url;
}

function TestLink()
{
    Write-Host "Hello";
}

function goToCoding()
{
    Set-Location $codingLoc;
    code .;
}

function initRepo($loc)
{
    Set-Location $codingLoc;
    git clone $loc;
}

function goToRepo($repo){
    $codingRepo = $codingLoc + "\" + $repo;
    Set-Location $codingRepo;
    git status;
}