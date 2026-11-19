# Download-AppxPackage - helper unduh paket Appx (dipakai Photos Legacy).

#function from: https://github.com/Andrew-J-Larson/OS-Scripts/blob/main/Windows/Wrapper-Functions/Download-AppxPackage-Function.ps1
function Download-AppxPackage {
    param(
        # there has to be an alternative, as sometimes the API fails on PackageFamilyName
        [string]$PackageFamilyName,
        [string]$ProductId,
        [string]$outputDir
    )
    if (-Not ($PackageFamilyName -Or $ProductId)) {
        # can't do anything without at least one
        Write-Error 'Missing either PackageFamilyName or ProductId.'
        return $null
    }
      
    try {
        $UserAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::Chrome # needed as sometimes the API will block things when it knows requests are coming from PowerShell
    }
    catch {
        #ignore error
    }
      
    $DownloadedFiles = @()
    $errored = $false
    $allFilesDownloaded = $true
      
    $apiUrl = 'https://store.rg-adguard.net/api/GetFiles'
    $versionRing = 'Retail'
      
    $architecture = switch ($env:PROCESSOR_ARCHITECTURE) {
        'x86' { 'x86' }
        { @('x64', 'amd64') -contains $_ } { 'x64' }
        'arm' { 'arm' }
        'arm64' { 'arm64' }
        default { 'neutral' } # should never get here
    }
      
    if (Test-Path $outputDir -PathType Container) {
        New-Item -Path "$outputDir\$PackageFamilyName" -ItemType Directory -Force | Out-Null
        $downloadFolder = "$outputDir\$PackageFamilyName"
    }
    else {
        
        $downloadFolder = Join-Path $tempDir $PackageFamilyName
        if (!(Test-Path $downloadFolder -PathType Container)) {
            New-Item $downloadFolder -ItemType Directory -Force | Out-Null
        }
    }
        
    $body = @{
        type = if ($ProductId) { 'ProductId' } else { 'PackageFamilyName' }
        url  = if ($ProductId) { $ProductId } else { $PackageFamilyName }
        ring = $versionRing
        lang = 'en-US'
    }
      
    # required due to the api being protected behind Cloudflare now
    if (-Not $apiWebSession) {
        $apiHostname = (($apiUrl.split('/'))[0..2]) -Join '/'
        # -SessionVariable butuh NAMA variabel (string), bukan isinya; sebelumnya memakai $apiWebSession yang masih kosong
        try {
            Invoke-WebRequest -Uri $apiHostname -UserAgent $UserAgent -SessionVariable 'apiSession' -UseBasicParsing | Out-Null
            $global:apiWebSession = $apiSession
        }
        catch {
            Write-Host ('An error occurred: ' + $_)
            return $false
        }
    }
      
    $raw = $null
    try {
        $raw = Invoke-RestMethod -Method Post -Uri $apiUrl -ContentType 'application/x-www-form-urlencoded' -Body $body -UserAgent $UserAgent -WebSession $apiWebSession
    }
    catch {
        $errorMsg = 'An error occurred: ' + $_
        Write-Host $errorMsg
        $errored = $true
        return $false
    }
      
    # hashtable of packages by $name
    #  > values = hashtables of packages by $version
    #    > values = arrays of packages as objects (containing: url, filename, name, version, arch, publisherId, type)
    [Collections.Generic.Dictionary[string, Collections.Generic.Dictionary[string, array]]] $packageList = @{}
    # populate $packageList
    $patternUrlAndText = '<tr style.*<a href=\"(?<url>.*)"\s.*>(?<text>.*\.(app|msi)x.*)<\/a>'
    $raw | Select-String $patternUrlAndText -AllMatches | ForEach-Object { $_.Matches } | ForEach-Object {
        $url = ($_.Groups['url']).Value
        $text = ($_.Groups['text']).Value
        $textSplitUnderscore = $text.split('_')
        $name = $textSplitUnderscore.split('_')[0]
        $version = $textSplitUnderscore.split('_')[1]
        $arch = ($textSplitUnderscore.split('_')[2]).ToLower()
        $publisherId = ($textSplitUnderscore.split('_')[4]).split('.')[0]
        $textSplitPeriod = $text.split('.')
        $type = ($textSplitPeriod[$textSplitPeriod.length - 1]).ToLower()
      
        # create $name hash key hashtable, if it doesn't already exist
        if (!($packageList.keys -match ('^' + [Regex]::escape($name) + '$'))) {
            $packageList["$name"] = @{}
        }
        # create $version hash key array, if it doesn't already exist
        if (!(($packageList["$name"]).keys -match ('^' + [Regex]::escape($version) + '$'))) {
            ($packageList["$name"])["$version"] = @()
        }
       
        # add package to the array in the hashtable
        ($packageList["$name"])["$version"] += @{
            url         = $url
            filename    = $text
            name        = $name
            version     = $version
            arch        = $arch
            publisherId = $publisherId
            type        = $type
        }
    }
      
    # an array of packages as objects, meant to only contain one of each $name
    $latestPackages = @()
    # grabs the most updated package for $name and puts it into $latestPackages
    $packageList.GetEnumerator() | ForEach-Object { ($_.value).GetEnumerator() | Select-Object -Last 1 } | ForEach-Object {
        $packagesByType = $_.value
        $msixbundle = ($packagesByType | Where-Object { $_.type -match '^msixbundle$' })
        $appxbundle = ($packagesByType | Where-Object { $_.type -match '^appxbundle$' })
        $msix = ($packagesByType | Where-Object { ($_.type -match '^msix$') -And ($_.arch -match ('^' + [Regex]::Escape($architecture) + '$')) })
        $appx = ($packagesByType | Where-Object { ($_.type -match '^appx$') -And ($_.arch -match ('^' + [Regex]::Escape($architecture) + '$')) })
        if ($msixbundle) { $latestPackages += $msixbundle }
        elseif ($appxbundle) { $latestPackages += $appxbundle }
        elseif ($msix) { $latestPackages += $msix }
        elseif ($appx) { $latestPackages += $appx }
    }
      
    # download packages
    # foreach (bukan ForEach-Object): 'break' di dalam ForEach-Object menghentikan seluruh skrip
    foreach ($pkg in $latestPackages) {
        $url = $pkg.url
        $filename = $pkg.filename
        # TODO: may need to include detection in the future of expired package download URLs..... in the case that downloads take over 10 minutes to complete
      
        $downloadFile = Join-Path $downloadFolder $filename
      
        # If file already exists, ask to replace it
        # Konsol disembunyikan, jadi Read-Host akan menggantung selamanya: file lama langsung ditimpa
        if (Test-Path $downloadFile) {
            Remove-Item -Path $downloadFile -Force -ErrorAction SilentlyContinue
        }
      
        if (!(Test-Path $downloadFile)) {
            # Write-Host "Attempting download of `"${filename}`" to `"${downloadFile}`" . . ."
            $fileDownloaded = $null
            $PreviousProgressPreference = $ProgressPreference
            $ProgressPreference = 'SilentlyContinue' # avoids slow download when using Invoke-WebRequest
            try {
                Invoke-WebRequest -Uri $url -OutFile $downloadFile
                $fileDownloaded = $?
            }
            catch {
                $ProgressPreference = $PreviousProgressPreference # return ProgressPreference back to normal
                $errorMsg = 'An error occurred: ' + $_
                Write-Host $errorMsg
                $errored = $true
                break
            }
            $ProgressPreference = $PreviousProgressPreference # return ProgressPreference back to normal
            if ($fileDownloaded) { $DownloadedFiles += $downloadFile }
            else { $allFilesDownloaded = $false }
        }
    }
      
    if ($errored) { Write-Host 'Completed with some errors.' }
    if (-Not $allFilesDownloaded) { Write-Host 'Warning: Not all packages could be downloaded.' }
    return $DownloadedFiles
}
