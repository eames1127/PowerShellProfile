# Network speed test using built-in PowerShell capabilities
function speedTest {
    param(
        [Parameter(Mandatory=$false)]
        [string]$testUrl = "http://speedtest.ftp.otenet.gr/files/test100k.db"
    )
    Write-Host "Testing network speed..." -ForegroundColor Yellow
    $testFile = "$env:TEMP\speedtest.tmp"
    
    try {
        $start = Get-Date
        Invoke-WebRequest -Uri $testUrl -OutFile $testFile -UseBasicParsing
        $end = Get-Date
        $duration = ($end - $start).TotalSeconds
        $fileSize = (Get-Item $testFile).Length / 1MB
        $speed = [math]::Round($fileSize / $duration * 8, 2)
        
        Write-Host "Download Speed: $speed Mbps ($(($fileSize * 1024).ToString('F1')) KB file)" -ForegroundColor Green
        Remove-Item $testFile -ErrorAction SilentlyContinue
    }
    catch {
        Write-Host "Speed test failed: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Display public and private IP addresses
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

# List available WiFi networks and connect to specified network
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

# Check what process is using a specific port
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

# Network diagnostics combo - ping, traceroute, DNS lookup
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

# Show network adapter information
function netAdapters {
    Write-Host "Network Adapters:" -ForegroundColor Cyan
    Get-NetAdapter | Where-Object Status -eq "Up" | 
    Select-Object Name, InterfaceDescription, LinkSpeed | 
    Format-Table -AutoSize
}

# Quick ping test
function pingTest {
    param(
        [Parameter(Mandatory=$true)]
        [string]$target
    )
    
    Test-Connection -ComputerName $target -Count 1 -Quiet
}