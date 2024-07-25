# New VM - ISO Optional 

# Set CSV file path
$csvPath = "C:\Class\vmdummyuserdata.csv"

# Check if the file exists
if (-not (Test-Path $csvPath)) {
    Write-Host "CSV file not found at '$csvPath'"
    exit
}

# Import the CSV file
$vms = Import-Csv -Path $csvPath


# Loop through each row in the CSV and create only the first 5 VMs
$vms | ForEach-Object { #can select which objects by adding parameters in this line after '$vms'
	$vmName = $_.VMName
	$memoryStartupBytes = [int]$_.vmMemoryStartupBytes
	$memoryStartupMB = $memoryStartupBytes * 1MB # Convert MB to Bytes
	if(-not ($vmPath = $_.vmPath)){
		"This data could not be found in your csv file. Please check if it is missing or mispelled."
	}
	$switchName = $_.vmSwitch

	# Create the VM
	New-VM -Name $vmName -MemoryStartupBytes $memoryStartupMB -Path $vmPath -SwitchName $switchName

	#check if path for VHD is assigned
	if ($_.vhdPath) {
		$vhdPath = $_.vhdPath
	} else {
		$vhdPath = "$vmPath\$vmName.vhdx"
	}

	Write-Host “vhdPath is set to: $vhdPath”

	#assign vhdSize
	$vhdSizeGB = [int]$_.vhdSize
	$vhdSize = $vhdSizeGB * 1MB

	# Create a VHD for the VM
	New-VHD -Path $vhdPath -SizeBytes $vhdSize -Dynamic

	# Attach the VHD to the VM
	Add-VMHardDiskDrive -VMName $vmName -Path $vhdPath

	# Set DVD Drive with ISO if isoPath is provided 
	if ($vm.isoPath) {
		Add-VMDvdDrive -VMName $vmName -Path $Path 
	}

	Write-Host "Created VM: $vmName with ISO: $isoPath"
}