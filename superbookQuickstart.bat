@echo off

echo ******************************************************************
echo ***        Welcome to the Superbook quick-start script!        ***
echo *** Please make sure you turned on usb debugging on your phone ***
echo ***          and installed the drivers if necessarry.          ***
echo ***                     for drivers go to:                     ***
echo ***      https://developer.android.com/studio/run/oem-usb      ***
echo ***                                                            ***
echo ***    I take no responsibility for the following commands!    ***
echo ***     You can open this script to check what it's doing.     ***
echo ***                                                            ***
echo *** If you want to enter the commands yourself, you can just   ***
echo *** open a shell (Shift+Right click) in this folder and start  ***
echo ***          with an adb commant (eg. "adb devices")           ***
echo ***                                                            ***
echo ***                 Please read the README.md                  ***
echo ***                                                            ***
echo ***       by Leonhard Künzler, 2018, leonhard@kuenzler.io      ***
echo ******************************************************************

echo.
echo 1: Devicecheck
echo    Checking for your device...
echo    If you don't see your device between the dots, it's not recognized. 
echo	In this case check the device manager and/or the link about the drivers above.
echo	if it ends with "device", everything is good. 
echo 	if it ends with "unauthorized" please check your phone screen and accept the promt
:deviceCheck
echo ........................................
adb devices
echo ........................................
set /P c=Try again? [Y/N]?
if /I "%c%" EQU "Y" goto :deviceCheck
if /I "%c%" EQU "N" goto :afterDeviceCheck
goto :deviceCheck

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
goto installSentioCheck

:installDisplayLink
adb shell input keyevent KEYCODE_WAKEUP
adb shell am start -a android.intent.action.VIEW -d 'market://details?id=com.displaylink.presenter'
echo Please check your phone screen!
pause 
:afterInstallDisplayLink

echo.
echo 4: Enable freeform windows (if sentio app is installed)
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
echo 5: DPI Change (if sentio app is installed)
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
echo 6: Reboot
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
echo 7: Done
echo    You're all set. Have fun!

:preEnd
pause
echo Exiting...
:end
