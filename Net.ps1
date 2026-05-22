# =========================================
# Blue's Network Doctor Toolkit
# Technician Grade Repair Utility
# =========================================

# ==============================
# AUTO ELEVATION
# ==============================

$currentUser = New-Object Security.Principal.WindowsPrincipal(
    [Security.Principal.WindowsIdentity]::GetCurrent()
)

if (-not $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {

    Write-Host ""
    Write-Host "Restarting as Administrator..." -ForegroundColor Yellow
    Write-Host ""

    Start-Process powershell "-NoProfile -ExecutionPolicy Bypass -Command `"irm https://raw.githubusercontent.com/YOURUSERNAME/YOURREPO/main/Net.ps1 | iex`"" -Verb RunAs

    exit
}

# ==============================
# VARIABLES
# ==============================

$ToolkitName = "Blue's Network Doctor Toolkit"

$BaseFolder = "$env:TEMP\BlueNetworkDoctor"
$LogFolder = "$BaseFolder\Logs"
$ToolsFolder = "$BaseFolder\Tools"

$SpeedTestFolder = "$ToolsFolder\Speedtest"
$SpeedTestZIP = "$ToolsFolder\speedtest.zip"

$SpeedTestEXE = "$SpeedTestFolder\speedtest.exe"

# ==============================
# CREATE FOLDERS
# ==============================

foreach ($folder in @(
    $BaseFolder,
    $LogFolder,
    $ToolsFolder,
    $SpeedTestFolder
)) {

    if (!(Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder | Out-Null
    }
}

# ==============================
# LOGGING
# ==============================

$LogFile = "$LogFolder\NetworkDoctor_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

Start-Transcript -Path $LogFile -Force

# ==============================
# UI
# ==============================

function Header {

    Clear-Host

    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "         $ToolkitName" -ForegroundColor Cyan
    Write-Host "==================================================" -ForegroundColor Cyan

    Write-Host ""
}

function PauseScreen {

    Write-Host ""
    Read-Host "Press ENTER to continue"
}

# ==============================
# CORE REPAIR FUNCTIONS
# ==============================

function Reset-Winsock {

    Write-Host "Resetting Winsock..." -ForegroundColor Yellow
    netsh winsock reset
}

function Reset-IPStack {

    Write-Host "Resetting TCP/IP Stack..." -ForegroundColor Yellow

    netsh int ip reset
    netsh interface ipv4 reset
    netsh interface ipv6 reset
}

function Flush-DNS {

    Write-Host "Flushing DNS..." -ForegroundColor Yellow
    ipconfig /flushdns
}

function Renew-IP {

    Write-Host "Releasing DHCP Lease..." -ForegroundColor Yellow
    ipconfig /release

    Write-Host "Renewing DHCP Lease..." -ForegroundColor Yellow
    ipconfig /renew
}

function Reset-Proxy {

    Write-Host "Resetting Proxy..." -ForegroundColor Yellow
    netsh winhttp reset proxy
}

function Reset-Firewall {

    Write-Host "Resetting Windows Firewall..." -ForegroundColor Yellow
    netsh advfirewall reset
}

function Clear-ARP {

    Write-Host "Clearing ARP Cache..." -ForegroundColor Yellow
    netsh interface ip delete arpcache
}

function Reset-Routes {

    Write-Host "Resetting Routing Table..." -ForegroundColor Yellow
    route -f
}

function Restart-NetworkAdapters {

    Write-Host "Restarting Network Adapters..." -ForegroundColor Yellow

    Get-NetAdapter | Restart-NetAdapter -Confirm:$false
}

function Full-NetworkReset {

    Write-Host ""
    Write-Host "WARNING:" -ForegroundColor Red
    Write-Host "This will remove and reinstall ALL network adapters." -ForegroundColor Red
    Write-Host ""

    $confirm = Read-Host "Continue? (Y/N)"

    if ($confirm -eq "Y") {

        netcfg -d

        Write-Host ""
        Write-Host "Network stack rebuild completed." -ForegroundColor Green
        Write-Host "A reboot is recommended." -ForegroundColor Yellow
    }
}

# ==============================
# DNS FUNCTIONS
# ==============================

function Get-ActiveAdapter {

    return Get-NetAdapter |
    Where-Object { $_.Status -eq "Up" } |
    Select-Object -First 1
}

function Set-GoogleDNS {

    $adapter = Get-ActiveAdapter

    Set-DnsClientServerAddress `
    -InterfaceAlias $adapter.Name `
    -ServerAddresses ("8.8.8.8","8.8.4.4")

    Write-Host "Google DNS Applied" -ForegroundColor Green
}

function Set-CloudflareDNS {

    $adapter = Get-ActiveAdapter

    Set-DnsClientServerAddress `
    -InterfaceAlias $adapter.Name `
    -ServerAddresses ("1.1.1.1","1.0.0.1")

    Write-Host "Cloudflare DNS Applied" -ForegroundColor Green
}

function Set-Quad9DNS {

    $adapter = Get-ActiveAdapter

    Set-DnsClientServerAddress `
    -InterfaceAlias $adapter.Name `
    -ServerAddresses ("9.9.9.9","149.112.112.112")

    Write-Host "Quad9 DNS Applied" -ForegroundColor Green
}

function Restore-DHCPDNS {

    $adapter = Get-ActiveAdapter

    Set-DnsClientServerAddress `
    -InterfaceAlias $adapter.Name `
    -ResetServerAddresses

    Write-Host "DHCP DNS Restored" -ForegroundColor Green
}

# ==============================
# WIFI FUNCTIONS
# ==============================

function Show-WifiProfiles {

    netsh wlan show profiles
}

function Delete-AllWifiProfiles {

    Write-Host ""
    Write-Host "WARNING: This removes ALL saved Wi-Fi profiles." -ForegroundColor Red

    $confirm = Read-Host "Continue? (Y/N)"

    if ($confirm -eq "Y") {

        netsh wlan delete profile name=*
    }
}

function Delete-SingleWifiProfile {

    $name = Read-Host "Enter Wi-Fi Profile Name"

    netsh wlan delete profile name="$name"
}

# ==============================
# SYSTEM REPAIR
# ==============================

function Run-SFC {

    Write-Host "Running System File Checker..." -ForegroundColor Yellow
    sfc /scannow
}

function Run-DISM {

    Write-Host "Running DISM RestoreHealth..." -ForegroundColor Yellow

    DISM /Online /Cleanup-Image /RestoreHealth
}

# ==============================
# TCP OPTIMIZATION
# ==============================

function TCP-Optimization {

    Write-Host "Applying TCP Optimizations..." -ForegroundColor Yellow

    netsh int tcp set global autotuninglevel=disabled
    netsh int tcp set global rss=enabled
    netsh int tcp set global chimney=enabled

    netsh int tcp set supplemental template=internet congestionprovider=ctcp

    Write-Host "Optimization Applied" -ForegroundColor Green
}

# ==============================
# DIAGNOSTICS
# ==============================

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

        $ip = (Invoke-WebRequest -Uri "https://api.ipify.org").Content

        Write-Host ""
        Write-Host "Public IP: $ip" -ForegroundColor Green
    }

    catch {

        Write-Host "Unable to fetch public IP" -ForegroundColor Red
    }
}

