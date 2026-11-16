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
1 = Spooler, 2 = reserved for a custom service (not yet configured), 88 = prompt for a name, anything else = list running services

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
<#
.SYNOPSIS
Return $true if the current session is running as Administrator.

.EXAMPLE
if (-not (isAdmin)) { sudoLast }
#>
function isAdmin {
    ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator)
}

<#
.SYNOPSIS
Re-run your previous command in a new elevated (Administrator) window.

.EXAMPLE
Restart-Service Spooler   # fails: access denied
sudoLast
#>
function sudoLast {
    $last = (Get-History -Count 1).CommandLine
    if (-not $last) {
        Write-Host "No previous command in history." -ForegroundColor Red
        return
    }
    $shell = (Get-Process -Id $PID).Path
    Write-Host "Re-running as Administrator: $last" -ForegroundColor Yellow
    # Encode the command so quotes and spaces survive being passed to the new process;
    # -NoExit keeps the window open so you can read the output
    $encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($last))
    Start-Process -FilePath $shell -Verb RunAs -ArgumentList '-NoExit', '-EncodedCommand', $encoded
}

<#
.SYNOPSIS
Show OS, uptime, CPU, memory and disk space at a glance.

.EXAMPLE
sysInfo
#>
function sysInfo {
    $os = Get-CimInstance Win32_OperatingSystem
    $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
    $uptime = (Get-Date) - $os.LastBootUpTime
    $totalGB = [math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
    $freeGB = [math]::Round($os.FreePhysicalMemory / 1MB, 1)

    Write-Host "System Information:" -ForegroundColor Cyan
    Write-Host "Computer: $env:COMPUTERNAME"
    Write-Host "OS:       $($os.Caption) (build $($os.BuildNumber))"
    Write-Host "Uptime:   $($uptime.Days)d $($uptime.Hours)h $($uptime.Minutes)m"
    Write-Host "CPU:      $($cpu.Name.Trim()) - $($cpu.LoadPercentage)% load"
    Write-Host "Memory:   $([math]::Round($totalGB - $freeGB, 1)) GB used of $totalGB GB"

    Write-Host "`nDisks:" -ForegroundColor Cyan
    Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
        $free = [math]::Round($_.FreeSpace / 1GB, 1)
        $size = [math]::Round($_.Size / 1GB, 1)
        $colour = if ($size -gt 0 -and ($free / $size) -lt 0.1) { 'Red' } else { 'Green' }
        Write-Host "  $($_.DeviceID) $free GB free of $size GB" -ForegroundColor $colour
    }
}

<#
.SYNOPSIS
Upgrade all winget packages and installed PowerShell modules.

.PARAMETER skipModules
Only run winget, not Update-Module.

.EXAMPLE
updateAll
#>
function updateAll {
    param(
        [switch]$skipModules
    )

    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "Upgrading winget packages..." -ForegroundColor Yellow
        winget upgrade --all --accept-source-agreements --accept-package-agreements
    } else {
        Write-Warning "winget not found - skipping app upgrades"
    }

    if (-not $skipModules) {
        Write-Host "`nUpdating PowerShell modules..." -ForegroundColor Yellow
        Get-InstalledModule -ErrorAction SilentlyContinue | ForEach-Object {
            # Inside catch, $_ becomes the error record, so keep the module name separately
            $moduleName = $_.Name
            try {
                Update-Module -Name $moduleName -ErrorAction Stop
                Write-Host "  $moduleName checked" -ForegroundColor Green
            } catch {
                Write-Host "  $moduleName failed: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
    Write-Host "`nUpdates complete." -ForegroundColor Green
}
