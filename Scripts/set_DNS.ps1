# Get the active network adapter
$adapter = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' }

# Check if an active adapter is found
if ($null -ne $adapter) {
    $adapterName = $adapter.Name
    Write-Output "Active network adapter: $adapterName"

    # Set the DNS server to 10.10.0.81
    Set-DnsClientServerAddress -InterfaceAlias $adapterName -ServerAddresses ("10.10.0.81")

    Write-Output "DNS server for adapter '$adapterName' set to 10.10.0.81"
} else {
    Write-Output "No active network adapter found."
}
