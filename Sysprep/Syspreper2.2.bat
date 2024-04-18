:: Syspreper.bat programado por Jorge Santos - Jefe Soprote TI FCOM SPA
:: Elimina blotware de la imagen de Windows, copia la configuracion de inicio a nuevos usuarios,
:: automatiza la creación de unattend.xml y ejecuta sysprep.exe
:: Ver. 2.2 - 20/03/2024

@echo off
title Syspreper
color 1F
mode con cols=80 lines=20

:: Menu de opciones
:inicio
cls
echo ----- Syspreper 2.2 -----
echo -------------------------
echo Seleccione una opcion:
echo (1) Eliminar bloatware de Windows
echo (2) Copiar programas anclados al inicio a nuevos usuarios (W11)
echo (3) Generar unattend.xml
echo (4) Ejecutar Sysprep (ya debe existir unattend.xml)
echo (5) Salir
set /p opc0=Seleccione una opcion : 
if %opc0%==1 goto bloatware
if %opc0%==2 goto pinned
if %opc0%==3 goto unattend
if %opc0%==4 goto sysprep
if %opc0%==5 goto end
echo Debe seleccionar 1, 2, 3, 4 o 5
echo.
goto inicio

:: Elimina todas las apps existentes que esten instaladas en el usuario actual y provisionadas en la imagen de Windows.
:: Las apps a eliminar se especifican en el archvivo applist.txt
:bloatware
cls
setlocal enabledelayedexpansion

for /f "delims=" %%a in (%~dp0applist.txt) do ( set "line=%%a"
    if not "!line:~0,1!"=="#" ( for /f "delims=*" %%b in ("!line!") do ( set "word=%%~b"
        cls
        echo ----- Syspreper 2.2 -----
        echo -------------------------
        echo Intentando desinstalar !word! . . .
        powershell -Command "Get-AppxPackage -AllUsers -Name '^*!word!^*' | Remove-AppxPackage; Get-AppxProvisionedPackage -Online | Where-Object { $_.PackageName -like '^*!word!^*' } | ForEach-Object { Remove-ProvisionedAppxPackage -Online -AllUsers -PackageName $_.PackageName }"
        )
    )
)
endlocal
echo.
echo Limpieza finalizada . . .
echo.
pause
goto inicio

:: Copiar la configuración del menu inicio actual a todos los nuevos usuarios
:pinned
cls
echo ----- Syspreper 2.2 -----
echo -------------------------
echo Debe configurar previamente el menu inicio de Windows 11 tal cual como
echo debe aparecer en los nuevos usuarios. Desea continuar?
set /p opc1=Seleccione una opcion (1)Si (2)No : 
if %opc1%==1 goto pincopy
if %opc1%==2 goto inicio
echo Debe seleccionar 1 o 2
echo.
goto pinned

:pincopy
cls
echo ----- Syspreper 2.2 -----
echo -------------------------
md %systemdrive%\Users\Default\AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState>nul 2>&1
copy %localappdata%\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState\start2.bin %systemdrive%\Users\Default\AppData\Local\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\LocalState\start2.bin
pause
goto inicio

:: Inicia la creacion del archivo unattend.xml
:unattend
cls
echo ----- Syspreper 2.2 -----
echo Creando el archivo %~dp0unattend.xml
echo -------------------------
echo.

