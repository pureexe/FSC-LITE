#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <GUIListBox.au3>
#include <GuiListView.au3>
#include <File.au3>
#include <array.au3>
#include <ExpListView.au3>
Global $Shell32 = DllOpen('shell32.dll')
;~ Global Const $FOLDER_ICON_INDEX = _GUIImageList_GetFileIconIndex(@SystemDir, 0, 1)
Global $aListViews[1][7] = [[0, 'Current Dir', 'Dir History', 'Columns', 'Function', 'ColumnWidths', 'ShowHidden']]
Global $regvar1,$locareg,$control_pr,$maincontrolgui,$infogui,$closeinfo
Global $hidden1load,$load1checkbox1,$load1checkbox2,$load1checkbox3,$load1checkbox4,$load1checkbox5,$sRestore = @ScriptDir & '\control.ini',$hList1="notuse"
$regvar1="main"
$locareg="HKEY_LOCAL_MACHINE\SOFTWARE\benjama\flashdrivesafechk\"
$control_pr=RegRead($locareg,$regvar1)
Opt("TrayOnEventMode",1)
 Opt("TrayMenuMode",1)
 OnAutoItExitRegister('_safe_Exit')
#Region ### START Koda GUI section ### Form=


if Not ProcessExists("FSC-Lite-scan.exe") Then
Run("FSC-Lite-scan.exe",@TempDir&"\FSC\")
ElseIf Not ProcessExists("FSC-Lite-scan.exe") And $control_pr<>"" Then
Run("FSC-Lite-scan.exet",$control_pr)
EndIf

If	$cmdline[0]=0 Then
	_maingui()
elseif $cmdline[0]="2" And $cmdline[1]="warnning" Then
	_warnning($cmdline[2])
ElseIf $cmdline[0]="2" And $cmdline[1]="expsafe" Then
	_safeexplorergui($cmdline[2])
ElseIf $cmdline[0]="1" And $cmdline[1]="expsafe" Then
	_safeexplorergui("My Computer")
ElseIf  $cmdline[1]="warnning" Then
	_warnning($cmdline[2])
ElseIf $cmdline[1]="start" Then

$prlist=IniRead("control.ini","main","prlist","1")
;	ShellExecute("flash-drive-scan.exe","",$control_pr)
	TrayCreateMenu("โปรแกรมตรวจจับไวรัสจาก Flash drive(Flash Drive Safe Check)")
 TrayCreateItem("")
 TrayCreateItem("คณะผู้จัดทำ")
 TrayItemSetOnEvent(-1, "DoAbout")
  TrayCreateItem("เปิดประวัติการเสียบflashdrive")
 TrayItemSetOnEvent(-1, "_logview")
   TrayCreateItem("จัดการไฟล์ทีถูกกักกัน")
 TrayItemSetOnEvent(-1, "_unblockvirus")
   TrayCreateItem("เปิด control panel")
 TrayItemSetOnEvent(-1, "_maingui")
 TrayCreateItem("")
TrayCreateItem("ออกจากโปรแกรม (ปิดระบบทั้งหมด)")
 TrayItemSetOnEvent(-1, "DoExit")
 TraySetState()
 if $cmdline[0]="2" And $cmdline[1]="start" Then
	if $cmdline[2]="skip" Then
 While 1
 WEnd
 EndIf
 Else
 While 1
#cs
$strComputer = "."
$objWMIService = ObjGet("winmgmts:\\" & $strComputer & "\root\cimv2")
$colEvents = $objWMIService.ExecNotificationQuery  ("Select * From __InstanceOperationEvent Within 5 Where " & "TargetInstance isa 'Win32_LogicalDisk'")
$x=1
$prlist=IniRead("control.ini","main","prlist","1")
	 if $prlist=1 Then $processlist=ProcessList()
	$objEvent = $colEvents.NextEvent
	If $objEvent.TargetInstance.DriveType = 2 Then
	Select
					Case $objEvent.Path_.Class() = "__InstanceCreationEvent"

					$uix=$objEvent.TargetInstance.DeviceId
					;SplashTextOn("","คำเตือนตรวจพบไฟล์ต้องสงสัยหากเป็นไวรัสโปรดลบทิ้งทันที ","400","150","-1","-1",33,"","","")
					If FileExists($objEvent.TargetInstance.DeviceId & "\*.exe") OR FileExists($objEvent.TargetInstance.DeviceId & "\*.pif") OR FileExists($objEvent.TargetInstance.DeviceId & "\*.lnk") Then
				;run("warning.exe"&" "&$uix)
					_warnning($uix)
				EndIf

			;	SplashOff()
						$safemode=IniRead("control.ini","main","safemode","1")
						$log=IniRead("control.ini","main","log","1")
						$SHD=IniRead("control.ini","main","SHD","1")
						$prlist=IniRead("control.ini","main","prlist","1")
						if $safemode=1 Then _safeexplorergui($uix);ShellExecute("explorer-safe.exe",$uix)
						If $log = 1 Then
							FileWriteLine("USBLog.txt", "วันที่ " & @MDAY & "/" & @MON & "/" & @YEAR & " เวลา " & @HOUR & "." & @MIN & "." & @SEC & @CRLF &  "ตรวจพบการเสียบ Flash Drive " & DriveGetLabel($objEvent.TargetInstance.DeviceId) & " (" & $objEvent.TargetInstance.DeviceId & ")"&@CRLF&"--------------------------------------------------------------------------------------------------------------")
							;ConsoleWrite("Drive " & $objEvent.TargetInstance.DeviceId & " has been added." & @CR)
						EndIf
						if $SHD=1 Then
							$ListSHD=_FileListToArray($uix,"*.")
						Local $attrildout
							for $i=0 to  $ListSHD[0]
								$attrildout=FileGetAttrib($uix&"\"&$ListSHD[$i])
									if $attrildout="SHD" Then Run("attrib -s -h "&$uix&"\"&$ListSHD[$i],$uix,@SW_HIDE)
									if @error Then
										MsgBox(64,"SHD error","SHD system ยังคงมีบัคอยู่ซึ่งกำลังดำเนินการแก้ *-*")
										ExitLoop
									EndIf
							Next
						EndIf
						if $prlist=1 Then
						Sleep(1000)
						$processlistnew=ProcessList()
						Local $newlist=""
						for $i=1 to $processlistnew[0][0]-$processlist[0][0]
							if $processlistnew[$processlist[0][0]+$i][0]<>"warning.exe" And $processlistnew[$processlist[0][0]+$i][0]<>"explorer-safe.exe" Then $newlist&=$processlistnew[$processlist[0][0]+$i][0]&@CRLF
						Next
						$chkuserkill=MsgBox(4,"FSC :: Warning","หลังจากการเสียบ flash drive พบว่ามีโปรแกรมเหล่านี้ถูกเรียกใช้"&@CRLF&@CRLF&$newlist&@CRLF&"ซึ่งหากเป็นโปรแกรมที่คุญไม่รู้จัก ให้กดyes เพื่อความปลอดภัยของคอมพิวเตอร์คุณ"&@CRLF&@CRLF&"กด Yes เพื่อปิดโปรแกรมที่รันขึ้นใหม่"&@CRLF&"กด NO เพื่อให้ทำงานต่อไป")
						if $chkuserkill=6 Then
						for $i=1 to $processlistnew[0][0]-$processlist[0][0]
							if $processlistnew[$processlist[0][0]+$i][0]<>"warning.exe" And $processlistnew[$processlist[0][0]+$i][0]<>"explorer-safe.exe" Then ProcessClose($processlistnew[$processlist[0][0]+$i][0])
						Next
						if @error Then
						MsgBox(64,"FSC :: ERROR","พบบัคที่ระบบ processlist")
						ExitLoop
					EndIf
				EndIf
				EndIf
						Case $objEvent.Path_.Class() = "__InstanceDeletionEvent"
						$log=IniRead("control.ini","main","log","1")
						if $log=1 Then
						;ConsoleWrite("Drive " & $objEvent.TargetInstance.DeviceId & " has been removed." & @CR)
						FileWriteLine("USBLog.txt", "วันที่ " & @MDAY & "/" & @MON & "/" & @YEAR & " เวลา " & @HOUR & "." & @MIN & "." & @SEC & @CRLF &  "ตรวจพบการถูกถอด Flash Drive " & DriveGetLabel($objEvent.TargetInstance.DeviceId) & " (" & $objEvent.TargetInstance.DeviceId & ")"&@CRLF&"--------------------------------------------------------------------------------------------------------------")
					EndIf
				EndSelect
			EndIf
#ce
 WEnd
 EndIf
 Else
;~ 	MsgBox(64,"ERROR","Method not found $CmdLine missing")
EndIf
Func _maingui()
	Local $Button1,$Button2,$Button3,$chklog,$Checkbox1,$Checkbox2,$Checkbox3,$nMsg,$lastchkhead,$lastchkupdate,$lastpatchead,$lastpatchupdate
$maincontrolgui = GUICreate("Control Panel :: Flash Drive Safe Check", 602,218, -1, -1)


$Checkbox1 = GUICtrlCreateCheckbox("เก็บ ประวัติการเสียบ Flash drive", 24, 8, 249, 17)
$Checkbox2 = GUICtrlCreateCheckbox("ระบบ Safe Mode Explorer", 24, 32, 169, 17)
$Checkbox3 = GUICtrlCreateCheckbox("แก้ไขโฟลเดอร์ที่ถูกซ่ออัตโนมัติ", 24, 56, 353, 17)
$Checkbox4 = GUICtrlCreateCheckbox("ระบบตรวจจับprocessหลังเสียบ flash drive", 24, 80, 345, 17)
$Button2 = GUICtrlCreateButton("คณะผู้จัดทำ", 416, 16, 177, 33)
$Button4 = GUICtrlCreateButton("จัดการไฟล์ทีถูกกักกัน", 416, 56, 177, 33)
$Button1 = GUICtrlCreateButton("ดูประวัติการเสียบ flash drive", 416, 96, 177, 33)
$Button3 = GUICtrlCreateButton("ปิดโปรแกรม(ปิดระบบทั้งหมด)", 416, 176, 177, 33)
$Button5 = GUICtrlCreateButton("explorer-safe", 416, 136, 177, 33)


$lastchkhead = GUICtrlCreateLabel("ตรวจสอบอัพเดตครั้งสุดท้ายเมื่อ :", 24, 104, 155, 17)
$lastchkupdate = GUICtrlCreateLabel("Loading...", 24, 128, 339, 17)
$lastpatchead = GUICtrlCreateLabel("อัพเดตระบบครั้งสุดท้ายเมื่อ :", 24, 152, 130, 17)
$lastpatchupdate = GUICtrlCreateLabel("Loading...", 24, 176, 339, 17)


GUICtrlSetData($lastchkupdate,IniRead("control.ini","patchinfo","lastcheck","ยังไม่เคยตรวจสอบการอัพเดตเลย"))
GUICtrlSetData($lastpatchupdate,IniRead("control.ini","patchinfo","lastpatch","ยังไม่เคยอัพเดตเลย"))
GUICtrlSetState($Checkbox1, $GUI_CHECKED)
GUICtrlSetState($Checkbox2, $GUI_CHECKED)
GUICtrlSetState($Checkbox3, $GUI_CHECKED)
GUICtrlSetState($Checkbox4, $GUI_CHECKED)


If  IniRead("control.ini","main","log","1") = 0 Then
	GUICtrlSetState($Checkbox1, $GUI_UNCHECKED)
EndIf
If  IniRead("control.ini","main","safemode","1") = 0 Then
	GUICtrlSetState($Checkbox2, $GUI_UNCHECKED)
EndIf
If  IniRead("control.ini","main","SHD","1") = 0 Then
	GUICtrlSetState($Checkbox3, $GUI_UNCHECKED)
EndIf
If  IniRead("control.ini","main","prlist","1") = 0 Then
	GUICtrlSetState($Checkbox4, $GUI_UNCHECKED)
	EndIf
#EndRegion ### END Koda GUI section ###

GUISetState(@SW_SHOW)
While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			GUISetState(@SW_HIDE,$maincontrolgui)
			ExitLoop
		Case $Checkbox1
			$chklog=IniRead("control.ini","main","log","1")
			If  $chklog = 1 Then
			IniWrite("control.ini","main","log","0")
		Else
			IniWrite("control.ini","main","log","1")
		EndIf
		Case $Checkbox2
			$chklog=IniRead("control.ini","main","safemode","1")
			If  $chklog = 1 Then
			IniWrite("control.ini","main","safemode","0")
		Else
			IniWrite("control.ini","main","safemode","1")
		EndIf
		Case $Checkbox3
			$chklog=IniRead("control.ini","main","SHD","1")
			If  $chklog = 1 Then
			IniWrite("control.ini","main","SHD","0")
		Else
			IniWrite("control.ini","main","SHD","1")
		EndIf
		Case $Checkbox4
			$chklog=IniRead("control.ini","main","prlist","1")
			If  $chklog = 1 Then
			IniWrite("control.ini","main","prlist","0")
		Else
			IniWrite("control.ini","main","prlist","1")
		EndIf
	Case $Button1
		;ShellExecute("logread.exe","",$control_pr)
		_logview()
	Case $Button2
		DoAbout()
	Case $Button3
		DoExit()
	Case $Button4
	;	ShellExecute("unblock.exe","",$control_pr)
		_unblockvirus()
	Case $Button5
		_safeexplorergui("My Computer")
EndSwitch
WEnd
EndFunc


Func _unblockvirus()
	Local $sItems, $aItems,$Form1,$Button1,$nMsg,$delquest,$delfile[100],$part1,$fileh,$open,$open2,$finalfile,$Button2,$filesec[100],$gener
$su=FileSelectFolder("เลือกflash drive ของคุณ","","","")
$unblockvirusgui = GUICreate("Restore File  :: Flash Drive Safe Check", 403, 451, -1, -1, BitOR($WS_SYSMENU,$WS_CAPTION,$WS_POPUP,$WS_POPUPWINDOW,$WS_BORDER,$WS_CLIPSIBLINGS), BitOR($WS_EX_TOPMOST,$WS_EX_WINDOWEDGE))
$Button1 = GUICtrlCreateButton("ลบ", 32, 408, 161, 41, $WS_GROUP)
$Button2 = GUICtrlCreateButton("ยกเลิกการกักกัน", 208, 408, 169, 41, $WS_GROUP)
$hListBox = GUICtrlCreateList("", 2, 2, 396, 396, BitOR($LBS_SORT,$LBS_STANDARD,$LBS_EXTENDEDSEL,$WS_VSCROLL,$WS_BORDER))


GUISetState(@SW_SHOW)

GUISetState()
	; Get indexes of selected items
_GUICtrlListBox_BeginUpdate($hListBox)
_GUICtrlListBox_ResetContent($hListBox)
_GUICtrlListBox_InitStorage($hListBox, 100, 4096)
_GUICtrlListBox_Dir($hListBox, $su&"\*.fsc")
_GUICtrlListBox_EndUpdate($hListBox)

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			GUISetState(@SW_HIDE,$unblockvirusgui)
			ExitLoop
		Case $Button1
					$aItems = _GUICtrlListBox_GetSelItemsText($hListBox)
					if $aItems[0]=0 Then
						MsgBox(64,"คำเตือน","คุณยังไม่ได้เลือกลบอะไรเลย")
						Else
						For $iI = 1 To $aItems[0]
							$sItems &= @LF & $aItems[$iI]
							Next
					;	$delquest=MsgBox(4, "ไฟล์ที่เลือก", "ไฟล์ที่เลือกมีดังนี้: " & $sItems)
					;	if  $delquest =6 Then
							for $iI=1 to $aItems[0]
								FileDelete($su&"\"&$aItems[$iI])
								Next
						;	MsgBox(64,"delete","ลบไวรัสเสร็จสมบูรณ์")
							_GUICtrlListBox_BeginUpdate($hListBox)
							_GUICtrlListBox_ResetContent($hListBox)
							_GUICtrlListBox_InitStorage($hListBox, 100, 4096)
							_GUICtrlListBox_Dir($hListBox, $su&"\*.fsc")
							_GUICtrlListBox_EndUpdate($hListBox)
					;	EndIf
						EndIf
					$sItems=""
				Case $Button2
					Local $file[100]
							$aItems = _GUICtrlListBox_GetSelItemsText($hListBox)
					if $aItems[0]=0 Then
						MsgBox(64,"คำเตือน","คุณยังไม่ได้เลือกลบอะไรเลย")
					Else
									For $iI = 1 To $aItems[0]
							$sItems &= @LF & $aItems[$iI]
							Next
						;$delquest=MsgBox(4, "ไฟล์ที่เลือก", "ไฟล์ที่เลือกมีดังนี้: " & $sItems)
						;if  $delquest =6 Then
							for $iI=1 to $aItems[0]
								$file[$iI]=$su&"\"&$aItems[$iI]
									$gener=StringLen($file[$iI])
								$filesec[$iI]=""
								for $i = 1 to $gener-4
								$filesec[$iI]&=StringMid($file[$iI], $i, 1)
								Next
							Next
							For $iI=1 to $aItems[0]
							$open=FileOpen($file[$iI],16)
							$fileh=Hex(FileRead($open))
							FileClose($open)
							$finalfile = _StringReverse($fileh)
							$open2=FileOpen($file[$iI],2)
							FileWrite($filesec[$iI],Binary("0x" & $finalfile))
							FileDelete($file[$iI])
							FileClose($open2)
							Next
							;MsgBox(64,"delete","กักกันไวรัสเสร็จสมบูรณ์")
							_GUICtrlListBox_BeginUpdate($hListBox)
							_GUICtrlListBox_ResetContent($hListBox)
							_GUICtrlListBox_InitStorage($hListBox, 100, 4096)
							_GUICtrlListBox_Dir($hListBox, $su&"\*.fsc")
							_GUICtrlListBox_EndUpdate($hListBox)
						;EndIf
						EndIf
					$sItems=""


	EndSwitch
WEnd

EndFunc

Func  _logview()
$logviewgui= GUICreate("ประวัติการใช้ flash drive :: Flash Drive Safe Check", 404, 452, -1, -1)
$Button1 = GUICtrlCreateButton("ล้างข้อมูล", 96, 408, 217, 41, $WS_GROUP)
$hListBox = GUICtrlCreateList("", 2, 2, 396, 396, BitOR($LBS_SORT,$LBS_STANDARD,$LBS_EXTENDEDSEL,$WS_VSCROLL,$WS_BORDER))
GUICtrlSetData(-1, "")
$i=1
		_GUICtrlListBox_BeginUpdate($hListBox)
	_GUICtrlListBox_ResetContent($hListBox)
	_GUICtrlListBox_InitStorage($hListBox, 100, 4096)
While 1
$content=FileReadLine("USBLog.txt",$i)
if $content="" Then
	ExitLoop
EndIf

	_GUICtrlListBox_InsertString($hListBox,$content)

$i=$i+1
WEnd
	_GUICtrlListBox_EndUpdate($hListBox)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			GUISetState(@SW_HIDE,$logviewgui)
			ExitLoop
		Case $Button1
			$x=FileOpen("USBLog.txt",2)
			FileClose($x)
			_GUICtrlListBox_BeginUpdate($hListBox)
	_GUICtrlListBox_ResetContent($hListBox)
	_GUICtrlListBox_InitStorage($hListBox, 100, 4096)
	EndSwitch
WEnd

EndFunc
Func _safeexplorergui($mainroot)
	if $mainroot="" Then $mainroot="My Computer"
Global $hidden1load=0,$load1checkbox1=0,$load1checkbox2=0,$load1checkbox3=0,$load1checkbox4=0,$load1checkbox5=0
Global $sRestore = @ScriptDir & '\control.ini'
Global $safeGUI = GUICreate("Safe explorer :: Flash drive safe check",735, 417)
Global $hList1 = _ExpListView_Create($safeGUI, $mainroot, 13, False, 29, 43, 680, 350)
If FileExists($sRestore)And IniRead($sRestore, 'ListViews', 'List1', '')<>""Then
    _ExpListView_ColumnViewsRestore($hList1, IniRead($sRestore, 'ListViews', 'List1', ''))
	$hidden1load=IniRead($sRestore,"ListViews","hiddenshow",0)
	$load1checkbox1=IniRead($sRestore,"ListViews","load1checkbox1",0)
	$load1checkbox2=IniRead($sRestore,"ListViews","load1checkbox2",0)
	$load1checkbox3=IniRead($sRestore,"ListViews","load1checkbox3",0)
	$load1checkbox4=IniRead($sRestore,"ListViews","load1checkbox4",0)
	$load1checkbox5=IniRead($sRestore,"ListViews","load1checkbox5",0)
EndIf

Global $sCurrentDirectory1 = GUICtrlCreateInput("", 70, 12, 480, 18)

$Back1 = GUICtrlCreateButton("กลับ", 618, 8, 53, 25, $WS_GROUP)
$Label1 = GUICtrlCreateLabel("Directory : ", 6, 12, 62, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
$input1 = GUICtrlCreateButton("ไป", 562, 8, 53, 25, $WS_GROUP)
$setting = GUICtrlCreateButton("ตั้งค่า", 672, 8, 49, 25, $WS_GROUP)

GUICtrlSetData($sCurrentDirectory1, _ExpListView_DirGetCurrent($hList1))
_ExpListView_SetFunction($hList1, '_Call_Function')

GUISetState(@SW_SHOW)

if $hidden1load=1 Then
			Local $flag = _ToggleHidden($hList1)
            _ExpListView_ShowHiddenFiles($hList1, $flag)
            _ExpListView_Refresh($hList1)
		endif
		Local $iColumn_Value = 0
			 If $load1checkbox1 = 1 Then $iColumn_Value += 1
			 If $load1checkbox2 = 1 Then $iColumn_Value += 2
			  If $load1checkbox3 = 1 Then $iColumn_Value += 4
			   If $load1checkbox4 = 1 Then $iColumn_Value += 8
            If $load1checkbox5 = 1 Then $iColumn_Value += 16
            _ExpListView_SetColumns($hList1, $iColumn_Value)

While 1
    $nMsg = GUIGetMsg()
    ;Switch $nMsg
     Select
		Case $nMsg=$GUI_EVENT_CLOSE
			GUISetState(@SW_HIDE,$safeGUI)
            ExitLoop
        Case $nMsg=$Back1
            _ExpListView_Back($hList1)
            GUICtrlSetData($sCurrentDirectory1, _ExpListView_DirGetCurrent($hList1))
		Case $nMsg=$input1
            Local $inputbox =GUICtrlRead($sCurrentDirectory1),$dirreturn
            $dirreturn=_ExpListView_DirSetCurrent($hList1, $inputbox)
           if $dirreturn<>1 Then MsgBox(64,"ERROR","ไม่พบfolderดังกล่าว")
			_ExpListView_DirSetCurrent($hList1, $inputbox)
            GUICtrlSetData($sCurrentDirectory1, _ExpListView_DirGetCurrent($hList1))
		Case $nMsg=$setting
			 _safe_settinggui()

	EndSelect
;EndSwitch
WEnd
EndFunc

;hWnd is the only parameter needed for the call function you create.
Func _Call_Function($hWnd)
    Switch $hWnd
        Case $hList1
            GUICtrlSetData($sCurrentDirectory1, _ExpListView_DirGetCurrent($hWnd))
    EndSwitch
EndFunc   ;==>_Call_Function

Func _ToggleHidden($List)
    Static $bFlag1 = -1, $bFlag2 = -1

    Switch $List
        Case $hList1
            $bFlag1 *= -1
            If $bFlag1 = -1 Then Return False

	EndSwitch

    Return True

EndFunc   ;==>_ToggleHidden

;Here we have a simple exit function that saves the column info so we can reload it at startup.
Func _safe_Exit()
	If $hList1<>"notuse" Then
    If Not FileExists($sRestore) Then _FileCreate($sRestore)
    IniWrite($sRestore, 'ListViews', 'List1', _ExpListView_ColumnViewsSave($hList1))
    IniWrite($sRestore,"ListViews","hiddenshow",$hidden1load)
	IniWrite($sRestore,"ListViews","load1checkbox1",$load1checkbox1)
	IniWrite($sRestore,"ListViews","load1checkbox2",$load1checkbox2)
	IniWrite($sRestore,"ListViews","load1checkbox3",$load1checkbox3)
	IniWrite($sRestore,"ListViews","load1checkbox4",$load1checkbox4)
	IniWrite($sRestore,"ListViews","load1checkbox5",$load1checkbox5)
	EndIf
EndFunc   ;==>_Exit

Func _safe_settinggui()
Local $Checkbox1,$Checkbox2,$Checkbox3,$Checkbox4,$Checkbox5
$infogui= GUICreate("การตั้งค่า", 248, 272, -1, -1, BitOR($WS_MINIMIZEBOX,$WS_DLGFRAME,$WS_GROUP,$WS_CLIPSIBLINGS),"",$safeGUI)
$Checkbox1 = GUICtrlCreateCheckbox("แสดงขนาด", 74, 32, 79, 19)
$Checkbox2 = GUICtrlCreateCheckbox("แสดงเวลาแก้ไข", 74, 58, 95, 19)
$Checkbox3 = GUICtrlCreateCheckbox("แสดงประเภท", 74, 82, 79, 19)
$Checkbox4 = GUICtrlCreateCheckbox("แสดงเวลาสร้าง", 74, 104,111, 19)
$Checkbox5 = GUICtrlCreateCheckbox("แสดงเวลาเปิด", 74, 128, 111, 19)
$HiddenCheckbox = GUICtrlCreateCheckbox("แสดงไฟล์ที่ซ่อน", 74, 154, 111, 19)
$closeinfo = GUICtrlCreateButton("ปิด", 64, 192, 121, 33, $WS_GROUP)
GUISetState(@SW_SHOW)
 If $load1checkbox1 = 1 Then GUICtrlSetState($Checkbox1,$GUI_CHECKED)
If $load1checkbox2 = 1 Then GUICtrlSetState($Checkbox2,$GUI_CHECKED)
  If $load1checkbox3 = 1 Then GUICtrlSetState($Checkbox3,$GUI_CHECKED)
   If $load1checkbox4 = 1 Then GUICtrlSetState($Checkbox4,$GUI_CHECKED)
   If $load1checkbox5 = 1 Then GUICtrlSetState($Checkbox5,$GUI_CHECKED)
   If $hidden1load = 1 Then GUICtrlSetState($HiddenCheckbox,$GUI_CHECKED)
While 1
	Local $s1Msg = GUIGetMsg()
	Select
	Case $s1Msg=$GUI_EVENT_CLOSE
		GUISetState(@SW_HIDE,$infogui)
		ExitLoop
		Case $s1Msg=$closeinfo
		GUISetState(@SW_HIDE,$infogui)
		ExitLoop
	Case $s1Msg=$Checkbox1 Or $s1Msg=$Checkbox2 or $s1Msg=$Checkbox3 Or $s1Msg=$Checkbox4 Or $s1Msg=$Checkbox5
		Local $iColumn_Value = 0
            If GUICtrlRead($Checkbox1) = $GUI_CHECKED Then
			$iColumn_Value += 1
			$load1checkbox1=1
		Else
			$load1checkbox1=0
			EndIf
            If GUICtrlRead($Checkbox2) = $GUI_CHECKED Then
			$iColumn_Value += 2
			$load1checkbox2=1
		Else
			$load1checkbox2=0
			EndIf
            If GUICtrlRead($Checkbox3) = $GUI_CHECKED Then
			$iColumn_Value += 4
			$load1checkbox3=1
		Else
			$load1checkbox3=0
			EndIf
            If GUICtrlRead($Checkbox4) = $GUI_CHECKED Then
			$iColumn_Value += 8
			$load1checkbox4=1
		Else
			$load1checkbox4=0
			EndIf
            If GUICtrlRead($Checkbox5) = $GUI_CHECKED Then
			$iColumn_Value += 16
			$load1checkbox5=1
			Else
			$load1checkbox5=0
			EndIf
            _ExpListView_SetColumns($hList1, $iColumn_Value)
		Case $s1Msg=$HiddenCheckbox
			If GUICtrlRead($HiddenCheckbox) = $GUI_CHECKED Then
				$hidden1load=1
			Else
				$hidden1load=0
			EndIf
			Local $flag = _ToggleHidden($hList1)
            _ExpListView_ShowHiddenFiles($hList1, $flag)
            _ExpListView_Refresh($hList1)
EndSelect

WEnd

 EndFunc

Func _warnning($su)
	Local $sItems, $aItems,$Form1,$Button1,$nMsg,$delquest,$delfile[100],$part1,$fileh,$open,$open2,$finalfile,$Button2
if $su="" Then $su=$CmdLine[2]
	; Create GUI
$Form1 = GUICreate("Warring Virus  :: Flash Drive Safe Check", 403, 451, -1, -1, BitOR($WS_SYSMENU,$WS_CAPTION,$WS_POPUP,$WS_POPUPWINDOW,$WS_BORDER,$WS_CLIPSIBLINGS), BitOR($WS_EX_TOPMOST,$WS_EX_WINDOWEDGE))
$Button1 = GUICtrlCreateButton("ลบ", 32, 408, 161, 41, $WS_GROUP)
$Button2 = GUICtrlCreateButton("กักกัน", 208, 408, 169, 41, $WS_GROUP)
$hListBox = GUICtrlCreateList("", 2, 2, 396, 396, BitOR($LBS_SORT,$LBS_STANDARD,$LBS_EXTENDEDSEL,$WS_VSCROLL,$WS_BORDER))


GUISetState(@SW_SHOW)
	; Add strings



	; Select a few items
GUISetState()
	; Get indexes of selected items
	_GUICtrlListBox_BeginUpdate($hListBox)
	_GUICtrlListBox_ResetContent($hListBox)
	_GUICtrlListBox_InitStorage($hListBox, 100, 4096)
	_GUICtrlListBox_Dir($hListBox, $su&"\*.exe")
	_GUICtrlListBox_Dir($hListBox, $su&"\*.inf")
	_GUICtrlListBox_Dir($hListBox, $su&"\*.pif")
	_GUICtrlListBox_Dir($hListBox, $su&"\*.lnk")
	_GUICtrlListBox_EndUpdate($hListBox)
	; Loop until user exits
While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			ExitLoop
		Case $Button1
					$aItems = _GUICtrlListBox_GetSelItemsText($hListBox)
					if $aItems[0]=0 Then
						MsgBox(64,"คำเตือน","คุณยังไม่ได้เลือกลบอะไรเลยหากไม่ต้องการเลือกโปรดปิดโปรแกรม")
						Else
						For $iI = 1 To $aItems[0]
							$sItems &= @LF & $aItems[$iI]
							Next
					;	$delquest=MsgBox(4, "ไฟล์ที่เลือก", "ไฟล์ที่เลือกมีดังนี้: " & $sItems)
					;	if  $delquest =6 Then
							for $iI=1 to $aItems[0]
								FileDelete($su&"\"&$aItems[$iI])
								Next
						;	MsgBox(64,"delete","ลบไวรัสเสร็จสมบูรณ์")
								_GUICtrlListBox_BeginUpdate($hListBox)
	_GUICtrlListBox_ResetContent($hListBox)
	_GUICtrlListBox_InitStorage($hListBox, 100, 4096)
	_GUICtrlListBox_Dir($hListBox, $su&"\*.exe")
	_GUICtrlListBox_Dir($hListBox, $su&"\*.inf")
	_GUICtrlListBox_Dir($hListBox, $su&"\*.pif")
	_GUICtrlListBox_Dir($hListBox, $su&"\*.lnk")
	_GUICtrlListBox_EndUpdate($hListBox)
					;	EndIf
						EndIf
					$sItems=""
				Case $Button2
					Local $file[100]
							$aItems = _GUICtrlListBox_GetSelItemsText($hListBox)
					if $aItems[0]=0 Then
						MsgBox(64,"คำเตือน","คุณยังไม่ได้เลือกลบอะไรเลย")
					Else
									For $iI = 1 To $aItems[0]
							$sItems &= @LF & $aItems[$iI]
							Next
						;$delquest=MsgBox(4, "ไฟล์ที่เลือก", "ไฟล์ที่เลือกมีดังนี้: " & $sItems)
						;if  $delquest =6 Then
							for $iI=1 to $aItems[0]
								$file[$iI]=$su&"\"&$aItems[$iI]
							Next
							For $iI=1 to $aItems[0]
							$open=FileOpen($file[$iI],16)
							$fileh=Hex(FileRead($open))
							FileClose($open)
							$finalfile = _StringReverse($fileh)
							$open2=FileOpen($file[$iI],2)
							FileWrite($file[$iI]&".fsc",Binary("0x" & $finalfile))
							FileDelete($file[$iI])
							FileClose($open2)
							Next
							;MsgBox(64,"delete","กักกันไวรัสเสร็จสมบูรณ์")
								_GUICtrlListBox_BeginUpdate($hListBox)
	_GUICtrlListBox_ResetContent($hListBox)
	_GUICtrlListBox_InitStorage($hListBox, 100, 4096)
	_GUICtrlListBox_Dir($hListBox, $su&"\*.exe")
	_GUICtrlListBox_Dir($hListBox, $su&"\*.inf")
	_GUICtrlListBox_Dir($hListBox, $su&"\*.pif")
	_GUICtrlListBox_Dir($hListBox, $su&"\*.lnk")
	_GUICtrlListBox_EndUpdate($hListBox)
						;EndIf
						EndIf
					$sItems=""


	EndSwitch
WEnd

EndFunc   ;==>_Main

Func _ExitLoop()
 Exit
 EndFunc

Func DoAbout()
$infogui= GUICreate("คณะผู้จัดทำ", 248, 272, -1, -1, BitOR($WS_MINIMIZEBOX,$WS_DLGFRAME,$WS_GROUP,$WS_CLIPSIBLINGS),"",$maincontrolgui)

$name_pan = GUICtrlCreateLabel("ด.ช.ปฎิภาณ       นิตย์เกษม    เลขที่ 12", 32, 16, 178, 17)
$name_pure = GUICtrlCreateLabel("ด.ช.ภัคพล          พงษ์ทวี        เลขที่ 13", 32, 40, 178, 17)
$name_mook = GUICtrlCreateLabel("ด.ญ.บวรลักษณ์  สุขประเสริฐ  เลขที่ 30", 32, 64, 179, 17)
$name_gam = GUICtrlCreateLabel("ด.ญ.อัญญาพร     เพิ่มชาติ      เลขที่ 38", 32, 88, 180, 17)
$classroom = GUICtrlCreateLabel("ชั้นมัธยมศึกษาปีที่  3/1", 64, 112, 110, 17)
$terminfo = GUICtrlCreateLabel("ภาคเรียนที่ 2 ปีการศึกษา  2554", 48, 136, 151, 17)
$schoolinfo = GUICtrlCreateLabel("โรงเรียนเบญจมราชูทิศ   ราชบุรี", 48, 160, 153, 17)
$closeinfo = GUICtrlCreateButton("ปิด", 64, 192, 121, 33, $WS_GROUP)
GUISetState(@SW_SHOW)
While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
		GUISetState(@SW_HIDE,$infogui)
		ExitLoop
		Case $closeinfo
		GUISetState(@SW_HIDE,$infogui)
		ExitLoop
	EndSwitch
WEnd

;MsgBox(64,"สร้างโดย","ด.ช.ปฏิภาณ นิตเกษม เลขที่ 12"&@CRLF&"ด.ช.ภัคพล  พงษ์ทวี   เลขที่ 13"&@CRLF&"ด.ญ.บวรลักษณ์  สุขประเสริฐ   เลขที่ 30"&@CRLF&"ด.ญ.อัญญาพร  เพิ่มชาติ   เลขที่ 38"&@CRLF&"ม.3/1 ปีการศึกษา 2554"&@CRLF&"โรงเรียนเบญจมราชูทิศ ราชบุรี")
 EndFunc

Func DoExit()
		ProcessClose("FSC-Lite-scan.exe")
	_safe_Exit()
 Exit
 EndFunc

#cs
โครงงาน เรื่อง โปรแกรมป้องกันไวรัสจากflash drive (Flash drive safe check)
สมาชิก
1.ด.ช. ปฎิภาณ  นิตเกษม เลขที่12
2.ด.ช.ภัคพล  พงษ์ทวี เลขที่ 13
3.ด.ญ.บวรลักษณ์  สุขประเสริฐ เลขที่30
4.ด.ญอัญญาพร  เพิ่มชาติ เลขที่ 38
กลุ่มที่ 5 ม.3/1
#ce