function Adapter-Info {

    Get-NetAdapter
}

# ==============================
# OOKLA SPEEDTEST
# ==============================

function Install-SpeedtestCLI {

    if (Test-Path $SpeedTestEXE) {

        return
    }

    Write-Host ""
    Write-Host "Downloading Ookla Speedtest CLI..." -ForegroundColor Cyan

    $DownloadURL = "https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-win64.zip"

    try {

        Invoke-WebRequest `
        -Uri $DownloadURL `
        -OutFile $SpeedTestZIP `
        -UseBasicParsing

        Write-Host "Extracting Speedtest CLI..." -ForegroundColor Cyan

        Expand-Archive `
        -Path $SpeedTestZIP `
        -DestinationPath $SpeedTestFolder `
        -Force

        Remove-Item $SpeedTestZIP -Force

        Write-Host "Speedtest CLI Installed" -ForegroundColor Green
    }

    catch {

        Write-Host ""
        Write-Host "Failed to download Speedtest CLI" -ForegroundColor Red
    }
}

function Speed-Test {

    Install-SpeedtestCLI

    if (!(Test-Path $SpeedTestEXE)) {

        Write-Host "Speedtest executable missing." -ForegroundColor Red
        return
    }

    Write-Host ""
    Write-Host "Launching Speed Test..." -ForegroundColor Green
    Write-Host ""

    & $SpeedTestEXE `
    --accept-license `
    --accept-gdpr
}

function Speed-TestJSON {

    Install-SpeedtestCLI

    $JSONPath = "$LogFolder\SpeedTest_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"

    & $SpeedTestEXE `
    --accept-license `
    --accept-gdpr `
    --format=json `
    > $JSONPath

    Write-Host ""
    Write-Host "JSON Report Saved:" -ForegroundColor Green
    Write-Host $JSONPath
}

# ==============================
# FULL REPAIR
# ==============================

function Full-Repair {

    Header

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
    Write-Host "Full Repair Completed" -ForegroundColor Green
}

# ==============================
# MENU
# ==============================

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
        Write-Host "27 - Speed Test JSON Export"
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
            27 { Speed-TestJSON }

            0  {

                Stop-Transcript

                Write-Host ""
                Write-Host "Logs Saved To:" -ForegroundColor Green
                Write-Host $LogFile

                exit
            }

            default {

                Write-Host ""
                Write-Host "Invalid Selection" -ForegroundColor Red
            }
        }

        PauseScreen

    } while ($true)
}

# ==============================
# START
# ==============================

MainMenu
