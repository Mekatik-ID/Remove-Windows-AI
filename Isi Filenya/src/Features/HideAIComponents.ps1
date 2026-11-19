# Hide-AI-Components - Sembunyikan komponen AI di Pengaturan

function Hide-AI-Components {
    #hide ai components in immersive settings
    Write-Status -msg "$(@('Hiding','Unhiding')[$revert]) Ai Components in Settings..."

    $existingSettings = try { Get-ItemPropertyValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' -Name 'SettingsPageVisibility' -ErrorAction SilentlyContinue }catch {}
    #early return if the user has already customized this with showonly rather than hide, in this event ill assume the user has knowledge of this key and aicomponents is likely not shown anyway
    if ($existingSettings -like '*showonly*') {
        Write-Status 'SettingsPageVisibility contains "showonly"...Skipping!' -errorOutput
        return 
    }
    
    if ($revert) {
        #tidak ada nilai yang perlu dikembalikan (mencegah menulis nilai kosong)
        if (-not $existingSettings) { return }
        #if the key is not just hide ai components then just remove it and retain the rest
        if ($existingSettings -ne 'hide:aicomponents;appactions;') {
            #in the event that this is just aicomponents but multiple times newkey will just be hide: which is valid
            $newKey = $existingSettings -replace 'aicomponents;appactions;', ''
            Reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' /v 'SettingsPageVisibility' /t REG_SZ /d $newKey /f >$null
        }
        else {
            Reg.exe delete 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' /v 'SettingsPageVisibility' /f >$null
        }
    }
    else {
        if ($existingSettings -and $existingSettings -notlike '*aicomponents;*') {
           
            if (!($existingSettings.endswith(';'))) {
                #doesnt have trailing ; so need to add it 
                $newval = $existingSettings + ';aicomponents;appactions;'
            }
            else {
                $newval = $existingSettings + 'aicomponents;appactions;'
            }
            
            Reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' /v 'SettingsPageVisibility' /t REG_SZ /d $newval /f >$null
        }
        elseif ($existingSettings -eq $null) {
            Reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' /v 'SettingsPageVisibility' /t REG_SZ /d 'hide:aicomponents;appactions;' /f >$null
        }
       
    }
}
