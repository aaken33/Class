# New VM - ISO Optional 
#Version #1 2024-07-24
#-------------------------------------------

# Set CSV file path
$csvPath = "C:\Users\Patrick\Downloads\0724vmCSV.csv"

# Check if the file exists
if (-not (Test-Path $csvPath)) {
    Write-Host "CSV file not found at '$csvPath. Please make sure the filepath is correct."
    exit
}

# Import the CSV file
$vms = Import-Csv -Path $csvPath


# Loop through each row in the CSV and create the VMs
$vms | ForEach-Object { #can select which objects by adding parameters in this line after '$vms'
	$vmName = $_.VMName
		Write-Host "Creating VM named : $vmName."
	$memoryStartupBytes = [int]$_.vmMemoryStartupBytes
		Write-Host "--MemoryStartupBytes: $memoryStartupBytes"
	$memoryStartupMB = $memoryStartupBytes * 1MB # Convert MB to Bytes
		Write-Host "--MemoryStartupMB: $memoryStartupMB"
	if(-not ($vmPath = $_.vmPath)){
		Write-Host "+-The 'vmPath' could not be found in your csv file. Please check if it is missing or mispelled."
	}else{
		Write-Host "--vmPath: $vmPath"
	}
	$switchName = $_.vmSwitch
		Write-Host "--Switch: $switchName"

	$vmGen = $_.vmGeneration
		Write-Host "--Generation: $vmGen"

	$vhdPath = $_.vhdPath
		Write-Host "--vhdPath: $vhdPath"

	# Create the VM
	New-VM -Name $vmName -MemoryStartupBytes $memoryStartupMB -SwitchName $switchName -Generation $vmGen -vhdPath $_.vhdPath
		Write-Host "Created VM: $vmName"

	#check if path for VHD is assigned
	#if ($_.vhdPath) {
		$vhdPath = $_.vhdPath
	#} else {
		#$vhdPath = "$vmPath\$vmName.vhdx"
	#}

	Write-Host “vhdPath is set to: $vhdPath”

	#assign vhdSize
	$vhdSizeGB = [int]$_.vhdSize
	$vhdSize = $vhdSizeGB * 1MB

	# Create a VHD for the VM
	#New-VHD -Path $vhdPath -SizeBytes $vhdSize -Dynamic

	# Attach the VHD to the VM
	#Add-VMHardDiskDrive -VMName $vmName -Path $vhdPath

	# Set DVD Drive with ISO if isoPath is provided 
	if ($vm.isoPath) {
		Add-VMDvdDrive -VMName $vmName -Path $Path 
		Write-Host "with ISO: $isoPath"
	}

	Start-VM -Name $vmName
}
