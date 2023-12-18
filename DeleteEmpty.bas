Const APP_VERSION As String = "23.12.12"

'##################################################################################
' GLOBAL INCLUDES
'##################################################################################

'##################################################################################
' GLOBAL VARIABLES
'##################################################################################

Dim Shared param_empty_folders As Byte = 1
Dim Shared param_0byte_files As Byte = 0
Dim Shared param_verbose As Byte = 0
Dim Shared currentTextColor As Integer
Dim Shared currentBackColor As Integer
Dim Shared emptyFolderList(99999) As String
Dim Shared emptyFolderIndex As Integer

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
Dim currentColor As Integer

'=======================================
' Parameter
'=======================================

If __FB_ARGC__ < 2 Then
	displayHelp()
	End
EndIf

currentColor = Color
currentTextColor = LoWord(currentColor)
currentBackColor = HiWord(currentColor)

For i As Integer = 1 To __FB_ARGC__ - 1
	Select Case Command(i)
		Case "-h", "-help", "--help", "-?", "/?"
			displayHelp()
			End

		Case "-v"
			param_verbose = 1

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

If param_path = "" Then
	displayHelp()
	End
EndIf

Print
Print " scanning " & param_path & " - please wait..."

fCnt = scanFolder("", param_path, param_recursive, 1) 

deleteFoldersFromList()

Print " ready"
' Sleep
End
