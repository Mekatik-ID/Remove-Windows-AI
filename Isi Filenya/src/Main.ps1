<#
  Remove Windows AI bay Mekatik
  Dibuat oleh: Mekatik
  Lisensi: lihat file LICENSE

  Cara pakai biasa : klik dua kali Remove Windows AI bay Mekatik.exe (di folder luar),
                     atau klik kanan Isi Filenya\Remove Windows AI bay Mekatik.bat -> Run as administrator
  Mode non-interaktif (contoh):
    powershell -File Isi Filenya\src\Main.ps1 -nonInteractive -AllOptions
    powershell -File Isi Filenya\src\Main.ps1 -nonInteractive -Options DisableRegKeys,RemoveAIFiles -InstallClassicApps notepad
#>

param(
    [switch]$EnableLogging,
    [switch]$nonInteractive,
    [ValidateSet('DisableRegKeys',
        'PreventAIPackageReinstall',
        'DisableCopilotPolicies',
        'RemoveAppxPackages',
        'RemoveRecallFeature',
        'RemoveCBSPackages',
        'RemoveAIFiles',
        'HideAIComponents',
        'DisableRewrite',
        'RemoveRecallTasks')]
    [array]$Options,
    [switch]$AllOptions,
    [switch]$revertMode,
    [switch]$backupMode,
    [ValidateSet('photoviewer', 'mspaint', 'snippingtool', 'notepad', 'photoslegacy')]
    [array]$InstallClassicApps
)

$Global:SrcRoot = $PSScriptRoot
$Global:MekatikRoot = Split-Path -Parent $PSScriptRoot
$Global:tempDir = [System.IO.Path]::GetTempPath()
$Global:revert = [int][bool]$revertMode
$Global:backup = [int][bool]$backupMode

if ($nonInteractive -and -not $AllOptions -and -not $Options -and -not $InstallClassicApps) {
    throw 'Mode non-interaktif butuh -Options, -AllOptions, atau -InstallClassicApps.'
}

. (Join-Path $Global:SrcRoot 'Core\Common.ps1')

# --- Wajib Windows PowerShell 5.1 ---
if ($PSVersionTable.PSVersion.Major -ge 6) {
    $Global:psversion = 7
    Write-Status -msg "Skrip ini butuh Windows PowerShell 5.1 (powershell.exe), bukan PowerShell $($PSVersionTable.PSVersion.Major)." -errorOutput
    if (-not $nonInteractive) {
        try {
            Add-Type -AssemblyName System.Windows.Forms
            [System.Windows.Forms.MessageBox]::Show("Skrip ini harus dijalankan di Windows PowerShell 5.1.`n`nVersi sekarang: $($PSVersionTable.PSVersion)`n`nGunakan powershell.exe, bukan pwsh.exe.",
                'Remove Windows AI bay Mekatik', 'OK', 'Error') | Out-Null
        }
        catch { }
    }
    exit 1
}
$Global:psversion = 5

# --- Wajib Administrator: jalankan ulang bila belum ---
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')
if (-not $isAdmin) {
    $cmd = "& '" + ($PSCommandPath -replace "'", "''") + "'"
    if ($nonInteractive) { $cmd += ' -nonInteractive' }
    if ($AllOptions) { $cmd += ' -AllOptions' }
    elseif ($Options) { $cmd += ' -Options ' + ($Options -join ',') }
    if ($InstallClassicApps) { $cmd += ' -InstallClassicApps ' + ($InstallClassicApps -join ',') }
    if ($revertMode) { $cmd += ' -revertMode' }
    if ($backupMode) { $cmd += ' -backupMode' }
    if ($EnableLogging) { $cmd += ' -EnableLogging' }
    $style = if ($nonInteractive) { 'Normal' } else { 'Hidden' }
    Start-Process powershell.exe -ArgumentList '-NoProfile', '-ExecutionPolicy', 'Bypass', '-WindowStyle', $style, '-Command', "`"$cmd`"" -Verb RunAs
    exit
}

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase
Add-Type -AssemblyName System.Windows.Forms

# Hapus tanda "diunduh dari internet" pada semua file proyek
Get-ChildItem -LiteralPath $Global:MekatikRoot -Recurse -File -ErrorAction SilentlyContinue | Unblock-File -ErrorAction SilentlyContinue

# --- Log (opsional) ---
if ($EnableLogging) {
    $date = (Get-Date).ToString('MM-dd-yyyy-HH:mm') -replace ':'
    $Global:logPath = "$env:USERPROFILE\RemoveWindowsAI$date.log"
    New-Item $logPath -Force | Out-Null
    Write-Status -msg "Log disimpan di [$logPath]"
    Start-Transcript -Path $logPath -IncludeInvocationHeader | Out-Null
    Stop-Transcript | Out-Null
    $Global:logInfo = [PSCustomObject]@{ Line = $null; Result = $null }
}

# --- Muat semua modul ---
foreach ($dir in 'Core', 'Features', 'ClassicApps') {
    foreach ($file in Get-ChildItem -LiteralPath (Join-Path $Global:SrcRoot $dir) -Filter *.ps1 | Sort-Object Name) {
        . $file.FullName
    }
}
. (Join-Path $Global:SrcRoot 'Catalog.ps1')
. (Join-Path $Global:SrcRoot 'UI\Show-MainWindow.ps1')

# --- Jalankan ---
try {
    if ($nonInteractive) {
        if ($Global:backup) { Create-RestorePoint -nonInteractive }

        $toRun = @($Global:Catalog | Where-Object { $_.Group -eq 'ai' -and ($AllOptions -or $Options -contains $_.Key) })
        foreach ($item in $toRun) {
            Write-Status -msg $item.Title
            & $item.Run
        }
        foreach ($app in $InstallClassicApps) { Install-ClassicApps -app $app }
    }
    else {
        Show-MainWindow
    }
}
catch {
    $msg = $_.Exception.Message
    Add-Content -Path (Join-Path $Global:tempDir 'Mekatik-error.log') -Value "$(Get-Date) $msg`r`n$($_.ScriptStackTrace)"
    if (-not $nonInteractive) {
        [System.Windows.MessageBox]::Show("Terjadi kesalahan:`n`n$msg", 'Remove Windows AI bay Mekatik', 'OK', 'Error') | Out-Null
    }
    else { Write-Status -msg $msg -errorOutput }
}
finally {
    Invoke-Cleanup
}
