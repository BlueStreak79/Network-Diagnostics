# ==============================
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