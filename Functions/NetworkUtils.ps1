<#
.SYNOPSIS
Rough download speed test (downloads ~10MB and reports Mbps).

.PARAMETER testUrl
URL of the file to download

.EXAMPLE
speedTest
#>
function speedTest {
    param(
        [Parameter(Mandatory=$false)]
        [string]$testUrl = "https://speed.cloudflare.com/__down?bytes=10000000"
    )
    Write-Host "Testing network speed..." -ForegroundColor Yellow
    $testFile = Join-Path ([IO.Path]::GetTempPath()) "speedtest.tmp"
    
    try {
        $start = Get-Date
        Invoke-WebRequest -Uri $testUrl -OutFile $testFile -UseBasicParsing
        $end = Get-Date
        $duration = ($end - $start).TotalSeconds
        $fileSize = (Get-Item $testFile).Length / 1MB
        $speed = [math]::Round($fileSize / $duration * 8, 2)
        
        Write-Host "Download Speed: $speed Mbps ($($fileSize.ToString('F1')) MB file)" -ForegroundColor Green
        Remove-Item $testFile -ErrorAction SilentlyContinue
    }
    catch {
        Write-Host "Speed test failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

<#
.SYNOPSIS
Show private IPv4 addresses, public IP and default gateway.

.EXAMPLE
myIP
#>
function myIP {
    Write-Host "Network Information:" -ForegroundColor Cyan
    
    # Private IP
    $privateIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.InterfaceAlias -notlike "*Loopback*"}).IPAddress
    Write-Host "Private IP: $($privateIP -join ', ')" -ForegroundColor Green
    
    # Public IP
    try {
        $publicIP = (Invoke-RestMethod -Uri "https://api.ipify.org" -TimeoutSec 5).Trim()
        Write-Host "Public IP: $publicIP" -ForegroundColor Green
    }
    catch {
        Write-Host "Public IP: Unable to retrieve" -ForegroundColor Red
    }
    
    # Gateway
    $gateway = (Get-NetRoute -DestinationPrefix "0.0.0.0/0" | Select-Object -First 1).NextHop
    Write-Host "Gateway: $gateway" -ForegroundColor Green
}

<#
.SYNOPSIS
List saved WiFi profiles, or connect to one.

.PARAMETER connectTo
Saved WiFi profile name to connect to

.EXAMPLE
wifiList

.EXAMPLE
wifiList -connectTo "HomeNetwork"
#>
function wifiList {
    param(
        [Parameter(Mandatory=$false)]
        [string]$connectTo
    )
    
    if ($connectTo) {
        Write-Host "Connecting to $connectTo..." -ForegroundColor Yellow
        netsh wlan connect name="$connectTo"
    } else {
        Write-Host "Available WiFi Networks:" -ForegroundColor Cyan
        (netsh wlan show profiles) -match "All User Profile" | ForEach-Object {
            ($_ -split ":")[1].Trim()
        }
    }
}

<#
.SYNOPSIS
Show which process is using a local TCP port.

.PARAMETER port
Local TCP port number

.EXAMPLE
checkPort 8080
#>
function checkPort {
    param(
        [Parameter(Mandatory=$true)]
        [int]$port
    )
    
    Write-Host "Checking port $port..." -ForegroundColor Yellow
    
    $connections = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
    if ($connections) {
        foreach ($conn in $connections) {
            $process = Get-Process -Id $conn.OwningProcess -ErrorAction SilentlyContinue
            if ($process) {
                Write-Host "Port $port is used by: $($process.ProcessName) (PID: $($conn.OwningProcess)) - State: $($conn.State)" -ForegroundColor Green
            } else {
                Write-Host "Port $port is used by PID: $($conn.OwningProcess) - State: $($conn.State)" -ForegroundColor Green
            }
        }
    } else {
        Write-Host "Port $port is not in use" -ForegroundColor Red
    }
}

<#
.SYNOPSIS
Run ping, DNS lookup and traceroute against a host.

.PARAMETER target
Host name or IP address

.EXAMPLE
netDiag github.com
#>
function netDiag {
    param(
        [Parameter(Mandatory=$true)]
        [string]$target
    )
    
    Write-Host "Network Diagnostics for: $target" -ForegroundColor Cyan
    
    # Ping test
    Write-Host "`nPing Test:" -ForegroundColor Yellow
    Test-Connection -ComputerName $target -Count 4
    
    # DNS lookup
    Write-Host "`nDNS Lookup:" -ForegroundColor Yellow
    try {
        Resolve-DnsName -Name $target | Select-Object Name, IPAddress, Type
    }
    catch {
        Write-Host "DNS lookup failed" -ForegroundColor Red
    }
    
    # Traceroute
    Write-Host "`nTrace Route:" -ForegroundColor Yellow
    try {
        $traceResult = Test-NetConnection -ComputerName $target -TraceRoute
        $traceResult.TraceRoute | ForEach-Object { Write-Host $_ }
    }
    catch {
        Write-Host "Traceroute failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

<#
.SYNOPSIS
List network adapters that are up, with link speed.

.EXAMPLE
netAdapters
#>
function netAdapters {
    Write-Host "Network Adapters:" -ForegroundColor Cyan
    Get-NetAdapter | Where-Object Status -eq "Up" | 
    Select-Object Name, InterfaceDescription, LinkSpeed | 
    Format-Table -AutoSize
}

<#
.SYNOPSIS
Single ping that returns $true or $false.

.PARAMETER target
Host name or IP address

.EXAMPLE
if (pingTest server01) { "up" }
#>
function pingTest {
    param(
        [Parameter(Mandatory=$true)]
        [string]$target
    )
    
    Test-Connection -ComputerName $target -Count 1 -Quiet
}