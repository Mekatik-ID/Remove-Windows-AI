# install-photoslegacy

function install-photoslegacy {

    $appx = Get-AppxPackage -AllUsers | Where-Object { $_.PackageFullName -like '*PhotosLegacy*' }

    if (!$appx) {

        try {
            Get-Command store -ErrorAction Stop
            #install photos legacy using new store cmdlet
            store install 9NV2L4XVMCXM
        }
        catch {
            Remove-Item "$($tempDir)Microsoft.PhotosLegacy_8wekyb3d8bbwe*" -Force -Recurse -ErrorAction SilentlyContinue
            $downloadedfiles = Download-AppxPackage -PackageFamilyName 'Microsoft.PhotosLegacy_8wekyb3d8bbwe' -outputDir "$tempDir"
            $package = $downloadedfiles | Where-Object { $_ -match '\.appxbundle$' } | Select-Object -First 1
            $dependencies = $downloadedfiles | Where-Object { $_ -match '\.appx$' } 
            if ($package) {
                try {
                    if ($dependencies) { Add-AppPackage $package -DependencyPath $dependencies -ForceApplicationShutdown }
                    else { Add-AppPackage $package -ForceApplicationShutdown }
                }
                catch {
                    Write-status -msg "Can't install PhotosLegacy via appxbundle... make sure you have the appx service enabled" -errorOutput
                }
                
            }
            else {
                Write-status -msg "Can't find PhotosLegacy Installer" -errorOutput
            }
        }
        
    }
}
