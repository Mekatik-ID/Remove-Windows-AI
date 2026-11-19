# Remove-AI-Appx-Packages - Hapus paket Appx AI

function Remove-AI-Appx-Packages {

    if ($revert) {

        #download appx packages from store
        $appxBackup = "$env:USERPROFILE\RemoveWindowsAI\Backup\AppxBackup"
        if (Test-Path $appxBackup) {
            $familyNames = Get-Content "$appxBackup\PackageFamilyNames.txt"
            foreach ($package in $familyNames) {
                Write-Status -msg "Attempting to Download $package..."
                $downloadedFiles = Download-AppxPackage -PackageFamilyName $package -outputDir $appxBackup
                $bundle = $downloadedFiles | Where-Object { $_ -match '\.appxbundle$' -or $_ -match '\.msixbundle$' } | Select-Object -First 1
                if ($bundle) {
                    Write-Status -msg "Installing $package..."
                    Add-AppPackage $bundle
                }
            }

            #cleanup
            Remove-Item "$appxBackup\*" -Recurse -Force -ErrorAction SilentlyContinue
        }
        else {
            Write-Status -msg 'Unable to Find AppxBackup in User Directory!' -errorOutput 
        }

    }
    else {

        #to make this part faster make a txt file in temp with chunck of removal 
        #code and then just run that from run 
        #trusted function due to the design of having it hidden from the user
        
        $packageRemovalPath = "$($tempDir)aiPackageRemoval.ps1"
        if (!(test-path $packageRemovalPath)) {
            New-Item $packageRemovalPath -Force | Out-Null
        }

        #needed for separate powershell sessions
        $aipackages = @(
            # 'MicrosoftWindows.Client.Photon'
            'MicrosoftWindows.Client.AIX'
            'MicrosoftWindows.Client.CoPilot'
            'Microsoft.Windows.Ai.Copilot.Provider'
            'Microsoft.Copilot'
            'Microsoft.MicrosoftOfficeHub'
            'MicrosoftWindows.Client.CoreAI'
            'Microsoft.Edge.GameAssist'
            'Microsoft.Office.ActionsServer'
            'aimgr'
            'Microsoft.WritingAssistant'
            #ai component packages installed on copilot+ pcs
            'MicrosoftWindows.*.Voiess'
            'MicrosoftWindows.*.Speion'
            'MicrosoftWindows.*.Livtop'
            'MicrosoftWindows.*.InpApp'
            'MicrosoftWindows.*.Filons'
            'WindowsWorkload.Data.Analysis.Stx.*'
            'WindowsWorkload.Manager.*'
            'WindowsWorkload.PSOnnxRuntime.Stx.*'
            'WindowsWorkload.PSTokenizer.Stx.*'
            'WindowsWorkload.QueryBlockList.*'
            'WindowsWorkload.QueryProcessor.Data.*'
            'WindowsWorkload.QueryProcessor.Stx.*'
            'WindowsWorkload.SemanticText.Data.*'
            'WindowsWorkload.SemanticText.Stx.*'
            'WindowsWorkload.Data.ContentExtraction.Stx.*'
            'WindowsWorkload.ScrRegDetection.Data.*'
            'WindowsWorkload.ScrRegDetection.Stx.*'
            'WindowsWorkload.TextRecognition.Stx.*'
            'WindowsWorkload.Data.ImageSearch.Stx.*'
            'WindowsWorkload.ImageContentModeration.*'
            'WindowsWorkload.ImageContentModeration.Data.*'
            'WindowsWorkload.ImageSearch.Data.*'
            'WindowsWorkload.ImageSearch.Stx.*'
            'WindowsWorkload.ImageSearch.Stx.*'
            'WindowsWorkload.ImageTextSearch.Data.*'
            'WindowsWorkload.PSOnnxRuntime.Stx.*'
            'WindowsWorkload.PSTokenizerShared.Data.*'
            'WindowsWorkload.PSTokenizerShared.Stx.*'
            'WindowsWorkload.ImageTextSearch.Stx.*'
            'WindowsWorkload.ImageTextSearch.Stx.*'
        )

        if ($backup) {

            #create file with package family names for reverting
            $appxBackup = "$env:USERPROFILE\RemoveWindowsAI\Backup\AppxBackup"
            if (!(Test-Path $appxBackup)) {
                New-Item $appxBackup -ItemType Directory -Force | Out-Null
            }

            $backuppath = New-Item $appxBackup -Name 'PackageFamilyNames.txt' -ItemType File -Force

            #daftar berisi wildcard (mis. WindowsWorkload.*), jadi cocokkan dengan -like, bukan -contains
            $familyNames = get-appxpackage -allusers | Where-Object { $n = $_.Name; @($aipackages | Where-Object { $n -like $_ }).Count -gt 0 }
            foreach ($familyName in $familyNames) {
                Add-Content -Path $backuppath.FullName -Value $familyName.PackageFamilyName 
            }

        }

        $code = @'
$aipackages = @(
    'MicrosoftWindows.Client.AIX'
    'MicrosoftWindows.Client.CoPilot'
    'Microsoft.Windows.Ai.Copilot.Provider'
    'Microsoft.Copilot'
    'Microsoft.MicrosoftOfficeHub'
    'MicrosoftWindows.Client.CoreAI'
    'Microsoft.Edge.GameAssist'
    'Microsoft.Office.ActionsServer'
    'aimgr'
    'Microsoft.WritingAssistant'
    'MicrosoftWindows.*.Voiess'
    'MicrosoftWindows.*.Speion'
    'MicrosoftWindows.*.Livtop'
    'MicrosoftWindows.*.InpApp'
    'MicrosoftWindows.*.Filons'
    'WindowsWorkload.Data.Analysis.Stx.*'
    'WindowsWorkload.Manager.*'
    'WindowsWorkload.PSOnnxRuntime.Stx.*'
    'WindowsWorkload.PSTokenizer.Stx.*'
    'WindowsWorkload.QueryBlockList.*'
    'WindowsWorkload.QueryProcessor.Data.*'
    'WindowsWorkload.QueryProcessor.Stx.*'
    'WindowsWorkload.SemanticText.Data.*'
    'WindowsWorkload.SemanticText.Stx.*'
    'WindowsWorkload.Data.ContentExtraction.Stx.*'
    'WindowsWorkload.ScrRegDetection.Data.*'
    'WindowsWorkload.ScrRegDetection.Stx.*'
    'WindowsWorkload.TextRecognition.Stx.*'
    'WindowsWorkload.Data.ImageSearch.Stx.*'
    'WindowsWorkload.ImageContentModeration.*'
    'WindowsWorkload.ImageContentModeration.Data.*'
    'WindowsWorkload.ImageSearch.Data.*'
    'WindowsWorkload.ImageSearch.Stx.*'
    'WindowsWorkload.ImageSearch.Stx.*'
    'WindowsWorkload.ImageTextSearch.Data.*'
    'WindowsWorkload.PSOnnxRuntime.Stx.*'
    'WindowsWorkload.PSTokenizerShared.Data.*'
    'WindowsWorkload.PSTokenizerShared.Stx.*'
    'WindowsWorkload.ImageTextSearch.Stx.*'
    'WindowsWorkload.ImageTextSearch.Stx.*'
)

$provisioned = get-appxprovisionedpackage -online 
$appxpackage = get-appxpackage -allusers
$store = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore'
$users = @('S-1-5-18'); if (test-path $store) { $users += $((Get-ChildItem $store -ea 0 | Where-Object { $_ -like '*S-1-5-21*' }).PSChildName) }

#use eol trick to uninstall some locked packages
foreach ($choice in $aipackages) {
    foreach ($appx in $($provisioned | Where-Object { $_.PackageName -like "*$choice*" })) {

        $PackageName = $appx.PackageName 
        $PackageFamilyName = ($appxpackage | Where-Object { $_.Name -eq $appx.DisplayName }).PackageFamilyName
        New-Item "$store\Deprovisioned\$PackageFamilyName" -force
     
        Set-NonRemovableAppsPolicy -Online -PackageFamilyName $PackageFamilyName -NonRemovable 0
       
        foreach ($sid in $users) { 
            New-Item "$store\EndOfLife\$sid\$PackageName" -force
        }  
        remove-appxprovisionedpackage -packagename $PackageName -online -allusers
    }
    foreach ($appx in $($appxpackage | Where-Object { $_.PackageFullName -like "*$choice*" })) {

        $PackageFullName = $appx.PackageFullName
        $PackageFamilyName = $appx.PackageFamilyName
        New-Item "$store\Deprovisioned\$PackageFamilyName" -force
        Set-NonRemovableAppsPolicy -Online -PackageFamilyName $PackageFamilyName -NonRemovable 0
       
        #remove inbox apps
        $inboxApp = "$store\InboxApplications\$PackageFullName"
        Remove-Item -Path $inboxApp -Force
       
        #get all installed user sids for package due to not all showing up in reg
        foreach ($user in $appx.PackageUserInformation) { 
            $sid = $user.UserSecurityID.SID
            if ($users -notcontains $sid) {
                $users += $sid
            }
            New-Item "$store\EndOfLife\$sid\$PackageFullName" -force
            remove-appxpackage -package $PackageFullName -User $sid 
        } 
        remove-appxpackage -package $PackageFullName -allusers
    }
}
'@
        Set-Content -Path $packageRemovalPath -Value $code -Force 
        #simpan kebijakan LocalMachine asli SEBELUM diubah, supaya bisa dikembalikan saat selesai
        $Global:ogMachinePolicyCaptured = $true
        $Global:ogMachinePolicyValue = try { Get-ItemPropertyValue -Path 'HKLM:\Software\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell' -Name 'ExecutionPolicy' -ErrorAction Stop } catch { $null }
        #allow removal script to run
        try {
            Set-ExecutionPolicy Unrestricted -Force -ErrorAction Stop
        }
        catch {
            #user has set powershell execution policy via group policy or via settings, to change it we need to update the registry 
            try {
                $Global:ogExecutionPolicy = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell' -Name 'ExecutionPolicy' -ErrorAction Stop
                Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell' /v 'EnableScripts' /t REG_DWORD /d '1' /f >$null
                Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell' /v 'ExecutionPolicy' /t REG_SZ /d 'Unrestricted' /f >$null
                $Global:executionPolicyUser = $false
                $Global:executionPolicyMachine = $false
                $Global:executionPolicyWow64 = $false
                $Global:executionPolicyUserPol = $false
            }
            catch {
                try {
                    $Global:ogExecutionPolicy = Get-ItemPropertyValue -Path 'HKCU:\Software\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell' -Name 'ExecutionPolicy' -ErrorAction Stop
                    Reg.exe add 'HKCU\Software\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell' /v 'ExecutionPolicy' /t REG_SZ /d 'Unrestricted' /f >$null
                    $Global:executionPolicyUser = $true
                    $Global:executionPolicyMachine = $false
                    $Global:executionPolicyWow64 = $false
                    $Global:executionPolicyUserPol = $false
                }
                catch {
                    try {
                        $Global:ogExecutionPolicy = Get-ItemPropertyValue -Path 'HKLM:\Software\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell' -Name 'ExecutionPolicy' -ErrorAction Stop
                        Reg.exe add 'HKLM\Software\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell' /v 'ExecutionPolicy' /t REG_SZ /d 'Unrestricted' /f >$null
                        $Global:executionPolicyUser = $false
                        $Global:executionPolicyMachine = $true
                        $Global:executionPolicyWow64 = $false
                        $Global:executionPolicyUserPol = $false
                    }
                    catch {
                        try {
                            $Global:ogExecutionPolicy = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell' -Name 'ExecutionPolicy' -ErrorAction Stop
                            Reg.exe add 'HKLM\SOFTWARE\Wow6432Node\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell' /v 'ExecutionPolicy' /t REG_SZ /d 'Unrestricted' /f >$null
                            $Global:executionPolicyUser = $false
                            $Global:executionPolicyMachine = $false
                            $Global:executionPolicyWow64 = $true
                            $Global:executionPolicyUserPol = $false

                        }
                        catch {
                            $Global:ogExecutionPolicy = Get-ItemPropertyValue -Path 'HKCU:\SOFTWARE\Policies\Microsoft\Windows\PowerShell' -Name 'ExecutionPolicy' 
                            Reg.exe add 'HKCU\SOFTWARE\Policies\Microsoft\Windows\PowerShell' /v 'EnableScripts' /t REG_DWORD /d '1' /f >$null
                            Reg.exe add 'HKCU\SOFTWARE\Policies\Microsoft\Windows\PowerShell' /v 'ExecutionPolicy' /t REG_SZ /d 'Unrestricted' /f >$null
                            $Global:executionPolicyUser = $false
                            $Global:executionPolicyMachine = $false
                            $Global:executionPolicyWow64 = $false
                            $Global:executionPolicyUserPol = $true
                        }
                        

                    }
                    
                }
               
            }
            
           
        }


        Write-Status -msg 'Removing AI Appx Packages...'
        $command = "&`"$($tempDir)aiPackageRemoval.ps1`""
        Run-Trusted -command $command -psversion $psversion

        #check packages removal
        #exit loop after 10 tries
        $attempts = 0
        do {
            Start-Sleep 1
            $packages = get-appxpackage -AllUsers | Where-Object { $n = $_.Name; @($aipackages | Where-Object { $n -like $_ }).Count -gt 0 }
            if ($packages) {
                $attempts++
                if ($EnableLogging) {
                    $Global:logInfo.Line = "Attempting to Remove Appx Packages, Attempt: $attempts"
                    $Global:logInfo.Result = "Found Packages: $packages"
                    Add-LogInfo -logPath $logPath -info $Global:logInfo
                }
                $command = "&`"$($tempDir)aiPackageRemoval.ps1`""
                Run-Trusted -command $command -psversion $psversion
            }
    
        }while ($packages -and $attempts -lt 10)

        if ($EnableLogging) {
            if ($attempts -ge 10) {
                Write-Status -msg 'Packages Removal Failed...' -errorOutput 
                $Global:logInfo.Line = 'Removing Appx Packages'
                $Global:logInfo.Result = "Removal Failed, Reached Max Attempts (10)... Leftover Packages: $packages"
                Add-LogInfo -logPath $logPath -info $Global:logInfo
            }
            else {
                Write-Status -msg 'Packages Removed Sucessfully...'
                $Global:logInfo.Line = 'Removing Appx Packages'
                $Global:logInfo.Result = 'Removal Success'
                Add-LogInfo -logPath $logPath -info $Global:logInfo
            }
        }
        else {
            if ($attempts -ge 10) {
                Write-Status -msg 'Packages Removal Failed...' -errorOutput 
                Write-Status -msg 'Use the Enable Logging Switch to Get More Info...'
            }
            else {
                Write-Status -msg 'Packages Removed Sucessfully...'
            }
        
        }

        #tell windows copilot pwa is already installed
        Reg.exe add 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoInstalledPWAs' /v 'CopilotPWAPreinstallCompleted' /t REG_DWORD /d '1' /f *>$null
        Reg.exe add 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoInstalledPWAs' /v 'Microsoft.Copilot_8wekyb3d8bbwe' /t REG_DWORD /d '1' /f *>$null
        #incase the user is on 25h2 and is using education or enterprise (required for this policy to work)
        #uninstalls copilot with group policy (will ensure it doesnt get reinstalled)
        Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Appx\RemoveDefaultMicrosoftStorePackages' /v 'Enabled' /t REG_DWORD /d '1' /f *>$null
        Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Appx\RemoveDefaultMicrosoftStorePackages\Microsoft.Copilot_8wekyb3d8bbwe' /v 'RemovePackage' /t REG_DWORD /d '1' /f *>$null
        Reg.exe add 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Appx\RemoveDefaultMicrosoftStorePackages\Microsoft.MicrosoftOfficeHub_8wekyb3d8bbwe' /v 'RemovePackage' /t REG_DWORD /d '1' /f *>$null

        ## undo eol unblock trick to prevent latest cumulative update (LCU) failing 
        #  $eolPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\EndOfLife'
        #  $eolKeys = (Get-ChildItem $eolPath).Name
        #  foreach ($path in $eolKeys) {
        #      Remove-Item "registry::$path" -Recurse -Force -ErrorAction SilentlyContinue
        #  }
    }

}
