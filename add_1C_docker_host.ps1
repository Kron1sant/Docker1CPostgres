if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "You need ba admin!"
    Read-Host
    Write-Host "Press any key..."
    break
}

$docker1c_ip = wsl -d docker-desktop -- /bin/sh -c "ip -4 addr |grep -E inet.+eth0 | sed -E 's/.+inet //; s/ brd.+//; s/\/\d+//'"
if ($docker1c_ip -notmatch "^\d{0,3}\.\d{0,3}\.\d{0,3}\.\d{0,3}") {
    Write-Warning "Docker IP address is wrong: $docker1c_ip"
    Read-Host
    Write-Host "Press any key..."
    break
}
$docker1c_host = "docker1c"
$new_hosts_record = $docker1c_ip + "`t" + $docker1c_host

$hosts_path="C:\Windows\System32\drivers\etc\hosts" 
Copy-Item $hosts_path hosts.bac
if (! $?) {
    Write-Warning "Wrong copy hosts.bac!"
    Read-Host
    Write-Host "Press any key..."
    break
}
Write-Host "Hosts file was backed up as 'hosts.bac' into a current dir"

((Get-Content -Path $hosts_path) -replace "^\s*\d{0,3}\.\d{0,3}\.\d{0,3}\.\d{0,3}\s+$docker1c_host", '# $0') + $new_hosts_record | Set-Content -Path $hosts_path -Force
if (! $?) {
    Copy-Item hosts.bac $hosts_path
    break
}
Write-Host "'$new_hosts_record' added to hosts file"
Write-Host "Press any key..."
Read-Host
