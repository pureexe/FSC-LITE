$regvar1="main"
$locareg="HKEY_LOCAL_MACHINE\SOFTWARE\benjama\flashdrivesafechk\lite"
$control_pr=RegRead($locareg,$regvar1)
DirCreate(@TempDir&"\FSC")
FileInstall("C:\Documents and Settings\Administrator\Desktop\fsc\FSC-Lite.exe",@TempDir&"\FSC\FSC-Lite.exe",1)
FileInstall("C:\Documents and Settings\Administrator\Desktop\fsc\FSC-Lite-scan.exe",@TempDir&"\FSC\FSC-Lite-scan.exe",1)
$userask=MsgBox(4,"FSC :: Lite setup","ต้องการติดตั้งแบบใช้ครั้งเดียว ใช่หรือไม่?"&@CRLF&"กดyes เพื่อติดตั้งแบบใช้ครั้งเดียวเมื่อปิดทุกอย่างจะหายไป"&@CRLF&"กดno เพื่อติดตั้งแบบถาวรโดยจะฝังregistyและstartup")
if $userask=7 Then
	FileCopy(@TempDir&"\FSC\FSC-Lite-scan.exe",@StartupDir&"FSC-Lite-scan.exe")
	FileCopy(@TempDir&"\FSC\FSC-Lite-scan.exe",@StartupCommonDir&"FSC-Lite-scan.exe")
	Regwrite($locareg,$regvar1,"REG_SZ",@TempDir&"\FSC\")
EndIf
Run(@TempDir&"\FSC\FSC-Lite-scan.exe",@TempDir&"\FSC")

