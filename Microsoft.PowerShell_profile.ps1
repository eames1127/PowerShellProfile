Clear-Host

$Host.UI.RawUI.BackgroundColor = "black";
$host.UI.RawUI.ForegroundColor = "cyan";
$host.ui.RawUI.WindowTitle = "Powershell Admin"

Write-host "The current profile in use is located at" $profile;

$funcRepo = (split-path -Parent $profile) + "\Functions"

$files = (Get-ChildItem -path $funcRepo -Recurse | Where-Object { $_.Extension -eq ".ps1" })

#Get all the .ps1 files that reside in the "Function" folder
foreach($file in $files)
{ 
    #Load the contents of the file into the profile
    $fileContents = [string]::join([environment]::newline, (get-content -path $file.fullname))
    invoke-expression $fileContents
}