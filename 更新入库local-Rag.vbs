Set shell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
projectDir = fso.GetParentFolderName(WScript.ScriptFullName)
shell.CurrentDirectory = projectDir
command = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File """ & projectDir & "\scripts\silent_start.ps1"" -Mode update"
shell.Run command, 0, False
