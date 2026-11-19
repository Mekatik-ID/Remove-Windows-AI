# Remove-Recall-Optional-Feature - Hapus fitur opsional Recall

function Remove-Recall-Optional-Feature {
    if (!$revert) {
        #doesnt seem to work just gets stuck (does anyone really want this shit lol)
        #Enable-WindowsOptionalFeature -Online -FeatureName 'Recall' -All -NoRestart
        #remove recall optional feature 
        Write-Status -msg 'Removing Recall Optional Feature...'
        try {
            $state = (Get-WindowsOptionalFeature -Online -FeatureName 'Recall' -ErrorAction Stop).State
            if ($state -and $state -ne 'DisabledWithPayloadRemoved') {
                $ProgressPreference = 'SilentlyContinue'
                try {
                    Disable-WindowsOptionalFeature -Online -FeatureName 'Recall' -Remove -NoRestart -ErrorAction Stop *>$null
                }
                catch {
                    #incase get-windowsoptionalfeature works but disable doesnt 
                    dism.exe /Online /Disable-Feature /FeatureName:Recall /Remove /NoRestart /Quiet
                }
            }
        }
        catch {
            #if get-windowsoptionalfeature errors fallback to dism
            $dismOutput = dism.exe /Online /Get-FeatureInfo /FeatureName:Recall
    
            if ($LASTEXITCODE -eq 0) {
                $isDisabledWithPayloadRemoved = $dismOutput | Select-String -Pattern 'State\s*:\s*Disabled with Payload Removed'
        
                if (!$isDisabledWithPayloadRemoved) {
                    dism.exe /Online /Disable-Feature /FeatureName:Recall /Remove /NoRestart /Quiet
                }
            }
        }
    }
}
