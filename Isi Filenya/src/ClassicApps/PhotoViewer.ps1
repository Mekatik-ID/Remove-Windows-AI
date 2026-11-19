# install-photoviewer

function install-photoviewer {
    
    #restore classic photoviewer
    # Kelas asosiasi yang HARUS dibuat (nama kelas, bukan ekstensi): Bitmap dan Tiff sebelumnya tidak pernah dibuat,
    # sehingga .bmp/.dib/.tif/.tiff/.cr2 menunjuk ke kelas yang tidak ada.
    $classes = @('Bitmap', 'Gif', 'JFIF', 'Jpeg', 'Png', 'Tiff', 'Wdp')
    foreach ($cls in $classes) {
        $base = "HKLM\SOFTWARE\Classes\PhotoViewer.FileAssoc.$cls"
        reg.exe add $base /v 'EditFlags' /t REG_DWORD /d 65536 /f >$null
        reg.exe add $base /v 'ImageOptionFlags' /t REG_DWORD /d 1 /f >$null
        reg.exe add $base /v 'FriendlyTypeName' /t REG_EXPAND_SZ /d '@%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll,-3055' /f >$null
        reg.exe add "$base\DefaultIcon" /ve /t REG_SZ /d '%SystemRoot%\System32\imageres.dll,-72' /f >$null
        reg.exe add "$base\shell\open" /v 'MuiVerb' /t REG_EXPAND_SZ /d '@%ProgramFiles%\Windows Photo Viewer\photoviewer.dll,-3043' /f >$null
        reg.exe add "$base\shell\open\command" /ve /t REG_EXPAND_SZ /d "%SystemRoot%\System32\rundll32.exe \`"%ProgramFiles%\Windows Photo Viewer\PhotoViewer.dll\`", ImageView_Fullscreen %1" /f >$null
        reg.exe add "$base\shell\open\DropTarget" /v 'Clsid' /t REG_SZ /d '{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}' /f >$null
    }

    # Daftarkan Photo Viewer sebagai aplikasi (agar muncul di Aplikasi Default)
    $cap = 'HKLM\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities'
    reg.exe add $cap /v 'ApplicationDescription' /t REG_EXPAND_SZ /d '@%ProgramFiles%\Windows Photo Viewer\photoviewer.dll,-3069' /f >$null
    reg.exe add $cap /v 'ApplicationName' /t REG_EXPAND_SZ /d '@%ProgramFiles%\Windows Photo Viewer\photoviewer.dll,-3009' /f >$null
    reg.exe add 'HKLM\SOFTWARE\RegisteredApplications' /v 'Windows Photo Viewer' /t REG_SZ /d 'Software\Microsoft\Windows Photo Viewer\Capabilities' /f >$null

    # Ekstensi -> kelas asosiasi
    $map = [ordered]@{
        '.bmp' = 'Bitmap'; '.dib' = 'Bitmap'
        '.cr2' = 'Tiff'; '.tif' = 'Tiff'; '.tiff' = 'Tiff'
        '.gif' = 'Gif'
        '.jfif' = 'JFIF'
        '.jpg' = 'Jpeg'; '.jpe' = 'Jpeg'; '.jpeg' = 'Jpeg'
        '.png' = 'Png'
        '.jxr' = 'Wdp'; '.wdp' = 'Wdp'
    }
    foreach ($ext in $map.Keys) {
        reg.exe add "$cap\FileAssociations" /v $ext /t REG_SZ /d "PhotoViewer.FileAssoc.$($map[$ext])" /f >$null
    }
}
