#Include Once "windows.bi"

Sub displayHelp()
	Print
	Print "DeleteEmpty Version " & APP_VERSION & " by M. Lindner"
	Print
	Print "usage: DeleteEmpty <options> <path>"
	Print
	Print "Options"
	Print "======================================================================="
	Print " -r    recursive"
	Print " -d    delete empty folders"
	Print " -0    delete 0 byte files"
	Print
	Print " -h, -help    this help"
End Sub







Function ScanFolder(ByVal path As String, ByVal recursive As Byte, ByVal level As Integer) As LongInt
	Dim wfd As WIN32_FIND_DATA
	Dim hwfd As HANDLE
	Dim szTmp As String
	Dim fileSize As LongInt
	Dim fileCnt As LongInt = 0
	Dim fCnt As LongInt = 0
	
	If Right(path, 1) = "\" Then path = Left(path, Len(path) - 1)

	hwfd = FindFirstFile(path & "\*", @wfd)
	
	If hwfd <> INVALID_HANDLE_VALUE Then
		While TRUE
			If (wfd.dwFileAttributes And FILE_ATTRIBUTE_DIRECTORY) = 0 Then
				' it's a file
				szTmp = path & "\" & wfd.cFileName
				fileCnt = fileCnt + 1
				
				'Print "[F] " & wfd.cFileName & " > " & wfd.nFileSizeLow
				
				If param_0byte_files = 1 And wfd.nFileSizeLow = 0 Then
					If Kill(szTmp) = 0 Then
						Print " delete 0 byte file : " & szTmp & "... OK"
						fileCnt = fileCnt - 1
					Else
						Print " delete 0 byte file : " & szTmp & "... FAILED"
					EndIf
				EndIf
			Else
				' it's a folder
				If wfd.cFileName <> "." And wfd.cFileName <> ".." Then
					szTmp = path & "\" & wfd.cFileName
					'fileCnt = fileCnt + 1

					'Print "[D](" & level & ") " & wfd.cFileName & " > "
					
					If level = 1 Then
						fCnt = ScanFolder(szTmp, recursive, (level + 1))	' call myself to scan this path
						'Print level & " : [[" & fCnt & "]]" & szTmp
						
						'If param_empty_folders = 1 And fCnt = 0 Then
						'	Print "[*] delete empty folder: [[" & fCnt & "]] " & szTmp
						'EndIf
					Else
						If recursive = 1 Then
							fCnt = ScanFolder(szTmp, recursive, (level + 1))	' call myself to scan this path
					'		'Print level & " ; [[" & fCnt & "]]" & szTmp
					'		
					'		If param_empty_folders = 1 And fCnt = 0 Then
					'			Print " [*] delete empty folder: ((" & fCnt & ")) " & szTmp
					'		EndIf
						EndIf
					EndIf
				EndIf
			EndIf
			
			If FindNextFile(hwfd,@wfd) = FALSE Then
				Exit While											' No more files in this path
			EndIf
		Wend

		FindClose(hwfd)											' Close the find handle
	EndIf
	
	'Print "[S] " & String(level, "-") & " " & path & " = " & fileCnt
	'Print "[X] " & level & " = " & param_empty_folders & " / " & fileCnt
	
	If param_empty_folders = 1 And fileCnt = 0 Then
		If RmDir(path) = 0 Then
			Print " delete empty folder: " & path & "... OK"
		Else
			Print " delete empty folder: " & path & "... FAILED - " & fileCnt & " files remaining"
		EndIf
	EndIf
	
	Return fileCnt
End Function
