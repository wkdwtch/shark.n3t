$namesFile = "names.txt"
$imageFile = "image.gif" 
$newImageName = "sharkn3t, by wikdlabs" + [char]169 + ".gif"

$currentDir = (Get-Item .).FullName

if (-not (Test-Path -LiteralPath ($currentDir + "\" + $namesFile))) {
    Write-Error "Cannot find names.txt in this folder!"
    Read-Host -Prompt "Press Enter to exit"
    exit
}

# Read names with full UTF-8 support
$entries = [System.IO.File]::ReadAllLines(($currentDir + "\" + $namesFile), [System.Text.Encoding]::UTF8)
$processedNames = New-Object System.Collections.Generic.HashSet[string]

Write-Host "Re-building and sorting 32,000+ folders into physical A-Z buckets..." -ForegroundColor Cyan

foreach ($line in $entries) {
    $originalName = $line.Trim()
    if ($originalName) {
        if (-not $processedNames.Add($originalName)) { continue }

        # Clean folder names
        $folderName = $originalName -replace '[\x00-\x1F\\/:*?"<>|]', ' '
        $folderName = $folderName.Trim() -replace '\.+$', ''
        $folderName = $folderName.Trim()

        if (-not $folderName) { continue }

        if ($folderName.Length -gt 45) {
            $shortFolder = $folderName.Substring(0, 45).Trim() -replace '\.+$', ''
        } else {
            $shortFolder = $folderName
        }

        # ALPHABET ROUTING
        $firstChar = $shortFolder.Substring(0,1).ToUpper()
        $alphaGroup = if ($firstChar -notmatch '^[A-Z]$') { "#" } else { $firstChar }

        # Explicit absolute text paths
        $alphaParentFolder = $currentDir + "\" + $alphaGroup
        $targetFolder = $alphaParentFolder + "\" + $shortFolder
        $sourceImagePath = $currentDir + "\" + $imageFile

        $newImagePath = $targetFolder + "\" + $newImageName
        $newGooglePath = $targetFolder + "\" + $shortFolder + " - Google.url"
        $ytShortcutPath = $targetFolder + "\" + $shortFolder + " - YouTube.url"
        $imgShortcutPath = $targetFolder + "\" + $shortFolder + " - Google Images.url"
        
        try {
            # Force create parent A-Z folder
            if (-not (Test-Path -LiteralPath $alphaParentFolder)) {
                $null = New-Item -ItemType Directory -Force -LiteralPath $alphaParentFolder
            }
            # Force create subfolder inside parent A-Z folder
            if (-not (Test-Path -LiteralPath $targetFolder)) {
                $null = New-Object System.IO.DirectoryInfo($targetFolder)
                [System.IO.Directory]::CreateDirectory($targetFolder) | Out-Null
            }
            # Copy GIF
            if ((Test-Path -LiteralPath $sourceImagePath) -and -not (Test-Path -LiteralPath $newImagePath)) {
                Copy-Item -LiteralPath $sourceImagePath -Destination $newImagePath -Force
            }
            # Google Shortcut
            if (-not (Test-Path -LiteralPath $newGooglePath)) {
                $encodedQuery = [Uri]::EscapeDataString($originalName)
                $targetUrl = "https:" + [char]47 + [char]47 + "://google.com" + [char]47 + "search?q=" + $encodedQuery
                $shortcutContent = "[InternetShortcut]" + "`r`n" + "URL=" + $targetUrl
                $stream = [System.IO.StreamWriter]::new($newGooglePath, $false, [System.Text.Encoding]::UTF8)
                $stream.Write($shortcutContent)
                $stream.Close()
            }
            # YouTube Shortcut
            if (-not (Test-Path -LiteralPath $ytShortcutPath)) {
                $encodedQuery = [Uri]::EscapeDataString($originalName)
                $targetUrl = "https:" + [char]47 + [char]47 + "://youtube.com" + [char]47 + "results?search_query=" + $encodedQuery
                $shortcutContent = "[InternetShortcut]" + "`r`n" + "URL=" + $targetUrl
                $stream = [System.IO.StreamWriter]::new($ytShortcutPath, $false, [System.Text.Encoding]::UTF8)
                $stream.Write($shortcutContent)
                $stream.Close()
            }
            # Google Images Shortcut
            if (-not (Test-Path -LiteralPath $imgShortcutPath)) {
                $encodedQuery = [Uri]::EscapeDataString($originalName)
                $targetUrl = "https:" + [char]47 + [char]47 + "://google.com" + [char]47 + "search?tbm=isch&q=" + $encodedQuery
                $shortcutContent = "[InternetShortcut]" + "`r`n" + "URL=" + $targetUrl
                $stream = [System.IO.StreamWriter]::new($imgShortcutPath, $false, [System.Text.Encoding]::UTF8)
                $stream.Write($shortcutContent)
                $stream.Close()
            }
        } catch {}
    }
}

# FORCE WINDOWS TO REFRESH THE SCREEN IMMEDIATELY
$shell = New-Object -ComObject Shell.Application
$shell.Namespace($currentDir).Self.InvokeVerb("Properties") | Out-Null
(New-Object -ComObject WScript.Shell).SendKeys("{F5}")

Write-Host "Success! The system has been forced to refresh. Look for the A-Z folders now!" -ForegroundColor Green
Read-Host -Prompt "Press Enter to finish"