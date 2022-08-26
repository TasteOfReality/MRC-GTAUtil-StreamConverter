#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.5
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>

#include <Array.au3>
#include <File.au3>
#include <MsgBoxConstants.au3>


#Region ### START Koda GUI section ### Form=
$Form1 = GUICreate("MRC GTAUtil Converter", 615, 316, 593, 301)
$ibFolderToConvert = GUICtrlCreateInput("--Folder to Convert--", 32, 40, 409, 21)
$btnFolderToConvert = GUICtrlCreateButton("Browse", 464, 32, 129, 33)
$ibFolderOutput = GUICtrlCreateInput("--Output Folder--", 32, 112, 409, 21)
$btnFolderOutput = GUICtrlCreateButton("Browse", 464, 104, 129, 33)
$btnStart = GUICtrlCreateButton("Start", 176, 168, 225, 97)
GUICtrlSetFont(-1, 20, 400, 0, "MS Sans Serif")
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

; Create an enum for the categories storing  the folder name as the value
Local $aCategoryEnum = ["head", "berd", "hair", "uppr", "lowr", "hand", "feet", "teef", "accs", "task", "decl", "jbib", "p_head", "eyes", "ears", "mouth", "lhand", "rhand", "lwrist", "rwrist", "hip", "lfoot", "rfoot"]
Local $aFCategoryCount = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
Local $aMCategoryCount = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.0]
While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $btnFolderToConvert
			BTNTrigger_BrowseFolder_AssignToInput("Select Folder To Convert", $ibFolderToConvert)
		Case $btnFolderOutput
			BTNTrigger_BrowseFolder_AssignToInput("Select Output Folder", $ibFolderOutput)
		Case $btnStart
			BTNTrigger_ConvertFolder(GUICtrlRead($ibFolderToConvert), GUICtrlRead($ibFolderOutput))
		Case $GUI_EVENT_CLOSE
			Exit

	EndSwitch
WEnd

Func BTNTrigger_BrowseFolder_AssignToInput($title, $inputBox)


		$inputDir = GUICtrlRead($inputBox)
		Local $cachedDir = ""
		if FileExists($inputDir) Then
			$cachedDir = $inputDir
		Else
			$cachedDir = @ScriptDir
		EndIf
		Local $dir = FileSelectFolder($title, $cachedDir)
		If FileExists($dir) Then
			GUICtrlSetData($inputBox, $dir)
		EndIf

EndFunc

