set moddir=%CD%
set modname="arcane_sniping"
@ECHO OFF

:MainMenu
CLS

ECHO 1. Build IWD
ECHO 2. Build Mod
ECHO 3. Exit
ECHO.

CHOICE /C 123 /M "Enter your choice: "

IF ERRORLEVEL 3 GOTO CloseAll
IF ERRORLEVEL 2 GOTO BuildMod
IF ERRORLEVEL 1 GOTO BuildIwd
pause

:BuildIwd
if exist images.iwd del images.iwd
7za a -tzip images.iwd images
goto MainMenu

:BuildMod
if not exist ..\..\zonetool.exe goto ERROR_ZONETOOL_EXE_NOT_FOUND

if exist ..\..\zone_source goto SKIP_ZONE_SOURCE_FOLDER
:MAKE_ZONE_SOURCE_FOLDER
mkdir ..\..\zone_source
:SKIP_ZONE_SOURCE_FOLDER

copy /Y mod.csv ..\..\zone_source

if exist ..\..\zonetool goto SKIP_ZONETOOL_FOLDER
:MAKE_ZONETEOOL_FOLDER
mkdir ..\..\zonetool
:SKIP_ZONETOOL_FOLDER

if exist ..\..\zonetool\mod goto SKIP_MOD_FOLDER
:MAKE_MOD_FOLDER
mkdir ..\..\zonetool\mod
:SKIP_MOD_FOLDER

xcopy images ..\..\zonetool\mod\images\ /SY
xcopy loaded_sound ..\..\zonetool\mod\loaded_sound\ /SY
xcopy maps ..\..\zonetool\mod\maps\ /SY
xcopy materials ..\..\zonetool\mod\materials\ /SY
xcopy mp ..\..\zonetool\mod\mp\ /SY
xcopy scripts ..\..\zonetool\mod\scripts\ /SY
xcopy sounds ..\..\zonetool\mod\sounds\ /SY

if not exist ..\..\zonetool\mod\techsets\ goto DO_TECHSETS
:DO_TECHSETS
choice /c YN /t 3 /d N /m "Compile Techsets"
if %errorlevel% equ 2 goto SKIP_TECHSETS
if exist ..\..\zonetool\mod\techsets\ del ..\..\zonetool\mod\techsets\ /Q
xcopy techsets ..\..\zonetool\mod\techsets\ /SY
:SKIP_TECHSETS

xcopy ui ..\..\zonetool\mod\ui\ /SY
xcopy ui_mp ..\..\zonetool\mod\ui_mp\ /SY
xcopy weapons ..\..\zonetool\mod\weapons\ /SY
xcopy xanim ..\..\zonetool\mod\xanim\ /SY
xcopy xmodel ..\..\zonetool\mod\xmodel\ /SY
xcopy xsurface ..\..\zonetool\mod\xsurface\ /SY

cd ..\..\
zonetool.exe -buildzone mod -quit
cd %moddir%

copy /Y ..\..\zone\english\mod.ff
del ..\..\zone\english\mod.ff
goto CopyAppdata
pause
goto MainMenu

:CopyAppdata
for /f "delims=" %%A in ('cd') do ( set modname=%%~nxA )

cd /d %LocalAppData%\Plutonium\storage\iw5\
if ERRORLEVEL 1 echo "Could not find Plutonium appdata folder..." & goto EOF

if not exist "mods\" ( mkdir mods )
cd mods\

if not exist "%modname%\" ( mkdir %modname% )
cd %modname%\

xcopy "%moddir%\mod.ff" "%cd%" /YF
xcopy "%moddir%\images.iwd" "%cd%" /YF
goto EOF

:EOF
pause

:CloseAll
exit