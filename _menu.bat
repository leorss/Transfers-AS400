@ECHO OFF
REM *****************************************************************
REM PARAMETROS
REM *****************************************************************

REM --------------------------------------
REM Fecha y Hora del sistema
REM --------------------------------------

SET fechaSistema=%date:~6,4%%date:~3,2%%date:~0,2%
SET horaSistema=%time:~0,2%%time:~3,2%%time:~6,2%

SET fechaEditada=%date:~0,2%/%date:~3,2%/%date:~6,4%
SET horaEditada=%time:~0,2%:%time:~3,2%:%time:~6,2%

REM --------------------------------------
REM Opciones
REM --------------------------------------
setlocal enabledelayedexpansion

REM Variables MENU Principal
SET descMenuPrincipal=Menu Transfers
SET descopcmenu1[1]=1 - Bajar datos tablas (Prod)
SET descopcmenu1[2]=2 - Subir datos tablas (UAT)
SET descopcmenu1[3]=3 - Actualizar Forma de Pago (UAT)
SET descopcmenu1[4]=4 - Bajar archivo CFDI (UAT)
SET descopcmenu1[5]=5 - Bajar archivo CFDI (Prod)
SET descopcmenu1[0]=0 - Salir

REM Variables MENU Archivo CFDI
SET descMenuCFDI=Seleccionar tipo archivo CFDI
SET descTpCFDI[1]=1 - Emision
SET descTpCFDI[2]=2 - Cancelacion
SET descTpCFDI[3]=3 - Nota Credito
SET descTpCFDI[4]=4 - Complemento de Pago
SET descTpCFDI[5]=5 - Todos
SET descTpCFDI[0]=0 - Regresa

REM Mensajes Ejecución
SET msgProc[1]=Descargando datos de las tablas ...         
SET msgProc[2]=Subiendo datos a las tablas ...             
SET msgProc[3]=Actualizando Tabla Forma de Pago ...        
SET msgProc[4]=Bajando archivo CFDI (UAT) ...
SET msgProc[5]=Bajando archivo CFDI (Prod) ...


REM *****************************************************************
REM MENUS
REM *****************************************************************

REM --------------------------------------
:menuPrincipal
REM --------------------------------------

CLS
COLOR 0A
	
@ECHO Fecha: %fechaEditada%         Hora: %horaEditada%
@ECHO.  
@ECHO ========================================
@ECHO  %descMenuPrincipal%
@ECHO ========================================
@ECHO.
@ECHO     %descopcmenu1[1]%
@ECHO     %descopcmenu1[2]%
@ECHO.     
@ECHO     %descopcmenu1[4]%
@ECHO     %descopcmenu1[5]%
@ECHO.    
@ECHO     %descopcmenu1[0]%
SET /p opcmenu1= ______________________________ Opc.:

SET %opcmenu2=0

IF "%opcmenu1%" EQU "0" ( GOTO :fin              )
IF "%opcmenu1%" EQU "1" ( GOTO :accPeriodo       )  
IF "%opcmenu1%" EQU "2" ( GOTO :accPeriodo       ) 
REM IF "%opcmenu1%" EQU "3" ( GOTO :confirma         ) 
IF "%opcmenu1%" EQU "4" ( GOTO :menuArchivoCFDI  )
IF "%opcmenu1%" EQU "5" ( GOTO :menuArchivoCFDI  )

@ECHO.
@ECHO  Opcion Invalida
@ECHO.
PAUSE .

GOTO :menuPrincipal

REM --------------------------------------
:menuArchivoCFDI
REM --------------------------------------

CLS
COLOR 0A
	
@ECHO Fecha: %fechaEditada%         Hora: %horaEditada%
@ECHO.  
@ECHO ========================================
@ECHO  %descMenuCFDI%
@ECHO ========================================
@ECHO.
@ECHO     %descTpCFDI[1]%
@ECHO     %descTpCFDI[2]%
@ECHO     %descTpCFDI[3]%
@ECHO     %descTpCFDI[4]%
@ECHO.    
@ECHO     %descTpCFDI[0]%
SET /p opcmenu2= ______________________________ Opc.:

IF "%opcmenu2%" EQU "0" ( GOTO :menuPrincipal )
IF "%opcmenu2%" EQU "1" ( GOTO :accFecha      )  
IF "%opcmenu2%" EQU "2" ( GOTO :accFecha      ) 
IF "%opcmenu2%" EQU "3" ( GOTO :accFecha      ) 
IF "%opcmenu2%" EQU "4" ( GOTO :accFecha      )

@ECHO.
@ECHO  Opcion Invalida
@ECHO.
PAUSE .

GOTO :menuArchivoCFDI

REM *****************************************************************
REM RUTINAS
REM *****************************************************************

REM --------------------------------------
:accPeriodo
REM --------------------------------------

CLS
@ECHO.
SET /p fecIni=Fecha Inicio (DDMMAAAA) :
SET /p fecFin=Fecha Fin    (DDMMAAAA) :

if %fecIni% > %fecFin% ( GOTO :confirmar )

GOTO :accPeriodo

REM --------------------------------------
:accFecha
REM --------------------------------------

CLS
@ECHO.
SET /p fecIni=Fecha (DDMMAAAA) :
SET fecFin=%fecIni%

if '%fecIni%' NEQ ''( GOTO :confirmar )

GOTO :accFecha

REM --------------------------------------
:confirmar
REM --------------------------------------

@ECHO.

FOR %%a IN (%opcmenu1%) DO ( ECHO Opcion: !descopcmenu1[%%a]! )

@ECHO.
SET /p confirmaSN= Confirma (S/N)..:

IF "%confirmaSN%" EQU "S" (GOTO :ejecutar)
IF "%confirmaSN%" EQU "s" (GOTO :ejecutar)
IF "%confirmaSN%" EQU "N" (GOTO :menuPrincipal)
IF "%confirmaSN%" EQU "n" (GOTO :menuPrincipal)	

GOTO :confirmar

REM --------------------------------------
:ejecutar
REM --------------------------------------

@ECHO.
FOR %%a IN (%opcmenu1%) DO ( ECHO !msgProc[%%a]! )

transfers.bat %opcmenu1% %opcmenu2% %fechaSistema% %horaSistema% %fecIni% %fecFin% > .\logs\log_%fechaSistema%_%horaSistema%.txt
GOTO :menuPrincipal

REM *****************************************************************
REM Fin
REM *****************************************************************

REM --------------------------------------
:fin
REM --------------------------------------
