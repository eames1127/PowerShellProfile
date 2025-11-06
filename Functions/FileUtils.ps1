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