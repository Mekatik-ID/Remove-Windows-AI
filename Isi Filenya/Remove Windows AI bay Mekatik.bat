@echo off
title Remove Windows AI bay Mekatik
cd /d "%~dp0"
set "MK_MAIN=%~dp0src\Main.ps1"
:: Minta hak Administrator jika belum. Yang dijalankan ulang adalah PowerShell (bukan file .bat ini lagi),
:: jadi peringatan keamanan "Open File - Security Warning" tidak muncul berulang.
:: Sengaja TIDAK memakai blok if ( ... ): path yang berisi tanda kurung tutup (mis. "Downloads (1)") merusak blok itu.
net session >nul 2>&1
if %errorlevel% neq 0 goto :elevate
:: Wajib Windows PowerShell 5.1 (bukan pwsh 7). Konsol disembunyikan, semua info tampil di jendela aplikasi.
start "" powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%MK_MAIN%"
exit /b
:elevate
powershell.exe -NoProfile -Command "Start-Process powershell.exe -Verb RunAs -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-WindowStyle','Hidden','-File',('\"'+$env:MK_MAIN+'\"'))"
exit /b
