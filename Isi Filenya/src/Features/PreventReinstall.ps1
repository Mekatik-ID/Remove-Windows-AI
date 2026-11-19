# Install-NOAIPackage - Cegah paket AI terpasang ulang

function Install-NOAIPackage {
    
    if (!$revert) {
        $package = Get-WindowsPackage -Online | Where-Object { $_.PackageName -like '*zoicware*' }
        if (!$package) {
            #check cpu arch
            $arm = ((Get-CimInstance -Class Win32_ComputerSystem).SystemType -match 'ARM64') -or ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64')
            $arch = if ($arm) { 'arm64' } else { 'amd64' }
            #add cert to registry
            $certRegPath = 'HKLM:\Software\Microsoft\SystemCertificates\ROOT\Certificates\8A334AA8052DD244A647306A76B8178FA215F344'
            if (!(Test-Path "$certRegPath")) {
                New-Item -Path $certRegPath -Force | Out-Null
            }

            #check if script is being ran locally 
            if ((Test-Path "$Global:MekatikRoot\data\AIPackage\amd64") -and (Test-Path "$Global:MekatikRoot\data\AIPackage\arm64")) {
                Write-Status -msg 'RemoveWindowsAI Packages Found Locally...'

                Write-Status -msg 'Installing RemoveWindowsAI Package...'
                try {
                    Add-WindowsPackage -Online -PackagePath "$Global:MekatikRoot\data\AIPackage\$arch\ZoicwareRemoveWindowsAI-$($arch)1.0.0.0.cab" -NoRestart -IgnoreCheck -ErrorAction Stop >$null
                }
                catch {
                    #user is using powershell 7 use dism command as fallback
                    dism.exe /Online /Add-Package /PackagePath:"$Global:MekatikRoot\data\AIPackage\$arch\ZoicwareRemoveWindowsAI-$($arch)1.0.0.0.cab" /NoRestart /IgnoreCheck >$null
                }
           
            }
            else {
                Write-Status -msg 'Downloading RemoveWindowsAI Package From Github...'
                $ProgressPreference = 'SilentlyContinue'
                try {
                    Invoke-WebRequest -Uri "https://github.com/zoicware/RemoveWindowsAI/raw/refs/heads/main/RemoveWindowsAIPackage/$arch/ZoicwareRemoveWindowsAI-$($arch)1.0.0.0.cab" -OutFile "$($tempDir)ZoicwareRemoveWindowsAI-$($arch)1.0.0.0.cab" -UseBasicParsing -ErrorAction Stop
                }
                catch {
                    Write-Status -msg 'Unable to Download Package, periksa koneksi internet' -errorOutput
                    return
                }

                Write-Status -msg 'Installing RemoveWindowsAI Package...'
                try {
                    Add-WindowsPackage -Online -PackagePath "$($tempDir)ZoicwareRemoveWindowsAI-$($arch)1.0.0.0.cab" -NoRestart -IgnoreCheck -ErrorAction Stop >$null
                }
                catch {
                    dism.exe /Online /Add-Package /PackagePath:"$($tempDir)ZoicwareRemoveWindowsAI-$($arch)1.0.0.0.cab" /NoRestart /IgnoreCheck >$null
                }
            }
        }
        else {
            Write-Status -msg 'Update package already installed...'
        }
        
        Write-Status -msg 'Checking update package install status...'
        $package = Get-WindowsPackage -Online | Where-Object { $_.PackageName -like '*zoicware*' }
        if ($package.PackageState -eq 'InstallPending') {
            Write-Status -msg 'Package installed incorrectly... Uninstalling!' -errorOutput
            try {
                Remove-WindowsPackage -Online -PackageName $package.PackageName -NoRestart -ErrorAction Stop
            }
            catch {
                dism.exe /Online /remove-package /PackageName:$($package.PackageName) /NoRestart
            }
            #remove reg install location 
            $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages'
            Get-ChildItem $regPath | ForEach-Object {
                $value = try { Get-ItemProperty "registry::$($_.Name)" -ErrorAction Stop } catch { $null }
                if ($value -and $value.PSPath -like '*zoicware*') {
                    Remove-Item -Path $value.PSPath -Recurse -Force
                }
            }
        }
    }
    else {
        
        $package = Get-WindowsPackage -Online | Where-Object { $_.PackageName -like '*zoicware*' }
        if ($package) {
            Write-Status 'Removing Custom Windows Update Package...' 
            try {
                Remove-WindowsPackage -Online -PackageName $package.PackageName -NoRestart -ErrorAction Stop
            }
            catch {
                dism.exe /Online /remove-package /PackageName:$($package.PackageName) /NoRestart
            }
            #remove reg install location 
            $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages'
            Get-ChildItem $regPath | ForEach-Object {
                $value = try { Get-ItemProperty "registry::$($_.Name)" -ErrorAction Stop } catch { $null }
                if ($value -and $value.PSPath -like '*zoicware*') {
                    Remove-Item -Path $value.PSPath -Recurse -Force
                }
            }
            
        }
        else {
            Write-Status 'Unable to Find Update Package...' -errorOutput 
        }
        
    }

}
