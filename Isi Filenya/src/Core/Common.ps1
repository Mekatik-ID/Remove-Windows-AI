# Fungsi umum yang dipakai semua modul.

function Write-Status {
    param(
        [string]$msg,
        [switch]$errorOutput,
        [switch]$warningOutput
    )
    if ($errorOutput) { $tag = '[ ! ERROR ]'; $color = 'Red' }
    elseif ($warningOutput) { $tag = '[ * WARNING ]'; $color = 'Yellow' }
    else { $tag = '[ + ]'; $color = 'Cyan' }

    Write-Host "$tag $msg" -ForegroundColor $color
    # Jika jendela utama aktif, kirim juga ke panel log di jendela
    if ($Global:MekatikUiLog) {
        try { & $Global:MekatikUiLog "$tag $msg" } catch { }
    }
}

function Add-LogInfo {
    param(
        [string]$logPath,
        $info
    )

    $content = @"
    ====================================
    Line: $($info.Line)
    Result: $($info.Result)
"@

    Add-Content $logPath -Value $content | Out-Null
}

function Create-RestorePoint {
    param(
        [switch]$nonInteractive
    )

    #check vss service first
    $vssService = Get-Service -Name 'VSS' -ErrorAction SilentlyContinue
    if ($vssService -and $vssService.StartType -eq 'Disabled') {
        try {
            Write-Status -msg 'Enabling VSS Service...'
            Set-Service -Name 'VSS' -StartupType Manual -ErrorAction Stop
            Start-Service -Name 'VSS' -ErrorAction Stop
        }
        catch {
            Write-Status -msg 'Unable to Start VSS Service... Can not create restore point!' -errorOutput
            return
        }
        
    }
    #enable system protection to allow restore points
    $restoreEnabled = Get-ComputerRestorePoint -ErrorAction SilentlyContinue
    if (!$restoreEnabled) {
        Write-Status -msg 'Enabling Restore Points on System...'
        Enable-ComputerRestore -Drive "$env:SystemDrive\" 
    }

    
    if ($nonInteractive) {
        #allow restore point to be created even if one was just made
        $restoreFreqPath = 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\SystemRestore'
        $restoreFreqKey = 'SystemRestorePointCreationFrequency'
        $currentValue = (Get-ItemProperty -Path $restoreFreqPath -Name $restoreFreqKey -ErrorAction SilentlyContinue).$restoreFreqKey
        if ($currentValue -ne 0) {
            Set-ItemProperty -Path $restoreFreqPath -Name $restoreFreqKey -Value 0 -Force
        }

        $restorePointName = "RemoveWindowsAI-$(Get-Date -Format 'yyyy-MM-dd')"
        Write-Status -msg "Creating Restore Point: [$restorePointName]"
        Write-Status -msg 'This may take a moment...please wait'
        Checkpoint-Computer -Description $restorePointName -RestorePointType 'MODIFY_SETTINGS' 
    }
    else {
        Write-Status -msg 'Opening Restore Point Dialog...'
        try {
            $proc = Start-Process 'SystemPropertiesProtection.exe' -ErrorAction Stop -PassThru
        }
        catch {
            $proc = Start-Process 'C:\Windows\System32\control.exe' -ArgumentList 'sysdm.cpl ,4' -PassThru
        }
        #click configure on the window
        Start-Sleep 1
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.SendKeys]::SendWait('%c') 
        Wait-Process -Id $proc.Id
    }

}

function Get-WindowsLangFolder {
    # Mengembalikan nama folder bahasa (mis. 'de-DE') sesuai bahasa instalasi Windows,
    # atau $null bila bahasanya en-US / tidak tersedia.
    $map = @{
        '0804' = 'zh-CN'; '0412' = 'ko-KR'; '0404' = 'zh-TW'; '0422' = 'uk-UA'; '041f' = 'tr-TR'
        '041e' = 'th-TH'; '241a' = 'sr-Latn-RS'; '0424' = 'sl-SI'; '041b' = 'sk-SK'; '0419' = 'ru-RU'
        '0418' = 'ro-RO'; '0816' = 'pt-PT'; '0416' = 'pt-BR'; '0415' = 'pl-PL'; '0413' = 'nl-NL'
        '0414' = 'nb-NO'; '0426' = 'lv-LV'; '0427' = 'lt-LT'; '0411' = 'ja-JP'; '0410' = 'it-IT'
        '040e' = 'hu-HU'; '041a' = 'hr-HR'; '040d' = 'he-IL'; '040c' = 'fr-FR'; '0c0c' = 'fr-CA'
        '040b' = 'fi-FI'; '0425' = 'et-EE'; '080a' = 'es-MX'; '040a' = 'es-ES'; '0809' = 'en-GB'
        '0408' = 'el-GR'; '0407' = 'de-DE'; '0406' = 'da-DK'; '0405' = 'cs-CZ'; '0402' = 'bg-BG'
        '0401' = 'ar-SA'; '041d' = 'sv-SE'
    }
    $langID = (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Nls\Language' -Name 'InstallLanguage').InstallLanguage
    if ($map.ContainsKey($langID)) { return $map[$langID] }
    return $null
}

function Restore-ExecutionPolicy {
    # Mengembalikan ExecutionPolicy yang diubah oleh Remove-AI-Appx-Packages
    # 1) Kebijakan LocalMachine: pakai nilai yang disimpan SEBELUM diubah (bukan nilai 'Unrestricted' yang sudah tertulis)
    $machineHandled = $false
    if ($Global:ogMachinePolicyCaptured) {
        $machineKey = 'HKLM\Software\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell'
        if ($Global:ogMachinePolicyValue) { Reg.exe add $machineKey /v 'ExecutionPolicy' /t REG_SZ /d $Global:ogMachinePolicyValue /f >$null }
        else { Reg.exe delete $machineKey /v 'ExecutionPolicy' /f *>$null }
        $Global:ogMachinePolicyCaptured = $false
        $machineHandled = $true
    }
    # 2) Jalur lain (kebijakan grup / HKCU)
    if (-not $Global:ogExecutionPolicy) { return }
    if ($Global:executionPolicyMachine -and $machineHandled) { $Global:ogExecutionPolicy = $null; return }
    if ($Global:executionPolicyUser) { $key = 'HKCU\Software\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell' }
    elseif ($Global:executionPolicyMachine) { $key = 'HKLM\Software\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell' }
    elseif ($Global:executionPolicyWow64) { $key = 'HKLM\SOFTWARE\Wow6432Node\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell' }
    elseif ($Global:executionPolicyUserPol) { $key = 'HKCU\SOFTWARE\Policies\Microsoft\Windows\PowerShell' }
    else { $key = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell' }
    Reg.exe add $key /v 'ExecutionPolicy' /t REG_SZ /d $Global:ogExecutionPolicy /f >$null
}

function Invoke-Cleanup {
    # Hapus file sementara dan kembalikan ExecutionPolicy
    foreach ($name in 'aiPackageRemoval.ps1', 'RemoveRecallTasks.ps1', 'PathsToDelete.txt', 'ZoicwareRemoveWindowsAI-*1.0.0.0.cab') {
        Remove-Item (Join-Path $Global:tempDir $name) -Force -ErrorAction SilentlyContinue
    }
    Restore-ExecutionPolicy
}
