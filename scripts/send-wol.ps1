<#
.SYNOPSIS
    Sends a Wake-on-LAN magic packet over UDP broadcast.
.EXAMPLE
    .\send-wol.ps1 -MacAddress "00:11:22:33:44:55" -BroadcastIp "192.168.1.255"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$MacAddress,

    [Parameter(Mandatory = $false)]
    [string]$BroadcastIp = "255.255.255.255",

    [Parameter(Mandatory = $false)]
    [int]$Port = 9
)

$cleanMac = $MacAddress.Replace(":", "").Replace("-", "")
if ($cleanMac.Length -ne 12) {
    Write-Error "Invalid MAC address format: $MacAddress"
    exit 1
}

$mac = [Net.NetworkInformation.PhysicalAddress]::Parse($cleanMac)
$targetBytes = $mac.GetAddressBytes()
$packet = [byte[]](,0xFF * 6) + ($targetBytes * 16)

$client = New-Object System.Net.Sockets.UdpClient
try {
    $client.Connect([System.Net.IPAddress]::Parse($BroadcastIp), $Port)
    $client.Send($packet, $packet.Length) | Out-Null
    Write-Host "Magic packet successfully sent to $MacAddress via $BroadcastIp`:$Port"
} finally {
    $client.Close()
}
