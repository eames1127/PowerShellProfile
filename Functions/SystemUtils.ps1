<#
.SYNOPSIS
Export recent error events from one or more servers to PDF.

.PARAMETER servers
Computer names to query

.PARAMETER days
How many days back to check

.EXAMPLE
checkEventLogs -servers @("SERVER01", "SERVER02") -days 7
#>
function checkEventLogs {
    param(
        [Parameter(Mandatory=$false)]
        [String[]]$servers = @("<server1>", "<server2>"),
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

<#
.SYNOPSIS
List or restart Windows services locally or on a remote machine.

.PARAMETER serviceID
1 = Spooler, 88 = prompt for a name, anything else = list running services

.PARAMETER machine
Remote computer name (blank for local)

.EXAMPLE
manageServices

.EXAMPLE
manageServices -serviceID 1

.EXAMPLE
manageServices -serviceID 88 -machine SERVER01
#>
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