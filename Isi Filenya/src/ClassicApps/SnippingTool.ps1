# install-snipping - memasang Snipping Tool klasik.

function install-snipping {
    param(
        [string]$path
    )
    Get-AppxPackage '*ScreenSketch*' -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue

    $command = "
    copy-item `"$path\snipping\SnippingTool.exe`" -Destination `"$env:systemroot\system32\SnippingTool.exe`" -Force
    copy-item `"$path\snipping\SnippingTool.exe.mui`" -Destination `"$env:systemroot\System32\en-US\SnippingTool.exe.mui`" -Force
"
    Run-Trusted -command $command
    Start-Sleep 1

    $pad = Get-WindowsLangFolder
    if ($pad) {
        $command = "Copy-Item -Path `"$path\snipping\snipping_lang_files\$pad\SnippingTool.exe.mui`" -Destination `"$env:SYSTEMROOT\System32\$pad\SnippingTool.exe.mui`" -Force"
        Run-Trusted -command $command
        Write-Status -msg "File bahasa $pad disalin"
    }

    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut('C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Accessories\SnippingTool.lnk')
    $Shortcut.TargetPath = 'C:\Windows\System32\SnippingTool.exe'
    $Shortcut.Save()
}
