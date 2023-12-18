#Include Once "windows.bi"

Namespace colors
	Const black As Integer = 0
	Const dark_blue As Integer = 1
	Const dark_green As Integer = 2
	Const dark_cyan As Integer = 3
	Const dark_red As Integer = 4
	Const dark_magenta As Integer = 5
	Const dark_yellow As Integer = 6
	Const grey As Integer = 7
	Const dark_grey As Integer = 8
	Const blue As Integer = 9
	Const green As Integer = 10
	Const cyan As Integer = 11
	Const red As Integer = 12
	Const magenta As Integer = 13
	Const yellow As Integer = 14
	Const white As Integer = 15
End Namespace

Sub displayHelp()
	Print
	Print "DeleteEmpty - deletes empty directories/files - by M. Lindner / Version " & APP_VERSION
	Print
	Print "usage: DeleteEmpty <options> <path>"
	Print
	Print "Options"
	Print "======================================================================="
	Print " -r            recursive"
	Print " -d            delete empty folders (default)"
	Print " -0            delete 0 byte files"
	Print " -v            verbose output"
	Print
	Print " -h, -help     this help"
End Sub

Function deleteThisFile(ByVal file As String, ByVal filename As String) As Integer
	Dim ret As Integer
	
	Print "  " & file & " - ";

	ret = Kill(file)
	
	If ret = 0 Then
		Color colors.dark_green, currentBackColor
		Print "deleted"
		Color currentTextColor, currentBackColor
	Else
		Color colors.dark_red, currentBackColor
		Print "failed to delete"
		Color currentTextColor, currentBackColor
	EndIf
	
	Return ret
End Function

Function deleteThisFolder(ByVal path As String, ByVal fileCnt As LongInt, ByVal show_error As Byte) As LongInt
	Dim folderPathNullTerminated As ZString * 255
	Dim ret As LongInt

	' Convert the folder path to a null-terminated string
	folderPathNullTerminated = path + Chr(0)

	' Attempt to remove the directory
	ret = RemoveDirectory(@folderPathNullTerminated)

	If ret <> 0 Then
		Print "  " & path & " - ";
		Color colors.green, currentBackColor
		Print "deleted"
		Color currentTextColor, currentBackColor
	Else
		If show_error = 1 And param_verbose = 1 Then
			Print "  " & path & " - ";
			Color colors.red, currentBackColor
			Print "failed to delete, maybe not empty"
			Color currentTextColor, currentBackColor
		EndIf
	EndIf

	Return ret
End Function

Function scanFolder(ByVal parent As String, ByVal path As String, ByVal recursive As Byte, ByVal level As Integer) As Integer
	Dim wfd As WIN32_FIND_DATA
	Dim hwfd As HANDLE
	Dim szTmp As String
	Dim fileSize As LongInt
	Dim fileCnt As Integer = 0
	Dim folderCnt As Integer = 0
	Dim totalCnt As Integer = 0
	Dim retCnt As Integer = 0


	If Right(path, 1) = "\" Then path = Left(path, Len(path) - 1)

	hwfd = FindFirstFile(path & "\*", @wfd)

	If hwfd <> INVALID_HANDLE_VALUE Then
		While TRUE
			If (wfd.dwFileAttributes And FILE_ATTRIBUTE_DIRECTORY) = 0 Then
				' it's a file
				szTmp = path & "\" & wfd.cFileName
				fileCnt = fileCnt + 1

				If param_0byte_files = 1 And wfd.nFileSizeLow = 0 Then
					If deleteThisFile(szTmp, wfd.cFileName) = 0 Then
						fileCnt = fileCnt - 1
					EndIf
				EndIf
			Else
				If wfd.cFileName <> "." And wfd.cFileName <> ".." Then
					' it's a folder
					szTmp = path & "\" & wfd.cFileName
					folderCnt = folderCnt + 1
					
					If recursive = 1 Then
						scanFolder(path, szTmp, recursive, (level + 1))	' call myself to scan this path
					EndIf
				EndIf
			EndIf

			If FindNextFile(hwfd,@wfd) = FALSE Then
				Exit While											' no more files in this path
			EndIf
		Wend

		FindClose(hwfd)											' close the find handle
	EndIf

	'Print fileCnt & "/" & folderCnt & ": " & path

	If fileCnt = 0 Then
		emptyFolderList(emptyFolderIndex) = path
		emptyFolderIndex = emptyFolderIndex + 1
	EndIf

	Return fileCnt
End Function

Sub deleteFoldersFromList()
	Dim i As Integer
	
	For i = 0 To emptyFolderIndex - 1
		If emptyFolderList(i) <> "" Then
			deleteThisFolder(emptyFolderList(i), 0, 1)
		EndIf
	Next
End Sub
