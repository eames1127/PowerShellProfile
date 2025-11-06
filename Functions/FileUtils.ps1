# Compress directory contents to dated archive
# Parameters: $fileName (archive name), $loc (source directory), $dest (destination directory)
function compressAndCopy {
    param(
        [Parameter(Mandatory=$true)]
        [String]$fileName,
        [Parameter(Mandatory=$true)]
        [String]$loc,
        [Parameter(Mandatory=$true)]
        [String]$dest
    )

    $date = Get-Date -Format "dd-M-yyyy"
    $archive = "$dest\$fileName`_$date"
    
    Get-ChildItem -Path $loc | Compress-Archive -DestinationPath $archive -CompressionLevel Optimal -Verbose -Confirm
    Write-Host "Finished copying files to $archive"
}

# Validate that all required files exist in a directory - useful for deployment verification,
# backup validation, or ensuring project dependencies are present
# Parameters: $path (directory to check), $fileList (array of filenames to verify)
# Returns: $true if all files found, $false if any missing
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

# Copy files by extension filter with confirmation
# Parameters: $copyFrom (source path, defaults to current location), $copyTo (destination path), $extFilter (file extensions to copy)
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