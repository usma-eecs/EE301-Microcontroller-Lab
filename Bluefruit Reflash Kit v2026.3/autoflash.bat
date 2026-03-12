@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Flash Bluefruit + CircuitPython + Diagnostics

rem ============================================================
rem EE301 / AI105 Bluefruit reflash helper
rem - Uses paths relative to this batch file
rem - Checks that required files exist before starting
rem - Waits for COM ports to enumerate
rem - Lets the user choose a COM port if more than one is found
rem - Warns clearly that CIRCUITPY will be replaced with diagnostics
rem ============================================================

set "SCRIPT_DIR=%~dp0"
pushd "%SCRIPT_DIR%" >nul 2>&1

rem ====== Config ======
set "NRFUTIL=adafruit-nrfutil.exe"
set "PKG=circuitplayground_nrf52840_bootloader-0.10.0_s140_6.1.1.zip"
set "UF2=adafruit-circuitpython-circuitplayground_bluefruit-en_US-10.1.3.uf2"
set "DIAG=diagnostics"
set "BAUD=115200"
set "BLLABEL=CPLAYBTBOOT"
set "CPYLABEL=CIRCUITPY"
set "ENUM_WAIT=15"
set "LABEL_WAIT=60"

echo ============================================================
echo  EE301 Bluefruit Reflash Utility
echo ============================================================
echo.
echo This script will:
echo   1. Flash the Bluefruit bootloader over USB serial
echo   2. Copy the CircuitPython UF2 to %BLLABEL%
echo   3. Wait for %CPYLABEL% to appear
echo   4. DELETE the current contents of %CPYLABEL%
echo   5. Copy the diagnostics files onto %CPYLABEL%
echo.
echo Before continuing:
echo   - Plug in exactly one Bluefruit if possible
echo   - Double-tap RESET so the outer NeoPixels are green
if not "%~1"=="" echo   - Serial port was provided on the command line: %~1
echo.

call :check_required "%NRFUTIL%" "required utility"
call :check_required "%PKG%" "bootloader DFU package"
call :check_required "%UF2%" "CircuitPython UF2 image"
call :check_required "%DIAG%" "diagnostics folder"

echo [INFO] Required files found.
echo.

rem ====== COM port selection ======
rem Priority: %1 (argument) > PORT (environment) > auto-detect
if not "%~1"=="" set "PORT=%~1"
if not defined PORT call :detect_port
if not defined PORT goto fail_no_port

echo [INFO] Using serial port: %PORT%
echo [INFO] Checking whether %PORT% can be opened...
call :probe_port "%PORT%"
if errorlevel 1 goto fail_port_open
echo [OK] Serial port %PORT% is reachable.
echo [INFO] Flashing bootloader on %PORT%...
set "NRFLOG=%TEMP%\autoflash_nrfutil_%RANDOM%_%RANDOM%.log"
"%NRFUTIL%" --verbose dfu serial --package "%PKG%" -b %BAUD% --singlebank --touch 1200 --port %PORT% >"%NRFLOG%" 2>&1
set "NRF_RC=%ERRORLEVEL%"
type "%NRFLOG%"
findstr /I /C:"could not open serial port" /C:"failed to open serial port" /C:"access is denied" /C:"permissionerror" /C:"no such file or directory" /C:"port busy" "%NRFLOG%" >nul
if not errorlevel 1 goto fail_port_open
if not "%NRF_RC%"=="0" goto fail_flash
del /q "%NRFLOG%" >nul 2>&1

echo [INFO] Waiting for %BLLABEL% drive...
call :wait_for_label "%BLLABEL%" %LABEL_WAIT%
if not defined DRIVE goto fail_boot_drive

echo [INFO] Copying UF2 to %DRIVE%...
copy "%UF2%" "%DRIVE%\" /Y >nul
if errorlevel 1 goto fail_copy_uf2

echo [OK] UF2 copied. Waiting for remount...
timeout /t 5 >nul

echo [INFO] Waiting for %CPYLABEL% to remount...
call :wait_for_label "%CPYLABEL%" %LABEL_WAIT%
if not defined DRIVE goto fail_circuitpy

echo [INFO] Drive %DRIVE% ready.
echo [WARNING] Existing files on %CPYLABEL% will be deleted and replaced.
echo [INFO] Installing diagnostics...

del /q "%DRIVE%\*" >nul 2>&1
for /d %%D in ("%DRIVE%\*") do rmdir /s /q "%%~fD"

xcopy "%DIAG%\*" "%DRIVE%\" /E /I /Y >nul
if errorlevel 1 goto fail_diag

