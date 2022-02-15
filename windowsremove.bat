@echo off
echo  "辅助功能镜像劫持"
echo "还原辅助功能"
copy 木马路径:C:\Windows\Temp\temp\osk.exe C:\Windows\System32\osk.exe
copy 木马路径:C:\Windows\Temp\temp\Magnify.exe C:\Windows\System32\Magnify.exe
copy 木马路径:C:\Windows\Temp\temp\Narrator.exe C:\Windows\System32\Narrator.exe
copy 木马路径:C:\Windows\Temp\temp\DisplaySwitch.exe C:\Windows\System32\DisplaySwitch.exe
copy 木马路径:C:\Windows\Temp\temp\AtBroker.exe C:\Windows\System32\AtBroker.exe

echo "删除映像劫持"
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\iexplore.exe" /v "Debugger" /f

echo "启动项"
del c:\user\%username%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\shell.exe

echo "删除启动项注册表后门"
reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run" /v "Debugger" /f
reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\RunOnce"  /v "Debugger" /f
reg delete "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run"  /v "Debugger" /f
reg delete "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\RunOnce"  /v "Debugger" /f

echo "删除自启动服务后门"
net stop "startup" || sc delete "startup"

echo "删除系统计划任务后门"
schtasks /delete /TN keep /F

echo "删除winlogon 登录劫持"
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Userinit /f

echo "删除Logon Scripts后门"
reg delete "HKEY_CURRENT_USER\Environment" /v startup /f

echo "删除屏幕保护程序劫持"
reg delete "HKEY_CURRENT_USER\Control Panel\Desktop" /v SCRNSAVE.EXE /f

echo "删除wmi无文件后门"
powershell Get-WMIObject -Namespace root\Subscription -Class CommandLineEventConsumer |Remove-WmiObject -Verbose

echo "删除影子账户"
net localgroup administrators test$ /del
net user test$ /delete
