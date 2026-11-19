# Remove-Recall-Tasks - Hapus tugas terjadwal Recall

function Remove-Recall-Tasks {
    if (!$revert) {
        #remove recall tasks
        Write-Status -msg 'Removing Recall Scheduled Tasks...'
        #believe it or not to disable and remove these you need system priv
        #create another sub script for removal
        $code = @"
Get-ScheduledTask -TaskPath '*WindowsAI*' -ErrorAction SilentlyContinue | Disable-ScheduledTask -ErrorAction SilentlyContinue
Remove-Item "`$env:Systemroot\System32\Tasks\Microsoft\Windows\WindowsAI" -Recurse -Force -ErrorAction SilentlyContinue
`$initConfigID = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tree\Microsoft\Windows\WindowsAI\Recall\InitialConfiguration" -Name 'Id'
`$policyConfigID = Get-ItemPropertyValue -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tree\Microsoft\Windows\WindowsAI\Recall\PolicyConfiguration" -Name 'Id'
if(`$initConfigID -and `$policyConfigID){
Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tasks\`$initConfigID" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tasks\`$policyConfigID" -Recurse -Force -ErrorAction SilentlyContinue
}
Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tree\Microsoft\Windows\WindowsAI" -Force -Recurse -ErrorAction SilentlyContinue
Get-ScheduledTask -TaskName "*Office Actions Server*" -ErrorAction SilentlyContinue | Disable-ScheduledTask -ErrorAction SilentlyContinue
    Remove-Item "`$env:Systemroot\System32\Tasks\Microsoft\Office\Office Actions Server" -ErrorAction SilentlyContinue -Force
    `$officeConfigID = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tree\Microsoft\Office\Office Actions Server' -Name 'Id'
    if (`$officeConfigID) {
        Remove-Item "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tasks\`$officeConfigID" -Recurse -Force -ErrorAction SilentlyContinue
    }
    Remove-Item 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\TaskCache\Tree\Microsoft\Office\Office Actions Server' -Recurse -Force -ErrorAction SilentlyContinue
"@
        
        $subScript = "$($tempDir)RemoveRecallTasks.ps1"
        New-Item "$subScript" -Force | Out-Null
        Set-Content "$subScript" -Value $code -Force

        $command = "&`"$subScript`""
        Run-Trusted -command $command -psversion $psversion
        Start-Sleep 1
        
        #when just running this option alone the tasks will be remade so we need to at least ensure they are disabled
        $command = "
        Get-ScheduledTask -TaskName '*Office Actions Server*' -ErrorAction SilentlyContinue | Disable-ScheduledTask -ErrorAction SilentlyContinue
        Get-ScheduledTask -TaskPath '*WindowsAI*' | Disable-ScheduledTask -ErrorAction SilentlyContinue
        "
        Run-Trusted -command $command -psversion $psversion
        
    }
    
}
