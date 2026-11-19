# Remove-AI-CBS-Packages - Hapus paket AI tersembunyi (CBS)

# not restoring for now shouldnt cause any issues (also may not even be possible to restore)
function Remove-AI-CBS-Packages {
    if (!$revert) {
        #additional hidden packages
        Write-Status -msg 'Removing Additional Hidden AI Packages...'
        #unhide the packages from dism, remove owners subkey for removal 
        $regPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\Packages'
        $ProgressPreference = 'SilentlyContinue'
        Get-ChildItem $regPath | ForEach-Object {
            $value = try { Get-ItemPropertyValue "registry::$($_.Name)" -Name Visibility -ErrorAction Stop } catch { $null }
    
            if ($value -ne $null) {
                # Tanda kurung wajib: -and dan -or berprioritas sama, tanpa kurung kondisi hanya berlaku untuk 'AIX'
                if ($_.PSChildName -like '*AIX*' -or $_.PSChildName -like '*Recall*' -or $_.PSChildName -like '*Copilot*' -or $_.PSChildName -like '*CoreAI*') {
                    # Simpan nama paket: di dalam blok catch, $_ adalah ErrorRecord, bukan kunci registry
                    $pkgName = $_.PSChildName
                    Set-ItemProperty "registry::$($_.Name)" -Name Visibility -Value 1 -Force
                    New-ItemProperty "registry::$($_.Name)" -Name DefVis -PropertyType DWord -Value 2 -Force | Out-Null
                    Remove-Item "registry::$($_.Name)\Owners" -Force -ErrorAction SilentlyContinue
                    Remove-Item "registry::$($_.Name)\Updates" -Force -ErrorAction SilentlyContinue
                    try {
                        Remove-WindowsPackage -Online -PackageName $_.PSChildName -NoRestart -ErrorAction Stop *>$null
                        $paths = Get-ChildItem "$env:windir\servicing\Packages" -Filter "*$($_.PSChildName)*" -ErrorAction SilentlyContinue 
                        foreach ($path in $paths) {
                            if ($path) {
                                Remove-Item $path.FullName -Force -ErrorAction SilentlyContinue
                            }
                        }
                        
                    }
                    catch {
                        #fallback to dism when user is using powershell 7
                        dism.exe /Online /Remove-Package /PackageName:$pkgName /NoRestart /Quiet
                        $paths = if ($pkgName) { Get-ChildItem "$env:windir\servicing\Packages" -Filter "*$pkgName*" -ErrorAction SilentlyContinue }
                        foreach ($path in $paths) {
                            if ($path) {
                                Remove-Item $path.FullName -Force -ErrorAction SilentlyContinue
                            }
                        }                    
                    }
        
                }
            }
            
        }
    }
}
