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

# Define parameters for the domain and domain admin account
$DomainName = "autoclass.com"
$AdminUsername = "eddy.admin"
$AdminPassword = "P@5%w0rd!@33"
$SecureAdminPassword = ConvertTo-SecureString $AdminPassword -AsPlainText -Force
$SafeModeAdminPassword = $SecureAdminPassword

# Install the AD DS role
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# Import the ADDSDeployment module
Import-Module ADDSDeployment

# Promote this server to a secondary domain controller
Install-ADDSDomainController -DomainName $DomainName `
                             -Credential (New-Object PSCredential($AdminUsername, $SecureAdminPassword)) `
                             -SafeModeAdministratorPassword $SafeModeAdminPassword `
                             -InstallDNS `
                             -NoGlobalCatalog:$false `
                             -Force

# Wait for the installation to complete
Write-Output "The server is being promoted to a secondary domain controller. This process may take some time."

# Reboot the server to complete the installation
Restart-Computer -Force
