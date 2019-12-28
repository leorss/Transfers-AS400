@ECHO OFF
@ECHO ************************************************************
@ECHO  Extraccion tablas AS/400
@ECHO ************************************************************

REM ===========================================================
REM Parámetros
REM ===========================================================

SET fechahorainiproc=%date:~0,2%/%date:~3,2%/%date:~6,4% - %time:~0,2%:%time:~3,2%:%time:~6,2%

REM -------------------------------
REM Parametros de entrada
REM -------------------------------
SET opcmenu1=%1
SET opcmenu2=%2
SET fechaSistema=%3
SET horaSistema=%4
SET fecIni=%5
SET fecFin=%6

REM -------------------------------
REM Servidor PROD
REM -------------------------------
SET ipPROD=ipservidorPROD
SET userPROD=user
SET passPROD=pass

REM -------------------------------
REM Servidor UAT
REM -------------------------------
SET ipUAT=ipservidorUAT
SET userUAT=user
SET passUAT=pass

REM -------------------------------
REM Fechas
REM -------------------------------

SET FecIniDia=%fecIni:~0,2%
SET FecIniMes=%fecIni:~2,2%
SET FecIniAño=%fecIni:~4,4%

SET FecFinDia=%fecFin:~0,2%
SET FecFinMes=%fecFin:~2,2%
SET FecFinAño=%fecFin:~4,4%

SET fecInvI=%fecIni:~4,4%%fecIni:~2,2%%fecIni:~0,2% 
SET fecInvF=%fecFin:~4,4%%fecFin:~2,2%%fecFin:~0,2% 

SET fecIni8=%fecIni%
SET fecFin8=%fecFin%

SET fecInvI6=%fecInvI:~2,6%
SET fecInvF6=%fecInvF:~2,6%

SET fecInvI7=1%fecInvI:~2,6%
SET fecInvF7=1%fecInvF:~2,6%

SET fecInvI8=%fecInvI%
SET fecInvF8=%fecInvF%

REM -------------------------------
REM Directorios
REM -------------------------------

SET dirArchivos=archivos\%fechaSistema%_%horaSistema%
SET dirTransfer=%cd%\%dirArchivos%
SET dirTransUlt=%cd%\archivos\_ultimos
SET dirArchCFDI=%cd%\archivos_CFDI

REM -------------------------------
REM Tipo ejecucion
REM -------------------------------

IF  %opcmenu1%==1 (GOTO :bajar)
IF  %opcmenu1%==2 (GOTO :subir)
IF  %opcmenu1%==3 (GOTO :actFormaPago)
IF  %opcmenu1%==4 (GOTO :bajarCFDIUAT)
IF  %opcmenu1%==5 (GOTO :bajarCFDIProd)

GOTO :opcInvalida 

@ECHO. 
REM   -----------------------------------------------------------
:bajar
REM   -----------------------------------------------------------
@ECHO Opcion %opcmenu1% - Bajar datos de las tablas

MKDIR .\%dirArchivos%

@ECHO Remueve transfers de download
DEL .\transfer_tto\*.TTO

@ECHO Restaura transfers de download
COPY .\transfer_bkp\bajar_*.TTO .\transfer_tto /V

@ECHO Sustituir variables
SED -i .\transfer_tto\*.TTO "&ipProd" "%ipPROD%"
SED -i .\transfer_tto\*.TTO "&FECINVI7" "%fecInvI7%"
SED -i .\transfer_tto\*.TTO "&FECINVF7" "%fecInvF7%"
SED -i .\transfer_tto\*.TTO "&FECINVI8" "%fecInvI8%"
SED -i .\transfer_tto\*.TTO "&FECINVF8" "%fecInvF8%"
SED -i .\transfer_tto\*.TTO "&dirTransfer" "%dirTransfer%"

@ECHO Ejecutar Transfers para bajar los datos
 DIR .\transfer_tto /b > transfer_tto.txt
 FOR /f  %%a IN (transfer_tto.txt) DO (
 
	@ECHO.
    @ECHO ********************************************
	@ECHO Ejecuta Transfer: %%a
    @ECHO ********************************************

	RXFERPCB .\transfer_tto\%%a %userPROD% %passPROD%
 )

@ECHO.
@ECHO --------------------------------------------
@ECHO Borrar archivos anteriores
@ECHO --------------------------------------------
@ECHO.
DEL .\archivos\_Ultimos\*.xls
DEL .\archivos\_Ultimos\*.FDF
 
@ECHO.
@ECHO --------------------------------------------
@ECHO Actualizar archivos
@ECHO --------------------------------------------
@ECHO.
COPY .\%dirArchivos%\*.xls .\archivos\_Ultimos /V
@ECHO.
COPY .\%dirArchivos%\*.FDF .\archivos\_Ultimos /V  

REM   ----------------------------------------------------------- 
GOTO :fin
REM   ----------------------------------------------------------- 

@ECHO. 
REM   ----------------------------------------------------------- 
:subir
REM   -----------------------------------------------------------
@ECHO Opcion %opcmenu1% - Subir datos a las tablas

