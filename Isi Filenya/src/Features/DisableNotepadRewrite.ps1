# Disable-Notepad-Rewrite - Matikan Rewrite di Notepad

function Disable-Notepad-Rewrite {
    #disable rewrite for notepad
    Write-Status -msg "$(@('Disabling','Enabling')[$revert]) Rewrite Ai Feature for Notepad..."
    <#
    taskkill /im notepad.exe /f *>$null
    #load notepad settings
    reg load HKU\TEMP "$env:LOCALAPPDATA\Packages\Microsoft.WindowsNotepad_8wekyb3d8bbwe\Settings\settings.dat" >$null
    #add disable rewrite
    $regContent = @'
Windows Registry Editor Version 5.00

[HKEY_USERS\TEMP\LocalState]
"RewriteEnabled"=hex(5f5e10b):00,e0,d1,c5,7f,ee,83,db,01
'@
    New-Item "$env:TEMP\DisableRewrite.reg" -Value $regContent -Force | Out-Null
    regedit.exe /s "$env:TEMP\DisableRewrite.reg"
    Start-Sleep 1
    reg unload HKU\TEMP >$null
    Remove-Item "$env:TEMP\DisableRewrite.reg" -Force -ErrorAction SilentlyContinue
    #>
    #above is old method before this policy to disable ai in notepad, [DEPRECIATED]
    Reg.exe add 'HKLM\SOFTWARE\Policies\WindowsNotepad' /v 'DisableAIFeatures' /t REG_DWORD /d @('1', '0')[$revert] /f *>$null
}
