# ==============================
# Blue's Network Doctor Toolkit
# Technician Grade Repair Utility
# ==============================

# Auto Elevation
If (-NOT ([Security.Principal.WindowsPrincipal]
[Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
[Security.Principal.WindowsBuiltInRole] "Administrator")) {

    Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# Create Logs Folder
$LogFolder = "$PSScriptRoot\logs"
If (!(Test-Path $LogFolder)) {
    New-Item -ItemType Directory -Path $LogFolder | Out-Null
}

$LogFile = "$LogFolder\NetworkDoctor_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
Start-Transcript -Path $LogFile

function Header {
    Clear-Host
    Write-Host "=========================================" -ForegroundColor Cyan
    Write-Host "        NETWORK DOCTOR TOOLKIT         " -ForegroundColor Green
    Write-Host "=========================================" -ForegroundColor Cyan
}

function PauseScreen {
    Write-Host ""
    Read-Host "Press ENTER to continue"
}

function Reset-Winsock {
    Write-Host "Resetting Winsock..."
    netsh winsock reset
}

function Reset-IPStack {
    Write-Host "Resetting TCP/IP Stack..."
    netsh int ip reset
    netsh interface ipv4 reset
    netsh interface ipv6 reset
}

function Flush-DNS {
    Write-Host "Flushing DNS..."
    ipconfig /flushdns
}

function Renew-IP {
    Write-Host "Releasing IP..."
    ipconfig /release

    Write-Host "Renewing IP..."
    ipconfig /renew
}

function Reset-Proxy {
    Write-Host "Resetting Proxy..."
    netsh winhttp reset proxy
}

function Reset-Firewall {
    Write-Host "Resetting Firewall..."
    netsh advfirewall reset
}

function Clear-ARP {
    Write-Host "Clearing ARP Cache..."
    netsh interface ip delete arpcache
}

function Reset-Routes {
    Write-Host "Resetting Routing Table..."
    route -f
}

function Restart-NetworkAdapters {
    Write-Host "Restarting Network Adapters..."
    Get-NetAdapter | Restart-NetAdapter -Confirm:$false
}

function Full-NetworkReset {
    Write-Host "Performing Full Network Stack Rebuild..."
    netcfg -d
}

function Set-GoogleDNS {
    $adapter = Get-NetAdapter | Where-Object {$_.Status -eq "Up"} | Select-Object -First 1

    Set-DnsClientServerAddress -InterfaceAlias $adapter.Name `
    -ServerAddresses ("8.8.8.8","8.8.4.4")

    Write-Host "Google DNS Applied"
}

function Set-CloudflareDNS {
    $adapter = Get-NetAdapter | Where-Object {$_.Status -eq "Up"} | Select-Object -First 1

    Set-DnsClientServerAddress -InterfaceAlias $adapter.Name `
    -ServerAddresses ("1.1.1.1","1.0.0.1")

    Write-Host "Cloudflare DNS Applied"
}

function Set-Quad9DNS {
    $adapter = Get-NetAdapter | Where-Object {$_.Status -eq "Up"} | Select-Object -First 1

    Set-DnsClientServerAddress -InterfaceAlias $adapter.Name `
    -ServerAddresses ("9.9.9.9","149.112.112.112")

    Write-Host "Quad9 DNS Applied"
}

function Restore-DHCPDNS {
    $adapter = Get-NetAdapter | Where-Object {$_.Status -eq "Up"} | Select-Object -First 1

    Set-DnsClientServerAddress -InterfaceAlias $adapter.Name -ResetServerAddresses

    Write-Host "DHCP DNS Restored"
}

function Show-WifiProfiles {
    netsh wlan show profiles
}

function Delete-AllWifiProfiles {
    netsh wlan delete profile name=*
}

function Delete-SingleWifiProfile {
    $name = Read-Host "Enter Wi-Fi Profile Name"
    netsh wlan delete profile name="$name"
}

function Run-SFC {
    sfc /scannow
}

function Run-DISM {
    DISM /Online /Cleanup-Image /RestoreHealth
}

function TCP-Optimization {
    Write-Host "Applying TCP Optimizations..."

    netsh int tcp set global autotuninglevel=disabled
    netsh int tcp set global rss=enabled
    netsh int tcp set global chimney=enabled

    netsh int tcp set supplemental template=internet congestionprovider=ctcp

    Write-Host "Optimization Applied"
}

function Connectivity-Test {
    Test-NetConnection google.com
}

function Ping-Test {
    $hostName = Read-Host "Enter Host"
    ping $hostName
}

function Trace-Test {
    $hostName = Read-Host "Enter Host"
    tracert $hostName
}

function DNS-Lookup {
    $hostName = Read-Host "Enter Domain"
    nslookup $hostName
}

function Public-IP {
    try {
        (Invoke-WebRequest -Uri "https://api.ipify.org").Content
    }
    catch {
        Write-Host "Unable to fetch public IP"
    }
}

function Adapter-Info {
    Get-NetAdapter
}

function Speed-Test {

    $SpeedTestEXE = "$PSScriptRoot\tools\speedtest.exe"

    if (Test-Path $SpeedTestEXE) {
        & $SpeedTestEXE
    }
    else {
        Write-Host "Speedtest CLI not found!"
        Write-Host "Place speedtest.exe inside tools folder"
    }
}

function Full-Repair {

    Reset-Winsock
    Reset-IPStack
    Flush-DNS
    Renew-IP
    Reset-Proxy
    Reset-Firewall
    Clear-ARP
    Reset-Routes
    Restart-NetworkAdapters

    Write-Host ""
    Write-Host "Full Repair Completed"
}

function MainMenu {

    do {

        Header

        Write-Host "1  - Full Network Repair"
        Write-Host "2  - Winsock Reset"
        Write-Host "3  - TCP/IP Reset"
        Write-Host "4  - Flush DNS"
        Write-Host "5  - Renew DHCP"
        Write-Host "6  - Firewall Reset"
        Write-Host "7  - Proxy Reset"
        Write-Host "8  - Restart Adapters"
        Write-Host "9  - Full Network Stack Reset"
        Write-Host "10 - Google DNS"
        Write-Host "11 - Cloudflare DNS"
        Write-Host "12 - Quad9 DNS"
        Write-Host "13 - Restore DHCP DNS"
        Write-Host "14 - Show Wi-Fi Profiles"
        Write-Host "15 - Delete All Wi-Fi Profiles"
        Write-Host "16 - Delete Single Wi-Fi Profile"
        Write-Host "17 - Run SFC"
        Write-Host "18 - Run DISM"
        Write-Host "19 - TCP Optimization"
        Write-Host "20 - Connectivity Test"
        Write-Host "21 - Ping Test"
        Write-Host "22 - Trace Route"
        Write-Host "23 - DNS Lookup"
        Write-Host "24 - Public IP"
        Write-Host "25 - Adapter Information"
        Write-Host "26 - Ookla Speed Test"
        Write-Host "0  - Exit"

        Write-Host ""
        $choice = Read-Host "Select Option"

        switch ($choice) {

            1  { Full-Repair }
            2  { Reset-Winsock }
            3  { Reset-IPStack }
            4  { Flush-DNS }
            5  { Renew-IP }
            6  { Reset-Firewall }
            7  { Reset-Proxy }
            8  { Restart-NetworkAdapters }
            9  { Full-NetworkReset }
            10 { Set-GoogleDNS }
            11 { Set-CloudflareDNS }
            12 { Set-Quad9DNS }
            13 { Restore-DHCPDNS }
            14 { Show-WifiProfiles }
            15 { Delete-AllWifiProfiles }
            16 { Delete-SingleWifiProfile }
            17 { Run-SFC }
            18 { Run-DISM }
            19 { TCP-Optimization }
            20 { Connectivity-Test }
            21 { Ping-Test }
            22 { Trace-Test }
            23 { DNS-Lookup }
            24 { Public-IP }
            25 { Adapter-Info }
            26 { Speed-Test }
            0  {
                Stop-Transcript
                Exit
            }

            default {
                Write-Host "Invalid Selection"
            }
        }

        PauseScreen

    } while ($true)
}

MainMenu
