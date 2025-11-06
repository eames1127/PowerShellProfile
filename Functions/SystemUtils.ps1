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

# Restart Windows services locally or remotely with predefined service IDs
# Parameters: $serviceID (1=Spooler, 2=Custom, 88=Manual input, 0/default=List services), $machine (remote computer name, empty for local)
# Usage examples:
#   manageServices                           # List running services locally
#   manageServices -serviceID 1              # Restart Spooler service locally
#   manageServices -serviceID 88             # Manually enter service name to restart locally
#   manageServices -serviceID 1 -machine "SERVER01"  # Restart Spooler on remote server
function manageServices {
    param(
        [Parameter(Mandatory=$false)]
        [int]$serviceID = 0,
        [Parameter(Mandatory=$false)]
        [string]$machine = ""
    )

    if ($machine -eq "") {
        Write-Host "Running locally..." -ForegroundColor Green
        switch ($serviceID) {
            1 {
                Write-Host "Restarting Spooler service..."
                Restart-Service -Name "Spooler" -Force
            }
            2 {
                Write-Host "Service ID 2 not configured" -ForegroundColor Yellow
            }
            88 {
                $serviceName = Read-Host "Enter service name to restart"
                Restart-Service -Name $serviceName -Force
            }
            Default {
                Write-Host "Showing all running services..."
                Get-Service | Where-Object Status -eq "Running" | Format-Table
            }
        }
    } else {
        Write-Host "Running against $machine..." -ForegroundColor Yellow
        $continue = Read-Host "Continue? (y/n)"
        
        if ($continue.ToLower() -eq 'y') {
            switch ($serviceID) {
                1 {
                    Write-Host "Restarting Spooler service on $machine..."
                    Get-Service -ComputerName $machine -Name "Spooler" | Restart-Service -Verbose
                }
                2 {
                    Write-Host "Service ID 2 not configured" -ForegroundColor Yellow
                }
                88 {
                    $serviceName = Read-Host "Enter service name to restart"
                    Get-Service -ComputerName $machine -Name $serviceName | Restart-Service -Verbose
                }
                Default {
                    Write-Host "Showing all running services on $machine..."
                    Get-Service -ComputerName $machine | Where-Object Status -eq "Running" | Format-Table
                }
            }
        } else {
            Write-Host "Aborted" -ForegroundColor Yellow
        }
    }
    Write-Host "Operation completed" -ForegroundColor Green
}