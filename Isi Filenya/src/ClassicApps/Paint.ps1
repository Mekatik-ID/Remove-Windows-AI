# install-paint - memasang Paint klasik.

function install-paint {
    param(
        [string]$path
    )
    Get-AppxPackage '*Microsoft.Paint*' | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue

    $command = "
    copy-item `"$path\paint\mspaint.exe`" -Destination `"$env:systemroot\system32\mspaint.exe`" -Force
    copy-item `"$path\paint\mspaint.exe.mui`" -Destination `"$env:systemroot\System32\en-US\mspaint.exe.mui`" -Force
    copy-item `"$path\paint\mspaint.exe.mun`" -Destination `"$env:systemroot\SystemResources`" -Force
"
    Run-Trusted -command $command
    Start-Sleep 1
    $command = "regedit.exe /s `"$path\paint\paint.reg`""
    Run-Trusted -command $command

    $pad = Get-WindowsLangFolder
    if ($pad) {
        $command = "Copy-Item -Path `"$path\paint\paint_lang_files\$pad\mspaint.exe.mui`" -Destination `"$env:SYSTEMROOT\System32\$pad\mspaint.exe.mui`" -Force"
        Run-Trusted -command $command
        Write-Status -msg "File bahasa $pad disalin"
    }

    # shortcut menu Start
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut('C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Paint.lnk')
    $Shortcut.TargetPath = 'C:\Windows\System32\mspaint.exe'
    $Shortcut.Save()
}
