Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")
Set txt = fso.OpenTextFile("names.txt", 1)

' Get the absolute, full path of the current folder where your script lives
currentFolder = fso.GetAbsolutePathName(".")

Do Until txt.AtEndOfStream
    originalName = Trim(txt.ReadLine)
    If originalName <> "" Then
        ' Clean the folder name for Windows compliance
        folderName = originalName
        forbidden = Array("\", "/", ":", "*", "?", """", "<", ">", "|")
        For Each char In forbidden
            folderName = Replace(folderName, char, " ")
        Next
        folderName = Trim(folderName)

        ' BYPASS WINDOWS MAX PATH: Format paths with the system unc prefix "\\?\"
        ' This allows paths to be up to 32,767 characters long instead of crashing at 260.
        longFolderPath = "\\?\" & currentFolder & "\" & folderName
        longShortcutPath = longFolderPath & "\" & folderName & ".url"

        ' Create the folder safely using the extended long path
        If Not fso.FolderExists(longFolderPath) Then 
            fso.CreateFolder(longFolderPath)
        End If
        
        ' Convert spaces and special characters for a clean URL string
        searchQuery = Replace(originalName, " ", "+")
        searchQuery = Replace(searchQuery, "&", "%26")
        
        ' Hardcode the domain parameter securely
        targetUrl = "https:" & Chr(47) & Chr(47) & "://google.com" & Chr(47) & "search?q=" & searchQuery
        
        ' SMART SKIPPING: Only create the shortcut if it doesn't already exist. 
        ' This keeps your script fast and prevents it from overwriting the first 7,077 items again.
        If Not fso.FileExists(longShortcutPath) Then
            Set shortcut = shell.CreateShortcut(longShortcutPath)
            shortcut.TargetPath = targetUrl
            shortcut.Save
        End If
    End If
Loop

txt.Close
MsgBox "Done! All 55,000+ folders and custom-named shortcuts successfully created.", 64, "Success"