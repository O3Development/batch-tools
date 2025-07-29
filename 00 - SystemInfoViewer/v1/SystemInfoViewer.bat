chcp 65001
setlocal enabledelayedexpansion

@echo off
net session
if %errorlevel% NEQ 0 goto runasadmin

cls
mode 80,40
color F0

for /f "skip=1 delims=" %%a in ('wmic cpu get name') do (
    if not defined CPU_BRAND set CPU_BRAND=%%a
)

for /f "skip=1 delims=" %%a in ('wmic path win32_videocontroller get name') do (
    if not defined GPU_BRAND set GPU_BRAND=%%a
)

chcp 437 >nul
for /f %%a in (
  'powershell -NoProfile -Command "(Get-WmiObject Win32_VideoController | Select-Object -First 1).AdapterRAM / 1MB"'
) do (
  set "GPU_VRAM=%%a MB"
)

for /f %%a in (
  'powershell -NoProfile -Command "[math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 2)"'
) do (
  set "RAM_GB=%%a GB"
)


chcp 65001 >nul

:main

for /f "skip=1 delims=" %%a in ('wmic cpu get loadpercentage') do (
    set "raw=%%a"
    set "CPU_LOAD=!raw: =!"
    goto afterloop
)

:afterloop

timeout /t 1 /nobreak >nul
cls
echo.
echo SystemInfoViewer v1.0 by O3Development
echo.
echo.
echo Motherboard Components:
echo 	CPU:
echo 	^|
echo 	^|—Name/Brand: !CPU_BRAND!
echo 	^|—Temparature: Coming Soon (Not available in this version.)
echo 	^|—Load: !CPU_LOAD!
echo.
echo 	GPU
echo 	^|
echo 	^|—Name/Brand: !GPU_BRAND!
echo 	^|—Temparature: Coming Soon (Not available in this version.)
echo 	^|—VRAM: !GPU_VRAM!
echo.
echo 	RAM
echo 	^|
echo 	^|—Capacity: !RAM_GB!
echo.
echo.
echo.
echo.
echo Learn more about it at my GitHub Repo and get more useful programs:
echo.
echo https://github.com/O3Development/batch-tools/tree/main

goto main

:runasadmin
cls
echo.
echo.
echo Program did not start with Admin Privileges.
echo Requesting Permission...
timeout /t 3 /nobreak >nul
powershell -Command "Start-Process '%~f0' -Verb runAs"
exit
