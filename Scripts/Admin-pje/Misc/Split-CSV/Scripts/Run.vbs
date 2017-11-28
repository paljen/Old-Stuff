On Error Resume Next

Dim wshShell
Dim fso
Dim oEnv
Dim sScriptdir
Dim sJobName
Dim sPSEngine
Dim sNet35Installed

    If WScript.Arguments.Count <> 1 Then
        WScript.Quit 87
    Else
        sJobName = WScript.Arguments(0)
    End If

    Set fso = CreateObject("Scripting.FileSystemObject")
    Set wshShell = CreateObject("WScript.Shell")
    Set oEnv = wshShell.Environment("PROCESS")

    sPkgdir = Mid(WScript.ScriptFullName, 1, InStr(WScript.ScriptFullName, "Scripts\" + WScript.ScriptName) -2)

    ' Verify if Powershell 2.0 is enabled
    sPSVersion = wshShell.RegRead("HKLM\SOFTWARE\Microsoft\Powershell\1\PowerShellEngine\PowerShellVersion")

    If (sPSVersion = "") Or (sPSVersion = "1.0") Then
       
        oEnv("SEE_MASK_NOZONECHECKS") = 1

        ' Determine if .NET Framework 3.5 is present
        sNet35Installed = wshShell.RegRead("HKLM\Software\Microsoft\NET Framework Setup\NDP\v3.5\Install")

        If Not sNet35Installed = "1" Then
            
            If fso.FileExists(sPkgdir & "\Resources\prereq\dotnetfx35.exe") = True Then
                iRetVal = wshShell.Run(Chr(34) & sPkgdir & "\Resources\prereq\dotnetfx35.exe" & Chr(34) & " /quiet /norestart", 0, True)
                If iRetVal <> 0 Then
                    WScript.Quit iRetVal
                End If
            Else
                WScript.Quit(2)
            End If
        End If

        If fso.FileExists(sPkgdir & "\Resources\prereq\" & GetPSHotfix()) = True Then
            iRetval = wshShell.Run(Chr(34) & sPkgdir & "\Resources\prereq\" & GetPSHotfix() & Chr(34) & " /quiet /norestart", 0, True)
            If iRetVal <> 0 Then
                WScript.Quit iRetVal
            End If
        Else
            WScript.Quit(2)
        End If
        
        oEnv.Remove("SEE_MASK_NOZONECHECKS")
        
        If iRetval <> 0 Then
            WScript.Quit iRetval
        End If

    End If

    sPSEngine = wshShell.RegRead("HKLM\SOFTWARE\Microsoft\Powershell\1\PowerShellEngine\ApplicationBase")

    If sPSEngine = "" Then
        WScript.Quit 2
    Else
        sPSEngine = sPSEngine & "\Powershell.exe"
    End If

    ' Execute Run.ps1
    iRetval = wshShell.Run(sPSEngine & " -ExecutionPolicy ByPass -NonInteractive -WindowStyle Hidden -File " & Chr(34) & sPkgdir & "\Scripts\Run.ps1" & Chr(34) & " " & Chr(34) & sJobName & Chr(34), 0, True)

    WScript.Quit iRetval


    Private Function GetOSVersion()
    Dim objWmi, objQuery

        Set objWmi = GetObject("winmgmts://./root/cimv2")
	Set objQuery = objWmi.ExecQuery("select * from Win32_operatingsystem")

	For Each os in objQuery

		GetOSVersion = os.Version
	Next
	

    End Function

    Private Function GetOSArchitecture()
    Dim objWmi, objQuery

      	Set objWmi = GetObject("winmgmts://./root/cimv2")
	Set objQuery = objWmi.ExecQuery("select * from Win32_operatingsystem")

	For Each os in objQuery
		GetOSArchitecture = os.OSArchitecture
	Next

    End Function

    Private Function GetPSHotfix()
    Dim sOSVer
    Dim sHotfix

        sOSVer = Mid(GetOSVersion, 1, 3)

        Select Case sOSVer
            
            Case "6.0"   'Vista, Server 2008

                If GetOSArchitecture() = "64-bit" Then
                    sHotfix = "Windows6.0-KB968930-x64.msu"
                Else
                    sHotfix = "Windows6.0-KB968930-x86.msu"
                End If

            Case "5.2"  'Server 2003
                sHotfix = "WindowsServer2003-KB968930-x86-ENG.exe"

            Case "5.1"  'XP
                sHotfix = "WindowsXP-KB968930-x86-ENG.exe"

        End Select

	
	GetPSHotfix = sHotfix
        
    End Function
