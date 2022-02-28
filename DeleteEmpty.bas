Const APP_VERSION As String = "23.07.05"

'##################################################################################
' GLOBAL INCLUDES
'##################################################################################

'##################################################################################
' GLOBAL VARIABLES
'##################################################################################

Dim Shared param_empty_folders As Byte = 0
Dim Shared param_0byte_files As Byte = 0

'##################################################################################
' PROJECT INCLUDES
'##################################################################################

#Include Once "inc/functions.bi"

'##################################################################################
' MAIN PROG
'##################################################################################

Dim param_recursive As Byte = 0
Dim param_path As String = ""
Dim fCnt As LongInt

'=======================================
' Parameter
'=======================================

'param_path = "D:\SynologyDrive"

If __FB_ARGC__ < 2 Then
	displayHelp()
	End
EndIf

For i As Integer = 1 To __FB_ARGC__ - 1
	Select Case Command(i)
		Case "-h", "-help", "--help", "-?", "/?"
			displayHelp()
			End

		Case "-r"
			param_recursive = 1

		Case "-d"
			param_empty_folders = 1

		Case "-0"
			param_0byte_files = 1

		Case Else
			If Left(Command(i), 1) = "-" Then
				Print "unknown arg "; i; " = '"; Command(i); "'"
			Else
				param_path = Command(i)
			EndIf
	End Select
Next

'=======================================
' Code
'=======================================

Print
Print "scanning " & param_path & " - please wait..."
Print

'Print "[I] " & String(0, "-") & " " & param_path

fCnt = ScanFolder(param_path, param_recursive, 1) 

'Print "{{" & fCnt & "}}

Print
Print "key..."
Sleep 10000
End
