$namesFile = "names.txt"
$imageFile = "image.gif" 

# Target the fresh, symbol-free root folder we just created
$outputBaseDir = "C:\SortedLibrary"

# Build the image file name using exact character codes to prevent encoding glitches
$newImageName = "sharkn3t, by wikdlabs" + [char]169 + ".gif"

$currentDir = (Get-Item .).FullName
$sourceNamesPath = $currentDir + "\" + $namesFile
$sourceImagePath = $currentDir + "\" + $imageFile

if (-not (Test-Path -LiteralPath $sourceNamesPath)) {
    Write-Error "Cannot find names.txt in this folder!"
    Read-Host -Prompt "Press Enter to exit"
    exit
}

# Ensure the new C:\SortedLibrary base directory exists
if (-not (Test-Path -LiteralPath $outputBaseDir)) {
    $null = New-Item -ItemType Directory -Force -LiteralPath $outputBaseDir
}

# Read names with full UTF-8 support
$entries = [System.IO.File]::ReadAllLines($sourceNamesPath, [System.Text.Encoding]::UTF8)
$processedNames = New-Object System.Collections.Generic.HashSet[string]

Write-Host "Building a pristine, sorted library directly inside $outputBaseDir..." -ForegroundColor Cyan

foreach ($line in $entries) {
    $originalName = $line.Trim()
    if ($originalName) {
        
        # Skip duplicate lines to keep it at 32,000 unique items
        if (-not $processedNames.Add($originalName)) { continue }

        # Clean individual folder names
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

        # ALPHABETICAL ROUTING ENGINE
        $firstChar = $shortFolder.Substring(0,1).ToUpper()
        $alphaGroup = if ($firstChar -notmatch '^[A-Z]$') { "#" } else { $firstChar }

        # Hardcode explicit target paths pointing safely away from the old folder symbols
        $alphaParentFolder = $outputBaseDir + "\" + $alphaGroup
        $targetFolder = $alphaParentFolder + "\" + $shortFolder

        $newImagePath = $targetFolder + "\" + $newImageName
        $newGooglePath = $targetFolder + "\" + $shortFolder + " - Google.url"
        $ytShortcutPath = $targetFolder + "\" + $shortFolder + " - YouTube.url"
        $imgShortcutPath = $targetFolder + "\" + $shortFolder + " - Google Images.url"
        
        try {
            # 1. Create the Main Alphabet parent folder (A, B, C...) inside C:\SortedLibrary
            if (-not (Test-Path -LiteralPath $alphaParentFolder)) {
                $null = New-Item -ItemType Directory -Force -LiteralPath $alphaParentFolder
            }

            # 2. Create the unique item folder inside the new alphabet parent folder
            if (-not (Test-Path -LiteralPath $targetFolder)) {
                $null = New-Item -ItemType Directory -Force -LiteralPath $targetFolder
            }
            
            # 3. GIF COPY
            if ((Test-Path -LiteralPath $sourceImagePath) -and -not (Test-Path -LiteralPath $newImagePath)) {
                Copy-Item -LiteralPath $sourceImagePath -Destination $newImagePath -Force
            }

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
            if ($stream) { $stream.Close() }
        }
    }
}

Write-Host "Success! Check C:\SortedLibrary to view your perfectly generated A-Z directories." -ForegroundColor Green
Read-Host -Prompt "Press Enter to finish"
