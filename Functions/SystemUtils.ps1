# Check Event Viewer logs on multiple servers and export to PDF
# Parameters: $servers (array of server names), $days (days back to check)
function checkEventLogs {
    param(
        [Parameter(Mandatory=$false)]
        [String[]]$servers = @("server1", "server2"),
        [Parameter(Mandatory=$false)]
        [int]$days = 10
    )

    $startDate = (Get-Date).AddDays(-$days)
    Write-Host "Checking Event Viewer on: $($servers -join ', ')"

    $logType = "Application","Security","System" | Out-GridView -Title "Select log type" -OutputMode Single

    if ($logType) {
        foreach ($server in $servers) {
            if (Test-Connection -ComputerName $server -Count 1 -Quiet) {
                Write-Host "Checking logs on $server"
                Get-WinEvent -ComputerName $server -FilterHashtable @{LogName = $logType; StartTime = $startDate; Level = 2} |
                Select-Object MachineName, RecordID, ProviderName, TimeCreated, LevelDisplayName, TaskDisplayName, Message |
                Sort-Object TimeCreated -Descending |
                Out-Printer "Microsoft Print to PDF"
                Write-Host "Finished on $server"
            } else {
                Write-Host "Server $server cannot be reached" -ForegroundColor Red
            }
        }
        Write-Host "Script completed" -ForegroundColor Green
    } else {
        Write-Host "No selection made"
    }
}