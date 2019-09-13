@echo off
setlocal enabledelayedexpansion
rem ***************************************************************************
rem @Title 			: Surveillance d'un partage
rem @Author 		: Cyril Bazin
rem @Date			: 06/09/2019
rem @Description 	: 
rem						- ping
rem						- lecture
rem						- ecriture
rem						- suppression
rem ***************************************************************************

set isilon=host
set fileToRead=\\path\file.ext
set fileToWrite=\\path\file.ext


for /L %%g in (1,1,500000) do (
	call::verifications
)


:verifications	
	rem ***************************************************************************
	rem *** GET DATE TIME ***
	rem ***************************************************************************
	for /f "tokens=1-3 delims=/ " %%a in ('date /t') do (set currentDate=%%c/%%a/%%b)
	for /f "tokens=1-3 delims=/:" %%a in ("%TIME%") do (set currentTime=%%a:%%b:%%c)


	rem ***************************************************************************
	rem *** SET LOGS
	rem ***************************************************************************
	set log=%currentDate% %currentTime%

	rem ***************************************************************************
	rem *** PING ***
	rem ***************************************************************************
	for /f "tokens=1-3 delims=/:" %%a in ("%TIME%") do (set startTime=%%a:%%b:%%c)
	for /f %%i in ('ping %isilon% ^| find /c "TTL"') do set pings=%%i
	for /f "tokens=1-3 delims=/:" %%a in ("%TIME%") do (set endTime=%%a:%%b:%%c)

	if %pings% == 0 (
		set log=%log%;NOK;%startTime%;%endTime%
	) else (
		set log=%log%;OK;%startTime%;%endTime%
	)


	rem ***************************************************************************
	rem *** LECTURE ***
	rem ***************************************************************************
	set reads=0
	for /f "tokens=1-3 delims=/:" %%a in ("%TIME%") do (set startTime=%%a:%%b:%%c)
	for /f "delims=" %%i in (%fileToRead%) do set reads=%%i
	for /f "tokens=1-3 delims=/:" %%a in ("%TIME%") do (set endTime=%%a:%%b:%%c)

	if !reads! == 0 (
		set log=%log%;NOK;%startTime%;%endTime%
	) else (
		set log=%log%;OK;%startTime%;%endTime%
	)


	rem ***************************************************************************
	rem *** ECRITURE ***
	rem ***************************************************************************
	set writes=0
	for /f "tokens=1-3 delims=/:" %%a in ("%TIME%") do (set startTime=%%a:%%b:%%c)
	echo "test write file" >> %fileToWrite%
	for /f "tokens=1-3 delims=/:" %%a in ("%TIME%") do (set endTime=%%a:%%b:%%c)

	if not exist %fileToWrite% (
		set log=%log%;NOK;%startTime%;%endTime%
	) else (
		set log=%log%;OK;%startTime%;%endTime%
	)



	rem ***************************************************************************
	rem *** DELETE ***
	rem ***************************************************************************
	set writes=0
	for /f "tokens=1-3 delims=/:" %%a in ("%TIME%") do (set startTime=%%a:%%b:%%c)
	del %fileToWrite%
	for /f "tokens=1-3 delims=/:" %%a in ("%TIME%") do (set endTime=%%a:%%b:%%c)

	if exist %fileToWrite% (
		set log=%log%;NOK;%startTime%;%endTime%
	) else (
		set log=%log%;OK;%startTime%;%endTime%
	)
	echo %log% >> C:\\Temp\\ISILON_Surveillance.log
	
	PING localhost -n 60 >NUL

	
goto:eof