# Jendela utama (tampilan: MainWindow.xaml, daftar opsi: Catalog.ps1).

function Update-Ui {
    # Biarkan WPF menggambar ulang di sela proses yang berjalan di thread yang sama
    $script:Window.Dispatcher.Invoke([Action] {}, [System.Windows.Threading.DispatcherPriority]::Background)
}

function Update-GroupLabels {
    foreach ($g in @(@('ai', $script:BtnToggleAi), @('classic', $script:BtnToggleClassic))) {
        $items = @($Global:Catalog | Where-Object { $_.Group -eq $g[0] })
        $off = @($items | Where-Object { -not $script:UiToggles[$_.Key].IsChecked })
        if ($off.Count -eq 0) { $g[1].Content = 'Kosongkan' } else { $g[1].Content = 'Pilih semua' }
    }
}

function Set-GroupState {
    param([string]$Group)
    $items = @($Global:Catalog | Where-Object { $_.Group -eq $Group })
    $off = @($items | Where-Object { -not $script:UiToggles[$_.Key].IsChecked })
    $newState = ($off.Count -gt 0)
    foreach ($i in $items) { $script:UiToggles[$i.Key].IsChecked = $newState }
    Update-GroupLabels
}

function New-OptionRow {
    param($Item)
    $w = $script:Window
    $title = New-Object System.Windows.Controls.TextBlock
    $title.Text = $Item.Title
    $title.Style = $w.FindResource('RowTitle')
    $desc = New-Object System.Windows.Controls.TextBlock
    $desc.Text = $Item.Desc
    $desc.Style = $w.FindResource('RowDesc')
    $panel = New-Object System.Windows.Controls.StackPanel
    [void]$panel.Children.Add($title)
    [void]$panel.Children.Add($desc)

    $row = New-Object System.Windows.Controls.Primitives.ToggleButton
    $row.Style = $w.FindResource('OptionRow')
    $row.Content = $panel
    $row.IsChecked = [bool]$Item.Default
    $row.Add_Click({ Update-GroupLabels })
    return $row
}

function Start-UiRun {
    param($Selected)

    $script:Busy = $true
    $errors = 0
    $Global:MekatikUiLog = {
        param($line)
        $script:UiLogBox.AppendText($line + "`r`n")
        $script:UiLogBox.ScrollToEnd()
        Update-Ui
    }

    $script:UiLogBox.Clear()
    $script:UiTitle.Text = 'Sedang diproses'
    $script:UiStep.Text = 'Menyiapkan...'
    $script:UiProgress.Value = 0
    $script:UiDone.Visibility = 'Collapsed'
    $script:UiOverlay.Visibility = 'Visible'
    Update-Ui

    try {
        Write-Status -msg 'Menghentikan proses AI yang sedang berjalan...'
        $aiProcesses = 'ai.exe', 'Copilot.exe', 'aihost.exe', 'aicontext.exe', 'ClickToDo.exe', 'aixhost.exe',
        'WorkloadsSessionHost.exe', 'WebViewHost.exe', 'aimgr.exe', 'AppActions.exe'
        foreach ($p in $aiProcesses) { taskkill /im $p /f *>$null }

        if ($Global:backup) {
            $script:UiStep.Text = 'Membuat titik pemulihan...'
            Update-Ui
            Create-RestorePoint
        }

        $done = 0
        foreach ($item in $Selected) {
            $script:UiStep.Text = $item.Title
            $script:UiProgress.Value = [int](100 * $done / $Selected.Count)
            Write-Status -msg "Menjalankan: $($item.Title)"
            try { & $item.Run }
            catch {
                $errors++
                Write-Status -msg "$($item.Title): $($_.Exception.Message)" -errorOutput
            }
            $done++
            Update-Ui
        }

        $script:UiProgress.Value = 100
        if ($errors -eq 0) {
            $script:UiTitle.Text = 'Selesai'
            $script:UiStep.Text = 'Semua langkah berhasil. Mulai ulang komputer agar perubahan berlaku penuh.'
        }
        else {
            $script:UiTitle.Text = 'Selesai dengan catatan'
            $script:UiStep.Text = "$errors langkah mengalami kesalahan, lihat log di atas. Mulai ulang komputer agar perubahan berlaku."
        }
    }
    catch {
        $script:UiTitle.Text = 'Terjadi kesalahan'
        $script:UiStep.Text = $_.Exception.Message
    }
    finally {
        $script:Busy = $false
        $Global:MekatikUiLog = $null
        $script:UiDone.Visibility = 'Visible'
    }
}