@ECHO Remueve transfers de upload
DEL .\transfer_tfr\*.TFR

@ECHO Restaura transfers de upload
COPY .\transfer_bkp\subir_*.TFR .\transfer_tfr /V
 
@ECHO Sustituir variables
REM SED -i .\transfer_tfr\*.TFR "&dirTransfer" "%dirTransfer%"
SED -i .\transfer_tfr\*.TFR "&dirTransfer" "%dirTransUlt%"
 
@ECHO Ejecutar Transfers para bajar los datos
 DIR .\transfer_tfr /b > transfer_tfr.txt
 FOR /f  %%a IN (transfer_tfr.txt) DO (
 
 	@ECHO.
    @ECHO ********************************************
	@ECHO Ejecuta Transfer: %%a
    @ECHO ********************************************

	RXFERPCB .\transfer_tfr\%%a %userUAT% %passUAT%
 )

REM   ----------------------------------------------------------- 
GOTO :fin
REM   ----------------------------------------------------------- 

@ECHO. 
REM   ----------------------------------------------------------- 
:actFormaPago
REM   -----------------------------------------------------------
@ECHO Opcion %opcmenu1% - Actualizar Forma de Pago

rem	RXFERPCB .\transfer_tfr\%%a %userUAT% %passUAT%

REM   ----------------------------------------------------------- 
GOTO :fin
REM   ----------------------------------------------------------- 

@ECHO. 
REM   ----------------------------------------------------------- 
:bajarCFDIUAT
REM   -----------------------------------------------------------
@ECHO Opcion %opcmenu1% - Bajar archivo CFDI UAT

IF  %opcmenu2%==1 (SET archivoCFDI=ESIV%fecInvI6%) 
IF  %opcmenu2%==2 (SET archivoCFDI=CSIV%fecInvI6%) 
IF  %opcmenu2%==3 (SET archivoCFDI=NSIV%fecInvI6%) 
IF  %opcmenu2%==4 (SET archivoCFDI=PSIV%fecInvI6%) 

@ECHO Remueve transfers de download
DEL .\transfer_tto\archivo_CFDI.TTO

@ECHO Restaura transfers de download
COPY .\transfer_bkp\archivo_CFDI.TTO .\transfer_tto /V

@ECHO Sustituir variables
SED -i .\transfer_tto\archivo_CFDI.TTO "&ipTransfer" "%ipUAT%"
SED -i .\transfer_tto\archivo_CFDI.TTO "&dirTransfer" "%dirArchCFDI%"
SED -i .\transfer_tto\archivo_CFDI.TTO "$archivo" "%archivoCFDI%"
SED -i .\transfer_tto\archivo_CFDI.TTO "$fechaHora" "%fechaSistema%%horaSistema%"

SET llamarArch=%dirArchCFDI%\%archivoCFDI%.txt
%llamarArch%

@ECHO %llamarArch%
pause .

@ECHO.
@ECHO ********************************************
@ECHO Ejecuta Transfer: archivo_CFDI.TTO
@ECHO ********************************************

RXFERPCB .\transfer_tto\archivo_CFDI.TTO %userUAT% %passUAT%

REM   ----------------------------------------------------------- 
GOTO :fin
REM   ----------------------------------------------------------- 

@ECHO. 
REM   ----------------------------------------------------------- 
:bajarCFDIProd
REM   -----------------------------------------------------------


REM   ----------------------------------------------------------- 
GOTO :fin
REM   ----------------------------------------------------------- 

REM ===========================================================
REM Errores
REM ===========================================================

:opcInvalida
@ECHO !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
@ECHO Opcion Invalida
@ECHO !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
@ECHO.
GOTO :fin
 
REM ===========================================================
:fin
REM ===========================================================

@ECHO.
@ECHO ==============================================
@ECHO Resumen Ejecucion
@ECHO ==============================================
@ECHO.
@ECHO Inicio Proceso : %fechahorainiproc%
@ECHO Fin Proceso    : %date:~0,2%/%date:~3,2%/%date:~6,4% - %time:~0,2%:%time:~3,2%:%time:~6,2%
@ECHO.

@ECHO ------------------------------------
@ECHO Fechas Extracción
@ECHO ------------------------------------
@ECHO.
@ECHO Fecha Inicial : %fecIni%
@ECHO Fecha Final   : %fecFin%
@ECHO.

@ECHO ------------------------------------
@ECHO Directorio transferencia archivos
@ECHO ------------------------------------
@ECHO.
@ECHO %dirTransfer%
@ECHO.

@ECHO ------------------------------------
@ECHO Servidor PROD
@ECHO ------------------------------------
@ECHO.
@ECHO IP       : %ipPROD%
@ECHO User     : %userPROD%
@ECHO Password : %passPROD%
@ECHO.

@ECHO ------------------------------------
@ECHO Servidor UAT
@ECHO ------------------------------------
@ECHO.
@ECHO IP       : %ipUAT%
@ECHO User     : %userUAT%
@ECHO Password : %passUAT%
@ECHO. 
