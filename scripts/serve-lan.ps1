# Start the game as a web page for phones on the same Wi-Fi.
# Usage (normal PowerShell, in the repo folder):  .\scripts\serve-lan.ps1
# One-time setup (admin PowerShell) so the phone is allowed through the firewall:
#   New-NetFirewallRule -DisplayName "sanguo-cards LAN" -Direction Inbound -Protocol TCP -LocalPort 8766 -RemoteAddress LocalSubnet -Profile Private -Action Allow
param([int]$Port = 8766)

# the LAN address = the adapter that has a default gateway (your Wi-Fi / Ethernet)
$ip = (Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway -and $_.NetAdapter.Status -eq "Up" } |
       Select-Object -First 1).IPv4Address.IPAddress
if (-not $ip) { Write-Error "找不到局域网 IP，确认电脑已连上 Wi-Fi"; exit 1 }

Write-Host ""
Write-Host "  手机浏览器打开:  http://${ip}:$Port" -ForegroundColor Yellow
Write-Host "  （手机要连同一个 Wi-Fi；关掉这个窗口或按 Ctrl+C 停止）"
Write-Host ""
$env:PYTHONIOENCODING = "utf-8"
textual serve -c -h $ip -p $Port -u "http://${ip}:$Port" -t "三国卡牌" "python -m sanguo"