echo [DONE] Diagnostics copied successfully.
echo [DONE] It is now safe to close this window.
goto success

:detect_port
set "PORT="
for /L %%T in (1,1,%ENUM_WAIT%) do (
  call :scan_ports
  if !COUNT! GTR 0 goto choose_port
  echo [INFO] Waiting for a COM port to appear... (%%T/%ENUM_WAIT%)
  timeout /t 1 >nul
)
exit /b 0

:choose_port
if "%COUNT%"=="1" (
  set "PORT=!PORT_1!"
  exit /b 0
)

echo [INFO] Detected serial ports:
for /L %%I in (1,1,%COUNT%) do echo   [%%I] !PORT_%%I!
echo.
:prompt_port
set "SELECTION="
set /p "SELECTION=Enter the number of the Bluefruit serial port and press Enter: "
if not defined SELECTION goto prompt_port
for /f "delims=0123456789" %%A in ("!SELECTION!") do set "BADNUM=%%A"
if defined BADNUM (
  set "BADNUM="
  echo [ERROR] Please enter a number from 1 to %COUNT%.
  goto prompt_port
)
if !SELECTION! LSS 1 (
  echo [ERROR] Please enter a number from 1 to %COUNT%.
  goto prompt_port
)
if !SELECTION! GTR %COUNT% (
  echo [ERROR] Please enter a number from 1 to %COUNT%.
  goto prompt_port
)
set "PORT=!PORT_%SELECTION%!"
exit /b 0

:scan_ports
set "COUNT=0"
for /f "tokens=3" %%A in ('reg query HKLM\HARDWARE\DEVICEMAP\SERIALCOMM 2^>nul ^| findstr /R /C:"COM[0-9][0-9]*"') do (
  set /a COUNT+=1
  set "PORT_!COUNT!=%%A"
)
exit /b 0

:wait_for_label
set "TARGET=%~1"
set "SECONDS=%~2"
set "DRIVE="
for /L %%S in (1,1,%SECONDS%) do (
  for %%D in (D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    vol %%D: 2>nul | findstr /I /C:"%TARGET%" >nul && set "DRIVE=%%D:"
  )
  if defined DRIVE exit /b 0
  if /I "%TARGET%"=="%CPYLABEL%" echo [WARNING] Single-tap RESET if %CPYLABEL% is not appearing in File Explorer.
  timeout /t 1 >nul
)
exit /b 0

:check_required
if exist "%~1" exit /b 0
echo [ERROR] Missing %~2: %~1
goto fail_missing

:probe_port
where powershell >nul 2>&1
if errorlevel 1 (
  echo [WARNING] PowerShell not found; skipping serial-port pre-check.
  exit /b 0
)
powershell -NoProfile -Command "$ErrorActionPreference='Stop'; $sp = New-Object System.IO.Ports.SerialPort; $sp.PortName='%~1'; $sp.BaudRate=1200; try { $sp.Open(); $sp.Close(); exit 0 } catch { Write-Output $_.Exception.Message; exit 1 }"
if errorlevel 1 exit /b 1
exit /b 0

:fail_no_port
echo [ERROR] No COM ports were detected.
echo         Double-tap RESET on the Bluefruit, wait a moment, and try again.
goto fail

:fail_flash
echo [ERROR] Bootloader flash failed.
echo         Confirm that the Bluefruit is in bootloader mode and that %PORT% is correct.
goto fail

:fail_port_open
echo [ERROR] The script could not open serial port %PORT%.
echo         Close any program that may already be using %PORT% and try again.
echo         Common causes include a serial monitor, another IDE window, or the wrong COM port.
goto fail

:fail_boot_drive
echo [ERROR] Drive "%BLLABEL%" was not found.
echo         Confirm the board entered bootloader mode after the DFU step.
goto fail

:fail_copy_uf2
echo [ERROR] Failed to copy the UF2 file to %DRIVE%.
goto fail

:fail_circuitpy
echo [ERROR] Drive "%CPYLABEL%" did not appear.
echo         Single-tap RESET once and check File Explorer.
goto fail

:fail_diag
echo [ERROR] Failed while copying the diagnostics files.
goto fail

:fail_missing
echo [ERROR] Keep all reflash-kit files together in one extracted folder.
goto fail

:fail
echo.
echo Press any key to close this window.
pause >nul
popd >nul 2>&1
exit /b 1

:success
echo.
echo Press any key to close this window.
pause >nul
popd >nul 2>&1
exit /b 0