echo ^<!-- unattend.xml preparado por Jorge Santos - Jefe Soporte TI FCOM SPA --^>>%~dp0unattend.xml
echo ^<!-- Consideraciones:>>%~dp0unattend.xml
echo         - Se establece la configuracion regional a Español Chile (zona horaria -04:00 con horario de verano)>>%~dp0unattend.xml
echo         - Se desactivan todas las opciones de privacidad (telemetria, reconocimiento de voz, id publicidad, etc.)>>%~dp0unattend.xml
echo         - Los servicios de localizacion permiten su activacion, pero debe hacerse manualmente (no es algo que se pueda predeterminar con Sysprep)>>%~dp0unattend.xml
echo         - Es obligatorio proporcionar una cuenta y su clave para iniciar sesion>>%~dp0unattend.xml
echo         - Se puede utilizar la cuenta Administrador si es necesario (elimine los comentarios de la etiqueta RunSynchronousCommand mas abajo)>>%~dp0unattend.xml
echo         - La imagen iniciara directamente en la cuenta proporcionada, con las configuraciones mencionadas anteriormente (no hay OOBE)>>%~dp0unattend.xml
echo --^>>>%~dp0unattend.xml
echo.
echo ^<?xml version="1.0" encoding="utf-8"?^>>>%~dp0unattend.xml
echo ^<unattend xmlns="urn:schemas-microsoft-com:unattend"^>>>%~dp0unattend.xml
echo     ^<settings pass="generalize"^> ^<!-- Paso generalizacion. Ocurre al ejecutar Sysprep y antes de sellar la imagen --^>>>%~dp0unattend.xml
echo         ^<component name="Microsoft-Windows-PnpSysprep" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"^>>>%~dp0unattend.xml
echo             ^<PersistAllDeviceInstalls^>true^</PersistAllDeviceInstalls^> ^<!-- Mantener instalados los dispositivos en el equipo (evita tener que detectarlos cada vez mientras sea el mismo modelo)--^>>>%~dp0unattend.xml
echo         ^</component^>>>%~dp0unattend.xml
echo     ^</settings^>>>%~dp0unattend.xml
echo     ^<settings pass="specialize"^> ^<!-- Paso de especializacion. Ocurre al inciar la imagen por primera vez y antes del OOBE --^>>>%~dp0unattend.xml
echo         ^<component name="Microsoft-Windows-Deployment" processorArchitecture="amd64" language="neutral" publicKeyToken="31bf3856ad364e35" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"^>>>%~dp0unattend.xml
echo             ^<RunSynchronous^>>>%~dp0unattend.xml
echo                 ^<RunSynchronousCommand wcm:action="add"^> ^<!-- Desactiva la solicitud de conexion de redes durante OOBE en Windows 11 --^>>>%~dp0unattend.xml
echo                     ^<Order^>1^</Order^>>>%~dp0unattend.xml
echo                     ^<Path^>reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE /v BypassNRO /t REG_DWORD /d 1 /f^</Path^>>>%~dp0unattend.xml
echo                 ^</RunSynchronousCommand^>>>%~dp0unattend.xml
echo                 ^<RunSynchronousCommand wcm:action="add"^> ^<!-- Habilita los servicios de localizacion de Windows para el equipo --^>>>%~dp0unattend.xml
echo                     ^<Order^>2^</Order^>>>%~dp0unattend.xml
echo                     ^<Path^>reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location /v Value /t REG_SZ /d Allow /f^</Path^>>>%~dp0unattend.xml
echo                 ^</RunSynchronousCommand^>>>%~dp0unattend.xml

:: Consulta si se utilizara la cuenta de Administrador local.
:administrador
cls
echo ----- Syspreper 2.2 -----
echo Creando el archivo %~dp0unattend.xml
echo -------------------------
echo Se utilizara la cuenta Administrador integrada?
set /p opc2=Seleccione una opcion (1)Si (2)No : 
echo.
if %opc2%==1 goto admintrue
if %opc2%==2 goto international
echo Debe seleccionar 1 o 2
echo.
goto administrador

:: Si se va a usar, escribe en unattend.xml los comandos para habilitarla.
:admintrue
echo                 ^<RunSynchronousCommand wcm:action="add"^>>>%~dp0unattend.xml
echo                     ^<Order^>3^</Order^>>>%~dp0unattend.xml
echo                     ^<Path^>net user Administrador /active:yes^</Path^>>>%~dp0unattend.xml
echo                 ^</RunSynchronousCommand^>>>%~dp0unattend.xml

