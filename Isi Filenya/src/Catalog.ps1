# Daftar semua opsi. Dipakai oleh jendela utama DAN mode non-interaktif,
# jadi untuk menambah/mengubah opsi cukup edit file ini.
#   Key     : nama untuk parameter -Options / -InstallClassicApps
#   Group   : 'ai' (hapus AI) atau 'classic' (aplikasi klasik)
#   Default : dicentang saat jendela dibuka
#   Run     : perintah yang dijalankan

$Global:Catalog = @(
    [pscustomobject]@{ Key = 'DisableRegKeys'; Group = 'ai'; Default = $true
        Title = 'Matikan lewat Registry'
        Desc = 'Mematikan Copilot, Recall, dan AI di Pencarian, Edge, dan Paint.'
        Run = { Disable-Registry-Keys } }
    [pscustomobject]@{ Key = 'PreventAIPackageReinstall'; Group = 'ai'; Default = $true
        Title = 'Cegah pemasangan ulang'
        Desc = 'Mencegah Windows Update memasang ulang paket AI.'
        Run = { Install-NOAIPackage } }
    [pscustomobject]@{ Key = 'DisableCopilotPolicies'; Group = 'ai'; Default = $true
        Title = 'Matikan kebijakan Copilot'
        Desc = 'Menonaktifkan Copilot di file kebijakan wilayah Windows.'
        Run = { Disable-Copilot-Policies } }
    [pscustomobject]@{ Key = 'RemoveAppxPackages'; Group = 'ai'; Default = $true
        Title = 'Hapus paket Appx AI'
        Desc = 'Menghapus aplikasi AI seperti Copilot, AIX, dan CoreAI.'
        Run = { Remove-AI-Appx-Packages } }
    [pscustomobject]@{ Key = 'RemoveRecallFeature'; Group = 'ai'; Default = $true
        Title = 'Hapus fitur Recall'
        Desc = 'Menghapus fitur Recall dari sistem.'
        Run = { Remove-Recall-Optional-Feature } }
    [pscustomobject]@{ Key = 'RemoveCBSPackages'; Group = 'ai'; Default = $true
        Title = 'Hapus paket AI tersembunyi (CBS)'
        Desc = 'Menghapus paket AI yang tersembunyi di sistem.'
        Run = { Remove-AI-CBS-Packages } }
    [pscustomobject]@{ Key = 'RemoveAIFiles'; Group = 'ai'; Default = $true
        Title = 'Bersihkan file AI'
        Desc = 'Menghapus file AI dari folder sistem, termasuk Copilot.'
        Run = { Remove-AI-Files } }
    [pscustomobject]@{ Key = 'HideAIComponents'; Group = 'ai'; Default = $true
        Title = 'Sembunyikan komponen AI di Pengaturan'
        Desc = 'Menyembunyikan halaman AI di Pengaturan Windows.'
        Run = { Hide-AI-Components } }
    [pscustomobject]@{ Key = 'DisableRewrite'; Group = 'ai'; Default = $true
        Title = 'Matikan Rewrite di Notepad'
        Desc = 'Mematikan fitur Rewrite (AI) di Notepad.'
        Run = { Disable-Notepad-Rewrite } }
    [pscustomobject]@{ Key = 'RemoveRecallTasks'; Group = 'ai'; Default = $true
        Title = 'Hapus tugas terjadwal Recall'
        Desc = 'Menghapus tugas Recall dari Task Scheduler.'
        Run = { Remove-Recall-Tasks } }

    [pscustomobject]@{ Key = 'photoviewer'; Group = 'classic'; Default = $false
        Title = 'Photo Viewer klasik'
        Desc = 'Mengembalikan Windows Photo Viewer lama sebagai pengganti Foto.'
        Run = { Install-ClassicApps -app 'photoviewer' } }
    [pscustomobject]@{ Key = 'mspaint'; Group = 'classic'; Default = $false
        Title = 'Paint klasik'
        Desc = 'Memasang Paint versi lama tanpa fitur AI.'
        Run = { Install-ClassicApps -app 'mspaint' } }
    [pscustomobject]@{ Key = 'snippingtool'; Group = 'classic'; Default = $false
        Title = 'Snipping Tool klasik'
        Desc = 'Memasang Snipping Tool versi lama.'
        Run = { Install-ClassicApps -app 'snippingtool' } }
    [pscustomobject]@{ Key = 'notepad'; Group = 'classic'; Default = $false
        Title = 'Notepad klasik'
        Desc = 'Memasang Notepad lama dari Windows 10.'
        Run = { Install-ClassicApps -app 'notepad' } }
    [pscustomobject]@{ Key = 'photoslegacy'; Group = 'classic'; Default = $false
        Title = 'Photos Legacy'
        Desc = 'Memasang aplikasi Foto versi lama dari Microsoft Store.'
        Run = { Install-ClassicApps -app 'photoslegacy' } }
)
