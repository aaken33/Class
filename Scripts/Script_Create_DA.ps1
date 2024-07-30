# Define the path to the new script file
$newScriptPath = "C:\adds\domain_user.ps1"  # Replace with the desired path

# Define the content of the new script
$scriptContent = @'
# Define parameters for the new forest
$DomainName = "AutoClass.com"

# Define parameters for the new domain admin account
$AdminUsername = "Eddy.Admin"
$AdminPassword = "SecureP@ssw0rd!"  # Replace with a secure password
$SecureAdminPassword = (ConvertTo-SecureString $AdminPassword -AsPlainText -Force)

# Create a new domain admin account
New-ADUser -Name $AdminUsername `
           -GivenName "Eddy" `
           -Surname "Admin" `
           -SamAccountName $AdminUsername `
           -UserPrincipalName "$AdminUsername@$DomainName" `
           -Path "CN=Users,DC=$(($DomainName -split '\.')[0]),DC=$(($DomainName -split '\.')[1])" `
           -AccountPassword $SecureAdminPassword `
           -Enabled $true

# Add the new account to the Domain Admins group
Add-ADGroupMember -Identity "Domain Admins" -Members $AdminUsername

Write-Output "Created domain admin account: $AdminUsername"
'@

# Write the content to the new script file
$scriptContent | Out-File -FilePath $newScriptPath -Encoding UTF8