Func BTNTrigger_ConvertFolder($inputDir, $outputDir)
		If FileExists($inputDir) == 0 Then
			MsgBox(16, "Error", "The input folder entered does not exist")
			Return
		EndIf
		If FileExists($outputDir) == 0 Then
			MsgBox(16, "Error", "The output folder entered does not exist")
			Return
		EndIf

		Local $aYDDraw = _FileListToArray($inputDir, "*.ydd")
		Local $aYTDraw = _FileListToArray($inputDir, "*.ytd")
		$aYDD = $aYDDraw
		$aYTD = $aYTDraw
		_ArraySort($aYDD)
		_ArraySort($aYTD)

		Local $progress = 0

		For $YDD In $aYDD
			If $YDD == $aYDDraw[0] Then
				ContinueLoop
			EndIf

			Local $searchString = StringSplit($YDD,"^")
			Local $YDDCategory = GetYDDCategory($YDD)
			Local $YDDIndex = GetYDDNumber($YDD)
			Local $Gender = GetYDDGender($YDD)
			Local $aCategoryCount = 0
			If $Gender == 1 Then
				$aCategoryCount = $aFCategoryCount[$YDDCategory]
			ElseIf $Gender == 2 Then
				$aCategoryCount = $aMCategoryCount[$YDDCategory]
			EndIf

			Local $YTDIndex = 0

			For $YTD In $aYTD
				If $YTD == $aYTDraw[0] Then
					ContinueLoop
				EndIf

				If StringInStr($YTD, $searchString[1] & "^" )  <> 0  Then
					Local $category = GetYDDCategory($YTD)
					Local $index = GetYDDNumber($YTD)
					;ConsoleWrite($category & ":" & $YDDCategory & " " & $index & ":" & $YDDIndex & @CRLF)
					If $category == $YDDCategory Then
						If $index == $YDDIndex Then
							local $dir = GetOutputPath($outputDir, $YTD, $aCategoryCount, True)
							FileCopy($inputDir & "\" & $YTD, $dir & $YTDIndex & ".ytd", 8)
							;FileMove($dir & $YTD, $dir & $YTDIndex & ".ytd")
							$YTDIndex = $YTDIndex + 1

						EndIf
					EndIf
				EndIf
			Next

			If $YTDIndex == 0 Then
				FileCopy($inputDir & "\" & $YDD, $outputDir & "\NoYTD\" & $YDD , 8)
				ContinueLoop
			EndIf
			local $dir = GetOutputPath($outputDir, $YDD, $aCategoryCount, False)
			FileCopy($inputDir & "\" & $YDD, $dir & $aCategoryCount & ".ydd" , 8)
			;FileMove($dir & "\" & $YDD, $dir & "\" & $YTDIndex & ".ytd")

			If $Gender == 1 Then
				$aFCategoryCount[$YDDCategory] = $aFCategoryCount[$YDDCategory] + 1
			ElseIf $Gender == 2 Then
				$aMCategoryCount[$YDDCategory] = $aMCategoryCount[$YDDCategory] + 1
			EndIf
			$progress = $progress + 1
			ToolTip($progress / $aYDDraw[0] * 100)
			;_ArrayDisplay($aCurrentYTDs)

		Next
		ToolTip("")




EndFunc



Func GetYDDCategory($file)
	Local $category = ""
	Local $searchString = StringSplit($file,"^")

	If StringInStr($searchString[2], "head") <> 0 Then
		If StringInStr($searchString[2], "p_head") <> 0  Then
			$category = 12
		Else
			$category = 0
		EndIf
	ElseIf StringInStr($searchString[2], "berd") <> 0  Then
		$category = 1
	ElseIf StringInStr($searchString[2], "hair") <> 0  Then
		$category = 2
	ElseIf StringInStr($searchString[2], "uppr") <> 0  Then
		$category = 3
	ElseIf StringInStr($searchString[2], "lowr") <> 0  Then
		$category = 4
	ElseIf StringInStr($searchString[2], "hand") <> 0  Then
		$category = 5
	ElseIf StringInStr($searchString[2], "feet") <> 0  Then
		$category = 6
	ElseIf StringInStr($searchString[2], "teef") <> 0  Then
		$category = 7
	ElseIf StringInStr($searchString[2], "accs") <> 0  Then
		$category = 8
	ElseIf StringInStr($searchString[2], "task") <> 0  Then
		$category = 9
	ElseIf StringInStr($searchString[2], "decl") <> 0  Then
		$category = 10
	ElseIf StringInStr($searchString[2], "jbib") <> 0  Then
		$category = 11
	ElseIf StringInStr($searchString[2], "eyes") <> 0  Then
		$category = 13
	ElseIf StringInStr($searchString[2], "ears") <> 0  Then
		$category = 14
	ElseIf StringInStr($searchString[2], "mouth") <> 0  Then
		$category = 15
	ElseIf StringInStr($searchString[2], "lhand") <> 0  Then
		$category = 16
	ElseIf StringInStr($searchString[2], "rhand") <> 0  Then
		$category = 17
	ElseIf StringInStr($searchString[2], "lwrist") <> 0  Then
		$category = 18
	ElseIf StringInStr($searchString[2], "rwrist") <> 0  Then
		$category = 19
	ElseIf StringInStr($searchString[2], "hip") <> 0  Then
		$category = 20
	ElseIf StringInStr($searchString[2], "lfoot") <> 0  Then
		$category = 21
	ElseIf StringInStr($searchString[2], "rfoot") <> 0  Then
		$category = 22
	EndIf
	return $category
EndFunc

Func GetYDDNumber($file)
	Local $aSearchStringRaw = StringSplit($file,"^")
	Local $aSearchString = StringSplit($aSearchStringRaw[2],"_")

	For $num In $aSearchString
		If $num == $aSearchString[0] Then
			ContinueLoop
		EndIf

		If Number($num) <> 0 Or $num == "000" Then
			return Number($num)
		EndIf
	Next

EndFunc

Func GetYDDGender($file)
	Local $searchStringRaw = StringSplit($file,"^")
	Local $searchFString = StringInStr($searchStringRaw[1], "mp_f")
	Local $searchMString = StringInStr($searchStringRaw[1], "mp_m")
	If $searchFString <> 0 Then
		Return 1
	ElseIf $searchMString <> 0 Then
		Return 2
	Else
		Return 0
	EndIf
EndFunc

Func IsProp($category)
	If $category >= 12 Then
		Return True
	EndIf
	Return False
EndFunc

Func GetOutputPath($outputDir, $file, $index, $isYTD)
	Local $dir = $outputDir
	Local $gender = GetYDDGender($file)
	Local $category = GetYDDCategory($file)
	Local $isProp = IsProp($category)

	If $gender == 1 And $isProp Then
		$dir = $dir & "\mp_f_freemode_01_p\props\"
	ElseIf $gender == 2 And $isProp Then
		$dir = $dir & "\mp_m_freemode_01_p\props\"
	ElseIf $gender == 1 And $isProp == False Then
		$dir = $dir & "\mp_f_freemode_01\components\"
	ElseIf $gender == 2 And $isProp == False Then
		$dir = $dir & "\mp_m_freemode_01\components\"
	EndIf

	$dir = $dir & $aCategoryEnum[$category] & "\"
	If $isYTD Then
		$dir = $dir & $index & "\"
	EndIf

	return $dir

EndFunc
