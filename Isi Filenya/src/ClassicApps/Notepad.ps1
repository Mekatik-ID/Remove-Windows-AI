# install-notepad

function install-notepad {

    #uninstall new notepad 
    taskkill.exe /im notepad.exe /f *>$null
    taskkill.exe /im dllhost.exe /f *>$null
    get-appxpackage '*notepad*' | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    #enable win10 notepad
    Add-WindowsCapability -Online -Name Microsoft.Windows.Notepad.System~~~~0.0.1.0 -LimitAccess | Out-Null
    # fix registry 
    Remove-Item -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\App Paths\notepad.exe' -Force -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Classes\Applications\notepad.exe' -Name NoOpenWith -Force -ErrorAction SilentlyContinue
    reg.exe add 'HKLM\SOFTWARE\Classes\*\OpenWithList\notepad.exe' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\.htm\OpenWithList' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\.htm\OpenWithList\notepad.exe' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\.inf' /ve /t REG_SZ /d 'inffile' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\.ini' /ve /t REG_SZ /d 'inifile' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\.log' /ve /t REG_SZ /d 'txtfile' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\.ps1' /ve /t REG_SZ /d 'Microsoft.PowerShellScript.1' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\.psd1' /ve /t REG_SZ /d 'Microsoft.PowerShellData.1' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\.psm1' /ve /t REG_SZ /d 'Microsoft.PowerShellModule.1' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\.scp' /ve /t REG_SZ /d 'txtfile' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\.txt' /ve /t REG_SZ /d 'txtfile' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\.txt\ShellNew' /v 'ItemName' /t REG_EXPAND_SZ /d '@%SystemRoot%\system32\notepad.exe,-470' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\.txt\ShellNew' /v 'NullFile' /t REG_SZ /d ' ' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\.wtx' /ve /t REG_SZ /d 'txtfile' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\Applications\notepad.exe' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\Applications\notepad.exe\shell' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\Applications\notepad.exe\shell\edit' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\Applications\notepad.exe\shell\edit\command' /ve /t REG_EXPAND_SZ /d '%SystemRoot%\system32\NOTEPAD.EXE %1' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\Applications\notepad.exe\shell\open' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\Applications\notepad.exe\shell\open\command' /ve /t REG_EXPAND_SZ /d '%SystemRoot%\system32\NOTEPAD.EXE %1' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\inffile' /ve /t REG_SZ /d 'Setup Information' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\inffile' /v 'FriendlyTypeName' /t REG_EXPAND_SZ /d '@%SystemRoot%\System32\setupapi.dll,-2000' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\inffile\DefaultIcon' /ve /t REG_EXPAND_SZ /d '%SystemRoot%\System32\imageres.dll,-69' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\inffile\shell' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\inffile\shell\open' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\inffile\shell\open\command' /ve /t REG_EXPAND_SZ /d '%SystemRoot%\system32\NOTEPAD.EXE %1' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\inffile\shell\print' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\inffile\shell\print\command' /ve /t REG_EXPAND_SZ /d '%SystemRoot%\system32\NOTEPAD.EXE /p %1' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\inifile' /ve /t REG_SZ /d 'Configuration Settings' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\inifile' /v 'EditFlags' /t REG_DWORD /d 0x00200000 /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\inifile' /v 'FriendlyTypeName' /t REG_SZ /d '@shell32.dll,-10151' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\inifile\DefaultIcon' /ve /t REG_EXPAND_SZ /d '%SystemRoot%\system32\imageres.dll,-69' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\inifile\shell' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\inifile\shell\open' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\inifile\shell\open\command' /ve /t REG_EXPAND_SZ /d '%SystemRoot%\system32\NOTEPAD.EXE %1' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\inifile\shell\print' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\inifile\shell\print\command' /ve /t REG_EXPAND_SZ /d '%SystemRoot%\system32\NOTEPAD.EXE /p %1' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\Microsoft.PowerShellData.1' /v 'EditFlags' /t REG_DWORD /d 0x00020000 /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\Microsoft.PowerShellData.1' /v 'FriendlyTypeName' /t REG_EXPAND_SZ /d "@\`"%systemroot%\system32\windowspowershell\v1.0\powershell.exe\`",-104" /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\Microsoft.PowerShellData.1\Shell' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\Microsoft.PowerShellData.1\Shell\Open' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\Microsoft.PowerShellData.1\Shell\Open\Command' /ve /t REG_SZ /d "\`"C:\Windows\System32\notepad.exe\`" \`"%1\`"" /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\Microsoft.PowerShellModule.1' /v 'EditFlags' /t REG_DWORD /d 0x00020000 /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\Microsoft.PowerShellModule.1' /v 'FriendlyTypeName' /t REG_EXPAND_SZ /d "@\`"%systemroot%\system32\windowspowershell\v1.0\powershell.exe\`",-106" /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\Microsoft.PowerShellModule.1\Shell' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\Microsoft.PowerShellModule.1\Shell\Open' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\Microsoft.PowerShellModule.1\Shell\Open\Command' /ve /t REG_SZ /d "\`"C:\Windows\System32\notepad.exe\`" \`"%1\`"" /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\Microsoft.PowerShellScript.1' /v 'EditFlags' /t REG_DWORD /d 0x00020000 /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\Microsoft.PowerShellScript.1' /v 'FriendlyTypeName' /t REG_EXPAND_SZ /d "@\`"%systemroot%\system32\windowspowershell\v1.0\powershell.exe\`",-103" /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\Microsoft.PowerShellScript.1\DefaultIcon' /ve /t REG_SZ /d "\`"C:\Windows\System32\WindowsPowerShell\v1.0\powershell_ise.exe\`",1" /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\Microsoft.PowerShellScript.1\Shell' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\Microsoft.PowerShellScript.1\Shell\Open' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\Microsoft.PowerShellScript.1\Shell\Open\Command' /ve /t REG_SZ /d "\`"C:\Windows\System32\notepad.exe\`" \`"%1\`"" /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\SystemFileAssociations\text\OpenWithList' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\SystemFileAssociations\text\OpenWithList\Notepad.exe' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\SystemFileAssociations\text\shell' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\SystemFileAssociations\text\shell\edit' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\SystemFileAssociations\text\shell\edit\command' /ve /t REG_EXPAND_SZ /d '%SystemRoot%\system32\NOTEPAD.EXE %1' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\SystemFileAssociations\text\shell\open' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\SystemFileAssociations\text\shell\open\command' /ve /t REG_EXPAND_SZ /d '%SystemRoot%\system32\NOTEPAD.EXE %1' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\txtfile' /ve /t REG_SZ /d 'Text Document' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\txtfile' /v 'EditFlags' /t REG_DWORD /d 0x00210000 /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\txtfile' /v 'FriendlyTypeName' /t REG_EXPAND_SZ /d '@%SystemRoot%\system32\notepad.exe,-469' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\txtfile\DefaultIcon' /ve /t REG_EXPAND_SZ /d '%SystemRoot%\system32\imageres.dll,-102' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\txtfile\shell' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\txtfile\shell\open' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\txtfile\shell\open\command' /ve /t REG_EXPAND_SZ /d '%SystemRoot%\system32\NOTEPAD.EXE %1' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\txtfile\shell\print' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\txtfile\shell\print\command' /ve /t REG_EXPAND_SZ /d '%SystemRoot%\system32\NOTEPAD.EXE /p %1' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\txtfile\shell\printto' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Classes\txtfile\shell\printto\command' /ve /t REG_EXPAND_SZ /d "%SystemRoot%\system32\notepad.exe /pt \`"%1\`" \`"%2\`" \`"%3\`" \`"%4\`"" /f >$null
    reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\Notepad' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\Notepad\Capabilities' /v 'ApplicationDescription' /t REG_EXPAND_SZ /d '@%SystemRoot%\system32\NOTEPAD.EXE,-9' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\Notepad\Capabilities' /v 'ApplicationName' /t REG_EXPAND_SZ /d '@%SystemRoot%\system32\NOTEPAD.EXE,-9' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\Notepad\Capabilities\FileAssociations' /v '.ini' /t REG_SZ /d 'inifile' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\Notepad\Capabilities\FileAssociations' /v '.log' /t REG_SZ /d 'logfile' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\Notepad\Capabilities\FileAssociations' /v '.scp' /t REG_SZ /d 'scpfile' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\Notepad\Capabilities\FileAssociations' /v '.txt' /t REG_SZ /d 'txtfile' /f >$null
    reg.exe add 'HKLM\SOFTWARE\Microsoft\Windows\Notepad\Capabilities\FileAssociations' /v '.wtx' /t REG_SZ /d 'wtxfile' /f >$null
    reg.exe add 'HKLM\SOFTWARE\RegisteredApplications' /v 'Notepad' /t REG_SZ /d 'Software\Microsoft\Windows\Notepad\Capabilities' /f >$null
    reg.exe add 'HKCU\Software\Microsoft\Notepad' /v 'ShowStoreBanner' /t REG_DWORD /d 0x00000000 /f >$null

    #create start shortcut
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut('C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Notepad.lnk')
    $Shortcut.TargetPath = 'C:\Windows\System32\Notepad.exe'
    $Shortcut.Save()

}
