$namesFile = "names.txt"
$imageFile = "image.gif" 

# Target base library folder pointing safely to your Desktop
$outputBaseDir = "$env:USERPROFILE\Desktop\SortedLibrary"

# Build the safe image file name
$newImageName = "sharkn3t, by wikdlabs" + [char]169 + ".gif"

$currentDir = (Get-Item .).FullName
$sourceNamesPath = Join-Path $currentDir $namesFile
$sourceImagePath = Join-Path $currentDir $imageFile

# Print debugging variables to screen
Write-Host "Current Script Location: $currentDir" -ForegroundColor Yellow
Write-Host "Target Library Base: $outputBaseDir" -ForegroundColor Yellow

if (-not (Test-Path -Path $sourceNamesPath)) {
    Write-Error "CRITICAL: Cannot find '$namesFile' inside: $currentDir"
    Read-Host -Prompt "Press Enter to exit"
    exit
}

# Ensure base directory exists (Modified for legacy PowerShell compatibility)
if (-not (Test-Path -Path $outputBaseDir)) {
    try {
        $null = New-Item -ItemType Directory -Force -Path $outputBaseDir
    } catch {
        Write-Error "CRITICAL: Failed to create base directory $outputBaseDir. Reason: $_"
        Read-Host -Prompt "Press Enter to exit"
        exit
    }
}

# Read names with strict UTF-8 support
$entries = [System.IO.File]::ReadAllLines($sourceNamesPath, [System.Text.Encoding]::UTF8)
$processedNames = New-Object System.Collections.Generic.HashSet[string]

Write-Host "Processing $($entries.Count) lines from text database..." -ForegroundColor Cyan

foreach ($line in $entries) {
    $originalName = $line.Trim()
    if ($originalName) {
        
        # Deduplication engine
        if (-not $processedNames.Add($originalName)) { continue }

        # Clean string to match valid folder standards
        $folderName = $originalName -replace '[\x00-\x1F\\/:*?"<>|]', ' '
        $folderName = $folderName.Trim() -replace '\.+$', ''
        $folderName = $folderName.Trim()

        if (-not $folderName) { continue }

        # Enforce character limits for subfolders
        if ($folderName.Length -gt 45) {
            $shortFolder = $folderName.Substring(0, 45).Trim() -replace '\.+$', ''
        } else {
            $shortFolder = $folderName
        }

        # Alphabetical Group Routing Engine
        $firstChar = $shortFolder.Substring(0,1).ToUpper()
        $alphaGroup = if ($firstChar -notmatch '^[A-Z]$') { "#" } else { $firstChar }

        # Combine folder destination strings cleanly
        $alphaParentFolder = Join-Path $outputBaseDir $alphaGroup
        $targetFolder = Join-Path $alphaParentFolder $shortFolder

        $newImagePath = Join-Path $targetFolder $newImageName
        $newGooglePath = Join-Path $targetFolder ($shortFolder + " - Google.url")
        $ytShortcutPath = Join-Path $targetFolder ($shortFolder + " - YouTube.url")
        $imgShortcutPath = Join-Path $targetFolder ($shortFolder + " - Google Images.url")
        
        $stream = $null
        try {
            # 1. Create the Main Alphabet parent folder (A, B, C...)
            if (-not (Test-Path -Path $alphaParentFolder)) {
                $null = New-Item -ItemType Directory -Force -Path $alphaParentFolder
            }

            # 2. Create the unique item folder
            if (-not (Test-Path -Path $targetFolder)) {
                $null = New-Item -ItemType Directory -Force -Path $targetFolder
            }
            
            # 3. Process image file replication (.gif copy)
            if ((Test-Path -Path $sourceImagePath) -and -not (Test-Path -Path $newImagePath)) {
                Copy-Item -Path $sourceImagePath -Destination $newImagePath -Force
            }

            # URL ENCODING FIXED: Pointing strictly to the parsed folder name
            $encodedQuery = [Uri]::EscapeDataString($shortFolder)

            # 4. GOOGLE LINK SHORTCUT
            if (-not (Test-Path -LiteralPath $newGooglePath)) {
                $encodedQuery = [Uri]::EscapeDataString($originalName)
                $protocol = "https:" + [char]47 + [char]47
                $domain = "://google.com" + [char]47
                $targetUrl = $protocol + $domain + "search?q=" + $encodedQuery
                $shortcutContent = "[InternetShortcut]" + "`r`n" + "URL=" + $targetUrl
                $stream = [System.IO.StreamWriter]::new($newGooglePath, $false, [System.Text.Encoding]::UTF8)
                $stream.Write($shortcutContent)
                $stream.Close()
            }
            
            # 5. YOUTUBE SHORTCUT
            if (-not (Test-Path -LiteralPath $ytShortcutPath)) {
                $encodedQuery = [Uri]::EscapeDataString($originalName)
                $protocol = "https:" + [char]47 + [char]47
                $domain = "://youtube.com" + [char]47
                $targetUrl = $protocol + $domain + "results?search_query=" + $encodedQuery
                $shortcutContent = "[InternetShortcut]" + "`r`n" + "URL=" + $targetUrl
                $stream = [System.IO.StreamWriter]::new($ytShortcutPath, $false, [System.Text.Encoding]::UTF8)
                $stream.Write($shortcutContent)
                $stream.Close()
            }

            # 6. GOOGLE IMAGES SHORTCUT
            if (-not (Test-Path -LiteralPath $imgShortcutPath)) {
                $encodedQuery = [Uri]::EscapeDataString($originalName)
                $protocol = "https:" + [char]47 + [char]47
                $domain = "://google.com" + [char]47
                $targetUrl = $protocol + $domain + "search?tbm=isch&q=" + $encodedQuery
                $shortcutContent = "[InternetShortcut]" + "`r`n" + "URL=" + $targetUrl
                $stream = [System.IO.StreamWriter]::new($imgShortcutPath, $false, [System.Text.Encoding]::UTF8)
                $stream.Write($shortcutContent)
                $stream.Close()
            }
        }

        catch {
            Write-Warning "Skipped item '$originalName' due to file-system block: $_"
            if ($stream) { $stream.Close() }
        }
    }
}

Write-Host "Success! Check your Desktop to view your perfectly generated A-Z directories." -ForegroundColor Green
Read-Host -Prompt "Press Enter to finish"
