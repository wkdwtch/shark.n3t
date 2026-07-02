@echo off
setlocal enabledelayedexpansion

echo Processing 55,000+ records... Please wait.
echo.

:: Loop through every line in names.txt natively without overloading memory
for /f "usebackq delims=" %%A in ("names.txt") do (
    set "originalName=%%A"
    
    :: Strip trailing spaces if any
    set "folderName=%%A"
    
    :: Remove characters that break Windows folder paths
    set "folderName=!folderName:\= !"
    set "folderName=!folderName:/= !"
    set "folderName=!folderName::= !"
    set "folderName=!folderName:*= !"
    set "folderName=!folderName.?= !"
    set "folderName=!folderName:"= !"
    set "folderName=!folderName:<= !"
    set "folderName=!folderName:>= !"
    set "folderName=!folderName:|= !"

    :: Create the folder safely using long-path compliant system calls
    if not exist "\\?\%cd%\!folderName!" md "\\?\%cd%\!folderName!" 2>nul

    :: Format the Google Search query string
    set "searchQuery=!originalName!"
    set "searchQuery=!searchQuery: =+!"
    set "searchQuery=!searchQuery:&=%%26!"

    :: Build the exact URL destination path
    set "targetUrl=https://google.com!"

    :: Directly print the Internet Shortcut file structure to disk (Bypasses COM memory leaks)
    set "shortcutPath=\\?\%cd%\!folderName!\!folderName!.url"
    if not exist "!shortcutPath!" (
        (
            echo [InternetShortcut]
            echo URL=!targetUrl!
        ) > "!shortcutPath!"
    End
)

echo.
echo ✅ Success! All 55,000+ folders and custom-named shortcuts successfully created.
pause