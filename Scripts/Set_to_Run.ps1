# Define task parameters
$taskName = "RunADDS_AutoOnce"
$scriptPath = "C:\ADDS\ADDS_Auto.ps1"
$taskAction = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-File `"$scriptPath`""
$taskTrigger = New-ScheduledTaskTrigger -AtStartup
$taskPrincipal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$taskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -AllowHardTerminate -AllowStartOnDemand

# Register the task with history enabled
Register-ScheduledTask -TaskName $taskName -Action $taskAction -Trigger $taskTrigger -Principal $taskPrincipal -Settings $taskSettings

# Enable history for the task
$taskHistory = Get-ScheduledTask -TaskName $taskName | Set-ScheduledTask -History
$taskHistory | Set-ScheduledTask -History

# Define the script to delete the task after execution
$deleteTaskScript = @"
# Check if the task exists
$taskName = "RunADDS_AutoOnce"
if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
    # Run the task
    Start-ScheduledTask -TaskName $taskName

    # Wait for the task to finish
    Start-Sleep -Seconds 60  # Adjust the sleep time as necessary

    # Unregister the task
    Unregister-ScheduledTask -TaskName $taskName -Force
}
"@

# Write the delete task script to a file
$deleteTaskScriptPath = "C:\ADDS\DeleteTaskAfterRun.ps1"
$deleteTaskScript | Out-File -FilePath $deleteTaskScriptPath -Encoding UTF8

# Schedule the deletion script to run after the task has completed
$deleteTaskAction = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-File `"$deleteTaskScriptPath`""
$deleteTaskTrigger = New-ScheduledTaskTrigger -AtStartup
$deleteTaskPrincipal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$deleteTaskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -AllowHardTerminate

Register-ScheduledTask -TaskName "DeleteTaskAfterRun" -Action $deleteTaskAction -Trigger $deleteTaskTrigger -Principal $deleteTaskPrincipal -Settings $deleteTaskSettings

Write-Output "Scheduled task created to run ADDS_Auto.ps1 on boot and delete itself after running."