:: Configuracion regional predeterminada para todas las cuentas de usuario
:international
echo             ^</RunSynchronous^>>>%~dp0unattend.xml
echo         ^</component^>>>%~dp0unattend.xml
echo         ^<component name="Microsoft-Windows-International-Core" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"^>>>%~dp0unattend.xml
echo             ^<InputLocale^>0000340a^</InputLocale^> ^<!-- Teclado Latinoamericano --^>>>%~dp0unattend.xml
echo             ^<SystemLocale^>es-CL^</SystemLocale^> ^<!-- Idioma Administrativo --^>>>%~dp0unattend.xml
echo             ^<UILanguage^>es-MX^</UILanguage^> ^<!-- Idioma en pantalla predeterminado --^>>>%~dp0unattend.xml
echo             ^<UILanguageFallback^>es-ES^</UILanguageFallback^> ^<!-- Idioma en pantalla en caso de que no este el predeterminado --^>>>%~dp0unattend.xml
echo             ^<UserLocale^>es-CL^</UserLocale^> ^<!-- Configuracion regional para los usuarios --^>>>%~dp0unattend.xml
echo         ^</component^>>>%~dp0unattend.xml
echo     ^</settings^>>>%~dp0unattend.xml

:check
cls
echo ----- Syspreper 2.2 -----
echo Creando el archivo %~dp0unattend.xml
echo -------------------------
echo Esta correcta esta informacion? (No se volvera a preguntar)
set /p opc5=Seleccione una opcion (1)Si (2)No : 
echo.
IF %opc5%==1 goto oobe
IF %opc5%==2 goto autologon
echo Debe seleccionar 1 o 2
echo.
goto check

:oobe
echo     ^<settings pass="oobeSystem"^> ^<!-- Paso OOBE. Ocurre antes del primer inicio de sesion --^>>>%~dp0unattend.xml
echo         ^<component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"^>>>%~dp0unattend.xml
echo             ^<OOBE^> ^<!-- Configurar automaticamente OOBE --^>>>%~dp0unattend.xml
echo                 ^<HideEULAPage^>true^</HideEULAPage^>>>%~dp0unattend.xml
echo                 ^<HideOEMRegistrationScreen^>true^</HideOEMRegistrationScreen^>>>%~dp0unattend.xml
echo                 ^<HideOnlineAccountScreens^>true^</HideOnlineAccountScreens^>>>%~dp0unattend.xml
echo                 ^<HideWirelessSetupInOOBE^>true^</HideWirelessSetupInOOBE^>>>%~dp0unattend.xml
echo                 ^<SkipMachineOOBE^>true^</SkipMachineOOBE^>>>%~dp0unattend.xml
echo                 ^<HideLocalAccountScreen^>true^</HideLocalAccountScreen^>>>%~dp0unattend.xml
echo                 ^<ProtectYourPC^>1^</ProtectYourPC^>>>%~dp0unattend.xml
echo             ^</OOBE^>>>%~dp0unattend.xml
echo             ^<TimeZone^>Pacific SA Standard Time^</TimeZone^> ^<!-- Establecer la zona horaria en -04:00 con horario de verano --^>>>%~dp0unattend.xml
echo         ^</component^>>>%~dp0unattend.xml
echo     ^</settings^>>>%~dp0unattend.xml
echo ^</unattend^>>>%~dp0unattend.xml

:unattend2
cls
echo ----- Syspreper 2.2 -----
echo -------------------------
echo %~dp0unattend.xml creado. Ejecutar Sysprep?
set /p opc6=Seleccione una opcion (1)Si (2)No : 
echo.
IF %opc6%==1 goto sysprep
IF %opc6%==2 goto inicio
echo Debe seleccionar 1 o 2
echo.
goto unattend2

:sysprep
cls
netsh wlan delete profile *>nul 2>&1
taskkill /IM Sysprep.exe>nul 2>&1
echo Iniciando Sysprep . . .
%windir%\System32\Sysprep\Sysprep.exe /unattend:%~dp0unattend.xml /generalize /oobe /shutdown

:end
exit 0