function Show-MainWindow {
    # ID aplikasi sendiri, supaya ikon di taskbar tidak ikut ikon PowerShell
    try {
        Add-Type -Namespace Mekatik -Name Shell -ErrorAction Stop -MemberDefinition '[System.Runtime.InteropServices.DllImport("shell32.dll")] public static extern void SetCurrentProcessExplicitAppUserModelID([System.Runtime.InteropServices.MarshalAs(System.Runtime.InteropServices.UnmanagedType.LPWStr)] string AppID);'
        [Mekatik.Shell]::SetCurrentProcessExplicitAppUserModelID('Mekatik.RemoveWindowsAI')
    }
    catch { }

    $xaml = [System.IO.File]::ReadAllText((Join-Path $Global:SrcRoot 'UI\MainWindow.xaml'), [System.Text.Encoding]::UTF8)
    $w = [System.Windows.Markup.XamlReader]::Parse($xaml)
    $script:Window = $w
    $script:Busy = $false

    # Logo
    $logoPath = Join-Path $Global:MekatikRoot 'assets\logo.png'
    if (Test-Path $logoPath) {
        $bmp = New-Object System.Windows.Media.Imaging.BitmapImage
        $bmp.BeginInit()
        $bmp.UriSource = New-Object System.Uri($logoPath)
        $bmp.CacheOption = [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
        $bmp.EndInit()
        $bmp.Freeze()
        $w.FindName('Logo').Source = $bmp
    }

    # Ikon jendela (title bar dan taskbar)
    $iconPath = Join-Path $Global:MekatikRoot 'assets\icon.ico'
    if (Test-Path $iconPath) {
        try { $w.Icon = [System.Windows.Media.Imaging.BitmapFrame]::Create((New-Object System.Uri($iconPath)), 'None', 'OnLoad') }
        catch { }
    }

    # Elemen yang dipakai ulang
    $script:UiOverlay = $w.FindName('Overlay')
    $script:UiTitle = $w.FindName('OverlayTitle')
    $script:UiStep = $w.FindName('OverlayStep')
    $script:UiProgress = $w.FindName('Progress')
    $script:UiLogBox = $w.FindName('LogBox')
    $script:UiDone = $w.FindName('DonePanel')
    $script:BtnToggleAi = $w.FindName('BtnToggleAi')
    $script:BtnToggleClassic = $w.FindName('BtnToggleClassic')

    # Baris opsi dari katalog
    $script:UiToggles = @{}
    $listAi = $w.FindName('ListAi')
    $listClassic = $w.FindName('ListClassic')
    foreach ($item in $Global:Catalog) {
        $row = New-OptionRow -Item $item
        $script:UiToggles[$item.Key] = $row
        if ($item.Group -eq 'ai') { [void]$listAi.Children.Add($row) }
        else { [void]$listClassic.Children.Add($row) }
    }
    Update-GroupLabels

    # Mode Revert / Backup (tidak boleh aktif bersamaan)
    $script:TglRevert = $w.FindName('TglRevert')
    $script:TglBackup = $w.FindName('TglBackup')
    $script:TglRevert.IsChecked = [bool]$Global:revert
    $script:TglBackup.IsChecked = [bool]$Global:backup
    $script:TglRevert.Add_Checked({ $Global:revert = 1; $script:TglBackup.IsChecked = $false })
    $script:TglRevert.Add_Unchecked({ $Global:revert = 0 })
    $script:TglBackup.Add_Checked({ $Global:backup = 1; $script:TglRevert.IsChecked = $false })
    $script:TglBackup.Add_Unchecked({ $Global:backup = 0 })

    # Tombol
    $script:BtnToggleAi.Add_Click({ Set-GroupState -Group 'ai' })
    $script:BtnToggleClassic.Add_Click({ Set-GroupState -Group 'classic' })
    $w.FindName('BtnMin').Add_Click({ $script:Window.WindowState = 'Minimized' })
    $w.FindName('BtnClose').Add_Click({ $script:Window.Close() })
    $w.FindName('BtnCancel').Add_Click({ $script:Window.Close() })
    $w.FindName('BtnLater').Add_Click({ $script:Window.Close() })
    $w.FindName('BtnRestart').Add_Click({
            Invoke-Cleanup
            Restart-Computer -Force
        })
    $w.FindName('BtnApply').Add_Click({
            $selected = @($Global:Catalog | Where-Object { $script:UiToggles[$_.Key].IsChecked })
            if ($selected.Count -eq 0) {
                [System.Windows.MessageBox]::Show('Belum ada opsi yang dipilih.', 'Remove Windows AI bay Mekatik', 'OK', 'Information') | Out-Null
                return
            }
            Start-UiRun -Selected $selected
        })

    # Jangan tutup jendela saat proses berjalan
    $w.Add_Closing({
            param($sender, $e)
            if ($script:Busy) { $e.Cancel = $true }
        })

    [void]$w.ShowDialog()
}
