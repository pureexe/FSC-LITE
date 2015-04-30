#include <file.au3>
#NoTrayIcon
$regvar1="main"
$locareg="HKEY_LOCAL_MACHINE\SOFTWARE\benjama\flashdrivesafechk\"
$control_pr=RegRead($locareg,$regvar1)
if Not ProcessExists("FSC-Lite.exe") Then
Run("FSC-Lite.exe start",@TempDir&"\FSC\")
ElseIf Not ProcessExists("FSC-Lite.exe") And $control_pr<>"" Then
Run("FSC-Lite.exe start",$control_pr)
EndIf
$strComputer = "."
$objWMIService = ObjGet("winmgmts:\\" & $strComputer & "\root\cimv2")
$colEvents = $objWMIService.ExecNotificationQuery  ("Select * From __InstanceOperationEvent Within 5 Where " & "TargetInstance isa 'Win32_LogicalDisk'")
$x=1
$prlist=IniRead("control.ini","main","prlist","1")
While 1
	 if $prlist=1 Then $processlist=ProcessList()
	$objEvent = $colEvents.NextEvent
	If $objEvent.TargetInstance.DriveType = 2 Then
	Select
					Case $objEvent.Path_.Class() = "__InstanceCreationEvent"

					$uix=$objEvent.TargetInstance.DeviceId
					;SplashTextOn("","คำเตือนตรวจพบไฟล์ต้องสงสัยหากเป็นไวรัสโปรดลบทิ้งทันที ","400","150","-1","-1",33,"","","")
					If FileExists($objEvent.TargetInstance.DeviceId & "\*.exe") OR FileExists($objEvent.TargetInstance.DeviceId & "\*.pif") OR FileExists($objEvent.TargetInstance.DeviceId & "\*.lnk") Then
				;run("warning.exe"&" "&$uix)
				run("FSC-Lite.exe"&" warnning "&$uix)
				EndIf

			;	SplashOff()
						$safemode=IniRead("control.ini","main","safemode","1")
						$log=IniRead("control.ini","main","log","1")
						$SHD=IniRead("control.ini","main","SHD","1")
						$prlist=IniRead("control.ini","main","prlist","1")
						if $safemode=1 Then run("FSC-Lite.exe"&" expsafe "&$uix);_safeexplorergui($uix);ShellExecute("explorer-safe.exe",$uix)
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
;~ 									if @error Then
;~ 										MsgBox(64,"SHD error","SHD system ยังคงมีบัคอยู่ซึ่งกำลังดำเนินการแก้ *-*")
;~ 										ExitLoop
;~ 									EndIf
							Next
						EndIf
						if $prlist=1 Then
						Sleep(1000)
						$processlistnew=ProcessList()
						Local $newlist=""
						for $i=1 to $processlistnew[0][0]-$processlist[0][0]
							if $processlistnew[$processlist[0][0]+$i][0]<>"FSC-Lite.exe" And $processlistnew[$processlist[0][0]+$i][0]<>"explorer-safe.exe" Then $newlist&=$processlistnew[$processlist[0][0]+$i][0]&@CRLF
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
	WEnd