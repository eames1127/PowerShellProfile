<#
.SYNOPSIS
Compress a folder's contents into a dated .zip archive in another folder.

.PARAMETER fileName
Archive name prefix (the date is appended)

.PARAMETER loc
Folder whose contents are archived

.PARAMETER dest
Folder the .zip is written to

.EXAMPLE
compressAndCopy -fileName backup -loc C:\Projects\site -dest D:\Archives
#>
function compressAndCopy {
    param(
        [Parameter(Mandatory=$true)]
        [String]$fileName,
        [Parameter(Mandatory=$true)]
        [String]$loc,
        [Parameter(Mandatory=$true)]
        [String]$dest
    )

    # UK date format (day-month-year)
    $date = Get-Date -Format "dd-MM-yyyy"
    $archive = Join-Path $dest "$($fileName)_$date.zip"
    
    Get-ChildItem -Path $loc | Compress-Archive -DestinationPath $archive -CompressionLevel Optimal -Verbose -Confirm
    Write-Host "Finished copying files to $archive"
}

<#
.SYNOPSIS
Check that a list of required files exists in a folder. Returns $true or $false.

.PARAMETER path
Folder to check

.PARAMETER fileList
File names that must be present

.EXAMPLE
validateFiles -path C:\Deploy -fileList @("app.exe", "app.config")
#>
function validateFiles {
    param(
        [Parameter(Mandatory=$true)]
        [String]$path,
        [Parameter(Mandatory=$false)]
        [String[]]$fileList = @("text.txt", "document.doc")
    )

    $missingFiles = @()
    
    Write-Host "Checking for required files in: $path"
    Write-Host "Files to verify: $($fileList -join ', ')"
    
    foreach ($file in $fileList) {
        $fullPath = Join-Path $path $file
        if (-not (Test-Path -LiteralPath $fullPath)) {
            $missingFiles += $file
        }
    }
    
    if ($missingFiles.Count -gt 0) {
        Write-Host "FAIL: Missing files in $path" -ForegroundColor Red
        foreach ($file in $missingFiles) {
            Write-Host "  - $file" -ForegroundColor Red
        }
        return $false
    } else {
        Write-Host "SUCCESS: All files found" -ForegroundColor Green
        return $true
    }
}

<#
.SYNOPSIS
Recursively copy files matching extension filters to a destination, with confirmation.

.PARAMETER copyFrom
Source folder (defaults to the current location)

.PARAMETER copyTo
Destination folder

.PARAMETER extFilter
Wildcard patterns to include

.EXAMPLE
copyByExtension -copyTo D:\Backup -extFilter @("*.ps1", "*.md")
#>
function copyByExtension {
    param(
        [Parameter(Mandatory=$false)]
        [string]$copyFrom = (Get-Location),
        [Parameter(Mandatory=$true)]
        [string]$copyTo,
        [Parameter(Mandatory=$false)]
        [string[]]$extFilter = @("*.ps1", "*.md", "*.docx")
    )

    Write-Host "Copy from: $copyFrom" -ForegroundColor DarkYellow
    Write-Host "Copy to: $copyTo" -ForegroundColor DarkYellow
    Write-Host "Extensions: $($extFilter -join ', ')" -ForegroundColor DarkYellow

    $continue = Read-Host "Continue? (y/n)"
    if ($continue.ToLower() -ne 'y') {
        Write-Host "Aborted" -ForegroundColor Red
        return
    }

    Get-ChildItem -Path "$copyFrom\*" -Recurse -Include $extFilter | ForEach-Object {
        Write-Host "Copying $($_.Name) to $copyTo"
        Copy-Item $_ -Destination $copyTo -Confirm
    }
    
    Write-Host "Finished copying files to $copyTo" -ForegroundColor Green
}
<#
.SYNOPSIS
Find files by name pattern under a folder (recursive).

.PARAMETER pattern
Text or wildcard to match in the file name. Plain text is matched anywhere in the name.

.PARAMETER path
Folder to search (defaults to the current location).

.EXAMPLE
findFile profile

.EXAMPLE
findFile *.log -path C:\Logs
#>
function findFile {
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$pattern,
        [Parameter(Mandatory=$false)]
        [string]$path = (Get-Location)
    )
    if ($pattern -notmatch '[\*\?]') { $pattern = "*$pattern*" }
    Get-ChildItem -Path $path -Filter $pattern -Recurse -File -ErrorAction SilentlyContinue |
        Select-Object LastWriteTime, @{ Name = 'SizeKB'; Expression = { [math]::Round($_.Length / 1KB, 1) } }, FullName
}

<#
.SYNOPSIS
Show the largest sub-folders of a folder, by total size.

.PARAMETER path
Folder to measure (defaults to the current location).

.PARAMETER top
How many folders to show (default 10).

.EXAMPLE
dirSize C:\Users -top 5
#>
function dirSize {
    param(
        [Parameter(Mandatory=$false, Position=0)]
        [string]$path = (Get-Location),
        [Parameter(Mandatory=$false)]
        [int]$top = 10
    )
    Write-Host "Measuring folders in $path..." -ForegroundColor Yellow
    Get-ChildItem -Path $path -Directory -Force -ErrorAction SilentlyContinue | ForEach-Object {
        $bytes = (Get-ChildItem -Path $_.FullName -Recurse -File -Force -ErrorAction SilentlyContinue |
            Measure-Object -Property Length -Sum).Sum
        [pscustomobject]@{ Folder = $_.Name; SizeMB = [math]::Round($bytes / 1MB, 1) }
    } | Sort-Object SizeMB -Descending | Select-Object -First $top | Format-Table -AutoSize
}
