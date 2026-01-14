@echo off
title INCIDENT RESPONSE COLLECTION - MUNICIPAL
color 0A

REM ===============================
REM INCIDENT RESPONSE COLLECTION
REM Windows CMD / Batch
REM ===============================

set BASE=C:\IR

echo [+] Creating evidence folders...

mkdir %BASE% 2>nul
mkdir %BASE%\Logs 2>nul
mkdir %BASE%\Network 2>nul
mkdir %BASE%\Processes 2>nul
mkdir %BASE%\Users 2>nul
mkdir %BASE%\Persistence 2>nul
mkdir %BASE%\Security 2>nul
mkdir %BASE%\System 2>nul

echo [+] Collecting system information...
systeminfo > %BASE%\System\systeminfo.txt
driverquery /v > %BASE%\System\drivers.txt

echo [+] Collecting process information...
tasklist /v > %BASE%\Processes\tasklist.txt
wmic process get Name,ProcessId,ParentProcessId,ExecutablePath,CommandLine /FORMAT:LIST > %BASE%\Processes\processes_wmic.txt

echo [+] Collecting network connections...
netstat -ano > %BASE%\Network\netstat_full.txt
netstat -ano | findstr ESTABLISHED > %BASE%\Network\net_established.txt

echo [+] Mapping PIDs to processes...
tasklist > %BASE%\Network\pid_process_map.txt

echo [+] Collecting user and privilege information...
net user > %BASE%\Users\local_users.txt
query user > %BASE%\Users\active_sessions.txt
net localgroup administrators > %BASE%\Users\administrators.txt

echo [+] Collecting persistence mechanisms...

echo - Scheduled Tasks
schtasks /query /fo LIST /v > %BASE%\Persistence\scheduled_tasks.txt

echo - Services
wmic service get Name,DisplayName,State,StartMode,PathName > %BASE%\Persistence\services.txt

echo - Run Keys
reg query HKLM\Software\Microsoft\Windows\CurrentVersion\Run > %BASE%\Persistence\run_hklm.txt
reg query HKCU\Software\Microsoft\Windows\CurrentVersion\Run > %BASE%\Persistence\run_hkcu.txt

echo [+] Collecting security events...
wevtutil qe Security /f:text /c:500 > %BASE%\Security\security_events.txt

echo [+] Collecting recently modified executables (last 7 days)...
forfiles /P C:\ /S /M *.exe /D -7 /C "cmd /c echo @path @fdate @ftime" > %BASE%\Processes\recent_executables.txt

echo [+] Writing summary...
echo INCIDENT RESPONSE SNAPSHOT COMPLETED > %BASE%\IR_SUMMARY.txt
echo Date: %DATE% %TIME% >> %BASE%\IR_SUMMARY.txt
hostname >> %BASE%\IR_SUMMARY.txt
whoami >> %BASE%\IR_SUMMARY.txt

echo.
echo =====================================
echo   INCIDENT RESPONSE COLLECTION DONE
echo   Evidence stored in: C:\IR
echo =====================================
pause
