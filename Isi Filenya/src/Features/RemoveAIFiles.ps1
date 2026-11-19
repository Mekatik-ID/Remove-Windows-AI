# Remove-AI-Files - Bersihkan file AI

function Remove-AI-Files {
    #prob add params here for each file removal 


    if ($revert) {
        if (Test-Path "$env:USERPROFILE\RemoveWindowsAI\Backup\AIFiles") {
            Write-Status -msg 'Restoring Appx Package Files...'
            $paths = Get-Content "$env:USERPROFILE\RemoveWindowsAI\Backup\AIFiles\backupPaths.txt"
            foreach ($path in $paths) {
                $fileName = Split-Path $path -Leaf
                $dest = Split-Path $path -Parent
                try {
                    Move-Item -Path "$env:USERPROFILE\RemoveWindowsAI\Backup\AIFiles\$fileName" -Destination $dest -Force -ErrorAction Stop
                }
                catch {
                    $command = "Move-Item -Path `"$env:USERPROFILE\RemoveWindowsAI\Backup\AIFiles\$fileName`" -Destination `"$dest`" -Force"
                    Run-Trusted -command $command -psversion $psversion
                    Start-Sleep 1
                }
            }

            if (Test-Path "$env:USERPROFILE\RemoveWindowsAI\Backup\AIFiles\OfficeAI") {
                Write-Status -msg 'Restoring Office AI Files...'
                Move-Item "$env:USERPROFILE\RemoveWindowsAI\Backup\AIFiles\OfficeAI\x64\AI" -Destination "$env:ProgramFiles\Microsoft Office\root\vfs\ProgramFilesCommonX64\Microsoft Shared\Office16" -Force 
                Move-Item "$env:USERPROFILE\RemoveWindowsAI\Backup\AIFiles\OfficeAI\x86\AI" -Destination "$env:ProgramFiles\Microsoft Office\root\vfs\ProgramFilesCommonX86\Microsoft Shared\Office16" -Force 
                Move-Item "$env:USERPROFILE\RemoveWindowsAI\Backup\AIFiles\OfficeAI\RootAI\AI" -Destination "$env:ProgramFiles\Microsoft Office\root\Office16" -Force 
                Move-Item "$env:USERPROFILE\RemoveWindowsAI\Backup\AIFiles\OfficeAI\ActionsServer\ActionsServer" -Destination "$env:ProgramFiles\Microsoft Office\root\vfs\ProgramFilesCommonX64\Microsoft Shared\Office16" -Force 
                Get-ChildItem "$env:USERPROFILE\RemoveWindowsAI\Backup\AIFiles\OfficeAI" -Filter '*.msix' | ForEach-Object {
                    Move-Item $_.FullName -Destination "$env:ProgramFiles\Microsoft Office\root\Integration\Addons" -Force
                }
            }

            Write-Status -msg 'Restoring AI URIs...'
            $regs = Get-ChildItem "$env:USERPROFILE\RemoveWindowsAI\Backup\AIFiles\URIHandlers"
            foreach ($reg in $regs) {
                Reg.exe import $reg.FullName *>$null
            }
           
            Write-Status -msg 'Files Restored... You May Need to Repair the Apps Using the Microsoft Store'
        }
        else {
            Write-Status -msg 'Unable to Find Backup Files!' -errorOutput 
        }
       
        <#
        if (Test-Path "$env:USERPROFILE\RemoveWindowsAI\Backup\CompStorage"){
            Get-ChildItem "$env:USERPROFILE\RemoveWindowsAI\Backup\CompStorage" -Filter "*.reg"
        }else{
            Write-Status -msg 'Unable to Find Component Storage Backup!' -errorOutput 
        }
        #>
    }
    else {

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
            'WindowsWorkload'
            'Voiess'
            'Speion'
            'Livtop'
            'InpApp'
            'Filons'
        )

        Write-Status -msg 'Removing Appx Package Files...'
        Write-Status -msg 'This could take a while on some systems, please be patient!' -warningOutput
        #-----------------------------------------------------------------------remove files
        $appsPath = "$env:SystemRoot\SystemApps"
        if (!(Test-Path $appsPath)) {
            $appsPath = "$env:windir\SystemApps"
        }
        $appsPath2 = "$env:ProgramFiles\WindowsApps"
    
        $appsPath3 = "$env:ProgramData\Microsoft\Windows\AppRepository"
    
        $appsPath4 = "$env:SystemRoot\servicing\Packages"
        if (!(Test-Path $appsPath4)) {
            $appsPath4 = "$env:windir\servicing\Packages"
        }
    
        $appsPath5 = "$env:SystemRoot\System32\CatRoot"
        if (!(Test-Path $appsPath5)) {
            $appsPath5 = "$env:windir\System32\CatRoot"
        }

        $appsPath6 = "$env:SystemRoot\SystemApps\SxS"
        if (!(Test-Path $appsPath6)) {
            $appsPath6 = "$env:windir\SystemApps\SxS"
        }
        $pathsSystemApps = (Get-ChildItem -Path $appsPath -Directory -Force -ErrorAction SilentlyContinue).FullName 
        $pathsWindowsApps = (Get-ChildItem -Path $appsPath2 -Directory -Force -ErrorAction SilentlyContinue).FullName 
        $pathsAppRepo = (Get-ChildItem -Path $appsPath3 -Directory -Force -Recurse -ErrorAction SilentlyContinue).FullName 
        $pathsServicing = (Get-ChildItem -Path $appsPath4 -Directory -Force -Recurse -ErrorAction SilentlyContinue).FullName
        $pathsCatRoot = (Get-ChildItem -Path $appsPath5 -Directory -Force -Recurse -ErrorAction SilentlyContinue).FullName 
        $pathsSXS = (Get-ChildItem -Path $appsPath6 -Directory -Force -ErrorAction SilentlyContinue).FullName 

        $packagesPath = @()
        #get full path
        foreach ($package in $aipackages) {
    
            foreach ($path in $pathsSystemApps) {
                if ($path -like "*$package*") {
                    $packagesPath += $path
                }
            }
    
            foreach ($path in $pathsWindowsApps) {
                if ($path -like "*$package*") {
                    $packagesPath += $path
                }
            }
    
            foreach ($path in $pathsAppRepo) {
                if ($path -like "*$package*") {
                    $packagesPath += $path
                }
            }

            foreach ($path in $pathsSXS) {
                if ($path -like "*$package*") {
                    $packagesPath += $path
                }
            }
    
        }
    
        #get additional files
        foreach ($path in $pathsServicing) {
            if ($path -like '*UserExperience-AIX*' -or $path -like '*Copilot*' -or $path -like '*UserExperience-Recall*' -or $path -like '*CoreAI*') {
                $packagesPath += $path
            }
        }
    
        foreach ($path in $pathsCatRoot) {
            if ($path -like '*UserExperience-AIX*' -or $path -like '*Copilot*' -or $path -like '*UserExperience-Recall*' -or $path -like '*CoreAI*') {
                $packagesPath += $path
            }
        }

        #add app actions mcp host
        $paths = @(
            "$env:LOCALAPPDATA\Microsoft\WindowsApps\ActionsMcpHost.exe"
            "$env:SystemRoot\System32\config\systemprofile\AppData\Local\Microsoft\WindowsApps\ActionsMcpHost.exe"
            "$env:SystemRoot\System32\config\systemprofile\AppData\Local\Microsoft\WindowsApps\MicrosoftWindows.Client.CBS_cw5n1h2txyewy\ActionsMcpHost.exe"
            "$env:LOCALAPPDATA\Microsoft\WindowsApps\MicrosoftWindows.Client.CBS_cw5n1h2txyewy\ActionsMcpHost.exe"
        )

        foreach ($path in $paths) {
            if (Test-Path $path) {
                $packagesPath += $path
            }
        }

        foreach ($packageName in $aipackages) {
            $path = Get-ChildItem "$env:LOCALAPPDATA\Packages" -Filter "*$packageName*" 
            if ($path) {
                $packagesPath += $path.FullName
            }
            
        }

    
        if ($backup) {
            Write-Status -msg 'Backing Up AI Files...'
            $backupDir = "$env:USERPROFILE\RemoveWindowsAI\Backup\AIFiles"
            if (!(Test-Path $backupDir)) {
                New-Item $backupDir -Force -ItemType Directory | Out-Null
            }
        }

        foreach ($Path in $packagesPath) {
            #only remove dlls from photon to prevent startmenu from breaking
            # if ($path -like '*Photon*') {
            #     $command = "`$dlls = (Get-ChildItem -Path $Path -Filter *.dll).FullName; foreach(`$dll in `$dlls){Remove-item ""`$dll"" -force}"
            #     Run-Trusted -command $command -psversion $psversion
            #     Start-Sleep 1
            # }
            # else {

            if ($backup) {
                $backupFiles = "$env:USERPROFILE\RemoveWindowsAI\Backup\AIFiles\backupPaths.txt"
                if (!(Test-Path $backupFiles -PathType Leaf)) {
                    New-Item $backupFiles -Force -ItemType File | Out-Null
                }
                try {
                    Copy-Item -Path $Path -Destination $backupDir -Force -Recurse -ErrorAction Stop
                    Add-Content -Path $backupFiles -Value $Path
                }
                catch {
                    #ignore any errors
                }
            }
            $command = "Remove-item ""$Path"" -force -recurse"
            Run-Trusted -command $command -psversion $psversion
            Start-Sleep 1
        
        }
    
        #remove machine learning dlls
        $paths = @(
            "$env:SystemRoot\System32\Windows.AI.MachineLearning.dll"
            "$env:SystemRoot\SysWOW64\Windows.AI.MachineLearning.dll"
            "$env:SystemRoot\System32\Windows.AI.MachineLearning.Preview.dll"
            "$env:SystemRoot\SysWOW64\Windows.AI.MachineLearning.Preview.dll"
            "$env:SystemRoot\System32\SettingsHandlers_Copilot.dll"
            "$env:SystemRoot\System32\SettingsHandlers_A9.dll"
        )
        foreach ($path in $paths) {
            if (Test-Path $path) {
                takeown /f $path *>$null
                icacls $path /grant *S-1-5-32-544:F /t *>$null
                try {
                    Remove-Item -Path $path -Force -ErrorAction Stop
                }
                catch {
                    #takeown didnt work remove file with system priv
                    $command = "Remove-Item -Path $path -Force"
                    Run-Trusted -command $command -psversion $psversion
                }
            }
        }
    
        Write-Status -msg 'Removing Hidden Copilot Installers...'
        #remove package installers in edge dir
        #installs Microsoft.Windows.Ai.Copilot.Provider
        $dir = "${env:ProgramFiles(x86)}\Microsoft"
        $folders = @(
            'Edge',
            'EdgeCore',
            'EdgeWebView'
        )
        foreach ($folder in $folders) {
            if ($folder -eq 'EdgeCore') {
                #edge core doesnt have application folder
                $fullPath = (Get-ChildItem -Path "$dir\$folder\*.*.*.*\copilot_provider_msix" -ErrorAction SilentlyContinue).FullName
            
            }
            else {
                $fullPath = (Get-ChildItem -Path "$dir\$folder\Application\*.*.*.*\copilot_provider_msix" -ErrorAction SilentlyContinue).FullName
            }
            if ($fullPath -ne $null) { Remove-Item -Path $fullPath -Recurse -Force -ErrorAction SilentlyContinue }
        }
    

        #remove copilot update in edge update dir
        $dir = "${env:ProgramFiles(x86)}\Microsoft\EdgeUpdate"
        if (Test-Path $dir) {
            $paths = Get-ChildItem $dir -Recurse -Filter '*CopilotUpdate.exe*' 
            foreach ($path in $paths) {
                if (Test-Path $path.FullName) {
                    Remove-Item $path.FullName -Force
                }
            }
        }

        $dir = "${env:ProgramFiles(x86)}\Microsoft"
        if (Test-Path $dir) {
            $paths = Get-ChildItem $dir -Recurse -Filter '*Copilot_setup*' 
            foreach ($path in $paths) {
                if (Test-Path $path.FullName) {
                    Remove-Item $path.FullName -Force
                }
            }
        }

        Reg.exe delete 'HKLM\SOFTWARE\Microsoft\EdgeUpdate' /v 'CopilotUpdatePath' /f *>$null
        Reg.exe delete 'HKLM\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate' /v 'CopilotUpdatePath' /f *>$null
    
        #remove additional installers
        $inboxapps = 'C:\Windows\InboxApps'
        $installers = Get-ChildItem -Path $inboxapps -Filter '*Copilot*'
        foreach ($installer in $installers) {
            takeown /f $installer.FullName *>$null
            icacls $installer.FullName /grant *S-1-5-32-544:F /t *>$null
            try {
                Remove-Item -Path $installer.FullName -Force -ErrorAction Stop
            }
            catch {
                #takeown didnt work remove file with system priv
                $command = "Remove-Item -Path $($installer.FullName) -Force"
                Run-Trusted -command $command -psversion $psversion
            }
        
        }
    
    
        #remove ai from outlook/office
        $aiPaths = @(
            "$env:ProgramFiles\Microsoft Office\root\vfs\ProgramFilesCommonX64\Microsoft Shared\Office16\AI",
            "$env:ProgramFiles\Microsoft Office\root\vfs\ProgramFilesCommonX86\Microsoft Shared\Office16\AI",
            "$env:ProgramFiles\Microsoft Office\root\Office16\AI",
            "$env:ProgramFiles\Microsoft Office\root\vfs\ProgramFilesCommonX64\Microsoft Shared\Office16\ActionsServer",
            "$env:ProgramFiles\Microsoft Office\root\Integration\Addons\aimgr.msix",
            "$env:ProgramFiles\Microsoft Office\root\Integration\Addons\WritingAssistant.msix",
            "$env:ProgramFiles\Microsoft Office\root\Integration\Addons\ActionsServer.msix"
        )
    
        foreach ($path in $aiPaths) {
            if (Test-Path $path -ErrorAction SilentlyContinue) {
                if ($backup) {
                    Write-Status -msg 'Backing Up Office AI Files...'
                    $backupDir = "$env:USERPROFILE\RemoveWindowsAI\Backup\AIFiles\OfficeAI"
                    if (!(Test-Path $backupDir)) {
                        New-Item $backupDir -Force -ItemType Directory | Out-Null
                    }

                    if ($path -eq "$env:ProgramFiles\Microsoft Office\root\vfs\ProgramFilesCommonX64\Microsoft Shared\Office16\AI") {
                        $backupDir = "$backupDir\x64"
                        New-Item $backupDir -Force -ItemType Directory | Out-Null
                    }
                    elseif ($path -eq "$env:ProgramFiles\Microsoft Office\root\vfs\ProgramFilesCommonX86\Microsoft Shared\Office16\AI") {
                        $backupDir = "$backupDir\x86"
                        New-Item $backupDir -Force -ItemType Directory | Out-Null
                    }
                    elseif ($path -eq "$env:ProgramFiles\Microsoft Office\root\Office16\AI") {
                        $backupDir = "$backupDir\RootAI"
                        New-Item $backupDir -Force -ItemType Directory | Out-Null
                    }
                    elseif ($path -eq "$env:ProgramFiles\Microsoft Office\root\vfs\ProgramFilesCommonX64\Microsoft Shared\Office16\ActionsServer") {
                        $backupDir = "$backupDir\ActionsServer"
                        New-Item $backupDir -Force -ItemType Directory | Out-Null
                    }
                    else {
                        $backupDir = "$env:USERPROFILE\RemoveWindowsAI\Backup\AIFiles\OfficeAI"
                    }
                    Copy-Item -Path $path -Destination $backupDir -Force -Recurse -ErrorAction SilentlyContinue
                }
                try {
                    Remove-Item $path -Recurse -Force -ErrorAction Stop
                }
                catch {
                    $command = "Remove-Item -LiteralPath `"$path`" -Recurse -Force"
                    Run-Trusted -command $command -psversion $psversion
                    Start-Sleep 1
                }
                
            }
        }

        #remove any screenshots from recall
        Write-Status -msg 'Removing Any Screenshots By Recall...'
        Remove-Item -Path "$env:LOCALAPPDATA\CoreAIPlatform*" -Force -Recurse -ErrorAction SilentlyContinue

        #remove ai uri handlers
        Write-Status -msg 'Removing AI URI Handlers...'
        $uris = @(
            'registry::HKEY_CLASSES_ROOT\ms-office-ai'
            'registry::HKEY_CLASSES_ROOT\ms-copilot'
            'registry::HKEY_CLASSES_ROOT\ms-clicktodo'
        )

        foreach ($uri in $uris) {
            if ($backup) {
                if (Test-Path $uri) {
                    $backupDir = "$env:USERPROFILE\RemoveWindowsAI\Backup\AIFiles\URIHandlers"
                    if (!(Test-Path $backupDir)) {
                        New-Item $backupDir -Force -ItemType Directory | Out-Null
                    }
                    $regExportPath = "$backupDir\$($uri -replace 'registry::HKEY_CLASSES_ROOT\\', '').reg"
                    Reg.exe export ($uri -replace 'registry::', '') $regExportPath /y *>$null
                }
            }
            Remove-Item $uri -Recurse -Force -ErrorAction SilentlyContinue
        }

        #prefire copilot nudges package by deleting the registry keys 
        Write-Status -msg 'Removing Copilot Nudges Registry Keys...'
        $keys = @(
            'registry::HKCR\Extensions\ContractId\Windows.BackgroundTasks\PackageId\MicrosoftWindows.Client.Core_*.*.*.*_x64__cw5n1h2txyewy\ActivatableClassId\Global.CopilotNudges.AppX*.wwa',
            'registry::HKCR\Extensions\ContractId\Windows.Launch\PackageId\MicrosoftWindows.Client.Core_*.*.*.*_x64__cw5n1h2txyewy\ActivatableClassId\Global.CopilotNudges.wwa',
            'registry::HKCR\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\Repository\Packages\MicrosoftWindows.Client.Core_*.*.*.*_x64__cw5n1h2txyewy\Applications\MicrosoftWindows.Client.Core_cw5n1h2txyewy!Global.CopilotNudges',
            'HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\Repository\Packages\MicrosoftWindows.Client.Core_*.*.*.*_x64__cw5n1h2txyewy\Applications\MicrosoftWindows.Client.Core_cw5n1h2txyewy!Global.CopilotNudges',
            'HKCU:\Software\Microsoft\Windows\CurrentVersion\PushNotifications\Backup\MicrosoftWindows.Client.Core_cw5n1h2txyewy!Global.CopilotNudges',
            'HKLM:\SOFTWARE\Classes\Extensions\ContractId\Windows.BackgroundTasks\PackageId\MicrosoftWindows.Client.Core_*.*.*.*_x64__cw5n1h2txyewy\ActivatableClassId\Global.CopilotNudges.AppX*.wwa',
            'HKLM:\SOFTWARE\Classes\Extensions\ContractId\Windows.BackgroundTasks\PackageId\MicrosoftWindows.Client.Core_*.*.*.*_x64__cw5n1h2txyewy\ActivatableClassId\Global.CopilotNudges.AppX*.mca',
            'HKLM:\SOFTWARE\Classes\Extensions\ContractId\Windows.Launch\PackageId\MicrosoftWindows.Client.Core_*.*.*.*_x64__cw5n1h2txyewy\ActivatableClassId\Global.CopilotNudges.wwa'
        )
        #get full paths and remove
        $fullkey = @()
        foreach ($key in $keys) {
            try {
                $fullKey = Get-Item -Path $key -ErrorAction Stop
                if ($null -eq $fullkey) { continue }
                if ($fullkey.Length -gt 1) {
                    foreach ($multikey in $fullkey) {
                        $command = "Remove-Item -Path `"registry::$multikey`" -Force -Recurse"
                        Run-Trusted -command $command -psversion $psversion
                        Start-Sleep 1
                        #remove any regular admin that have trusted installer bug
                        Remove-Item -Path "registry::$multikey" -Force -Recurse -ErrorAction SilentlyContinue
                    }
                }
                else {
                    $command = "Remove-Item -Path `"registry::$fullKey`" -Force -Recurse"
                    Run-Trusted -command $command -psversion $psversion
                    Start-Sleep 1
                    #remove any regular admin that have trusted installer bug
                    Remove-Item -Path "registry::$fullKey" -Force -Recurse -ErrorAction SilentlyContinue
                }
         
            }
            catch {
                continue
            }
        }

        #remove ai app checks in updates (not sure if this does anything)
        $command = "Reg.exe delete 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell\Update\Packages\MicrosoftWindows.Client.CoreAI_cw5n1h2txyewy' /f"
        Run-Trusted -command $command -psversion $psversion
        Reg.exe delete 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell\Update\Packages\Components' /v 'AIX' /f *>$null
        Reg.exe delete 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell\Update\Packages\Components' /v 'CopilotNudges' /f *>$null
        Reg.exe delete 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell\Update\Packages\Components' /v 'AIContext' /f *>$null

        reg.exe delete 'HKCU\Software\Microsoft\Windows\CurrentVersion\App Paths\ActionsMcpHost.exe' /f *>$null
        reg.exe delete 'HKLM\Software\Microsoft\Windows\CurrentVersion\App Paths\ActionsMcpHost.exe' /f *>$null

        #remove app actions files 
        #these will get remade when updating
        taskkill.exe /im AppActions.exe /f *>$null
        taskkill.exe /im VisualAssist.exe /f *>$null
        $paths = @(
            "$env:windir\SystemApps\MicrosoftWindows.Client.CBS_cw5n1h2txyewy\ActionUI"
            "$env:windir\SystemApps\MicrosoftWindows.Client.CBS_cw5n1h2txyewy\VisualAssist"
            "$env:windir\SystemApps\MicrosoftWindows.Client.CBS_cw5n1h2txyewy\AppActions.exe"
            "$env:windir\SystemApps\MicrosoftWindows.Client.CBS_cw5n1h2txyewy\AppActions.dll"
            "$env:windir\SystemApps\MicrosoftWindows.Client.CBS_cw5n1h2txyewy\VisualAssistExe.exe"
            "$env:windir\SystemApps\MicrosoftWindows.Client.CBS_cw5n1h2txyewy\VisualAssistExe.dll"
        )

        Write-Status -msg 'Removing App Actions Files...'
        foreach ($path in $paths) {
            if (Test-Path $path) {
                if ((Get-Item $path).PSIsContainer) {
                    takeown /f "$path" /r /d Y *>$null
                    icacls "$path" /grant *S-1-5-32-544:F /t *>$null
                    Remove-Item "$path" -Force -Recurse -ErrorAction SilentlyContinue
                }
                else {
                    takeown /f "$path" *>$null
                    icacls "$path" /grant *S-1-5-32-544:F /t *>$null
                    Remove-Item "$path" -Force -ErrorAction SilentlyContinue
                }
            }
        }
        

        Write-Status -msg 'Removing AI From Component Store (WinSxS)...'
        Write-Status -msg 'This could take a while on some systems, please be patient!' -warningOutput
        #additional dirs and reg keys
        $aiKeyWords = @(
            'AIX',
            'Copilot',
            'Recall',
            'CoreAI',
            'aimgr'
        )
        $regLocations = @(
            'registry::HKCR\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage',
            'HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppContainer\Storage',
            'registry::HKCR\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\Repository\Packages',
            'HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\Repository\Packages',
            'registry::HKCR\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData',
            'HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData',
            'registry::HKCR\PackagedCom\Package',
            'HKCU:\Software\Classes\PackagedCom\Package',
            'HKCU:\Software\RegisteredApplications',
            'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\SideBySide\Winners'
        )
        $dirs = @(
            'C:\Windows\WinSxS',
            'C:\Windows\System32\CatRoot'
        )
        
        New-Item "$($tempDir)PathsToDelete.txt" -ItemType File -Force | Out-Null
        foreach ($keyword in $aiKeyWords) {
            foreach ($location in $regLocations) {
                Get-ChildItem $location -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.PSChildName -like "*$keyword*" } | ForEach-Object {
                    try {
                        Remove-Item $_.PSPath -Recurse -Force -ErrorAction Stop
                    }
                    catch {
                        #ignore when path is null
                    }
                    
                }
            }

        }

        foreach ($dir in $dirs) {
            Get-ChildItem $dir -Recurse -ErrorAction SilentlyContinue | Where-Object { 
                $_.FullName -like "*$($aiKeyWords[0])*" -or 
                $_.FullName -like "*$($aiKeyWords[1])*" -or 
                $_.FullName -like "*$($aiKeyWords[2])*" -or
                $_.FullName -like "*$($aiKeyWords[3])*" -or
                $_.FullName -like "*$($aiKeyWords[4])*" -and
                $(Test-Path $_.FullName -PathType Container) -eq $true 
            } | ForEach-Object {
                #add paths to txt to delete with trusted installer
                Add-Content "$($tempDir)PathsToDelete.txt" -Value $_.FullName | Out-Null
            } 
        }
        
        
        $command = "Get-Content `"$($tempDir)PathsToDelete.txt`" | ForEach-Object {Remove-Item `$_ -Force -Recurse -EA 0}"
        Run-Trusted -command $command -psversion $psversion
        Start-Sleep 1
    }

    #TEST:
    # remove ai components from component storage
    # this will prevent sfc from trying to repair files removed 
    # but seems to prevent windows update from working
    <#
    $compPath = "$env:systemroot\System32\config\COMPONENTS"

    reg.exe query 'HKLM\COMPONENTS' /ve *>$null
    if ($LASTEXITCODE -ne 0) {
        reg.exe load 'HKLM\COMPONENTS' $compPath >$null
    }

    if ($LASTEXITCODE -ne 0) {
        Write-Status -msg "Unable to Load $compPath" -errorOutput
    }
    else {
        $paths = Get-ChildItem 'registry::HKLM\COMPONENTS\DerivedData\Components' | Where-Object { $_.PSChildName -like '*copilot*' -or
            $_.PSChildName -like '*userexperience-aix*' -or
            $_.PSChildName -like '*userexperience-recall*' -or
            $_.PSChildName -like '*userexperience-coreai*' } 

        if ($paths) {
            Write-Status -msg 'Removing AI Components Found in Component Storage...'
            #backup by default for now
            $backupPath = "$env:USERPROFILE\RemoveWindowsAI\Backup\CompStorage"
            if (!(Test-Path $backupPath)) {
                New-Item $backupPath -ItemType Directory | Out-Null
            }

            foreach ($path in $paths) {
                reg.exe export $path.Name "$backupPath\$($path.PSChildName).reg" /y >$null
                reg.exe delete $path.Name /f
            }
            
        }
        else {
            Write-Status -msg 'No Ai Components Found in Component Storage'
        }

    }
    #>
}
