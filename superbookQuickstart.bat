@echo off

echo *******************************************************************
echo ***        Welcome to the Superbook quick-start script!         ***
echo *** Please make sure you turned on usb debugging on your phone. ***
echo ***                                                             ***
echo ***    I take no responsibility for the following commands!     ***
echo ***     You can open this script to check what it's doing.      ***
echo ***                                                             ***
echo ***                 Please read the README.txt                  ***
echo ***                                                             ***
echo ***       by Leonhard Künzler, 2018, leonhard@kuenzler.io       ***
echo ***       and Danny Sortino, 2018, danny.sortino@hotmail.co.uk  ***
echo *******************************************************************

IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

echo    Clockwork universial usb driver provides driver support for most devices.
echo    If you already have the drives for your your mobile installed then you do not need to install this.
echo    If these drivers do not work, grab the correct ones from https://developer.android.com/studio/run/oem-usb
set /P c=Install clockwork universal usb driver app (Note: requires admin)? [Y/N]?
if /I "%c%" EQU "Y" goto :checkIfAdmin
goto :checkDownloadADB

:checkIfAdmin
if '%errorlevel%' NEQ '0' (
	echo Requesting administrative privileges...
	goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"
"%temp%\getadmin.vbs"
goto checkDownloadADB
	

:gotAdmin
if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
pushd "%CD%"
CD /D "%~dp0"
goto clockworkmod

:clockworkmod
echo Installing clockworkmod
powershell -command "start-bitstransfer -source http://download.clockworkmod.com/test/UniversalAdbDriverSetup.msi"
setlocal
cd /d %~dp0
msiexec.exe /i %cd%\UniversalAdbDriverSetup.msi /QN /L*V "%temp%\msilog.log"
del UniversalAdbDriverSetup.msi
exit /B

:checkDownloadADB
echo.
echo    ADB is needed for executing commands on the phone.
echo    If you already have adb.exe inside this directory then you do not need to download this.
set /P c=Download ADB (Note: needed for further commands)? [Y/N]?
if /I "%c%" EQU "Y" (
	SET /A extracted=1
	goto :installADB
)
if /I "%c%" EQU "N" (
	SET /A extracted=0
	goto :deviceCheck
)

:installADB
powershell -command "start-bitstransfer -source https://dl.google.com/android/repository/platform-tools-latest-windows.zip"
setlocal
cd /d %~dp0
Call :UnZipFile "%cd%\" "%cd%\platform-tools-latest-windows.zip"
del platform-tools-latest-windows.zip
cd "%cd%\platform-tools"
goto deviceCheck

:deviceCheck
echo.
echo 1: Devicecheck
echo    Checking for your device...
echo    If you don't see your device between the dots, it's not recognized. 
echo	In this case check the device manager and/or the link about the drivers above.
echo	if it ends with "device", everything is good. 
echo 	if it ends with "unauthorized" please check your phone screen and accept the prompt
:checkDevices
echo ........................................
adb devices
echo ........................................
set /P c=Try again? [Y/N]?
if /I "%c%" EQU "Y" goto :checkDevices
if /I "%c%" EQU "N" goto :afterDeviceCheck
goto :checkDevices

:afterDeviceCheck
echo.
echo 2: Install sentio app
echo    This app will provide you with a desktop interface and takes care
echo    of firmware updates. You should install it.

:installSentioCheck
set /P c=Install sentio app? [Y/N]?
if /I "%c%" EQU "Y" goto :installSentio
if /I "%c%" EQU "N" goto :afterInstallSentio
goto installSentioCheck

:installSentio
adb shell input keyevent KEYCODE_WAKEUP
adb shell am start -a android.intent.action.VIEW -d 'market://details?id=com.sentio.desktop'
echo Please check your phone screen!
pause 
:afterInstallSentio

echo.
echo 3: Install displaylink app
echo    This app will manage the video output from your phone to the superbook.
echo    It's mandatory to install it.

:installDisplayLinkCheck
set /P c=Install displaylink app? [Y/N]?
if /I "%c%" EQU "Y" goto :installDisplayLink
if /I "%c%" EQU "N" goto :afterInstallDisplayLink
goto installDisplayLinkCheck

:installDisplayLink
adb shell input keyevent KEYCODE_WAKEUP
adb shell am start -a android.intent.action.VIEW -d 'market://details?id=com.displaylink.presenter'
echo Please check your phone screen!
pause 
:afterInstallDisplayLink

echo.
echo 4: Install displaylink demo app
echo    This app will manage the video output from your phone to the superbook.
echo    It may be required to get the superbook up and running

:installDisplayLinkDemoCheck
set /P c=Install displaylink demo app? [Y/N]?
if /I "%c%" EQU "Y" goto :installDisplayLinkDemo
if /I "%c%" EQU "N" goto :afterInstallDisplayLinkDemo
goto installDisplayLinkDemoCheck

:installDisplayLinkDemo
adb shell input keyevent KEYCODE_WAKEUP
adb shell am start -a android.intent.action.VIEW -d 'market://details?id=com.displaylink.desktop.demo'
echo Please check your phone screen!
pause 
:afterInstallDisplayLinkDemo

echo.
echo 5: Enable freeform windows (if sentio app is installed)
echo    In order to resize windows you need to activate freeform windows.
echo    (see https://medium.com/sentio-superbook/how-to-enable-multi-window-in-android-o-678cced03db2)

:freeformWindowCheck
set /P c=Activate freeform windows? [Y/N]?
if /I "%c%" EQU "Y" goto :setFreeformWindow
if /I "%c%" EQU "N" goto :afterSetFreeformWindow
goto freeformWindowCheck

:setFreeformWindow
adb shell settings put global enable_freeform_support 1
echo    ...done
pause 
:afterSetFreeformWindow

echo.
echo 6: DPI Change (if sentio app is installed)
echo    The Superbook and your phone most likely don't have the same resolution.
echo    For the resolution to be changed automatically, a security flag has to be set. 
echo    (see https://medium.com/sentio-superbook/enabling-sentio-desktop-dpi-resolution-change-d1a0b40e2c84)

:secureSettingsCheck
set /P c=Do you like to activate automatic dpi change? [Y/N]?
if /I "%c%" EQU "Y" goto :setSecureSettings
if /I "%c%" EQU "N" goto :afterSetSecureSettings
goto secureSettingsCheck

:setSecureSettings
adb shell pm grant com.sentio.desktop android.permission.WRITE_SECURE_SETTINGS
echo    ...done
pause 
:afterSetSecureSettings


echo.
echo 7: OnePlus always-on OTG
echo    If you are using a OnePlus device on OxygenOS, then it is recommended
echo    that you permanently enable OTG.

:restartCheck
set /P c=Would you like to permanently enable OTG? [Y/N]?
if /I "%c%" EQU "Y" goto :onePlusPermanentOTG
if /I "%c%" EQU "N" goto :afterOnePlusPermanentOTG
goto restartCheck

:onePlusPermanentOTG
start adb shell settings put global oneplus_otg_auto_disable 0
pause 
:afterOnePlusPermanentOTG

echo.
echo 8: Reboot
echo    Done! You're all set to use the Superbook!
echo    If you activated one of the settings above, you should restart your phone. 

:restartCheck
set /P c=Should your phone be restarted? [Y/N]?
if /I "%c%" EQU "Y" goto :restart
if /I "%c%" EQU "N" goto :afterRestart
goto restartCheck

:restart
start adb reboot
pause 
:afterRestart

echo.
echo 9: Done
echo    You're all set. Have fun!
adb kill-server
timeout 1
if /I "%extracted%" EQU "1" goto cleanupPlatformTools

:cleanupPlatformTools
cd ..
@RD /S /Q "%cd%\platform-tools"

:preEnd
pause
echo Exiting...
:end


:UnZipFile <ExtractTo> <newzipfile>
set vbs="%temp%\_.vbs"
if exist %vbs% del /f /q %vbs%
>%vbs%  echo Set fso = CreateObject("Scripting.FileSystemObject")
>>%vbs% echo If NOT fso.FolderExists(%1) Then
>>%vbs% echo fso.CreateFolder(%1)
>>%vbs% echo End If
>>%vbs% echo set objShell = CreateObject("Shell.Application")
>>%vbs% echo set FilesInZip=objShell.NameSpace(%2).items
>>%vbs% echo objShell.NameSpace(%1).CopyHere(FilesInZip)
>>%vbs% echo Set fso = Nothing
>>%vbs% echo Set objShell = Nothing
cscript //nologo %vbs%
if exist %vbs% del /f /q %vbs%

