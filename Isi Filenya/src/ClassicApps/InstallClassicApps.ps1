# Install-ClassicApps - pintu masuk untuk memasang aplikasi klasik.
# Semua file ada di folder data\ClassicApps (tanpa unduhan).

function Install-ClassicApps {
    param(
        [ValidateSet('photoviewer', 'mspaint', 'snippingtool', 'notepad', 'photoslegacy')]
        [string]$app
    )

    $classicApps = Join-Path $Global:MekatikRoot 'data\ClassicApps'
    if (-not (Test-Path $classicApps)) {
        Write-Status -msg "Folder $classicApps tidak ditemukan. Ekstrak ulang file zip." -errorOutput
        return
    }

    switch ($app) {
        'photoviewer' { Write-Status -msg 'Memasang Photo Viewer klasik...'; install-photoviewer }
        'mspaint' { Write-Status -msg 'Memasang Paint klasik...'; install-paint -path $classicApps }
        'snippingtool' { Write-Status -msg 'Memasang Snipping Tool klasik...'; install-snipping -path $classicApps }
        'notepad' { Write-Status -msg 'Memasang Notepad klasik...'; install-notepad }
        'photoslegacy' { Write-Status -msg 'Memasang Photos Legacy...'; install-photoslegacy }
    }
}
