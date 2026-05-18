@echo off

:: Get the current code page
for /f "tokens=2 delims=:" %%a in ('%SystemRoot%\System32\chcp.com') do set "OLD_CP=%%a"
:: Switch to code page 65001 for UTF-8
"%SystemRoot%\System32\chcp.com" 65001 >nul


:: In case it contains spaces, we need to use a temporary variable to avoid issues with delayed expansion
set "TEMPDIR=%~1"
if "%~1" == "--norestart" set "TEMPDIR=%~2"
if "%~1" == "--norelaunch" set "TEMPDIR=%~2"

setlocal enabledelayedexpansion

:: UnRen-forall.bat - UnRen Launcher Script named UnRen-forall.bat for compatibility
:: Made by (SM) aka JoeLurmel @ f95zone.to
:: This script is licensed under GNU GPL v3 — see LICENSE for details

:: DO NOT MODIFY BELOW THIS LINE unless you know what you're doing
:: Define various global names
set "NAME=forall"
set "VERSION=v0.77 - 05/17/26"
title UnRen-%NAME%.bat - %VERSION%
set "URL_REF=https://f95zone.to/threads/92717/post-17110063/"
set "SCRIPTDIR=%~dp0"
set "UPD_TDIR=%TEMP%\UnRenUpdate"
set "SCRIPTNAME=%~nx0"
set "BASENAME=%SCRIPTNAME:.bat=%"
set "UNRENLOG=%TEMP%\%BASENAME%.log"
set "PWRSHELL=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
if exist "%UNRENLOG%" del /f /q "%UNRENLOG%" >nul 2>&1


:: Use wmic for older system or PowerShell for newer ones to get date and time
set "datetime="
set "WMICEXE=%SystemRoot%\System32\wbem\wmic.exe"
if exist "%WMICEXE%" (
    for /f "skip=1 tokens=1" %%a in ('%WMICEXE% os get LocalDateTime') do (
        set "datetime=%%a"
        goto :dbreak
    )
) else (
    for /f "delims=" %%a in ('"%PWRSHELL%" -NoProfile -Command "(Get-CimInstance Win32_OperatingSystem).LocalDateTime.ToString(\"yyyyMMddHHmmss\")"') do (
         set "datetime=%%a"
         goto :dbreak
    )
)
:dbreak
:: Parse the datetime string
set year=%datetime:~0,4%
set month=%datetime:~4,2%
set day=%datetime:~6,2%
set hour=%datetime:~8,2%
set minute=%datetime:~10,2%
set second=%datetime:~12,2%
set formatted_date=%month%/%day%/%year:~2,2%
set formatted_time=%hour%:%minute%:%second%


:: Start the Log
>> "%UNRENLOG%" echo.
echo UnRen-%NAME%.bat %VERSION%, started on %formatted_date% at %formatted_time% >> "%UNRENLOG%"
>> "%UNRENLOG%" echo.


:: Set default values
set "MDEFS=acefg"
set "MDEFS2=12acefg"
set "CTIME=5"
set "_7ZIPLOC=%ProgramFiles%\7-Zip\7z.exe"
:: External configuration file for LNG, MDEFS, MDEFS2 and CTIME.
set "UNREN_CFG=%SCRIPTDIR%UnRen-cfg.txt"
set "OLD_UNREN_CFG=%SCRIPTDIR%UnRen-cfg.bat"
if exist "%OLD_UNREN_CFG%" if not exist "%UNREN_CFG%" (
    move /y "%OLD_UNREN_CFG%" "%UNREN_CFG%" %DEBUGREDIR%
)
:: Load external configuration
if exist "%UNREN_CFG%" (
    for /f "usebackq tokens=1,* delims== " %%A in ("%UNREN_CFG%") do (
        if /i "%%A"=="set" (
            set %%B
        )
    )
)

:: Defined from external configuration file
if defined LNG goto :lngtest

:: Clean retrieval of language code via WMIC or PowerShell
if exist "%WMICEXE%" (
    for /f "skip=1 tokens=1" %%l in ('%WMICEXE% os get oslanguage') do (
        set LNGID=%%l
        goto :found_lcid
    )
) else (
    for /f %%l in ('"%PWRSHELL%" -NoProfile -Command "Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -ExpandProperty OSLanguage"') do (
        set LNGID=%%l
        goto :found_lcid
    )
)

:: LCID correspondence
:found_lcid
if "%LNGID%" == "1033" set "LNG=en"
if "%LNGID%" == "1036" set "LNG=fr"
if "%LNGID%" == "3082" set "LNG=es"
if "%LNGID%" == "1040" set "LNG=it"
if "%LNGID%" == "1031" set "LNG=de"
if "%LNGID%" == "1049" set "LNG=ru"
if "%LNGID%" == "2052" set "LNG=zh"
if not defined LNG set "LNG=en"

:: Language support test
:lngtest
set "SUPPORTED= de es en fr it ru zh "
set "FIND= %LNG% "
echo "%SUPPORTED%" | "%SystemRoot%\System32\findstr.exe" /i "%FIND%" >nul
if %errorlevel% NEQ 0 set "LNG=en"

:: To be able to take screenshots for F95zone
if not "%~2" == "" (
    echo "%SUPPORTED%" | "%SystemRoot%\System32\findstr.exe" /i " %~2 " >nul
    if %errorlevel% EQU 0 set "LNG=%~2"
)

if "%LNGID%" == "1036" if "%LNG%" == "zh" (
    "%SystemRoot%\System32\chcp.com" 936 >nul
)


:: Definition of reusable texts not language dependent
set "GRY=[90m"
set "RED=[91m"
set "ORA=[38;5;208m"
set "GRE=[92m"
set "YEL=[93m"
set "MAG=[95m"
set "CYA=[96m"
set "RES=[0m"
for /f "tokens=4-5 delims=. " %%i in ('ver') do set OSVERS=%%i.%%j
if "%OSVERS%" == "6.1" (
    if exist "%SystemRoot%\ansicon.exe" (
        "%SystemRoot%\ansicon.exe" -i %DEBUGREDIR%
    ) else (
        set "ansmsg1.en=Warning: ANSI colors not supported on Windows 7 without Ansicon."
        set "ansmsg1.fr=Attention : les couleurs ANSI ne sont pas prises en charge sur Windows 7 sans Ansicon."
        set "ansmsg1.es=Advertencia: Colores ANSI no soportados en Windows 7 sin Ansicon."
        set "ansmsg1.it=Attenzione: colori ANSI non supportati su Windows 7 senza Ansicon."
        set "ansmsg1.de=Warnung: ANSI Farben nicht unterstuetzt auf Windows 7 ohne Ansicon."
        set "ansmsg1.ru=Предупреждение: ANSI-цвета не поддерживаются на Windows 7 без Ansicon."
        set "ansmsg1.zh=注意：Windows 7 无 Ansicon 不支持 ANSI 颜色。"

        set "ansmsg2.en=Please download Ansicon from https://github.com/adoxa/ansicon/releases"
        set "ansmsg2.fr=Veuillez télécharger Ansicon depuis https://github.com/adoxa/ansicon/releases"
        set "ansmsg2.es=Por favor, descargue Ansicon desde https://github.com/adoxa/ansicon/releases"
        set "ansmsg2.it=Per favore, scarica Ansicon da https://github.com/adoxa/ansicon/releases"
        set "ansmsg2.de=Bitte laden Sie Ansicon von https://github.com/adoxa/ansicon/releases herunter"
        set "ansmsg2.ru=Пожалуйста, загрузите Ansicon с https://github.com/adoxa/ansicon/releases"
        set "ansmsg2.zh=请从 https://github.com/adoxa/ansicon/releases 下载 Ansicon"

        set "ansmsg3.en=Extract x86/x64 directory content to %SystemRoot% and it will be used automatically."
        set "ansmsg3.fr=Extrayez le contenu du répertoire x86/x64 dans %SystemRoot% et il sera utilisé automatiquement."
        set "ansmsg3.es=Extraiga el contenido del directorio x86/x64 a %SystemRoot% y se usara automaticamente."
        set "ansmsg3.it=Estrae il contenuto del cartella x86/x64 in %SystemRoot% e verra' usato automaticamente."
        set "ansmsg3.de=Extrahieren Sie den Inhalt des Verzeichnisses x86/x64 in %SystemRoot% und es wird automatisch verwendet."
        set "ansmsg3.ru=Извлеките содержимое каталога x86/x64 в %SystemRoot% и он будет использоваться автоматически."
        set "ansmsg3.zh=将 x86/x64 目录内容提取到 %SystemRoot% 并且它将自动使用。"

        echo.
        echo !ansmsg1.%LNG%!
        echo.
        echo !ansmsg2.%LNG%!
        echo !ansmsg3.%LNG%!
        echo.
        pause

        call :exitn 3
    )
)


:: Definition of reusable texts
set "EMPTY=[      ]"
set "NOK=[  %RED%NOK%RES% ]"
set "OK=[  %GRE%OK%RES%  ]"
set "SKIP=[ %CYA%SKIP%RES% ]"
set "WARN=[ %ORA%WARN%RES% ]"

:: language dependent here, defined for each supported language.
:: The script will use the appropriate one based on the detected or selected language.
set "ANYKEY.en=Press any key to exit"
set "ANYKEY.fr=Appuyez sur une touche pour quitter"
set "ANYKEY.es=Presione cualquier tecla para salir"
set "ANYKEY.it=Premere un tasto per uscire"
set "ANYKEY.de=Drücken Sie eine beliebige Taste, um zu beenden"
set "ANYKEY.ru=Нажмите любую клавишу для выхода"
set "ANYKEY.zh=按任意键退出"

set "ARIGHT.en=Please run this script as an administrator to add the entry."
set "ARIGHT.fr=Veuillez exécuter ce script en tant qu'administrateur pour ajouter l'entrée."
set "ARIGHT.es=Por favor, ejecute este script como administrador para agregar la entrada."
set "ARIGHT.it=Per favore, esegui questo script come amministratore per aggiungere la voce."
set "ARIGHT.de=Bitte führen Sie dieses Skript als Administrator aus, um den Eintrag hinzuzufügen."
set "ARIGHT.ru=Пожалуйста, запустите этот скрипт от имени администратора, чтобы добавить элемент."
set "ARIGHT.zh=请以管理员身份运行此脚本以添加条目。"

set "FDELETE.en=Failed to delete:"
set "FDELETE.fr=Échec de la suppression :"
set "FDELETE.es=No se pudo eliminar:"
set "FDELETE.it=Impossibile eliminare:"
set "FDELETE.de=Fehler beim Löschen von:"
set "FDELETE.ru=Не удалось удалить:"
set "FDELETE.zh=无法删除："

set "FCREATE.en=Failed to create:"
set "FCREATE.fr=Impossible de créer :"
set "FCREATE.es=No se pudo crear:"
set "FCREATE.it=Impossibile creare:"
set "FCREATE.de=Die Erstellung von ist fehlgeschlagen:"
set "FCREATE.ru=Не удалось создать:"
set "FCREATE.zh=创建失败："

set "FMOVE.en=Failed to move:"
set "FMOVE.fr=Impossible de déplacer :"
set "FMOVE.es=No se pudo mover:"
set "FMOVE.it=Impossibile spostare:"
set "FMOVE.de=Fehler beim Verschieben von:"
set "FMOVE.ru=Не удалось переместить:"
set "FMOVE.zh=移动失败："

set "APRESENT.en=Option already installed."
set "APRESENT.fr=Option déjà installée."
set "APRESENT.it=Opzione già installata."
set "APRESENT.es=Opci&oacute;n ya instalada."
set "APRESENT.de=Option bereits installiert."
set "APRESENT.ru=Опция уже установлена."
set "APRESENT.zh=选项已安装。"

set "TWRM.en=This will remove:"
set "TWRM.fr=Cela supprimera :"
set "TWRM.it=Questo rimuoverà:"
set "TWRM.es=Esto eliminará:"
set "TWRM.de=Dies wird entfernen:"
set "TWRM.ru=Это удалит:"
set "TWRM.zh=这将移除："

set "TWADD.en=This will add:"
set "TWADD.fr=Cela ajoutera:"
set "TWADD.it=Questo aggiungerà:"
set "TWADD.es=Esto añadirá:"
set "TWADD.de=Dies wird hinzufügen:"
set "TWADD.ru=Это добавит:"
set "TWADD.zh=这将添加："

set "INCASEOF.en=In case of problem, please refer to:"
set "INCASEOF.fr=En cas de problème, veuillez vous référer à :"
set "INCASEOF.it=In caso di problemi, si prega di fare riferimento a:"
set "INCASEOF.es=En caso de problemas, consulte:"
set "INCASEOF.de=Im Falle von Problemen wenden Sie sich bitte an:"
set "INCASEOF.ru=В случае проблемы обратитесь к:"
set "INCASEOF.zh=如果出现问题，请参考："

set "INCASEDEL.en=In case of problem, delete the following files/dirs:"
set "INCASEDEL.fr=En cas de problème, supprimez le(s) fichier(s)/répertoire(s) suivants :"
set "INCASEDEL.it=In caso di problemi, eliminare i seguenti file/directory:"
set "INCASEDEL.es=En caso de problemas, elimine los siguientes archivos/directorios:"
set "INCASEDEL.de=Im Falle von Problemen löschen Sie die folgenden Dateien/Verzeichnisse:"
set "INCASEDEL.ru=В случае проблемы удалите следующие файлы/каталоги:"
set "INCASEDEL.zh=如果出现问题，请删除以下文件/目录："

set "UNDWNLD.en=Unable to download:"
set "UNDWNLD.fr=Impossible de télécharger :"
set "UNDWNLD.es=No se puede descargar:"
set "UNDWNLD.it=Impossibile scaricare:"
set "UNDWNLD.de=Download nicht möglich:"
set "UNDWNLD.ru=Не удалось загрузить:"
set "UNDWNLD.zh=无法下载："

set "UNINSTALL.en=Unable to install:"
set "UNINSTALL.fr=Impossible d'installer :"
set "UNINSTALL.es=No se puede instalar:"
set "UNINSTALL.it=Impossibile installare:"
set "UNINSTALL.de=Installation nicht möglich:"
set "UNINSTALL.ru=Не удалось установить:"
set "UNINSTALL.zh=无法安装："

set "UNEXTRACT.en=Unable to extract:"
set "UNEXTRACT.fr=Impossible d'extraire :"
set "UNEXTRACT.es=No se puede extraer:"
set "UNEXTRACT.it=Impossibile estrarre:"
set "UNEXTRACT.de=Fehler beim Herunterladen von:"
set "UNEXTRACT.ru=Не удалось извлечь:"
set "UNEXTRACT.zh=无法提取："

set "FNOTFOUND.en=File not found:"
set "FNOTFOUND.fr=Fichier introuvable :"
set "FNOTFOUND.es=Archivo no encontrado:"
set "FNOTFOUND.it=File non trovato:"
set "FNOTFOUND.de=Datei nicht gefunden:"
set "FNOTFOUND.ru=Файл не найден:"
set "FNOTFOUND.zh=找不到文件："

set "ENTERYN.en=Enter [Y/N] (default N):"
set "ENTERYN.fr=Entrez [O/N] (par défaut N) :"
set "ENTERYN.es=Ingrese [S/N] (predeterminado N):"
set "ENTERYN.it=Inserisci [S/N] (predefinito N):"
set "ENTERYN.de=Geben Sie [J/N] ein (Standard N):"
set "ENTERYN.ru=Введите [Y/N] (по умолчанию N):"
set "ENTERYN.zh=输入 [Y/N]（默认 N）："

set "CLEANUP.en=Cleaning up temporary files"
set "CLEANUP.fr=Nettoyage des fichiers temporaires"
set "CLEANUP.es=Limpiando archivos temporales"
set "CLEANUP.it=Pulizia dei file temporanei"
set "CLEANUP.de=Bereinigen temporärer Dateien"
set "CLEANUP.ru=Очистка временных файлов"
set "CLEANUP.zh=清理临时文件"

set "UNACONT.en=Unable to continue."
set "UNACONT.fr=Impossible de continuer."
set "UNACONT.es=No se puede continuar."
set "UNACONT.it=Impossibile continuare."
set "UNACONT.de=Kann nicht fortgesetzt werden."
set "UNACONT.ru=Не удалось продолжить."
set "UNACONT.zh=无法继续。"

set "NOTFOUND.en=No file(s) found"
set "NOTFOUND.fr=Pas de fichier(s) trouvé(s)"
set "NOTFOUND.es=No se han encontrado archivos(s)"
set "NOTFOUND.it=Nessun file trovato"
set "NOTFOUND.de=Keine Datei(en) gefunden"
set "NOTFOUND.ru=Файл(ы) не найден(ы)"
set "NOTFOUND.zh=找不到檔案"

set "LOGCHK.en=Please check the "%UNRENLOG%" for details."
set "LOGCHK.fr=Veuillez consulter le "%UNRENLOG%" pour plus de détails."
set "LOGCHK.es=Por favor, consulte el "%UNRENLOG%" para más detalles."
set "LOGCHK.it=Controlla il "%UNRENLOG%" per ulteriori dettagli."
set "LOGCHK.de=Bitte überprüfen Sie das "%UNRENLOG%" auf Einzelheiten."
set "LOGCHK.ru=Пожалуйста, проверьте "%UNRENLOG%" для получения дополнительных сведений."
set "LOGCHK.zh=请查看 "%UNRENLOG%" 以了解详情。"

set "UNIT.en=bytes"
set "UNIT.fr=octets"
set "UNIT.es=bytes"
set "UNIT.it=byte"
set "UNIT.de=Bytes"
set "UNIT.ru=байт"
set "UNIT.zh=字节"
:: End of reusable texts


:: Initializing debug mode
set "DEBUGREDIR=>nul 2>>%UNRENLOG%"
set "DEBUGLEVEL=0"
set "NOCLS=0"


:: Check if it's launched with Windows Terminal, and relaunch with correct size if not
set "NEW_COLS=110"
set "NEW_LINES=60"
set /a "NEW_LINES_UP=%NEW_LINES%+5"
if defined WT_SESSION if not "%~1" == "--norelaunch" (
    REM To avoid infinite loop in case of wrong relaunch argument, we check if the second argument is --norelaunch and skip the relaunch if it's the case.
    for /f "delims=" %%A in ('%SYSTEMROOT%\System32\where wt.exe') do set WT_PATH=%%A
    wt.exe --size %NEW_COLS%,%NEW_LINES% "%SystemRoot%\System32\cmd.exe" /c "%~f0" --norelaunch
    REM start "%SCRIPTNAME%" "%SystemRoot%\System32\cmd.exe" /c ""%~0" --norelaunch""
    exit /b
)

if not defined WT_SESSION (
    REM Set the cmd screen size with backup of old settings
    set "count=0"
    for /f "tokens=*" %%A in ('"%SystemRoot%\System32\mode.com" con') do (
        REM Split the line into tokens
        for %%B in (%%A) do (
            set "val=%%B"
            REM Check if it's a number
            echo !val! |  "%SystemRoot%\System32\findstr.exe" /r "[0-9][0-9]" >nul
            if !errorlevel! EQU 0 (
                set /a count+=1
                if !count! EQU 1 (
                    set "ORIG_LINES=!val!"
                )
                if !count! EQU 2 (
                    set "ORIG_COLS=!val!"
                )
            )
        )
    )
    %SystemRoot%\System32\mode.com con: cols=%NEW_COLS% lines=%NEW_LINES_UP% %DEBUGREDIR%
    %SystemRoot%\System32\mode.com con: cols=%NEW_COLS% lines=%NEW_LINES% %DEBUGREDIR%
)

:: Run only one time
:thanks
set "regexe=%SystemRoot%\System32\reg.exe"

::"%regexe%" delete "HKCU\Software\UnRen" /va /f %DEBUGREDIR%
"%regexe%" query "HKCU\Software\UnRen" /v Thanks %DEBUGREDIR%
if %errorlevel% EQU 0 (
    goto :nothanks
)

:: Check if already restarted
if "%~1" == "--norestart" (
    shift
    goto :already_restarted
)

:: Save cmd.exe parameters for later use
for /f "tokens=2*" %%A in ('%regexe% query "HKCU\Console" /v FaceName 2^>nul') do set "OLD_FACE=%%B"
for /f "tokens=2*" %%A in ('%regexe% query "HKCU\Console" /v FontSize 2^>nul') do set "OLD_SIZE=%%B"
for /f "tokens=2*" %%A in ('%regexe% query "HKCU\Console" /v FontFamily 2^>nul') do set "OLD_FAMILY=%%B"
for /f "tokens=2*" %%A in ('%regexe% query "HKCU\Console" /v FontWeight 2^>nul') do set "OLD_WEIGHT=%%B"

:: Set Consolas font for better display of the message, and save old settings to restore them later.
:: This is done by adding registry entries. The script will be relaunched with the new settings,
:: and the old settings will be restored at the end of the script.
"%regexe%" add "HKCU\Console" /v FaceName /t REG_SZ /d "Consolas" /f >nul
"%regexe%" add "HKCU\Console" /v FontSize /t REG_DWORD /d 0x000E0010 /f >nul
"%regexe%" add "HKCU\Console" /v FontFamily /t REG_DWORD /d 0x00000040 /f >nul
"%regexe%" add "HKCU\Console" /v FontWeight /t REG_DWORD /d 0x00000190 /f >nul

:: Not relaunched yet → relaunch
setlocal disabledelayedexpansion
start "%SCRIPTNAME%" "%SystemRoot%\System32\cmd.exe" /c ""%~0" --norestart "%TEMPDIR%" "%LNG%""
exit /b

:already_restarted
set "thanks1.en=May the Force be with those who support me:"
set "thanks1.fr=Que la Force soit avec celles et ceux qui me soutiennent :"
set "thanks1.es=Que la Fuerza esté con quienes me apoyan:"
set "thanks1.it=Che la Forza sia con chi mi supporta:"
set "thanks1.de=Möge die Macht mit denen sein, die mich unterstützen:"
set "thanks1.ru=Пусть Сила будет с теми, кто поддерживает меня:"
set "thanks1.zh=愿原力与你们这些支持我的人同在："

set "thanks2.en=Like the Force, I'm grateful to all who support me on f95zone. Thank you"
set "thanks2.fr=Comme la Force, je remercie tous ceux qui me soutiennent sur f95zone. Merci"
set "thanks2.es=Como la Fuerza, estoy agradecido a todos los que me apoyan en f95zone. Gracias"
set "thanks2.it=Come la Forza, sono grato a tutti quelli che mi supportano su f95zone. Grazie"
set "thanks2.de=Wie die Macht, bin ich dankbar zu allen, die mich auf f95zone unterstutzen. Danke"
set "thanks2.ru=Как Сила, я благодарен всем, кто поддерживает меня на f95zone. Спасибо"
set "thanks2.zh=就如原力,我深感所有支持我的人。 谢谢"

color 0f
echo.
echo                          ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠟⣛⣉⣉⣁⣀⡨⣭⣙⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
echo                          ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⢛⣡⣴⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣜⢿⡿⠿⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
echo                          ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠋⣁⣈⣉⡙⠛⠋⠉⠉⠉⣉⣩⣭⣭⣭⣭⣿⣿⣿⣿⣿⣿⣶⣶⣬⣭⣭⣛⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
echo                          ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢋⡴⠿⣻⣿⣷⣶⣶⣶⣾⣿⣿⣿⣿⣿⣛⣻⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣝⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿
echo                          ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠁⢀⣤⠾⠟⠛⠛⠛⠛⠻⠿⢿⣿⣟⠿⠿⠿⠿⠷⠀⠈⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢿⣿⣷⢻⣿⣿⣿⣿⣿⣿⣿⣿
echo                          ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⣠⡾⠋⠀⠠⠶⠶⣶⣶⣶⣶⣿⣿⣿⣿⣷⣤⣤⣤⣤⡤⠄⠀⠙⠿⠿⠿⠿⣿⣿⣿⣿⣿⣷⡻⣿⣆⢿⣿⣿⣿⣿⣿⣿⣿
echo                          ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⣵⣿⣴⠶⠛⠁⣀⣀⣀⣉⠛⠿⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣄⣤⣦⡘⢿⣶⣿⣿⣿⣿⣿⣿⣮⢻⡘⣿⣿⣿⣿⣿⣿⣿
echo                          ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⣼⠟⢋⣤⣶⠾⠿⠿⠿⠿⠿⡿⠦⠀⠀⠀⠀⠠⠴⠒⠲⠿⣿⡀⠀⠁⠀⠀⣙⢿⣿⣿⠻⣷⣍⡛⠿⠻⣷⣷⡘⣿⣿⣿⣿⣿⣿
echo                          ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⣼⠃⣴⣿⣯⠔⣀⣤⣤⡤⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠷⠀⠀⠀⠤⣌⠻⣿⣿⡶⣶⣍⡻⣷⣄⠈⢿⣧⠸⣿⣿⣿⣿⣿
echo                          ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠏⣼⠃⣼⣿⣿⡿⣾⡿⠛⠁⣠⣴⣾⣿⠿⠛⠁⠀⣀⣀⣠⣤⣤⣤⣤⣤⣀⠀⣠⣄⠈⢧⠘⣏⠇⢻⣏⠻⣿⣿⣆⠀⢿⣇⢻⣿⣿⣿⣿
echo                          ⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⢠⠃⠠⠟⣩⡟⠀⠟⢀⣴⣿⣿⣿⢏⣡⡄⢀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡈⠃⠀⠀⠀⠙⢷⡀⠙⠿⠀⠸⣿⢸⣿⣿⣿⣿
echo                          ⣿⣿⣿⣿⣿⣿⣿⣿⡟⠀⠈⠀⢀⣼⣿⠇⡰⢀⣾⣿⣿⣿⣿⣿⣿⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⢰⡀⠀⠀⠀⠃⠀⠀⠀⠀⢿⢸⣿⣿⣿⣿
echo                          ⣿⣿⣿⣿⣿⣿⣿⡿⢰⠀⠀⠀⠾⠟⢻⣿⠃⣼⣿⣿⣿⣿⣿⣿⣿⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡆⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀⢸⢀⣿⣿⣿⣿
echo                          ⣿⣿⣿⣿⣿⣿⣿⢡⡇⢠⠀⠀⠀⢀⡟⠁⢰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠸⢸⣿⣿⣿⣿
echo                          ⣿⣿⣿⣿⣿⣿⢃⣿⡓⠛⠀⠀⠀⠀⡄⠀⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⣿⣿⣿
echo                          ⣿⣿⣿⣿⣿⣿⢸⠛⠋⠀⠀⠀⠀⢰⠁⢠⣿⣿⣯⣴⣶⣤⡉⠙⠛⠛⠛⠿⣿⣿⣿⡿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠃⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿
echo                          ⣿⣿⣿⣿⣿⣿⡸⣆⠀⠀⠀⠀⠀⢸⠀⣾⣿⣿⣿⣿⣉⣴⡖⠐⠀⣤⡘⢷⣿⣿⣿⣷⣿⠿⠿⠛⠉⠉⠁⠀⠀⠈⠛⢿⡿⠉⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿
echo                          ⣿⣿⣿⣿⣿⣿⢱⡯⠴⠒⠀⢀⣇⠀⢰⣿⣿⣿⣿⣿⣿⣿⣝⣷⣿⣿⣭⣿⣿⣿⣿⣿⡟⠀⣠⠠⢤⣄⠢⢀⣄⡀⠀⠀⣀⣤⡄⠀⠀⠀⠀⠀⠀⠀⣸⣿⣿⣿⣿⣿
echo                          ⣿⣿⣿⣿⣿⣿⡄⣀⡀⠀⠀⣿⣿⣆⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣿⣿⣿⣧⣿⣿⣿⣿⣟⡿⠿⢟⣡⣶⣾⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿
echo                          ⣿⣿⣿⠿⣋⣵⠞⠉⠀⠀⠀⠘⢿⡟⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⣤⢄⣿⣿⣿⣿⣿⣿
echo                          ⡿⢛⣵⠾⠋⠀⠀⠀⠀⠀⢠⡞⠀⣰⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣿⣿⣿⣿⣿⣿⣧⣿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⢀⣀⢀⣾⡟⣼⣿⣿⣿⣿⣿⣿
echo                          ⡴⠟⠁⠀⠀⠀⠀⠀⠀⣰⡟⠀⢠⣿⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⢟⣵⣿⣿⣿⣿⣿⣿⣿⣦⡌⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⢠⡿⠿⡿⢋⣼⣿⣿⣿⣿⣿⣿⣿
echo                          ⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⡇⠀⣼⣿⢸⣿⣿⣿⣿⣿⣿⣿⣿⣡⣾⣿⡛⣻⣿⣿⣿⠿⢿⣿⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠁⠀⢠⣴⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿
echo                          ⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⡇⢀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⣀⣠⣴⣦⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠏⣠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
echo                          ⠀⠀⠀⠀⠀⠀⠀⠀⣾⣿⡇⢸⣿⣿⣿⡻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⢻⣿⣿⣿⣿⣿⣿⣧⢻⣿⣿⣿⣿⣿⣿⠏⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
echo                          ⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣧⠘⣿⣿⣿⣷⠹⣿⣿⣿⣿⣟⣥⣬⣍⣉⣉⡙⠛⠿⠛⠿⢿⣿⣿⣿⣿⣷⣿⣿⣿⣿⡿⢫⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
echo                          ⠀⠀⠀⠀⠀⠀⠀⠀⢹⣿⣿⡄⢻⣿⣿⣿⣧⡹⣿⣿⣿⣿⣿⣿⣿⣻⢿⣿⣷⣶⣶⣶⣶⣴⢶⣬⡟⣿⣿⣿⡿⢋⢴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
echo                          ⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣷⡈⢿⣿⣿⣿⣷⡘⢿⣿⣿⣿⣿⣿⣿⣷⣶⣭⣭⣭⣭⣭⣶⣿⣿⣷⣿⣿⠟⠁⠹⣷⡙⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
echo                          ⠀⠀⠀⠀⠀⠀⠀⡄⠀⢿⣿⣿⣷⡈⢿⣿⣿⣿⣷⣄⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣿⣿⣿⡿⠟⠁⠀⠢⡱⠌⠻⣮⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
echo                          ⠀⠀⠀⠀⠀⠀⢸⡇⠀⠈⢿⣿⣿⣿⡌⢿⣿⣿⣿⣿⣧⡈⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠋⢰⡆⢧⠀⠀⠀⠀⢰⣝⢷⣜⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
echo                          ⠀⠀⠀⠀⠀⣰⠟⠁⠀⠀⠈⣿⡟⣿⣿⣆⠻⣿⣿⣿⣿⣷⡀⣭⣛⡛⠛⠛⠙⠛⠛⠛⠛⠋⠀⠀⢸⣿⠸⠀⠀⠀⠀⠀⢻⣦⡹⣦⡻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
echo                          ⠀⠀⢀⣤⣾⣥⣶⠀⠀⠀⠀⠘⢿⣞⣿⣿⣦⠙⣿⣿⣿⣿⣿⣿⣿⣿⣦⡀⠀⣀⡀⠀⠀⠀⠀⠀⢸⡏⠀⡇⢀⣀⣀⣀⣠⣿⣿⣌⢳⡙⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿
echo                          ⢸⣷⣿⣿⣿⣿⣿⠀⣾⡆⠀⠀⠈⢻⣎⢿⣿⣷⡌⢿⣿⣿⣿⣿⣿⣿⣿⡿⠿⢟⡁⠀⠀⠀⢀⣴⡟⢀⡀⠁⢸⣿⣿⣿⣿⣿⣿⣿⣷⡙⣄⢪⣝⡻⢿⣿⣿⣿⣿⣿
echo                          ⣿⣿⣿⣿⣿⣿⣿⠀⣿⣿⠀⠀⠀⠀⠙⣷⣿⣿⣿⣦⠙⣿⣿⣿⣿⣿⣶⣾⣿⣿⠟⠁⢀⣴⣿⡟⢠⣿⣿⡄⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⡌⣦⠹⣿⣷⡝⢿⣿⣿⣿
echo                          ⣿⣿⣿⣿⣿⣿⣿⠀⣿⣿⡄⠀⠀⠀⠀⠈⠻⣿⣿⣿⣷⣌⠻⣿⣿⣿⣿⣿⠟⠁⠀⢠⣿⡿⠋⠀⣾⣿⣿⣷⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⠟⣰⣿⣿⣿⡌⣿⣿⣿
echo                          ⣿⣿⣿⣿⣿⣿⣿⣦⣿⣿⣇⠀⠀⠀⠀⠀⠀⠀⠙⠻⢿⡿⢃⣿⣿⣿⠟⣠⣾⣿⠂⣼⡿⠁⠀⢸⣿⣿⣿⣿⣷⣿⣿⣿⣿⣿⣿⣿⡿⢟⣥⣾⣿⣿⣿⣿⣿⡘⣿⣿
echo                          ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⣿⣿⣿⣿⣿⣿⡟⢀⣿⡇⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⢋⣴⣿⣿⣿⣿⣿⣿⡟⢻⣷⢹⣿
echo                          ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⢃⣾⣿⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⡿⢋⣴⣿⣿⣿⣿⣿⣿⣿⣿⡇⢤⣿⡇⢿
echo                          ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣿⢃⣾⣿⣿⣆⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣷⣄⡻⢿⣿⣿⣿⣿⣿⣿⣿⣿⠠⣤⣹⣿⢸
echo                          ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⢃⣾⣿⣿⣿⣿⣆⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣍⡛⢿⣿⣿⣿⣿⣿⢠⣈⢿⣿⡾
echo                          ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⢃⣾⣿⣿⣿⣿⣿⣿⣧⡈⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣌⣻⣿⣿⣿⠀⣿⣷⢹⡇
echo                          ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡆⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⣿⢃⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣽⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠇⣿⣿⣿⣿⠀⣿⣇⣾⡇
echo.
echo.
call :center "%YEL%!thanks1.%LNG%!%RES%"
echo.
call :center "%MAG%https://ko-fi.com/Y8Y21X6CZD%RES%"
echo.
call :center "!thanks2.%LNG%!"
echo.
call :center "%CYA%Gen Urobuchi%RES%."

timeout /T 5 %DEBUGREDIR%
color

:: Restore cmd.exe parameters
if defined OLD_FACE (
   "%regexe%" add "HKCU\Console" /v FaceName /t REG_SZ /d "%OLD_FACE%" /f >nul
) else (
   "%regexe%" delete "HKCU\Console" /v FaceName /f %DEBUGREDIR%
)

if defined OLD_SIZE (
   "%regexe%" add "HKCU\Console" /v FontSize /t REG_DWORD /d %OLD_SIZE% /f >nul
) else (
   "%regexe%" delete "HKCU\Console" /v FontSize /f %DEBUGREDIR%
)

if defined OLD_FAMILY (
   "%regexe%" add "HKCU\Console" /v FontFamily /t REG_DWORD /d %OLD_FAMILY% /f >nul
) else (
   "%regexe%" delete "HKCU\Console" /v FontFamily /f %DEBUGREDIR%
)

if defined OLD_WEIGHT (
   "%regexe%" add "HKCU\Console" /v FontWeight /t REG_DWORD /d %OLD_WEIGHT% /f >nul
) else (
   "%regexe%" delete "HKCU\Console" /v FontWeight /f %DEBUGREDIR%
)

"%regexe%" add "HKCU\Software\UnRen" /v Thanks /t REG_DWORD /d 1 /f >nul

:nothanks
cls


:: We need PowerShell for later, make sure it exists
set "pshell.en=Checking for availability of PowerShell"
set "pshell.fr=Vérification de la disponibilité de PowerShell"
set "pshell.es=Comprobando la disponibilidad de PowerShell"
set "pshell.it=Verifica della disponibilità di PowerShell"
set "pshell.de=Überprüfung der Verfügbarkeit von PowerShell"
set "pshell.ru=Проверка доступности PowerShell"
set "pshell.zh=检查 PowerShell 是否可用"

call :elog -n "%EMPTY%" "!pshell.%LNG%!..."
for /f "delims=" %%A in ('"%SystemRoot%\System32\where.exe" pwsh.exe 2^>nul') do (
    if not "%%A" == "" set "PWRSHELL=%%A"
)
if not exist "%PWRSHELL%" (
    set "pshell1.en=Powershell is required."
    set "pshell1.fr=Erreur Powershell est requis."
    set "pshell1.es=Error Se requiere Powershell."
    set "pshell1.it=Errore Powershell è richiesto."
    set "pshell1.de=Fehler Powershell ist erforderlich."
    set "pshell1.ru=Ошибка требуется PowerShell."
    set "pshell1.zh=需要 PowerShell。"

    set "pshell2.en=This is included in Windows 7, 8 and 10. XP/Vista users can"
    set "pshell2.fr=Ce programme est inclus dans Windows 7, 8 et 10. Les utilisateurs de XP/Vista peuvent"
    set "pshell2.es=Esto está incluido en Windows 7, 8 y 10. Los usuarios de XP/Vista pueden"
    set "pshell2.it=Questo programma è incluso in Windows 7, 8 e 10. Gli utenti di XP/Vista possono"
    set "pshell2.de=Dieses Programm ist in Windows 7, 8 und 10 enthalten. XP/Vista-Benutzer können"
    set "pshell2.ru=Это включено в Windows 7, 8 и 10. Пользователи XP/Vista могут"
    set "pshell2.zh=Windows 7、8 和 10 包含此组件。XP/Vista 用户可以"

    set "pshell3.en=download it here: %MAG%https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.5%RES%"
    set "pshell3.fr=le télécharger ici : %MAG%https://learn.microsoft.com/fr-fr/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.5%RES%"
    set "pshell3.es=descargarlo aquí: %MAG%https://learn.microsoft.com/es-es/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.5%RES%"
    set "pshell3.it=scaricarlo qui: %MAG%https://learn.microsoft.com/it-it/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.5%RES%"
    set "pshell3.de=es hier herunterladen: %MAG%https://learn.microsoft.com/de-de/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.5%RES%"
    set "pshell3.ru=скачать его здесь: %MAG%https://learn.microsoft.com/ru-ru/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.5%RES%"
    set "pshell3.zh=在此下载：%MAG%https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.5%RES%"

    call :elog "%NOK%"
    call :elog .
    call :elog "    !pshell1.%LNG%!. !UNACONT.%LNG%!"
    call :elog "    !pshell2.%LNG%!"
    call :elog "    !pshell3.%LNG%!"
    call :elog .
    pause>nul|set /p=".      !ANYKEY.%LNG%!..."

    call :exitn 3
) else (
    call :elog "%OK%"
)


:: Check for required files
call :check_all_files


:: Set the working directory
set "wdir1.en=Error The specified directory does not exist."
set "wdir1.fr=Erreur Le répertoire spécifié n'existe pas."
set "wdir1.es=Error El directorio especificado no existe."
set "wdir1.it=Errore la directory specificata non esiste."
set "wdir1.de=Fehler Das angegebene Verzeichnis existiert nicht."
set "wdir1.ru=Ошибка Указанный каталог не существует."
set "wdir1.zh=错误：指定的目录不存在。"

set "wdir2.en=Are you sure we're in the game's root directory?"
set "wdir2.fr=Êtes-vous sûr que nous sommes dans le répertoire racine du jeu ?"
set "wdir2.es=¿Está seguro de que estamos en el directorio raíz del juego?"
set "wdir2.it=Sei sicuro che siamo nella directory principale del gioco?"
set "wdir2.de=Sind Sie sicher, dass wir uns im Stammverzeichnis des Spiels befinden?"
set "wdir2.ru=Вы уверены, что находимся в корневом каталоге игры?"
set "wdir2.zh=确定我们在游戏根目录中吗？"

set "wdir3.en=Testing write access to game directory"
set "wdir3.fr=Test de l'accès en écriture au répertoire du jeu"
set "wdir3.es=Prueba de acceso de escritura al directorio del juego"
set "wdir3.it=Verifica l'accesso in scrittura alla directory di gioco"
set "wdir3.de=Testen des Schreibzugriffs auf das Spieledirectory"
set "wdir3.ru=Проверка доступа на запись в каталог игры"
set "wdir3.zh=测试对游戏目录的写入权限"

:: Check if game path is provided and set it
set "LAUNCHED_WDIR=0"
set "WORKDIR="
:: Remove surrounding quotes if any
if not "!TEMPDIR!" == "" set "TEMPDIR=!TEMPDIR:"=!"
if "!TEMPDIR!" == "" (
    set "setpath1.en=Enter the path to the game, drag'n'drop it here,"
    set "setpath1.fr=Entrez le chemin vers le jeu, faites-le glisser ici,"
    set "setpath1.es=Introduzca la ruta al juego, arrástrelo aquí,"
    set "setpath1.it=Inserisci il percorso del gioco, trascinalo qui,"
    set "setpath1.de=Geben Sie den Pfad zum Spiel ein, ziehen Sie es hierher,"
    set "setpath1.ru=Введите путь к игре, перетащите его сюда,"
    set "setpath1.zh=输入游戏路径，将其拖放到此处，"

    set "setpath2.en=or press Enter if this tool is already in the desired folder."
    set "setpath2.fr=ou appuyez sur Entrée si cet outil se trouve déjà dans le dossier souhaité."
    set "setpath2.es=o presione Entrar si esta herramienta ya se encuentra en la carpeta deseada."
    set "setpath2.it=oppure premi Invio se questo strumento si trova già nella cartella desiderata."
    set "setpath2.de=oder drücken Sie die Eingabetaste, wenn sich dieses Tool bereits im gewünschten Ordner befindet."
    set "setpath2.ru=или нажмите Enter, если этот инструмент уже находится в нужной папке."
    set "setpath2.zh=或者如果此工具已在所需文件夹中，请按 Enter 键。"

    set "setpath3.en=If drag'n'drop does not work, please copy/paste the path instead: "
    set "setpath3.fr=Si le glisser-déposer ne fonctionne pas, veuillez copier/coller le chemin à la place : "
    set "setpath3.es=Si arrastrar y soltar no funciona, copie/pegue la ruta en su lugar: "
    set "setpath3.it=Se il trascinamento della selezione non funziona, copia/incolla il percorso invece: "
    set "setpath3.de=Wenn das Ziehen und Ablegen nicht funktioniert, kopieren Sie den Pfad bitte stattdessen hierher: "
    set "setpath3.ru=Если перетаскивание не работает, пожалуйста, скопируйте/вставьте путь вместо этого: "
    set "setpath3.zh=如果拖放不起作用，请复制/粘贴路径："

    setlocal enabledelayedexpansion
    echo.
    echo !setpath1.%LNG%!
    echo !setpath2.%LNG%!
    echo.
    set "_question=!setpath3.%LNG%!"
    for /f "delims=" %%A in ("!_question!") do (
        endlocal
        set /p "WORKDIR=%%A"
    )
    if not defined WORKDIR (
        set "WORKDIR=%cd%"
    )
) else (
    set "WORKDIR=!TEMPDIR!"
    if "%WORKDIR%" == "." (
        set "WORKDIR=%cd%"
    )
    set "LAUNCHED_WDIR=1"
)

setlocal disabledelayedexpansion
:: Remove surrounding quotes if any
set "WORKDIR=%WORKDIR:"=%"

:: Normalize WORKDIR to an absolute path
for %%A in ("%WORKDIR%") do set "WORKDIR=%%~fA"

:: Check if WORKDIR is a valid path
set "HAS_BAD="
:: Characters that CAN appear in a valid Windows path but WILL break batch logic:
setlocal disabledelayedexpansion
echo "%WORKDIR%" | "%SystemRoot%\System32\findstr.exe" /C:"!" >nul && (
    call set "HAS_BAD=!"
)
echo "%WORKDIR%" | "%SystemRoot%\System32\findstr.exe" /C:"&" >nul && (
    if not defined HAS_BAD (
        call set "HAS_BAD=&"
    ) else (
        call set "HAS_BAD=%%HAS_BAD%%,&"
    )
)
endlocal & set "HAS_BAD=%HAS_BAD%"
for %%C in ("(" ")" "=" ";" "'" "`" "[" "]" "{" "}" "+" "~") do (
    echo "%WORKDIR%" | "%SystemRoot%\System32\findstr.exe" /C:"%%~C" >nul && (
        if not defined HAS_BAD (
            call set "HAS_BAD=%%~C"
        ) else (
            call set "HAS_BAD=%%HAS_BAD%%,%%~C"
        )
    )
)
setlocal enabledelayedexpansion
if defined HAS_BAD (
    set "invchars.en=Invalid character detected in the path"
    set "invchars.fr=Caractère invalide détecté dans le chemin"
    set "invchars.es=Se ha detectado un carácter no válido en la ruta de acceso"
    set "invchars.it=Carattere non valido rilevato nel percorso di accesso"
    set "invchars.de=Ungültiges Zeichen im Pfad gefunden"
    set "invchars.ru=Обнаружен недействительный символ в пути доступа"
    set "invchars.zh=路径中检测到无效字符"

    echo %NOK% !invchars.%LNG%! '%RED%!HAS_BAD!%RES%'. !UNACONT.%LNG%!
    call :elog .
    pause>nul|set /p=".      !ANYKEY.%LNG%!..."

    call :exitn 3
)

setlocal disabledelayedexpansion
for /f "delims=" %%A in ("%WORKDIR%") do (
    endlocal
    cd /d "%%A"
    if %errorlevel% NEQ 0 (
        call :elog "%NOK%" "!wdir1.%LNG%!%RES%"
        call :elog .
        call :elog "    !wdir2.%LNG%!"
        call :elog .
        pause>nul|set /p=".      !ANYKEY.%LNG%!..."

        call :exitn 3
    )
)

:: Analysis of debug arguments
if /i "%~3" == "-d" (
    set "DEBUGREDIR=>>%UNRENLOG% 2>&1"
    set "DEBUGLEVEL=1"
    set "NOCLS=1"
    if %DEBUGLEVEL% GEQ 1 echo "%PWRSHELL%" -NoProfile -Command "$h = Get-Host; $h.UI.RawUI.BufferSize = New-Object Management.Automation.Host.Size(!NEW_COLS!,5000)" >> "%UNRENLOG%"
    "%PWRSHELL%" -NoProfile -Command "$h = Get-Host; $h.UI.RawUI.BufferSize = New-Object Management.Automation.Host.Size(!NEW_COLS!,5000)" %DEBUGREDIR%
)
if /i "%~3" == "-dd" (
    echo on
    set "DEBUGREDIR=>>%UNRENLOG% 2>&1"
    set "DEBUGLEVEL=2"
    set "NOCLS=1"
    if %DEBUGLEVEL% GEQ 1 echo "%PWRSHELL%" -NoProfile -Command "$h = Get-Host; $h.UI.RawUI.BufferSize = New-Object Management.Automation.Host.Size(!NEW_COLS!,9000)" >> "%UNRENLOG%"
    "%PWRSHELL%" -NoProfile -Command "$h = Get-Host; $h.UI.RawUI.BufferSize = New-Object Management.Automation.Host.Size(!NEW_COLS!,9000)" %DEBUGREDIR%
)


:: Check that you are in the root directory of the game.
set "reqdir1.en=Checking if game, lib, renpy directories exist"
set "reqdir1.fr=Vérification de l'existence des répertoires game, lib et renpy"
set "reqdir1.es=Comprobando si existen los directorios game, lib, renpy"
set "reqdir1.it=Controllo dell'esistenza delle directory game, lib, renpy"
set "reqdir1.de=Überprüfung der Existenz der Verzeichnisse game, lib, renpy"
set "reqdir1.ru=Проверка наличия каталогов game, lib, renpy"
set "reqdir1.zh=检查 game、lib、renpy 目录是否存在"

setlocal disabledelayedexpansion
for /f "delims=" %%A in ("%WORKDIR%") do (
    endlocal
    cd /d "%%A"
)
set "missing="
call :elog -n "%EMPTY%" "!reqdir1.%LNG%!..."
set "missing="
if not exist ".\game" (
    set "missing=%YEL%.\game%RES%"
)
if not exist ".\lib" (
    if defined missing (
        set "missing=!missing!, %YEL%.\lib%RES%"
    ) else (
        set "missing=%YEL%.\lib%RES%"
    )
)
if not exist ".\renpy" (
    if defined missing (
        set "missing=!missing!, %YEL%.\renpy%RES%"
    ) else (
        set "missing=%YEL%.\renpy%RES%"
    )
)

set "reqdir2.en=Cannot locate %missing% directories."
set "reqdir2.fr=Erreur Impossible de localiser les répertoires %missing%."
set "reqdir2.es=Error No se pueden localizar los directorios %missing%."
set "reqdir2.it=Errore Impossibile localizzare le directory %missing%."
set "reqdir2.de=Fehler Unmöglich, die Verzeichnisse %missing% zu finden."
set "reqdir2.ru=Ошибка Не удалось найти каталоги %missing%."
set "reqdir2.zh=找不到 %missing% 目录。"
if defined missing (
    call :elog "%NOK%"
    call :elog .
    call :elog "    !reqdir2.%LNG%!. !UNACONT.%LNG%!"
    call :elog "    !wdir2.%LNG%!"
    call :elog .
    pause>nul|set /p=".      !ANYKEY.%LNG%!..."

    call :exitn 3
) else (
    call :elog "%OK%"
)

:: Check if .\game is writable
call :elog -n "%EMPTY%" "!wdir3.%LNG%!..."
if %DEBUGLEVEL% GEQ 1 echo copy /y nul ".\game\test.txt" >> "%UNRENLOG%"
copy /y nul ".\game\test.txt" %DEBUGREDIR%
if %errorlevel% NEQ 0 (
    call :elog "%NOK%"
    call :elog .
    call :elog "    !wdir2.%LNG%!"
    call :elog .
    pause>nul|set /p=".      !ANYKEY.%LNG%!..."

    call :exitn 3
) else (
    if %DEBUGLEVEL% GEQ 1 echo del /f /q ".\game\test.txt" >> "%UNRENLOG%"
    del /f /q ".\game\test.txt" %DEBUGREDIR%
    call :elog "%OK%"
)


:: Set UNRENLOG for debugging purpose
If exist "%TEMP%\%BASENAME%.log" (
    if %DEBUGLEVEL% GEQ 1 echo move /y "%TEMP%\%BASENAME%.log" "%WORKDIR%\%BASENAME%.log" >> "%UNRENLOG%"
    move /y "%TEMP%\%BASENAME%.log" "%WORKDIR%\%BASENAME%.log" >nul 2>&1
    if !errorlevel! NEQ 0 (
        call :elog "%NOK%" "!FMOVE.%LNG%! %YEL%%TEMP%\%BASENAME%.log%RES% !decm10a.%LNG%! %YEL%%WORKDIR%\%BASENAME%.log%RES%"
        call :elog .
        pause>nul|set /p=".      !ANYKEY.%LNG%!..."

        call :exitn 3
    )
)
set "UNRENLOG=%WORKDIR%\%BASENAME%.log"
set "UNRENLOG=%UNRENLOG:"=%"


:: Check for Python System
set "PYTHONEXE="
set "PYVERSION2="
set "PYVERSION3="
set "PYTHONSYSTEM="

setlocal enabledelayedexpansion
set "pysystem1.en=Checking for Python installation on the system"
set "pysystem1.fr=Vérification de l'installation de Python sur le système"
set "pysystem1.es=Comprobando la instalación de Python en el sistema"
set "pysystem1.it=Controllo dell'installazione di Python sul sistema"
set "pysystem1.de=Überprüfung der Python-Installation auf dem System"
set "pysystem1.ru=Проверка установки Python на системе"
set "pysystem1.zh=检查系统是否安装 Python"

set "pysystem2.en=Python 2 and 3 are available on the system."
set "pysystem2.fr=Python 2 et 3 sont disponibles sur le système."
set "pysystem2.es=Python 2 y 3 están disponibles en el sistema."
set "pysystem2.it=Python 2 e 3 sono disponibili sul sistema."
set "pysystem2.de=Python 2 und 3 sind auf dem System verfügbar."
set "pysystem2.ru=Python 2 и 3 доступны на системе."
set "pysystem2.zh=系统上可用 Python 2 和 3。"

set "pysystem3.en=Only Python 2 is available on the system."
set "pysystem3.fr=Seul Python 2 est disponible sur le système."
set "pysystem3.es=Solo Python 2 disponible en el sistema."
set "pysystem3.it=Solo Python 2 è disponibile sul sistema."
set "pysystem3.de=Nur Python 2 ist auf dem System verfügbar."
set "pysystem3.ru=Только Python 2 доступен на системе."
set "pysystem3.zh=只有 Python 2 可用于系统。"

set "pysystem4.en=Only Python 3 is available on the system."
set "pysystem4.fr=Seul Python 3 est disponible sur le système."
set "pysystem4.es=Solo Python 3 disponible en el sistema."
set "pysystem4.it=Solo Python 3 è disponibile sul sistema."
set "pysystem4.de=Nur Python 3 ist auf dem System verfugbar."
set "pysystem4.ru=Только Python 3 доступен на системе."
set "pysystem4.zh=只有 Python 3 可用于系统。"

set "pysystem5.en=Python is not available on the system."
set "pysystem5.fr=Python n'est pas disponible sur le système."
set "pysystem5.es=Python no disponible en el sistema."
set "pysystem5.it=Python non disponibile sul sistema."
set "pysystem5.de=Python ist auf dem System nicht verfugbar."
set "pysystem5.ru=Python не доступен на системе."
set "pysystem5.zh=系统上不可用 Python。"

set "pythonv2="
set "pythonv3="
set "pythonexe="
set "pythonsystem="
call :elog -n "%EMPTY%" "!pysystem1.%LNG%!..."
if exist "%SystemRoot%\py.exe" (
    "%SystemRoot%\py.exe" --list >"%TEMP%\pylist.txt" 2>&1
    for /f "tokens=1,2 delims=:" %%A in ('%SystemRoot%\System32\findstr.exe /i "V:" "%TEMP%\pylist.txt"') do (
        :: %%B contains major.minor eg: "3.14", "3.9 *", "2.7"
        for /f "tokens=1,2 delims=." %%M in ("%%B") do (
            :: %%M = major (eg: "3"), %%N = minor with optional " *" (eg: "14", "9 *")
            for /f "tokens=1 delims= " %%V in ("%%N") do (
                :: %%V = minor clean (eg: "14", "9", "7")
                if "%%M" == "2" (
                    if "%%V" == "7" (
                        set "pythonexe=%SystemRoot%\py.exe"
                        set "pythonv2=-V:%%M.%%V"
                        set "pythonsystem=-E"
                    )
                ) else if "%%M" == "3" (
                    if %%V GEQ 9 (
                        set "pythonexe=%SystemRoot%\py.exe"
                        set "pythonv3=-V:%%M.%%V"
                        set "pythonsystem=-E"
                    )
                )
            )
        )
    )
)
del /f /q "%TEMP%\pylist.txt" %DEBUGREDIR%

set "PATH=%SystemDrive%\Python27:%PATH%"
for /f "delims=" %%A in ('"%SystemRoot%\System32\where.exe" python.exe 2^>nul') do (
    if not "%%A" == "" (
        echo "%%A" | "%SystemRoot%\System32\findstr.exe" /i "WindowsApps" >nul
        if errorlevel 1 (
            if exist "%%A" (
                for /f "tokens=2 delims= " %%B in ('"%%A" -V 2^>^&1') do (
                    for /f "tokens=1,2 delims=." %%M in ("%%B") do (
                        if "%%M" == "2" (
                            if not defined pythonexe (
                                set "pythonexe=%%A"
                                set "pythonsystem=-E"
                            )
                        ) else if "%%M" == "3" (
                            if %%N GEQ 9 (
                                if not defined pythonv3 (
                                    set "pythonexe=%%A"
                                    set "pythonsystem=-E"
                                )
                            )
                        )
                    )
                )
            )
        )
    )
)

if defined pythonv2 if defined pythonv3 (
    call :elog "%OK%"
    call :elog "         !pysystem2.%LNG%!"
) else if defined pythonv2 if not defined pythonv3 (
    call :elog "%OK%"
    call :elog "         !pysystem3.%LNG%!"
) else if not defined pythonv2 if defined pythonv3 (
    call :elog "%OK%"
    call :elog "         !pysystem4.%LNG%!"
) else (
    call :elog "%SKIP%"
    call :elog "         !pysystem5.%LNG%!"
)
endlocal & set "PYTHONEXE=%pythonexe%" & set "PYVERSION2=%pythonv2%" & set "PYVERSION3=%pythonv3%" & set "PYTHONSYSTEM=%pythonsystem%"


:: Check for Python Game
set "python1.en=Checking if Python Game is available"
set "python1.fr=Vérification de la disponibilité de Python Jeu"
set "python1.es=Comprobando la disponibilidad de Python Juego"
set "python1.it=Controllo della disponibilità di Python Gioco"
set "python1.de=Python-Spiel verfugen"
set "python1.ru=Проверка доступности Python-игры"
set "python1.zh=检查 Python 游戏是否可用"

set "python2.en=Python version:"
set "python2.fr=Version de Python :"
set "python2.es=Versión de Python :"
set "python2.it=Versione di Python :"
set "python2.de=Python-Version :"
set "python2.ru=Версия Python :"
set "python2.zh=Python 版本："

set "python3.en=Cannot locate python directory."
set "python3.fr=Impossible de localiser le répertoire python."
set "python3.es=No se puede localizar el directorio de Python."
set "python3.it=Impossibile localizzare la directory di Python."
set "python3.de=Python-Verzeichnis kann nicht gefunden werden."
set "python3.ru=Не удалось найти каталог Python."
set "python3.zh=找不到 python 目录。"

call :elog -n "%EMPTY%" "!python1.%LNG%!..."

:: Doublecheck to avoid issues with Milfania games
set "PYTHONHOME="
set "PYTHONPATH="
if exist "%WORKDIR%\lib\py3-windows-x86_64\pythonw.exe" if exist "%WORKDIR%\lib\py3-windows-x86_64\python.exe" (
    if not "%PROCESSOR_ARCHITECTURE%" == "x86" (
        <nul set /p=.
        set "PYTHONHOME=%WORKDIR%\lib\py3-windows-x86_64\"
    ) else if exist "%WORKDIR%\lib\py3-windows-i686\python.exe" (
        <nul set /p=.
        set "PYTHONHOME=%WORKDIR%\lib\py3-windows-i686\"
    )
) else if exist "%WORKDIR%\lib\py3-windows-i686\python.exe" (
    <nul set /p=.
    set "PYTHONHOME=%WORKDIR%\lib\py3-windows-i686\"
)
if exist "%WORKDIR%\lib\py2-windows-x86_64\python.exe" (
    if not "%PROCESSOR_ARCHITECTURE%" == "x86" (
        <nul set /p=.
        set "PYTHONHOME=%WORKDIR%\lib\py2-windows-x86_64\"
    ) else if exist "%WORKDIR%\lib\py2-windows-i686\python.exe" (
        <nul set /p=.
        set "PYTHONHOME=%WORKDIR%\lib\py2-windows-i686\"
    )
) else if exist "%WORKDIR%\lib\py2-windows-i686\python.exe" (
    <nul set /p=.
    set "PYTHONHOME=%WORKDIR%\lib\py2-windows-i686\"
)
if exist "%WORKDIR%\lib\windows-x86_64\python.exe" (
    if not "%PROCESSOR_ARCHITECTURE%" == "x86" (
        <nul set /p=.
        set "PYTHONHOME=%WORKDIR%\lib\windows-x86_64\"
    ) else if exist "%WORKDIR%\lib\windows-i686\python.exe" (
        <nul set /p=.
        set "PYTHONHOME=%WORKDIR%\lib\windows-i686\"
    )
) else if exist "%WORKDIR%\lib\windows-i686\python.exe" (
    <nul set /p=.
    set "PYTHONHOME=%WORKDIR%\lib\windows-i686\"
)
set "PYTHONPATH=%PYTHONHOME%"

:: Set the PYNOASSERT according to "%PYTHONHOME%Lib".
if exist "%PYTHONHOME%Lib" (
    set "PYNOASSERT=-O"
) else (
    set "PYNOASSERT="
)

for /f "tokens=2 delims= " %%a in ('"%PYTHONHOME%python.exe" -V 2^>^&1') do set PYTHONVERS=%%a
:: Extraction of major and minor versions
for /f "tokens=1,2 delims=." %%b in ("%PYTHONVERS%") do (
    set PYTHONMAJOR=%%b
    set PYTHONMINOR=%%c
)

set "RPATOOL_NEW="
set "UNRPYC_NEW="
:: Priority to Python 3.x if present
if %PYTHONMAJOR% GEQ 3 if exist "%WORKDIR%\lib\python%PYTHONMAJOR%.%PYTHONMINOR%" (
    <nul set /p=.
    set "PYTHONPATH=%WORKDIR%\lib\python%PYTHONMAJOR%.%PYTHONMINOR%"
    set "RPATOOL_NEW=y"
    set "UNRPYC_NEW=y"
    goto :pyend
)

:: Searching for the latest version of Python 2.x
if exist "%WORKDIR%\lib\pythonlib%PYTHONMAJOR%.%PYTHONMINOR%" (
    <nul set /p=.
    set "PYTHONPATH=%WORKDIR%\lib\pythonlib%PYTHONMAJOR%.%PYTHONMINOR%"
    set "RPATOOL_NEW=n"
    set "UNRPYC_NEW=n"
) else if exist "%WORKDIR%\lib\python%PYTHONMAJOR%.%PYTHONMINOR%" (
    <nul set /p=.
    set "PYTHONPATH=%WORKDIR%\lib\python%PYTHONMAJOR%.%PYTHONMINOR%"
    set "RPATOOL_NEW=n"
    set "UNRPYC_NEW=n"
)

:pyend
if not exist "%PYTHONPATH%" (
    call :elog "%NOK%"
    call :elog .
    call :elog "    %RED%!python3.%LNG%!%RES%. !UNACONT.%LNG%!"
    call :elog "    !wdir2.%LNG%!"
    call :elog .
    pause>nul|set /p=".      !ANYKEY.%LNG%!..."

    call :exitn 3
) else (
    call :elog "%OK%" "!python2.%LNG%! %YEL%%PYTHONVERS%%RES%"
)
if not defined PYTHONEXE (
    set "PYTHONEXE=%PYTHONHOME%python.exe"
)

:: Used later for base64 decoding
>"%TEMP%\b64decode.py" (
    echo import base64, sys, os
    echo.
    echo if len^(sys.argv^) ^< 3:
    echo     sys.stderr.write^("Usage: script.py <src> <dst>\n"^)
    echo     sys.exit^(1^)
    echo.
    echo src, dst = sys.argv[1], sys.argv[2]
    echo.
    echo try:
    echo    with open^(src, 'rb'^) as f:
    echo        raw = f.read^(^)
    echo except IOError as e:
    echo    sys.stderr.write^("Failed to read source file '%%s': %%s\n" %% ^(src, e^)^)
    echo    sys.exit^(1^)
    echo.
    echo try:
    echo    raw = raw.replace^(b'\r', b''^).replace^(b'\n', b''^)
    echo    missing = len^(raw^) %% 4
    echo    if missing:
    echo        raw += b'=' * ^(4 - missing^)
    echo    data = base64.b64decode^(raw^)
    echo except Exception as e:
    echo    sys.stderr.write^("Failed to decode base64 from '%%s': %%s\n" %% ^(src, e^)^)
    echo    sys.exit^(1^)
    echo.
    echo try:
    echo    with open^(dst, 'wb'^) as f:
    echo        f.write^(data^)
    echo except IOError as e:
    echo    sys.stderr.write^("Failed to write destination file '%%s': %%s\n" %% ^(dst, e^)^)
    echo    if os.path.exists^(dst^):
    echo        try:
    echo            os.remove^(dst^)
    echo            sys.stderr.write^("Cleaned up partial file '%%s'\n" %% dst^)
    echo        except OSError as e2:
    echo            sys.stderr.write^("Failed to clean up '%%s': %%s\n" %% ^(dst, e2^)^)
    echo    sys.exit^(1^)
)

:: Check for Ren'Py version
set "renpyvers1.en=Ren'Py version found:"
set "renpyvers1.fr=Version Ren'Py trouvée :"
set "renpyvers1.es=Versión de Ren'Py encontrada:"
set "renpyvers1.it=Versione Ren'Py rilevata:"
set "renpyvers1.de=Ren'Py-Version gefunden:"
set "renpyvers1.ru=Найдена версия Ren'Py:"
set "renpyvers1.zh=检测到的 Ren'Py 版本 :"

set "renpyvers2.en=Checking Ren'Py version"
set "renpyvers2.fr=Vérification de la version de Ren'Py"
set "renpyvers2.es=Comprobando la versión de Ren'Py"
set "renpyvers2.it=Controllo della versione di Ren'Py"
set "renpyvers2.de=Überprüfung der Ren'Py-Version"
set "renpyvers2.ru=Проверка версии Ren'Py"
set "renpyvers2.zh=检查 Ren'Py 版本"

set "renpyvers3.en=Unable to detect Ren'Py version,"
set "renpyvers3.fr=Impossible de détecter la version de Ren'Py,"
set "renpyvers3.es=No se puede detectar la versión de Ren'Py,"
set "renpyvers3.it=Impossibile rilevare la versione di Ren'Py,"
set "renpyvers3.de=Unmöglich, die Ren'Py-Version zu erkennen, bitte sicherstellen,"
set "renpyvers3.ru=Не удалось обнаружить версию Ren'Py, пожалуйста,"
set "renpyvers3.zh=无法检测 Ren'Py 版本，"

set "renpyvers4.en=please ensure the game is compatible with UnRen."
set "renpyvers4.fr=es-tu sûr que le jeu est compatible avec UnRen ?"
set "renpyvers4.es=asegúrese de que el juego sea compatible con UnRen."
set "renpyvers4.it=assicurati che il gioco sia compatibile con UnRen."
set "renpyvers4.de=dass das Spiel mit UnRen kompatibel ist."
set "renpyvers4.ru=убедитесь, что игра совместима с UnRen."
set "renpyvers4.zh=请确保游戏与 UnRen 兼容。"

setlocal disabledelayedexpansion
for /f "delims=" %%A in ("%WORKDIR%") do (
    endlocal
    cd /d "%%A"
)

set "detect_renpy_version=%WORKDIR%\detect_renpy_version.py"
>"%detect_renpy_version%.b64" (
    <nul set /p="IyEvdXNyL2Jpbi9lbnYgcHl0aG9uDQojIC0qLSBjb2Rpbmc6IHV0Zi04IC0qLQ0KaW1wb3J0IG9zDQppbXBvcnQgc3lzDQppbXBvcnQgcmUNCg0KIyAtLS0gMS4gU3RhbmRhcmQgbWV0aG9kOiBpbXBvcnQgcmVucHkgLS0tDQp0cnk6DQogICAgaW1wb3J0IHJlbnB5DQogICAgcHJpbnQocmVucHkudmVyc2lvbl90dXBsZVswXSkNCiAgICBzeXMuZXhpdCgwKQ0KZXhjZXB0IEV4Y2VwdGlvbjoNCiAgICBwYXNzICAjIGZhbGxiYWNrIGJlbG93DQoNCmRlZiBkZXRlY3RfZnJvbV9zY3JpcHRfdmVyc2lvbihnYW1lX2Rpcik6DQogICAgIyAxKSBSZW4nUHkgNy84IDogc2NyaXB0X3ZlcnNpb24udHh0DQogICAgcGF0aCA9IG9zLnBhdGguam9pbihnYW1lX2RpciwgInNjcmlwdF92ZXJzaW9uLnR4dCIpDQogICAgaWYgb3MucGF0aC5pc2ZpbGUocGF0aCk6DQogICAgICAgIHRyeToNCiAgICAgICAgICAgIHdpdGggb3BlbihwYXRoLCAiciIpIGFzIGY6DQogICAgICAgICAgICAgICAgY29udGVudCA9IGYucmVhZCgpLnN0cmlwKCkNCg0KICAgICAgICAgICAgIyBUdXBsZSBmb3JtYXQgOiAoOCwgMSwgMCkNCiAgICAgICAgICAgIG0gPSByZS5zZWFyY2gocidcKFxzKihcZCspXHMqLCcsIGNvbnRlbnQpDQogICAgICAgICAgICBpZiBtOg0KICAgICAgICAgICAgICAgIHJldHVybiBpbnQobS5ncm91cCgxKSkNCg0KICAgICAgICAgICAgIyBTaW1wbGUgZm9ybWF0IDogOC4xLjAgb3UgOA0KICAgICAgICAgICAgbSA9IHJlLm1hdGNoKHInXHMqKFxkKyknLCBjb250ZW50KQ0KICAgICAgICAgICAgaWYgbToNCiAgICAgICAgICAgICAgICByZXR1cm4gaW50KG0uZ3JvdXAoMSkpDQoNCiAgICAgICAgZXhjZXB0IEV4Y2VwdGlvbjoNCiAgICAgICAgICAgIHBhc3MNCg0KICAgICMgMikgUmVuJ1B5IDYgOiByZW5weS92ZXJzaW9uLnB5DQogICAgdmVyc2lvbl9weSA9IG9zLnBhdGguam9pbihnYW1lX2RpciwgInJlbnB5IiwgInZlcnNpb24ucHkiKQ0KICAgIGlmIG9zLnBhdGguaXNmaWxlKHZlcnNpb25fcHkpOg0KICAgICAgICB0cnk6DQogICAgICAgICAgICB3aXRoIG9wZW4odmVyc2lvbl9weSwgInIiKSBhcyBmOg0KICAgICAgICAgICAgICAgIGNvbnRlbnQgPSBmLnJlYWQoKQ0KDQogICAgICAgICAgICAjIHZlcnNpb24gPSAiNi45OS4xNCINCiAgICAgICAgICAgIG0gPSByZS5zZWFyY2gocid2ZXJzaW9uXHMqPVxzKiIoXGQrKScsIGNvbnRlbnQpDQogICAgICAgICAgICBpZiBtOg0KICAgICAgICAgICAgICAgIHJldHVybiBpbnQobS5ncm91cCgxKSkNCg0KICAgICAgICBleGNlcHQgRXhjZXB0aW9uOg0KICAgICAgICAgICAgcGFzcw0KDQogICAgcmV0dXJuIE5vbmUNCg0KDQpkZWYgZGV0ZWN0X2Zyb21fcnB5YyhnYW1lX2Rpcik6DQogICAgIiIiDQogICAgUmVhZHMgdGhlIG1hZ2ljIG51bWJlciBvZiAucnB5YyAvIC5ycHltYyBmaWxlcy4NCiAgICBSZW4nUHkgNjogbWFnaWMg4oCcUkVOUFkgUlBDMeKAnSAgLT4gbWFqb3IgNiAoYW5kIHNvbWUgZWFybHkgNykNCiAgICBSZW4nUHkgNzogbWFnaWMg4oCcUkVOUFkgUlBDMuKAnSAgLT4gbWFqb3IgNw0KICAgIFJlbidQeSA4OiBtYWdpYyDigJxSRU5QWSBSUEMy4oCdICB3aXRoIFB5dGhvbiAzIChjYW5ub3QgYmUgZWFzaWx5IGRpc3Rpbmd1aXNoZWQNCiAgICAgICAgICAgICAgICBmcm9tIDcgdXNpbmcgbWFnaWMgYWxvbmUsIG90aGVyIG1ldGhvZHMgYXJlIHVzZWQgdG8gY29tcGxldGUgdGhlIHByb2Nlc3MpDQogICAgTm90ZTogc29tZSBlYXJseSBSZW4nUHkgNyBtYXkgc3RpbGwgdXNlIOKAnFJFTlBZIFJQQzHigJ0gbWFnaWMsIGJ1dCB0aGV5IGFyZSByYXJlIGFuZCB3ZSBwcmlvcml0aXplIHRoZSBtb3JlIGNvbW1vbiBjYXNlLg0KICAgICIiIg0KICAgIG1hZ2ljX21hcCA9IHsNCiAgICAgICAgYiJSRU5QWSBSUEMxIjogNiwNCiAgICAgICAgYiJSRU5QWSBSUEMyIjogNywgICMgY2FuIGFsc28gYmUgOA0KICAgIH0NCiAgICBmb3Igcm9vdCwgZGlycywgZmlsZXMgaW4gb3Mud2FsayhnYW1lX2Rpcik6DQogICAgICAgIGZvciBmbmFtZSBpbiBmaWxlczoNCiAgICAgICAgICAgIGlmIGZuYW1lLmVuZHN3aXRoKCIucnB5YyIpIG9yIGZuYW1lLmVuZHN3aXRoKCIucnB5bWMiKToNCiAgICAgICAgICAgICAgICBmcGF0aCA9IG9zLnBhdGguam9pbihyb290LCBmbmFtZSkNCiAgICAgICAgICAgICAgICB0cnk6DQogICAgICAgICAgICAgICAgICAgIHdpdGggb3BlbihmcGF0aCwgInJiIikgYXMgZjoNCiAgICAgICAgICAgICAgICAgICAgICAgIGhlYWRlciA9IGYucmVhZCgxMCkNCiAgICAgICAgICAgICAgICAgICAgZm9yIG1hZ2ljLCBtYWpvciBpbiBtYWdpY19tYXAuaXRlbXMoKToNCiAgICAgICAgICAgICAgICAgICAgICAgIGlmIGhlYWRlci5zdGFydHN3aXRoKG1hZ2ljKToNCiAgICAgICAgICAgICAgICAgICAgICAgICAgICByZXR1cm4gbWFqb3INCiAgICAgICAgICAgICAgICBleGNlcHQgRXhjZXB0aW9uOg0KICAgICAgICAgICAgICAgICAgICBjb250aW51ZQ0KICAgIHJldHVybiBOb25lDQoNCg0KZGVmIGRldGVjdF9mcm9tX2V4ZWN1dGFibGUoZ2FtZV9kaXIpOg0KICAgICIiIg0KICAgIExvb2sgZm9yIHZlcnNpb24gY2x1ZXMgaW4gdGhlIGV4ZWN1dGFibGVzL2xpYnMgcHJlc2VudA0KICAgIGluIHRoZSBnYW1lIGZvbGRlciAoc3RyaW5ncyDigJw3LuKAnSBvciDigJw4LuKAnSBjbG9zZSB0byDigJxSZW4nUHnigJ0pLg0KICAgICIiIg0KICAgIGJhc2UgPSBvcy5wYXRoLmRpcm5hbWUoZ2FtZV9kaXIpICAjIHBhcmVudCBmb2xkZXIgb2YgdGhlIGdhbWUvIGZvbGRlcg0KICAgIHNlYXJjaF9kaXJzID0gW2Jhc2UsIGdhbWVfZGlyXQ0KICAgIHBhdHRlcm5zID0gWw0KICAgICAgICAocmUuY29tcGlsZShyIlJlbi4/UHlccysoXGQpXC5cZCIpLCBOb25lKSwNCiAgICAgICAgKHJlLmNvbXBpbGUociJyZW5weVtfXC1dKFxkKVwuXGQiKSwgcmUuSUdOT1JFQ0FTRSksDQogICAgXQ0KICAgIGZvciBzZGlyIGluIHNlYXJjaF9kaXJzOg0KICAgICAgICBmb3IgZm5hbWUgaW4gb3MubGlzdGRpcihzZGlyKToNCiAgICAgICAgICAgIGZwYXRoID0gb3MucGF0aC5qb2luKHNkaXIsIGZuYW1lKQ0KICAgICAgICAgICAgaWYgbm90IG9zLnBhdGguaXNmaWxlKGZwYXRoKToNCiAgICAgICAgICAgICAgICBjb250aW51ZQ0KICAgICAgICAgICAgIyBPbmx5IHNtYWxsIHRleHQgb3IgbG9nIGZpbGVzIGFyZSByZWFkLg0KICAgICAgICAgICAgaWYgZm5hbWUuZW5kc3dpdGgoKCIudHh0IiwgIi5sb2ciLCAiLmluaSIsICIuY2ZnIiwgIi5qc29uIikpOg0KICAgICAgICAgICAgICAgIHRyeToNCiAgICAgICAgICAgICAgICAgICAgd2l0aCBvcGVuKGZwYXRoLCAiciIpIGFzIGY6DQogICAgICAgICAgICAgICAgICAgICAgICBjb250ZW50ID0gZi5yZWFkKDQwOTYpDQogICAgICAgICAgICAgICAgICAgIGZvciBwYXQsIGZsYWdzIGluIHBhdHRlcm5zOg0KICAgICAgICAgICAgICAgICAgICAgICAgbSA9IHBhdC5zZWFyY2goY29udGVudCkNCiAgICAgICAgICAgICAgICAgICAgICAgIGlmIG06DQogICAgICAgICAgICAgICAgICAgICAgICAgICAgbWFqb3IgPSBpbnQobS5ncm91cCgxKSkNCiAgICAgICAgICAgICAgICAgICAgICAgICAgICBpZiBtYWpvciBpbiAoNiwgNywgOCk6DQogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIHJldHVybiBtYWpvcg0KICAgICAgICAgICAgICAgIGV4Y2VwdCBFeGNlcHRpb246DQogICAgICAgICAgICAgICAgICAgIHBhc3MNCiAgICByZXR1cm4gTm9uZQ0KDQoNCmRlZiBkZXRlY3RfZnJvbV9hcmNoaXZlKGdhbWVfZGlyKToNCiAgICAiIiINCiAgICBJbnNwZWN0IHRoZSAucnBhIGFyY2hpdmVzIHRvIGRldGVjdCB0aGUgdmVyc2lvbi4NCiAgICBSUEEtMS4wIC0+IFJlbidQeSA2IGVhcmx5DQogICAgUlBBLTIuMCAtPiBSZW4nUHkgNg0KICAgIFJQQS0zLjAgLT4gUmVuJ1B5IDYvNw0KICAgIFJQQU4zLjAgLT4gUmVuJ1B5IDggKG5ldyBuZXV0cm9uIGFyY2hpdmUpDQogICAgWmlYLTEyQSAtPiBSZW4nUHkgOCAobmV3IG5ldXRyb24gYXJjaGl2ZSkNCiAgICBaaVgtMTJCIC0+IFJlbidQeSA4IChuZXcgbmV1dHJvbiBhcmNoaXZlKQ0KICAgICIiIg0KICAgIHJwYV9tYWpvcl9tYXAgPSB7DQogICAgICAgIGIiUlBBLTEuMCI6IDYsDQogICAgICAgIGIiUlBBLTIuMCI6IDYsDQogICAgICAgIGIiUlBBLTMuMCI6IDcsICAgIyBNYXliZSA2IGFzIHdlbGwsIGJ1dCB3ZSdsbCByZWZpbmUgaXQgbGF0ZXIuDQogICAgICAgIGIiUlBBTjMuMCI6IDgsDQogICAgICAgIGIiWmlYLTEyQSI6IDgsDQogICAgICAgIGIiWmlYLTEyQiI6IDgsDQogICAgfQ0KICAgIGZvdW5kID0gTm9uZQ0KICAgIGZvciBmbmFtZSBpbiBvcy5saXN0ZGlyKGdhbWVfZGlyKToNCiAgICAgICAgaWYgbm90IGZuYW1lLmVuZHN3aXRoKCIucnBhIik6DQogICAgICAgICAgICBjb250aW51ZQ0KICAgICAgICBmcGF0aCA9IG9zLnBhdGguam9pbihnYW1lX2RpciwgZm5hbWUpDQogICAgICAgIHRyeToNCiAgICAgICAgICAgIHdpdGggb3BlbihmcGF0aCwgInJiIikgYXMgZjoNCiAgICAgICAgICAgICAgICBoZWFkZXIgPSBmLnJlYWQoOCkNCiAgICAgICAgICAgIGZvciBtYWdpYywgbWFqb3IgaW4gcnBhX21ham9yX21hcC5pdGVtcygpOg0KICAgICAgICAgICAgICAgIGlmIGhlYWRlci5zdGFydHN3aXRoKG1hZ2ljKToNCiAgICAgICAgICAgICAgICAgICAgIyBXZSBrZWVwIHRoZSBoaWdoZXN0IG1ham9yIGZvdW5kLg0KICAgICAgICAgICAgICAgICAgICBpZiBmb3VuZCBpcyBOb25lIG9yIG1ham9yID4gZm91bmQ6DQogICAgICAgICAgICAgICAgICAgICAgICBmb3VuZCA9IG1ham9yDQogICAgICAgIGV4Y2VwdCBFeGNlcHRpb246DQogICAgICAgICAgICBwYXNzDQogICAgcmV0dXJuIGZvdW5kDQoNCg0KZGVmIGRldGVjdF9yZW5weV9tYWpvcihnYW1lX3BhdGgpOg0KICAgICIiIg0KICAgIERldGVjdHMgdGhlIG1ham9yIFJlbidQeSB2ZXJzaW9uICg2LCA3LCBvciA4KSBmcm9tIHRoZSBnYW1lIHBhdGguDQogICAgZ2FtZV9wYXRoIGNhbiBiZSB0aGUgZ2FtZSdzIHJvb3QgZm9sZGVyIG9yIHRoZSDigJxnYW1lL+KAnSBzdWJmb2xkZXIuDQogICAgIiIiDQogICAgIyBOb3JtYWxpemU6IHdlIHdhbnQgdGhlIOKAnGdhbWUv4oCdIGZvbGRlcg0KICAgIGlmIG9zLnBhdGguYmFzZW5hbWUoZ2FtZV9wYXRoKSA9PSAiZ2FtZSI6DQogICAgICAgIGdhbWVfZGlyID0gZ2FtZV9wYXRoDQogICAgZWxzZToNCiAgICAgICAgY2FuZGlkYXRlID0gb3MucGF0aC5qb2luKGdhbWVfcGF0aCwgImdhbWUiKQ0KICAgICAgICBpZiBvcy5wYXRoLmlzZGlyKGNhbmRpZGF0ZSk6DQogICAgICAgICAgICBnYW1lX2RpciA9IGNhbmRpZGF0ZQ0KICAgICAgICBlbHNlOg0KICAgICAgICAgICAgZ2FtZV9kaXIgPSBnYW1lX3BhdGggICMgd2UgdHJ5IGRpcmVjdGx5DQoNCiAgICBpZiBub3Qgb3MucGF0aC5pc2RpcihnYW1lX2Rpcik6DQogICAgICAgIHByaW50KCJFUlJPUjogZGlyZWN0b3J5IG5vdCBmb3VuZDoge30iLmZvcm1hdChnYW1lX2RpcikpDQogICAgICAgIHN5cy5leGl0KDEpDQoNCiAgICAjIDEuIHNjcmlwdF92ZXJzaW9uLnR4dCAocHJpb3JpdHkgYnV0IG9wdGlvbmFsKQ0KICAgIG1ham9yID0gZGV0ZWN0X2Zyb21fc2NyaXB0X3ZlcnNpb24oZ2FtZV9kaXIpDQogICAgaWYgbWFqb3IgaXMgbm90IE5vbmU6DQogICAgICAgIHJldHVybiBtYWpvcg0KDQogICAgIyAyLiBBcmNoaXZlcyAucnBhIChSZWxpYWJsZSBzaWduYXR1cmVzIGZvciBSZW4nUHkgOCkNCiAgICBtYWpvciA9IGRldGVjdF9mcm9tX2FyY2hpdmUoZ2FtZV9kaXIpDQogICAgaWYgbWFqb3IgaXMgbm90IE5vbmU6DQogICAgICAgICMgUlBBLTMuMCBjYW4gYmUgNiBvciA3OyB3ZSByZWZpbmUgaXQgd2l0aCB0aGUgLnJweWMgZmlsZXMuDQogICAgICAgIGlmIG1ham9yID09IDc6DQogICAgICAgICAgICBycHljX21ham9yID0gZGV0ZWN0X2Zyb21fcnB5YyhnYW1lX2RpcikNCiAgICAgICAgICAgIGlmIHJweWNfbWFqb3IgaXMgbm90IE5vbmU6DQogICAgICAgICAgICAgICAgcmV0dXJuIHJweWNfbWFqb3INCiAgICAgICAgcmV0dXJuIG1ham9yDQoNCiAgICAjIDMuIC5ycHljIGZpbGVzICh2ZXJ5IHJlbGlhYmxlIGZvciBSZW4nUHkgNiBhbmQgN"
    <nul set /p="ywgYnV0IGRvIG5vdCBkaXN0aW5ndWlzaCBiZXR3ZWVuIDcgYW5kIDgpOg0KICAgIG1ham9yID0gZGV0ZWN0X2Zyb21fcnB5YyhnYW1lX2RpcikNCiAgICBpZiBtYWpvciBpcyBub3QgTm9uZToNCiAgICAgICAgcmV0dXJuIG1ham9yDQoNCiAgICAjIDQuIFRleHQgZmlsZXMgaW4gdGhlIHJvb3QgZm9sZGVyIChtYXkgY29udGFpbiB2ZXJzaW9uIGluZm8sIGVzcGVjaWFsbHkgZm9yIFJlbidQeSA4KToNCiAgICBtYWpvciA9IGRldGVjdF9mcm9tX2V4ZWN1dGFibGUoZ2FtZV9kaXIpDQogICAgaWYgbWFqb3IgaXMgbm90IE5vbmU6DQogICAgICAgIHJldHVybiBtYWpvcg0KDQogICAgcmV0dXJuIE5vbmUNCg0KDQpkZWYgbWFpbigpOg0KICAgIGlmIGxlbihzeXMuYXJndikgPCAyOg0KICAgICAgICBwcmludCgiVXNhZ2U6IHt9IDxnYW1lX3BhdGg+Ii5mb3JtYXQoc3lzLmFyZ3ZbMF0pKQ0KICAgICAgICBzeXMuZXhpdCgxKQ0KDQogICAgZ2FtZV9wYXRoID0gc3lzLmFyZ3ZbMV0NCg0KICAgIG1ham9yID0gZGV0ZWN0X3JlbnB5X21ham9yKGdhbWVfcGF0aCkNCg0KICAgIGlmIG1ham9yIGlzIE5vbmU6DQogICAgICAgIHByaW50KCJFUlJPUjogaW1wb3NzaWJsZSB0byBkZXRlY3QgUmVuJ1B5IHZlcnNpb24gaW4gOiB7fSIuZm9ybWF0KGdhbWVfcGF0aCkpDQogICAgICAgIHN5cy5leGl0KDEpDQoNCiAgICBpZiBtYWpvciBub3QgaW4gKDYsIDcsIDgpOg0KICAgICAgICBwcmludCgiRVJST1I6IHVuZXhwZWN0ZWQgUmVuJ1B5IHZlcnNpb24gZGV0ZWN0ZWQgOiB7fSIuZm9ybWF0KG1ham9yKSkNCiAgICAgICAgc3lzLmV4aXQoMSkNCg0KICAgIHByaW50KG1ham9yKQ0KDQoNCmlmIF9fbmFtZV9fID09ICJfX21haW5fXyI6DQogICAgbWFpbigpDQo="
)

call :pwsh_exp "!renpyvers2.%LNG%!..." "%detect_renpy_version%"
if not exist "%detect_renpy_version%" (
    call :elog "%NOK%"
    call :elog .
    call :elog "!FCREATE.%LNG%! %YEL%%detect_renpy_version%%RES%. !UNACONT.%LNG%!"
    call :elog .
    pause>nul|set /p=".      !ANYKEY.%LNG%!..."

    call :exitn 3
) else (
    if %DEBUGLEVEL% GEQ 1 echo "%PYTHONHOME%python.exe" %PYNOASSERT% "%detect_renpy_version% "%WORKDIR%" >> "%UNRENLOG%"
    "%PYTHONHOME%python.exe" %PYNOASSERT% "%detect_renpy_version%" "%WORKDIR%" > "%TEMP%\renpy_version.tmp"
    set /p RENPYVERSION=<"%TEMP%\renpy_version.tmp"
    del "%TEMP%\renpy_version.tmp"
    if not defined RENPYVERSION (
        call :elog "%NOK%"
        call :elog .
        call :elog "    !renpyvers3.%LNG%!"
        call :elog "    !renpyvers4.%LNG%!. !UNACONT.%LNG%!"
        call :elog .
        pause>nul|set /p=".      !ANYKEY.%LNG%!..."

        call :exitn 3
    ) else (
        call :elog "%OK%" "!renpyvers1.%LNG%! %YEL%!RENPYVERSION!%RES%"
    )
)
if %DEBUGLEVEL% GEQ 1 echo del /f /q "%detect_renpy_version%" >> "%UNRENLOG%"
del /f /q "%detect_renpy_version%" %DEBUGREDIR%

:: Set the colors and default choice
if %RENPYVERSION% GEQ 8 (
    set "ESC1=%RED%"
    set "ESC2=%GRE%"
    set "def=2"
) else if %RENPYVERSION% LEQ 7 (
    set "ESC1=%GRE%"
    set "ESC2=%RED%"
    set "def=1"
) else (
    set "ESC1=%YEL%"
    set "ESC2=%YEL%"
    set "def=x"
)

:: Auto-launch if it's started with a WORKDIR argument
if "%LAUNCHED_WDIR%" == "1" (
    :: Handle single choices
    if "!def!" == "1" (
        call "%SCRIPTDIR%UnRen-legacy.bat" "!WORKDIR!"
        goto exitn
    ) else if "!def!" == "2" (
        call "%SCRIPTDIR%UnRen-current.bat" "!WORKDIR!"
        goto exitn
    )
)

:: Set the proper argument for py.exe according to the Ren'Py version detected
set "PYVERSION="
if %RENPYVERSION% GEQ 8 if defined PYVERSION3 (
    set "PYVERSION=%PYVERSION3%"
)
if %RENPYVERSION% LEQ 7 if defined PYVERSION2 (
    set "PYVERSION=%PYVERSION2%"
)

:: Display all the variables in the log for debugging purpose
call :DisplayVars "Init phase"


:: Splash screen
:menu
set "sscreen1.en=is no longer a script for processing RPYC and RPA but a launcher,"
set "sscreen1.fr=n'est plus un script pour les traitements des RPYC et RPA mais un lanceur,"
set "sscreen1.es=ya no es un script para procesar RPYC y RPA, sino un lanzador."
set "sscreen1.it=Non è più uno script per elaborare RPYC e RPA, ma un launcher,"
set "sscreen1.de=ist kein Skript mehr zur Verarbeitung von RPYC und RPA, sondern ein Launcher,"
set "sscreen1.ru=больше не является скриптом для обработки RPYC и RPA, а является программой запуска,"
set "sscreen1.zh=不再是一个用于处理 RPYC 和 RPA 的脚本，而是一个启动器，"

set "sscreen2.en=to launch UnRen-legacy.bat or UnRen-current.bat."
set "sscreen2.fr=pour exécuter UnRen-legacy.bat ou UnRen-current.bat."
set "sscreen2.es=para lanzar UnRen-legacy.bat o UnRen-current.bat."
set "sscreen2.it=per lanciare UnRen-legacy.bat o UnRen-current.bat."
set "sscreen2.de=um UnRen-legacy.bat oder UnRen-current.bat zu starten."
set "sscreen2.ru=для запуска UnRen-legacy.bat или UnRen-current.bat."
set "sscreen2.zh=用于启动 UnRen-legacy.bat 或 UnRen-current.bat。"

set "sscreen3.en=Made with %RED%<3%YEL% for the fans - by JoeLurmel @ f95zone.to"
set "sscreen3.fr=Fait avec %RED%<3%YEL% pour les fans - par JoeLurmel @ f95zone.to"
set "sscreen3.es=Hecho con %RED%<3%YEL% para los fans - por JoeLurmel @ f95zone.to"
set "sscreen3.it=Fatto con %RED%<3%YEL% per i fan - di JoeLurmel @ f95zone.to"
set "sscreen3.de=Hergestellt mit %RED%<3%YEL% für die Fans - von JoeLurmel @ f95zone.to"
set "sscreen3.ru=Сделано с %RED%<3%YEL% для фанатов - JoeLurmel @ f95zone.to"
set "sscreen3.zh=由 JoeLurmel @ f95zone.to 为粉丝制作 - %RED%<3%YEL%"

if "%NOCLS%" == "0" cls
REM call :center "%ORA%__________________________________________________________________________________%RES%"
call :center "%ORA%╔═══════════════════════════════════════════════════════════════════════════════════╗%RES%"
echo               %ORA%    __  __      ____                  __          __%RES%
echo               %ORA%   / / / /___  / __ \___  ____       / /_  ____ _/ /_%RES%
echo               %ORA%  / / / / __ \/ /_/ / _ \/ __ \     / __ \/ __ ^`/ __/%RES%
echo               %ORA% / /_/ / / / / __  /  __/ / / / _  / /_/ / /_/ / /_%RES%
echo               %ORA% \____/_/ /_/_/  \_\___/_/ /_/ (_) \_.__/\__^,_/\__/ - %NAME% %CYA%%VERSION%%RES%
echo.
echo                 !sscreen1.%LNG%!
echo                 !sscreen2.%LNG%!
echo.
call :center "%YEL%!INCASEOF.%LNG%!%RES%"
call :center "%MAG%%URL_REF%%RES%"
echo.
call :center "%YEL%!sscreen3.%LNG%!%RES%"
echo.
set /a rand=%random% %%17
if %rand% == 0 call :center "“ Hack the planet! ” – Dade Murphy"
if %rand% == 1 call :center "“ Resistance is futile. ” – Borg"
if %rand% == 2 call :center "“ There is no spoon. ” – Neo"
if %rand% == 3 call :center "“ I'm in. ” – Mr. Robot"
if %rand% == 4 call :center "“ All your base are belong to us. ” – CATS"
if %rand% == 5 call :center "“ Would you like to know more? ” – Various"
if %rand% == 6 call :center "“ This message will self-destruct in 5... 4... 3... ” – Impossible Mission"
if %rand% == 7 call :center "“ If you're reading this, you're already better than 90% of users... ”"
if %rand% == 8 call :center "“ I'm not a hacker. I'm a code poet. ” – Various"
if %rand% == 9 call :center "“ Welcome to the command line. Abandon all GUIs, ye who enter here. ”"
if %rand% == 10 call :center "“ rm -rf / — because chaos is an art form. ”"
if %rand% == 11 call :center "“ This script runs faster than your Wi-Fi on a Monday. ”"
if %rand% == 12 call :center "“ The cake is a lie. ” – Portal"
if %rand% == 13 call :center "“ I am Groot. ” – Groot"
if %rand% == 14 call :center "“ Do or do not. There is no try. ” – Yoda"
if %rand% == 15 call :center "“ I know kung fu. ” – Neo"
if %rand% == 16 call :center "“ You have been recruited by the Star League to defend the frontier. ” – The Last Starfighter"
REM call :center "%ORA%__________________________________________________________________________________%RES%"
call :center "%ORA%╚═══════════════════════════════════════════════════════════════════════════════════╝%RES%"

set "MTITLE.en=Working directory: "
set "MTITLE.fr=Répertoire de travail : "
set "MTITLE.es=Directorio de trabajo: "
set "MTITLE.it=Directory di lavoro: "
set "MTITLE.de=Aktuelles Verzeichnis: "
set "MTITLE.ru=Рабочий каталог: "
set "MTITLE.zh=工作目录："

set "choice1.en=Launch UnRen-legacy.bat."
set "choice1.fr=Lancer UnRen-legacy.bat."
set "choice1.es=Lanzar UnRen-legacy.bat."
set "choice1.it=Eseguire UnRen-legacy.bat."
set "choice1.de=UnRen-legacy.bat ausführen."
set "choice1.ru=Запустить UnRen-legacy.bat."
set "choice1.zh=启动 UnRen-legacy.bat。"

set "choice2.en=Launch UnRen-current.bat."
set "choice2.fr=Lancer UnRen-current.bat."
set "choice2.es=Lanzar UnRen-current.bat."
set "choice2.it=Eseguire UnRen-current.bat."
set "choice2.de=UnRen-current.bat ausführen."
set "choice2.ru=Запустить UnRen-current.bat."
set "choice2.zh=启动 UnRen-current.bat。"

set "minfo1.en=The following options are independent of the Ren'Py version."
set "minfo1.fr=Les options suivantes sont indépendantes de la version de Ren'Py."
set "minfo1.es=Las siguientes opciones son independientes de la versión de Ren'Py."
set "minfo1.it=Le seguenti opzioni sono indipendenti dalla versione di Ren'Py."
set "minfo1.de=Die folgenden Optionen sind unabhängig von der Ren'Py-Version."
set "minfo1.ru=Следующие параметры независимы от версии Ren'Py."
set "minfo1.zh=以下选项与 Ren'Py 版本无关。"

set "choicea.en=Enable Console (Shift+O) and Developer menu (Shift+D)."
set "choicea.fr=Activer la Console (Maj+O) et le menu Développeur (Maj+D)."
set "choicea.es=Activar la Consola (Mayús+O) y el menú de desarrollador (Mayús+D)."
set "choicea.it=Attiva la Console (Maiusc+O) e il menu sviluppatore (Maiusc+D)."
set "choicea.de=Aktiviert die Konsole (Umschalt+O) und das Entwicklermenü (Umschalt+D)."
set "choicea.ru=Активируйте консоль (Shift+O) и меню «Разработчик» (Shift+D)."
set "choicea.zh=启用控制台（Shift+O）和开发者菜单（Shift+D）"

set "choiceb.en=Enable debug mode %RED%(Can break your game)%RES%."
set "choiceb.fr=Activer le mode debug %RED%(peut casser le jeu)%RES%."
set "choiceb.es=Activar el modo debug %RED%(puede romper el juego)%RES%."
set "choiceb.it=Attiva la modalità debug %RED%(può rompere il gioco)%RES%."
set "choiceb.de=Aktiviert Sie den Debug-Modus %RED%(kann Ihr Spiel beschädigen)%RES%."
set "choiceb.ru=Включить режим отладки %RED%(может сломать игру)%RES%."
set "choiceb.zh=启用调试模式 %RED%（可能会破坏游戏）%RES%"

set "choicec.en=Force Skip (Unseen Text, After Choices)."
set "choicec.fr=Forcer Skip (Unseen Text, After Choices)."
set "choicec.es=Forzar Skip (Unseen Text, After Choices)."
set "choicec.it=Forza Skip (Unseen Text, After Choices)."
set "choicec.de=Zwangsweise überspringen (Unseen Text, After Choices)."
set "choicec.ru=Принудить Skip (Unseen Text, After Choices)."
set "choicec.zh=强制跳过（未读文本、选择后）"

set "choiced.en=Force all Skip (Unseen Text, After Choices, Transitions)."
set "choiced.fr=Forcer tous les Skip (Unseen Text, After Choices, Transitions)."
set "choiced.es=Forzar todos los Skip (Unseen Text, After Choices, Transitions)."
set "choiced.it=Forza tutti gli Skip (Unseen Text, After Choices, Transitions)."
set "choiced.de=Zwangsweise überspringen (Unseen Text, After Choices, Transitions)."
set "choiced.ru=Принудить все пропуски (Unseen Text, After Choices, Transitions)."
set "choiced.zh=强制全部跳过（未读文本、选择后、过渡）"

set "choicee.en=Force enable rollback (scroll wheel)."
set "choicee.fr=Activer le 'Rollback' (molette de défilement)."
set "choicee.es=Forzar la activación del 'Rollback' (rueda de desplazamiento)."
set "choicee.it=Forza l'attivazione del 'Rollback' (rotella di scorrimento)."
set "choicee.de=Aktivieren Sie 'Rollback' (Scrollrad)."
set "choicee.ru=Принудить активацию 'Rollback' (колесо прокрутки)."
set "choicee.zh=强制启用 'Rollback'（滚轮）"

set "choicef.en=Enable 'Quick Save' (Shift+S, F5) and 'Quick Load' (Shift+L, F9)."
set "choicef.fr=Activer 'Quick Save' (Shift+S, F5) et 'Quick Load' (Shift+L, F9)."
set "choicef.es=Activar 'Quick Save' (Shift+S, F5) y 'Quick Load' (Shift+L, F9)."
set "choicef.it=Attiva 'Quick Save' (Shift+S, F5) e 'Quick Load' (Shift+L, F9)."
set "choicef.de=Aktivieren Sie 'Quick Save' (Shift+S, F5) und 'Quick Load' (Shift+L, F9)."
set "choicef.ru=Включить 'Quick Save' (Shift+S, F5) и 'Quick Load' (Shift+L, F9)."
set "choicef.zh=启用 'Quick Save' (Shift+S, F5) 和 'Quick Load' (Shift+L, F9)。"

set "choiceg.en=Try forcing the 'Quick Menu' to display."
set "choiceg.fr=Essayer de forcer l'affichage du 'Quick Menu'."
set "choiceg.es=Intenta forzar la visualización del 'Quick Menu'."
set "choiceg.it=Prova a forzare la visualizzazione del 'Quick Menu'."
set "choiceg.de=Versuche, die Anzeige des 'Quick Menu' zu erzwingen."
set "choiceg.ru=Попробуй заставить отобразиться 'Quick Menu'."
set "choiceg.zh=尝试强制显示 'Quick Menu'。"

set "choiceh.en=Download and add Universal Gallery Unlocker ZLZK."
set "choiceh.fr=Télécharger et ajouter le Universal Gallery Unlocker ZLZK."
set "choiceh.es=Descargar y agregar el Universal Gallery Unlocker ZLZK."
set "choiceh.it=Scarica e aggiungi il Universal Gallery Unlocker ZLZK."
set "choiceh.de=Universal Gallery Unlocker ZLZK herunterladen und hinzufügen."
set "choiceh.ru=Скачать и добавить Universal Gallery Unlocker ZLZK."
set "choiceh.zh=下载并添加 ZLZK 的通用画廊解锁器"

set "choicei.en=Download and add Universal Choice Descriptor ZLZK."
set "choicei.fr=Télécharger et ajouter le Universal Choice Descriptor ZLZK."
set "choicei.es=Descargar y agregar el Universal Choice Descriptor ZLZK."
set "choicei.it=Scarica e aggiungi il Universal Choice Descriptor ZLZK."
set "choicei.de=Universal Choice Descriptor ZLZK herunterladen und hinzufügen."
set "choicei.ru=Скачать и добавить Universal Choice Descriptor ZLZK."
set "choicei.zh=下载并添加 ZLZK 的通用选择描述器"

set "choicej.en=Download and add Universal Transparent Text Box Mod by Penfold Mole."
set "choicej.fr=Télécharger et ajouter le Universal Transparent Text Box Mod par Penfold Mole."
set "choicej.es=Descargar y agregar el Universal Transparent Text Box Mod de Penfold Mole."
set "choicej.it=Scarica e aggiungi il Universal Transparent Text Box Mod di Penfold Mole."
set "choicej.de=Universal Transparent Text Box Mod von Penfold Mole herunterladen und hinzufügen."
set "choicej.ru=Скачать и добавить Universal Transparent Text Box Mod от Penfold Mole."
set "choicej.zh=下载并添加 Penfold Mole 的通用透明文本框 Mod"

set "choicek.en=Download and add 0x52_URM by 0x52."
set "choicek.fr=Télécharger et ajouter 0x52_URM de 0x52."
set "choicek.es=Descargar y agregar 0x52_URM de 0x52."
set "choicek.it=Scarica e aggiungi 0x52_URM di 0x52."
set "choicek.de=Lade 0x52_URM von 0x52 herunterladen und hinzufügen."
set "choicek.ru=Скачать и добавить 0x52_URM от 0x52."
set "choicek.zh=下載並加入 0x52_URM by 0x52。"

set "choicel.en=Replace the name of any character name."
set "choicel.fr=Remplacer le nom de n'importe quel personnage."
set "choicel.es=Reemplazar el nombre de cualquier personaje."
set "choicel.it=Sostituire il nome di qualsiasi personaggio."
set "choicel.de=Ersetze den Namen eines beliebigen Charakters."
set "choicel.ru=Заменить имя любого персонажа."
set "choicel.zh=替换任何角色的名字。"

set "choicem.en=Multiple choice in one shot"
set "choicem.fr=Choix multiples en une seule fois"
set "choicem.es=Selección múltiple de una sola vez"
set "choicem.it=Scelta multipla in un colpo solo"
set "choicem.de=Mehrfachauswahl auf einmal"
set "choicem.ru=Множественный выбор за один раз"
set "choicem.zh=一次性应用多个选项"

set "choicen.en=Remove the nasty sync folder in the %YEL%AppData subfolder%RES%."
set "choicen.fr=Supprimer le dossier de synchronisation nuisible dans le %YEL%sous dossier AppData%RES%."
set "choicen.es=Eliminar el carpeta de sincronización peligrosa en el %YEL%subcarpeta AppData%RES%."
set "choicen.it=Rimuovi la cartella di sincronizzazione pericolosa nel %YEL%sotto cartella AppData%RES%."
set "choicen.de=Entferne das schmutzige Synchronisationsverzeichnis im %YEL%Unterverzeichnis AppData%RES%."
set "choicen.ru=Удалить нежелательную папку синхронизации в подпапке %YEL%AppData%RES%."
set "choicen.zh=在 %YEL%AppData%RES% 子文件夹中删除那个不好的同步文件夹。"

set "choicep.en=Add a custom add-on."
set "choicep.fr=Ajouter un add-on personnalisé."
set "choicep.es=Agregar un add-on personalizado."
set "choicep.it=Aggiungi un add-on personalizzato."
set "choicep.de=Eigenes Add-on hinzufügen."
set "choicep.ru=Добавить пользовательский аддон."
set "choicep.zh=添加自定义插件。"

set "choicer.en=Restoration of the original files."
set "choicer.fr=Restauration des fichiers originaux."
set "choicer.es=Recuperación de los archivos originales."
set "choicer.it=Ripristino dei file originali."
set "choicer.de=Wiederherstellung der Originaldateien."
set "choicer.ru=Восстановление исходных файлов."
set "choicer.zh=還原原始檔案。"

set "choices.en=Deleting backups."
set "choices.fr=Suppresion des sauvegardes."
set "choices.es=Eliminación de las copias de seguridad."
set "choices.it=Eliminazione dei backup."
set "choices.de=Löschen der Sicherungskopien."
set "choices.ru=Удаление резервных копий."
set "choices.zh=刪除備份。"

set "choicet.en=Extract text for translation purposes"
set "choicet.fr=Extraire le texte à des fins de traduction"
set "choicet.es=Extraer texto con fines de traducción"
set "choicet.it=Estrai il testo a scopo di traduzione"
set "choicet.de=Text zum Übersetzen extrahieren"
set "choicet.ru=Извлечь текст для перевода"
set "choicet.zh=提取文本用于翻译目的"

set "choiceu.en=Start update check for UnRen and its components."
set "choiceu.fr=Lancer la vérification des mises à jour pour UnRen et ses composants."
set "choiceu.es=Iniciar la verificación de actualizaciones para UnRen y sus componentes."
set "choiceu.it=Avvia il controllo degli aggiornamenti per UnRen e i suoi componenti."
set "choiceu.de=Starten Sie die Update-Prüfung für UnRen und seine Komponenten."
set "choiceu.ru=Начать проверку обновлений для UnRen и его компонентов."
set "choiceu.zh=开始检查 UnRen 及其组件的更新"

set "minfo2.en=The following choices require administrative privileges."
set "minfo2.fr=Les choix suivants nécessitent des privilèges administrateurs."
set "minfo2.es=Las siguientes opciones requieren privilegios administrativos."
set "minfo2.it=Le seguenti opzioni richiedono privilegi amministrativi."
set "minfo2.de=Die folgenden Optionen erfordern administrative Berechtigungen."
set "minfo2.ru=Следующие варианты требуют административных прав."
set "minfo2.zh=以下选项需要管理员权限。"

set "minfo2a.en=The following choices no longer require administrative privileges."
set "minfo2a.fr=Les choix suivants ne nécessitent plus de privilèges administrateurs."
set "minfo2a.es=Las siguientes opciones ya no requieren privilegios administrativos."
set "minfo2a.it=Le seguenti opzioni non richiedono più privilegi amministrativi."
set "minfo2a.de=Die folgenden Optionen erfordern keine administrativen Berechtigungen mehr."
set "minfo2a.ru=Следующие варианты больше не требуют административных прав."
set "minfo2a.zh=以下选项不再需要管理员权限。"

set "choice+.en=Add a right-click menu entry to run the script."
set "choice+.fr=Ajouter une entrée de menu contextuel pour exécuter le script."
set "choice+.es=Agregar una entrada de menú contextual para ejecutar el script."
set "choice+.it=Aggiungi una voce al menu contestuale per eseguire lo script."
set "choice+.de=Fügen Sie einen Eintrag im Kontextmenü hinzu, um das Skript auszuführen."
set "choice+.ru=Добавить элемент контекстного меню для запуска скрипта."
set "choice+.zh=添加右键菜单项以运行脚本。"

set "choice-.en=Remove the right-click menu entry from the registry."
set "choice-.fr=Supprimer l'entrée de menu contextuel du registre."
set "choice-.es=Eliminar la entrada de menú contextual del registro."
set "choice-.it=Rimuovi la voce del menu contestuale dal registro."
set "choice-.de=Einträge im Kontextmenü aus der Registrierung entfernen."
set "choice-.ru=Удалить элемент контекстного меню из реестра."
set "choice-.zh=从注册表中移除右键菜单项。"

set "mquest.en=Your choice (1,2,a-n,p,r,s,t,u,+,-,x by default "
set "mquest.fr=Votre choix (1, 2, a-n, p, r, s, t, u, +, -, x par défaut "
set "mquest.es=Su elección (1,2,a-n,p,r,s,t,u,+,-,x por defecto "
set "mquest.it=La tua scelta (1,2,a-n,p,r,s,t,u,+,-,x predefinito "
set "mquest.de=Ihre Wahl (1,2,a-n,p,r,s,t,u,+,-,x für Standard "
set "mquest.ru=Ваш выбор (1,2,a-n,p,r,s,t,u,+,-,x по умолчанию "
set "mquest.zh=你的选择 (1, 2, a-n, p, r, s, t, u, +, -, 默认为 x): "

set "choicex.en=Exit"
set "choicex.fr=Quitter"
set "choicex.es=Salir"
set "choicex.it=Esci"
set "choicex.de=Beenden"
set "choicex.ru=Выход"
set "choicex.zh=退出"

set "uchoice.en=Unknown choice:"
set "uchoice.fr=Choix inconnu :"
set "uchoice.es=Opción desconocida:"
set "uchoice.it=Scelta sconosciuta:"
set "uchoice.de=Unbekannte Wahl:"
set "uchoice.ru=Неизвестный выбор:"
set "uchoice.zh=未知选择："

:: Menu display
echo.
call :center "!MTITLE.%LNG%!%YEL%%WORKDIR%%RES%"
echo.
echo        1) %ESC1%!choice1.%LNG%!%RES%
echo        2) %ESC2%!choice2.%LNG%!%RES%
echo.
echo        %YEL%!minfo1.%LNG%!%RES%
echo        a) %CYA%!choicea.%LNG%!%RES%
echo        b) %CYA%!choiceb.%LNG%!%RES%
echo        c) %CYA%!choicec.%LNG%!%RES%
echo        d) %CYA%!choiced.%LNG%!%RES%
echo        e) %CYA%!choicee.%LNG%!%RES%
echo        f) %CYA%!choicef.%LNG%!%RES%
echo        g) %CYA%!choiceg.%LNG%!%RES%
echo        h) %CYA%!choiceh.%LNG%!%RES%
echo        i) %CYA%!choicei.%LNG%!%RES%
echo        j) %CYA%!choicej.%LNG%!%RES%
echo        k) %CYA%!choicek.%LNG%!%RES%
echo        l) %CYA%!choicel.%LNG%!%RES%
echo        m) %CYA%!choicem.%LNG%!%RES%
echo        n) %CYA%!choicen.%LNG%!%RES%
echo        p) %CYA%!choicep.%LNG%!%RES%
echo        r) %YEL%!choicer.%LNG%!%RES%
echo        s) %YEL%!choices.%LNG%!%RES%
echo        t) %CYA%!choicet.%LNG%!%RES%
echo        u) %CYA%!choiceu.%LNG%!%RES%
echo.
set OLDREG=0
call :check_old_reg
if %OLDREG% EQU 1 (
    echo        %YEL%!minfo2.%LNG%!%RES%
) else (
    echo        %YEL%!minfo2a.%LNG%!%RES%
)
echo        +) %CYA%!choice+.%LNG%!%RES%
echo        -) %CYA%!choice-.%LNG%!%RES%
echo.
echo        x) %YEL%!choicex.%LNG%!%RES%

set "def.en=[%YEL%%def%%RES%]: "
set "def.fr=[%YEL%%def%%RES%] : "
set "def.es=[%YEL%%def%%RES%]: "
set "def.it=[%YEL%%def%%RES%]: "
set "def.de=[%YEL%%def%%RES%]: "
set "def.ru=[%YEL%%def%%RES%]: "
set "def.zh=[%YEL%%def%%RES%] : "

:: Reading the selection
echo.
echo.
set "OPTION="
set /p "OPTION=!mquest.%LNG%!!def.%LNG%!"
:: Default to the first OPTION if no input is given
if not defined OPTION set "OPTION=%def%"
set "OPTION=%OPTION: =%"
:: Handle single choices
if "%OPTION%" == "1" (
    call "%SCRIPTDIR%UnRen-legacy.bat" "!WORKDIR!"
    goto exitn
)
if "%OPTION%" == "2" (
    call "%SCRIPTDIR%UnRen-current.bat" "!WORKDIR!"
    goto exitn
)
if /i "%OPTION%" == "a" call :console
if /i "%OPTION%" == "b" call :debug
if /i "%OPTION%" == "c" call :skip
if /i "%OPTION%" == "d" call :skipall
if /i "%OPTION%" == "e" call :rollback
if /i "%OPTION%" == "f" call :quick
if /i "%OPTION%" == "g" call :qmenu
if /i "%OPTION%" == "h" call :add_ugu
if /i "%OPTION%" == "i" call :add_ucd
if /i "%OPTION%" == "j" call :add_utbox
if /i "%OPTION%" == "k" call :add_urm
if /i "%OPTION%" == "l" call :replace_anyname
if /i "%OPTION%" == "m" call :multiChoice
if /i "%OPTION%" == "n" call :nasty_sync
if /i "%OPTION%" == "p" call :add_custom_addon
if /i "%OPTION%" == "r" call :restore_files
if /i "%OPTION%" == "s" call :delete_backups
if /i "%OPTION%" == "t" call :extract_text
if /i "%OPTION%" == "u" call :check_update


if "%OPTION%" == "+" call :add_reg
if "%OPTION%" == "-" call :remove_reg

if /i "%OPTION%" == "x" goto exitn

echo.
<nul set /p="%RED%!uchoice.%LNG%! %YEL%%OPTION%%RES%"
echo.
timeout /T 2 %DEBUGREDIR%
goto :menu


:: Drop our console/dev mode enabler into the game folder
:console
set "unren-console=%WORKDIR%\game\unren-console.rpy"

call :elog .
call :elog "!TWADD.%LNG%! %YEL%%unren-console%.%RES%"
call :elog .
call :elog "!INCASEDEL.%LNG%!"
call :elog "%YEL%%unren-console%%RES%"
call :elog "%YEL%%unren-console%c%RES%"

if exist "%unren-console%" (
    call :elog .
    call :elog "%SKIP%" "!APRESENT.%LNG%!"
    call :elog .
) else (
    >"%unren-console%.b64" (
        <nul set /p="IyBNYWRlIGJ5IChTTSkgYWthIEpvZUx1cm1lbCBAIGY5NXpvbmUudG8NCg0KZGVmaW5lIDk5OSBjb25maWcuY29uc29sZSA9IFRydWUNCmRlZmluZSA5OTkgY29uZmlnLmRldmVsb3BlciA9IFRydWUNCg=="
    )
    call :elog .
    call :pwsh_exp "!choicea.%LNG%!.." "%unren-console%"
    if not exist "!unren-console!" (
        call :elog "%NOK%" "!FCREATE.%LNG%! %YEL%%unren-console%%RES%"
        call :elog .
    ) else (
        call :elog "%OK%"
    )
)
timeout /T 1 %DEBUGREDIR%
goto :finish


:: Drop our debug mode enabler into the game folder
:debug
set "unren-debug=%WORKDIR%\game\unren-debug.rpy"

call :elog .
call :elog "!TWADD.%LNG%! %YEL%%unren-debug%.%RES%"
call :elog .
call :elog "!INCASEDEL.%LNG%!%RES%"
call :elog "%YEL%%unren-debug%%RES%"
call :elog "%YEL%%unren-debug%c%RES%"

if exist "%unren-debug%" (
    call :elog .
    call :elog "%SKIP%" "!APRESENT.%LNG%!%RES%"
    call :elog .
) else (
    >"%unren-debug%.b64" (
        <nul set /p="IyBNYWRlIGJ5IChTTSkgYWthIEpvZUx1cm1lbCBAIGY5NXpvbmUudG8NCg0KZGVmaW5lIDk5OSBjb25maWcuZGVidWcgPSBUcnVlDQo="
    )
    call :elog .
    call :pwsh_exp "!choiceb.%LNG%!.." "%unren-debug%"
    if not exist "%unren-debug%" (
        call :elog "%NOK%" "!FCREATE.%LNG%! %YEL%%unren-debug%%RES%"
        call :elog .
    ) else (
        call :elog "%OK%"
    )
)
timeout /T 1 %DEBUGREDIR%
goto :finish


:: Drop our skip file into the game folder
:skip
set "unren-skip=%WORKDIR%\game\unren-skip.rpy"

call :elog .
call :elog "!TWADD.%LNG%! %YEL%%unren-skip%.%RES%"
call :elog .
call :elog "!INCASEDEL.%LNG%!%RES%"
call :elog "%YEL%%unren-skip%%RES%"
call :elog "%YEL%%unren-skip%c%RES%"

if exist "%unren-skip%" (
    call :elog .
    call :elog "%SKIP%" "!APRESENT.%LNG%!%RES%"
    call :elog .
) else (
    >"%unren-skip%.b64" (
        <nul set /p="IyBNYWRlIGJ5IChTTSkgYWthIEpvZUx1cm1lbCBAIGY5NXpvbmUudG8NCg0KaW5pdCA5OTkgcHl0aG9uOg0KDQogICAgIyBNYW5kYXRvcnkNCiAgICBfcHJlZmVyZW5jZXMuYWxsb3dfc2tpcHBpbmcgPSBUcnVlDQogICAgcmVucHkuY29uZmlnLmFsbG93X3NraXBwaW5nID0gVHJ1ZQ0KDQogICAgdHJ5Og0KICAgICAgICBjb25maWcua2V5bWFwWydza2lwJ10gPSBbICdLX0xDVFJMJywgJ0tfUkNUUkwnIF0NCiAgICBleGNlcHQ6DQogICAgICAgIHBhc3MNCg0KICAgICMgVW5zZWVuIFRleHQNCiAgICBfcHJlZmVyZW5jZXMuc2tpcF91bnNlZW4gPSBUcnVlDQogICAgcmVucHkuZ2FtZS5wcmVmZXJlbmNlcy5za2lwX3Vuc2VlbiA9IFRydWUNCg0KICAgICMgQWZ0ZXIgQ2hvaWNlcw0KICAgIF9wcmVmZXJlbmNlcy5za2lwX2FmdGVyX2Nob2ljZXMgPSBUcnVlDQogICAgcmVucHkuZ2FtZS5wcmVmZXJlbmNlcy5za2lwX2FmdGVyX2Nob2ljZXMgPSBUcnVlDQoNCiAgICAjIEFsbG93IEZhc3Qgc2tpcHBpbmcNCiAgICByZW5weS5jb25maWcuZmFzdF9za2lwcGluZyA9IFRydWUNCg0KICAgICMgRnJvbSBKYXNvbjogQ29taW5nIG9mIGFnZQ0KICAgIHBlcnNpc3RlbnQuZ2FtZV9jb21wbGV0ZWQgPSBUcnVlDQo="
    )
    call :elog .
    call :pwsh_exp "!choicec.%LNG%!.."  "%unren-skip%"
    if not exist "%unren-skip%" (
        call :elog "%NOK%" "!FCREATE.%LNG%! %YEL%%unren-skip%%RES%"
        call :elog .
    ) else (
        call :elog "%OK%"
    )
)
timeout /T 1 %DEBUGREDIR%
goto :finish


:: Drop our skip file into the game folder
:skipall
set "unren-skipall=%WORKDIR%\game\unren-skipall.rpy"

call :elog .
call :elog "!TWADD.%LNG%! %YEL%%unren-skipall%.%RES%"
call :elog .
call :elog "!INCASEDEL.%LNG%!%RES%"
call :elog "%YEL%%unren-skipall%%RES%"
call :elog "%YEL%%unren-skipall%c%RES%"

if exist "%unren-skipall%" (
    call :elog .
    call :elog "%SKIP%" "!APRESENT.%LNG%!%RES%"
    call :elog .
) else (
    >"%unren-skipall%.b64" (
        <nul set /p="IyBNYWRlIGJ5IChTTSkgYWthIEpvZUx1cm1lbCBAIGY5NXpvbmUudG8NCg0KaW5pdCA5OTkgcHl0aG9uOg0KDQogICAgIyBNYW5kYXRvcnkNCiAgICBfcHJlZmVyZW5jZXMuYWxsb3dfc2tpcHBpbmcgPSBUcnVlDQogICAgcmVucHkuY29uZmlnLmFsbG93X3NraXBwaW5nID0gVHJ1ZQ0KDQogICAgdHJ5Og0KICAgICAgICBjb25maWcua2V5bWFwWydza2lwJ10gPSBbICdLX0xDVFJMJywgJ0tfUkNUUkwnIF0NCiAgICBleGNlcHQ6DQogICAgICAgIHBhc3MNCg0KICAgICMgVW5zZWVuIFRleHQNCiAgICBfcHJlZmVyZW5jZXMuc2tpcF91bnNlZW4gPSBUcnVlDQogICAgcmVucHkuZ2FtZS5wcmVmZXJlbmNlcy5za2lwX3Vuc2VlbiA9IFRydWUNCg0KICAgICMgQWZ0ZXIgQ2hvaWNlcw0KICAgIF9wcmVmZXJlbmNlcy5za2lwX2FmdGVyX2Nob2ljZXMgPSBUcnVlDQogICAgcmVucHkuZ2FtZS5wcmVmZXJlbmNlcy5za2lwX2FmdGVyX2Nob2ljZXMgPSBUcnVlDQoNCiAgICAjIFRyYW5zaXRpb25zDQogICAgX3ByZWZlcmVuY2VzLnRyYW5zaXRpb25zID0gMA0KDQogICAgIyBBbGxvdyBGYXN0IHNraXBwaW5nDQogICAgcmVucHkuY29uZmlnLmZhc3Rfc2tpcHBpbmcgPSBUcnVlDQoNCiAgICAjIEZyb20gSmFzb246IENvbWluZyBvZiBhZ2UNCiAgICBwZXJzaXN0ZW50LmdhbWVfY29tcGxldGVkID0gVHJ1ZQ0K"
    )
    call :elog .
    call :pwsh_exp "!choiced.%LNG%!.." "%unren-skipall%"
    if not exist "%unren-skipall%" (
        call :elog "%NOK%" "!FCREATE.%LNG%! %YEL%%unren-skipall%%RES%"
        call :elog .
    ) else (
        call :elog "%OK%"
    )
)
timeout /T 1 %DEBUGREDIR%
goto :finish


:: Drop our rollback file into the game folder
:rollback
set "unren-rollback=%WORKDIR%\game\unren-rollback.rpy"

call :elog .
call :elog "!TWADD.%LNG%! %YEL%%unren-rollback%.%RES%"
call :elog .
call :elog "!INCASEDEL.%LNG%!%RES%"
call :elog "%YEL%%unren-rollback%%RES%"
call :elog "%YEL%%unren-rollback%c%RES%"

if exist "%unren-rollback%" (
    call :elog .
    call :elog "%SKIP%" "!APRESENT.%LNG%!%RES%"
    call :elog .
) else (
    >"%unren-rollback%.b64" (
        <nul set /p="IyBNYWRlIGJ5IChTTSkgYWthIEpvZUx1cm1lbCBAIGY5NXpvbmUudG8NCg0KaW5pdCA5OTkgcHl0aG9uOg0KICAgIHJlbnB5LmNvbmZpZy5yb2xsYmFja19lbmFibGVkID0gVHJ1ZQ0KICAgIHJlbnB5LmNvbmZpZy5oYXJkX3JvbGxiYWNrX2xpbWl0ID0gMjU2DQogICAgcmVucHkuY29uZmlnLnJvbGxiYWNrX2xlbmd0aCA9IDI1Ng0KICAgIGRlZiB1bnJlbl9ub2Jsb2NrKCphcmdzLCAqKmt3YXJncyk6DQogICAgICAgIHJldHVybg0KICAgIHJlbnB5LmJsb2NrX3JvbGxiYWNrID0gdW5yZW5fbm9ibG9jaw0KICAgIHRyeToNCiAgICAgICAgY29uZmlnLmtleW1hcFsncm9sbGJhY2snXSA9IFsgJ0tfUEFHRVVQJywgJ3JlcGVhdF9LX1BBR0VVUCcsICdLX0FDX0JBQ0snLCAnbW91c2Vkb3duXzQnIF0NCiAgICBleGNlcHQ6DQogICAgICAgIHBhc3MNCg=="
    )
    call :elog .
    call :pwsh_exp "!choicee.%LNG%!.." "%unren-rollback%"
    if not exist "%unren-rollback%" (
        call :elog "%NOK%" "!FCREATE.%LNG%! %YEL%%unren-rollback%%RES%"
        call :elog .
    ) else (
        call :elog "%OK%"
    )
)
timeout /T 1 %DEBUGREDIR%
goto :finish


:: Drop our Quick Save/Load file into the game folder
:quick
set "unren-quick=%WORKDIR%\game\unren-quick.rpy"

call :elog .
call :elog "!TWADD.%LNG%! %YEL%%unren-quick%.%RES%"
call :elog .
call :elog "!INCASEDEL.%LNG%!%RES%"
call :elog "%YEL%%unren-quick%%RES%"
call :elog "%YEL%%unren-quick%c%RES%"

if exist "%unren-quick%" (
    call :elog .
    call :elog "%SKIP%" "!APRESENT.%LNG%!%RES%"
    call :elog .
) else (
    >"%unren-quick%.b64" (
        <nul set /p="IyBNYWRlIGJ5IChTTSkgYWthIEpvZUx1cm1lbCBAIGY5NXpvbmUudG8NCg0KaW5pdCA5OTkgcHl0aG9uOg0KICAgIHRyeToNCiAgICAgICAgY29uZmlnLnVuZGVybGF5WzBdLmtleW1hcFsncXVpY2tTYXZlJ10gPSBRdWlja1NhdmUoKQ0KICAgICAgICBjb25maWcua2V5bWFwWydxdWlja1NhdmUnXSA9ICdLX0Y1Jw0KICAgICAgICBjb25maWcudW5kZXJsYXlbMF0ua2V5bWFwWydxdWlja0xvYWQnXSA9IFF1aWNrTG9hZCgpDQogICAgICAgIGNvbmZpZy5rZXltYXBbJ3F1aWNrTG9hZCddID0gJ0tfRjknDQogICAgZXhjZXB0Og0KICAgICAgICBwYXNzDQo="
    )
    call :elog .
    call :pwsh_exp "!choicef.%LNG%!.." "%unren-quick%"
    if not exist "%unren-quick%" (
        call :elog "%NOK%" "!FCREATE.%LNG%! %YEL%%unren-quick%%RES%"
        call :elog .
    ) else (
        call :elog "%OK%"
    )
)
timeout /T 1 %DEBUGREDIR%
goto :finish


:: Drop our Quick Menu file into the game folder
:qmenu
set "unren-qmenu=%WORKDIR%\game\unren-qmenu.rpy"

call :elog .
call :elog "!TWADD.%LNG%! %YEL%%unren-qmenu%.%RES%"
call :elog .
call :elog "!INCASEDEL.%LNG%!%RES%"
call :elog "%YEL%%unren-qmenu%%RES%"
call :elog "%YEL%%unren-qmenu%c%RES%"

if exist "%unren-qmenu%" (
    call :elog .
    call :elog "%SKIP%" "!APRESENT.%LNG%!%RES%"
    call :elog .
) else (
    >"%unren-qmenu%.b64" (
        <nul set /p="IyBNYWRlIGJ5IChTTSkgYWthIEpvZUx1cm1lbCBAIGY5NXpvbmUudG8NCg0KaW5pdCBweXRob246DQogICAgZGVmIGFsd2F5c19lbmFibGVfcXVpY2tfbWVudSgpOg0KICAgICAgICBzdG9yZS5xdWlja19tZW51ID0gVHJ1ZQ0KICAgICAgICByZW5weS5zaG93X3NjcmVlbigicXVpY2tfbWVudSIpDQogICAgY29uZmlnLm92ZXJsYXlfZnVuY3Rpb25zLmFwcGVuZChhbHdheXNfZW5hYmxlX3F1aWNrX21lbnUpDQoNCiAgICBkZWYgZm9yY2VfcXVpY2tfbWVudV9vbl9pbnRlcmFjdCgpOg0KICAgICAgICBzdG9yZS5xdWlja19tZW51ID0gVHJ1ZQ0KICAgIGNvbmZpZy5pbnRlcmFjdF9jYWxsYmFja3MuYXBwZW5kKGZvcmNlX3F1aWNrX21lbnVfb25faW50ZXJhY3Qp"
    )
    call :elog .
    call :pwsh_exp "!choiceg.%LNG%!.." "%unren-qmenu%"
    if not exist "%unren-qmenu%" (
        call :elog "%NOK%" "!FCREATE.%LNG%! %YEL%%unren-qmenu%%RES%"
        call :elog .
    ) else (
        call :elog "%OK%"
    )
)
timeout /T 1 %DEBUGREDIR%
goto :finish


:: Add the Universal Gallery Unlocker to the game folder
:add_ugu
set "ugu_name=Universal_Gallery_Unlocker ZLZK"
set "url=https://attachments.f95zone.to/2024/01/3314515_Universal_Gallery_Unlocker_2024-01-24_ZLZK.zip"
set "uguzip=%TEMP%\Universal_Gallery_Unlocker.zip"
set "uguhardzip=%TEMP%\hard.zip"
set "ugusoftzip=%TEMP%\soft.zip"
set "ugudir=%WORKDIR%\game\_mods"

call :elog .
call :elog "!INCASEOF.%LNG%! %RES%"
call :elog "%MAG%https://f95zone.to/threads/universal-gallery-unlocker-2024-01-24-zlzk.136812/%RES%"
call :elog .
call :elog "!TWADD.%LNG%! %YEL%%ugudir%.%RES%"
call :elog .
call :elog "!INCASEDEL.%LNG%!%RES%"
call :elog "%YEL%%ugudir%\ZLZK_UGU_soft%RES%"
call :elog .
call :elog -n "%EMPTY%" "!choiceh.%LNG%!.."

if %DEBUGLEVEL% GEQ 1 echo "%PWRSHELL%" -NoProfile -Command "(New-Object System.Net.WebClient).DownloadFile('%url%','%uguzip%')" >> "%UNRENLOG%"
"%PWRSHELL%" -NoProfile -Command "(New-Object System.Net.WebClient).DownloadFile('%url%','%uguzip%')" %DEBUGREDIR%
if %errorlevel% NEQ 0 (
    call :elog "%NOK%" "!UNDWNLD.%LNG%! %MAG%%url%%RES%"
    call :elog .
    goto :skip_ugu

) else (
    if %DEBUGLEVEL% GEQ 1 echo "%PWRSHELL%" -NoProfile -Command "Expand-Archive -Force '%uguzip%' '%TEMP%'" >> "%UNRENLOG%"
    "%PWRSHELL%" -NoProfile -Command "Expand-Archive -Force '%uguzip%' '%TEMP%'" %DEBUGREDIR%
    if not exist "%uguhardzip%" (
        call :elog "%NOK%" "!FNOTFOUND.%LNG%! %YEL%%uguhardzip%%RES%"
        call :elog .
        goto :skip_ugu
    )
    if not exist "%ugusoftzip%" (
        call :elog "%NOK%" "!FNOTFOUND.%LNG%! %YEL%%ugusoftzip%%RES%"
        call :elog .
        goto :skip_ugu
    )
    if %DEBUGLEVEL% GEQ 1 echo "%PWRSHELL%" -NoProfile -Command "Expand-Archive -Force '%ugusoftzip%' '%WORKDIR%'" >> "%UNRENLOG%"
    "%PWRSHELL%" -NoProfile -Command "Expand-Archive -Force '%ugusoftzip%' '%WORKDIR%'" %DEBUGREDIR%
    if !errorlevel! NEQ 0 (
        call :elog "%NOK%" "!UNEXTRACT.%LNG%! %YEL%%ugusoftzip%%RES%"
        call :elog .
        goto :skip_ucd
    ) else (
        call :elog "%OK%"
    )
    del /f /q "%ugusoftzip%" %DEBUGREDIR%
    del /f /q "%uguhardzip%" %DEBUGREDIR%
    del /f /q "%uguzip%" %DEBUGREDIR%
    del /f /q "%TEMP%\readme.txt" %DEBUGREDIR%
)
timeout /T 1 %DEBUGREDIR%
goto :finish


:: Add the Universal Choice Descriptor to the game folder
:add_ucd
set "ucd_name=Universal_Choice_Descriptor ZLZK"
set "url=https://attachments.f95zone.to/2024/01/3314453_Universal_Choice_Descriptor.zip"
set "ucdzip=%TEMP%\Universal_Choice_Descriptor.zip"
set "ucdzip_part1=%TEMP%\Universal_Choice_Descriptor_[2024-01-24]_[ZLZK].zip"
set "ucdzip_part2=%TEMP%\ZLZK_[2024-01-24]_[ZLZK].zip"
set "ucddir=%WORKDIR%\game\_mods\"

call :elog .
call :elog "!INCASEOF.%LNG%!%RES%"
call :elog "%MAG%https://f95zone.to/threads/universal-gallery-unlocker-2024-01-24-zlzk.136812/%RES%"
call :elog .
call :elog "!TWADD.%LNG%! %YEL%%ucddir%.%RES%"
call :elog .
call :elog "!INCASEDEL.%LNG%!%RES%"
call :elog "%YEL%%ucddir%%RES%"
call :elog .
call :elog -n "%EMPTY%" "!choicei.%LNG%!.."

if %DEBUGLEVEL% GEQ 1 echo "%PWRSHELL%" -NoProfile -Command "(New-Object System.Net.WebClient).DownloadFile('%url%','%ucdzip%')" >> "%UNRENLOG%"
"%PWRSHELL%" -NoProfile -Command "(New-Object System.Net.WebClient).DownloadFile('%url%','%ucdzip%')" %DEBUGREDIR%
if not exist "%ucdzip%" (
	call :elog "%NOK%" "!UNDWNLD.%LNG%! %MAG%%url%%RES%"
    call :elog .
	goto :skip_ucd
) else (
    if %DEBUGLEVEL% GEQ 1 echo "%PWRSHELL%" -NoProfile -Command "Expand-Archive -Force '%ucdzip%' '%TEMP%'" >> "%UNRENLOG%"
	"%PWRSHELL%" -NoProfile -Command "Expand-Archive -Force '%ucdzip%' '%TEMP%'" %DEBUGREDIR%
    if not exist "%ucdzip_part1%" (
        call :elog "%NOK%" "!FNOTFOUND.%LNG%! %YEL%%ucdzip_part1%%RES%"
        call :elog .
        goto :skip_ucd
    ) else (
        move /y "%ucdzip_part1%" %TEMP%\part1.zip %DEBUGREDIR%
    )
    if not exist "%ucdzip_part2%" (
        call :elog "%NOK%" "!FNOTFOUND.%LNG%! %YEL%%ucdzip_part2%%RES%"
        call :elog .
        goto :skip_ucd
    ) else (
        move /y "%ucdzip_part2%" %TEMP%\part2.zip %DEBUGREDIR%
    )
    if %DEBUGLEVEL% GEQ 1 echo "%PWRSHELL%" -NoProfile -Command "Expand-Archive -Force '%TEMP%\part1.zip' '%WORKDIR%'" >> "%UNRENLOG%"
    "%PWRSHELL%" -NoProfile -Command "Expand-Archive -Force '%TEMP%\part1.zip' '%WORKDIR%'" %DEBUGREDIR%
    if !errorlevel! NEQ 0 (
        call :elog "%NOK%" "!UNEXTRACT.%LNG%! %YEL%%ucdzip_part1%%RES%"
        goto :skip_ucd
    )
    if %DEBUGLEVEL% GEQ 1 echo "%PWRSHELL%" -NoProfile -Command "Expand-Archive -Force '%TEMP%\part2.zip' '%WORKDIR%'" >> "%UNRENLOG%"
    "%PWRSHELL%" -NoProfile -Command "Expand-Archive -Force '%TEMP%\part2.zip' '%WORKDIR%'" %DEBUGREDIR%
    if !errorlevel! NEQ 0 (
        call :elog "%NOK%" "!UNEXTRACT.%LNG%! %YEL%%ucdzip_part2%%RES%"
        call :elog .
        goto :skip_ucd
    )
    call :elog "%OK%%"
    :skip_ucd
	del /f /q "%ucdzip%" %DEBUGREDIR%
    del /f /q "%ucdzip_part1%" %DEBUGREDIR%
    del /f /q "%TEMP%\part1.zip" %DEBUGREDIR%
    del /f /q "%ucdzip_part2%" %DEBUGREDIR%
    del /f /q "%TEMP%\part2.zip" %DEBUGREDIR%
    del /f /q "%TEMP%\readme.txt" %DEBUGREDIR%
)
timeout /T i %DEBUGREDIR%
goto :finish


:: Download and install Universal Transparent Text Box Mod by Penfold Mole
:add_utbox
set "utboxmsg.en=Checking for 7zip.exe availability."
set "utboxmsg.fr=Vérification de la disponibilité de 7zip.exe."
set "utboxmsg.es=Verificación de la disponibilidad de 7zip.exe."
set "utboxmsg.it=Verifica la disponibilità di 7zip.exe."
set "utboxmsg.de=7zip.exe Verfication."
set "utboxmsg.ru=Проверка доступности 7zip.exe."
set "utboxmsg.zh=检查7zip.exe的可用性。"

set "utbox_name=Universal Transparent Text Box Mod"
set "url=https://attachments.f95zone.to/2023/12/3214690_RenPy_universal_transparent_textbox_mod_v2.6.4_by_Penfold_Mole.7z"
set "utboxzip=%TEMP%\RenPy_Transparent_Text_Box_Mod.7z"
set "utbox_file=%WORKDIR%\game\y_outline.rpy"
set "utbox_tdir=%TEMP%\utbox"

call :elog -n "%EMPTY%" "!utboxmsg.%LNG%!.."
:: Need 7z.exe for extraction
if not exist "%_7ZIPLOC%" (
    call :elog "%NOK%" "!FNOTFOUND.%LNG%! %YEL%%_7ZIPLOC%%RES%"
    call :elog .
    timeout /T 1 %DEBUGREDIR%
    goto :skip_utbox
) else (
    call :elog "%OK%"
)

call :elog .
call :elog "!INCASEOF.%LNG%! %RES%"
call :elog "%MAG%https://f95zone.to/threads/renpy-transparent-text-box-mod-v2-6-4.11925/%RES%"
call :elog .
call :elog "!TWADD.%LNG%! %YEL%%utbox_file%.%RES%"
call :elog .
call :elog "!INCASEDEL.%LNG%!%RES%"
call :elog "%YEL%%utbox_file%%RES%"
call :elog .
call :elog -n "%EMPTY%" "!choicej.%LNG%!.."
if %DEBUGLEVEL% GEQ 1 echo "%PWRSHELL%" -NoProfile -Command "(New-Object System.Net.WebClient).DownloadFile('%url%','%utboxzip%')" >> "%UNRENLOG%"
"%PWRSHELL%" -NoProfile -Command "(New-Object System.Net.WebClient).DownloadFile('%url%','%utboxzip%')" %DEBUGREDIR%
if not exist "%utboxzip%" (
    call :elog "%NOK%" "!UNDWNLD.%LNG%! %MAG%%url%%RES%"
    call :elog .
    goto :skip_utbox
) else (
    if %DEBUGLEVEL% GEQ 1 echo "%_7ZIPLOC%" x -y -o"%utbox_tdir%" "%utboxzip%" >> "%UNRENLOG%"
    "%_7ZIPLOC%" x -y -o"%utbox_tdir%" "%utboxzip%" %DEBUGREDIR%
    if not exist "%utbox_tdir%\game\y_outline.rpy" (
        call :elog "%NOK%" "!UNEXTRACT.%LNG%! %YEL%%utboxzip%%RES%"
        call :elog .
        goto :skip_utbox
    ) else (
        move /y "%utbox_tdir%\game\y_outline.rpy" "%WORKDIR%\game" %DEBUGREDIR%
        if exist "%utbox_file%" (
            call :elog "%OK%"
        ) else (
            call :elog "%NOK%" "!FNOTFOUND.%LNG%! %YEL%%utbox_file%%RES%"
            call :elog .
        )
    )
)
:skip_utbox
if exist "%utboxzip%" if not %utboxzip% == "" (del /f /q "%utboxzip%" %DEBUGREDIR%)
if exist "%utbox_tdir%" if not %utbox_tdir% == "" (rd /s /q "%utbox_tdir%" %DEBUGREDIR%)

timeout /T 1 %DEBUGREDIR%
goto :finish


:: Download 0x52_URM and add to the game
:add_urm
set "urm_name=0x52_URM"
set "url=https://attachments.f95zone.to/2025/07/5028578_0x52_URM.zip"
set "urm_zip=%TEMP%\0x52_URM.zip"
set "urm_rpa=%WORKDIR%\game\0x52_URM.rpa"

call :elog .
call :elog "!INCASEOF.%LNG%! %RES%"
call :elog "%MAG%https://f95zone.to/threads/universal-renpy-mod-urm-2-6-2-mod-any-renpy-game-yourself.48025/%RES%"
call :elog .
call :elog "!TWADD.%LNG%! %YEL%%urm_rpa%.%RES%"
call :elog .
call :elog "!INCASEDEL.%LNG%!%RES%"
call :elog "%YEL%%urm_rpa%%RES%"
call :elog .
call :elog -n "%EMPTY%" "!choicek.%LNG%!.."

if %DEBUGLEVEL% GEQ 1 echo "%PWRSHELL%" -NoProfile -Command "(New-Object System.Net.WebClient).DownloadFile('%url%','%urm_zip%.tmp')" >> "%UNRENLOG%"
"%PWRSHELL%" -NoProfile -Command "(New-Object System.Net.WebClient).DownloadFile('%url%','%urm_zip%.tmp')" %DEBUGREDIR%
if not exist "%urm_zip%.tmp" (
	call :elog "%NOK%" "!UNDWNLD.%LNG%! %YEL%!urm_name!.zip.%RES%"
    call :elog .
    goto :skip_urm
) else (
    move /y "%urm_zip%.tmp" "%urm_zip%" %DEBUGREDIR%
    if %DEBUGLEVEL% GEQ 1 echo "%PWRSHELL%" -NoProfile -Command "Expand-Archive -Force '%urm_zip%' '%WORKDIR%\game'" >> "%UNRENLOG%"
	"%PWRSHELL%" -NoProfile -Command "Expand-Archive -Force '%urm_zip%' '%WORKDIR%\game'" %DEBUGREDIR%
	if !errorlevel! NEQ 0 (
		call :elog "%NOK%" "!FNOTFOUND.%LNG%! %YEL%!urm_name!%RES%"
        call :elog .
	) else (
		call :elog "%OK%"
	)
    :skip_urm
	del /f /q "%urm_zip%" %DEBUGREDIR%
)
timeout /T 1 %DEBUGREDIR%
goto :finish


:: Add a custom add-on
:add_custom_addon
set "download.en=Download and install a custom add-on from a URL or local path."
set "download.fr=Téléchargez et installez un add-on personnalisé à partir d'une URL ou d'un chemin local."
set "download.es=Descarga e instala un complemento personalizado desde una URL o ruta local."
set "download.it=Scarica e installa un add-on personalizzato dall'URL o dal percorso locale."
set "download.de=Laden und installieren Sie ein benutzerdefiniertes Add-on aus einer URL oder einem lokalen Pfad."
set "download.ru=Загрузите и установите пользовательский аддон по URL или локальному пути."
set "download.zh=从 URL 或本地路径下载并安装自定义插件。"

set "custom_name.en=Custom Add-on"
set "custom_name.fr=Add-on personnalisé"
set "custom_name.es=Add-on personalizado"
set "custom_name.it=Add-on personalizzato"
set "custom_name.de=Benutzerdefiniertes Add-on"
set "custom_name.ru=Пользовательский аддон"
set "custom_name.zh=自定义插件"

set "enter_url.en=Enter the URL or local path to the add-on (zip, rar, or folder): "
set "enter_url.fr=Entrez l'URL ou le chemin local vers l'add-on (zip, rar ou dossier) : "
set "enter_url.es=Ingrese la URL o ruta local al add-on (zip, rar o carpeta): "
set "enter_url.it=Inserisci l'URL o il percorso locale all'add-on (zip, rar o cartella): "
set "enter_url.de=Geben Sie die URL oder den lokalen Pfad zum Add-on ein (zip, rar oder Ordner): "
set "enter_url.ru=Введите URL или локальный путь к аддону (zip, rar или папка): "
set "enter_url.zh=输入插件的 URL 或本地路径（zip、rar 或文件夹）："

call :elog .
call :elog "!TWADD.%LNG%! %YEL%%WORKDIR%\game\!custom_name.%LNG%!...%RES%"
call :elog .
call :elog "!choicep.%LNG%!.."

set /p "addon_path=!enter_url.%LNG%!"
if not defined addon_path (
    call :elog "%NOK%" "No path provided."
    goto :eof
)

set "addon_path=%addon_path:"=%"

:: Check if it's a URL or local path
echo %addon_path% | "%SystemRoot%\System32\findstr.exe" /r "^https\?://" >nul
if %errorlevel% EQU 0 (
    :: It's a URL
    set "temp_zip=%TEMP%\custom_addon.zip"
    call :elog -n "%EMPTY%" "!download.%LNG%!.."
    if %DEBUGLEVEL% GEQ 1 echo "%PWRSHELL%" -NoProfile -Command "(New-Object System.Net.WebClient).DownloadFile('%addon_path%','%temp_zip%')" >> "%UNRENLOG%"
    "%PWRSHELL%" -NoProfile -Command "(New-Object System.Net.WebClient).DownloadFile('%addon_path%','%temp_zip%')" %DEBUGREDIR%
    if !errorlevel! NEQ 0 (
        call :elog "%NOK%" "!UNDWNLD.%LNG%! %MAG%%addon_path%%RES%"
        goto :skip_custom
    )
    set "source=%temp_zip%"
) else (
    :: Local path
    if not exist "%addon_path%" (
        call :elog "%NOK%" "!FNOTFOUND.%LNG%! %YEL%%addon_path%%RES%"
        goto :skip_custom
    )
    set "source=%addon_path%"
)

:: Check if it's a zip/rar or folder
if exist "%source%\*" (
    :: It's a folder, copy it
    call :elog "Copying folder..."
    xcopy "%source%" "%WORKDIR%\game\" /E /I /H /Y %DEBUGREDIR%
    if !errorlevel! NEQ 0 (
        call :elog "%NOK%" "Failed to copy folder."
    ) else (
        call :elog "%OK%"
    )
) else (
    :: Assume it's an archive
    call :elog -n "%EMPTY%" "Extracting archive..."
    if %DEBUGLEVEL% GEQ 1 echo "%PWRSHELL%" -NoProfile -Command "Expand-Archive -Force '%source%' '%WORKDIR%\game'" >> "%UNRENLOG%"
    "%PWRSHELL%" -NoProfile -Command "Expand-Archive -Force '%source%' '%WORKDIR%\game'" %DEBUGREDIR%
    if !errorlevel! NEQ 0 (
        call :elog "%NOK%" "!UNEXTRACT.%LNG%! %YEL%%source%%RES%"
    ) else (
        call :elog "%OK%"
    )
    if defined temp_zip del /f /q "%temp_zip%" %DEBUGREDIR%
)

:skip_custom
timeout /T 1 %DEBUGREDIR%
goto :finish


:: Replace any character name in game files
:replace_anyname
set "renaname.en=Please input the new name (without quotes): "
set "renaname.fr=Veuillez saisir le nouveau nom (sans guillemets) : "
set "renaname.es=Por favor ingrese el nuevo nombre (sin comillas): "
set "renaname.it=Si prega di inserire il nuovo nome (senza virgolette): "
set "renaname.de=Bitte geben Sie den neuen Namen (ohne Anführungszeichen) ein: "
set "renaname.ru=Пожалуйста, введите новое имя (без кавычек): "
set "renaname.zh=请输入新名称（不带引号）："

set "renaname2.en=No name provided."
set "renaname2.fr=Aucun nom fourni."
set "renaname2.es=No se proporcionó ningún nombre."
set "renaname2.it=Nome non fornito."
set "renaname2.de=Kein Name angegeben."
set "renaname2.ru=Имя не указано."
set "renaname2.zh=未提供名称。"

set "renaname3.en=Please input the old name (without quotes): "
set "renaname3.fr=Veuillez saisir l'ancien nom (sans guillemets) : "
set "renaname3.es=Por favor ingrese el nombre antiguo (sin comillas): "
set "renaname3.it=Si prega di inserire il vecchio nome (senza virgolette): "
set "renaname3.de=Bitte geben Sie den alten Namen (ohne Anführungszeichen) ein: "
set "renaname3.ru=Пожалуйста, введите старое имя (без кавычек): "
set "renaname3.zh=请输入旧名称（不带引号）："

set "unr-unkonwn=%WORKDIR%\game\unr-unkonwn.rpy"

call :elog .
:oldname
call :elog .
if not "%OPTION%" == "m" echo.
set "oldname="
echo oldname=!renaname3.%LNG%! >> "%UNRENLOG%"
set /p "oldname=!renaname3.%LNG%!"

if "%oldname%" == "" (
    call :elog .
    call :elog "%NOK%" "!renaname2.%LNG%!%RES%"
    call :elog .
    goto :oldname
) else (
    echo oldname=!oldname! >> "%UNRENLOG%"
)
set "unr-unkonwn=%WORKDIR%\game\unr-%oldname%.rpy"

call :elog .
call :elog "!TWADD.%LNG%! %YEL%%unr-unkonwn%.%RES%"
call :elog .
call :elog "!INCASEDEL.%LNG%!%RES%"
call :elog "%YEL%%unr-unkonwn%%RES%"
call :elog "%YEL%%unr-unkonwn%c%RES%"

:newname
call :elog .
set "newname="
echo newname=!renaname.%LNG%! >> "%UNRENLOG%"
set /p "newname=!renaname.%LNG%!"

if "%newname%" == "" (
    call :elog .
    call :elog "%NOK%" "!renaname2.%LNG%!%RES%"
    call :elog .
    goto :newname
) else (
    echo newname=!newname! >> "%UNRENLOG%"
)

>"%unr-unkonwn%.b64" (
    <nul set /p="IyBNYWRlIGJ5IChTTSkgYWthIEpvZUx1cm1lbCBAIGY5NXpvbmUudG8NCg0KaW5pdCA5OTkgcHl0aG9uOg0KICAgIGltcG9ydCByZQ0KDQogICAgIyBQbGFjZWhvbGRlcnMgcmVwbGFjZWQgYnkgUG93ZXJTaGVsbCBiZWZvcmUgZXhlY3V0aW9uDQogICAgT0xEID0gIm9sZG5hbWUiDQogICAgTkVXID0gIm5ld25hbWUiDQoNCiAgICBkZWYgX2Nhc2VfbGlrZShzLCBtb2RlbCk6DQogICAgICAgICMgQWxpZ24gdGhlIGNhc2Ugb2YgcyB3aXRoIHRoYXQgb2YgbW9kZWwgKHVwcGVyLCBUaXRsZSwgbG93ZXIpDQogICAgICAgIGlmIG1vZGVsLmlzdXBwZXIoKToNCiAgICAgICAgICAgIHJldHVybiBzLnVwcGVyKCkNCiAgICAgICAgZWxpZiBtb2RlbFs6MV0uaXN1cHBlcigpIGFuZCBtb2RlbFsxOl0uaXNsb3dlcigpOg0KICAgICAgICAgICAgcmV0dXJuIHMuY2FwaXRhbGl6ZSgpDQogICAgICAgIGVsc2U6DQogICAgICAgICAgICByZXR1cm4gcy5sb3dlcigpDQoNCiAgICBkZWYgcmVwbGFjZV90ZXh0KHQpOg0KICAgICAgICBvbGQgPSBPTEQNCiAgICAgICAgbmV3ID0gTkVXDQoNCiAgICAgICAgb19lc2MgPSByZS5lc2NhcGUob2xkKQ0KICAgICAgICBmX29sZCA9IG9sZFs6MV0NCiAgICAgICAgZl9uZXcgPSBuZXdbOjFdDQoNCiAgICAgICAgIyAxKSBSZXBsYWNlbWVudCBvZiB0aGUgZW50aXJlIHdvcmQgKGNhc2UtaW5zZW5zaXRpdmUpIHdpdGggY2FzZSByZXN0b3JhdGlvbg0KICAgICAgICBiYXNlX3BhdCA9IHJlLmNvbXBpbGUocmYiXGIoP2k6KHtvX2VzY30pKVxiIikNCiAgICAgICAgZGVmIGJhc2VfcmVwbChtKToNCiAgICAgICAgICAgIHJldHVybiBfY2FzZV9saWtlKG5ldywgbS5ncm91cCgxKSkNCiAgICAgICAgdCA9IGJhc2VfcGF0LnN1YihiYXNlX3JlcGwsIHQpDQoNCiAgICAgICAgIyAyKSBTdHV0dGVyaW5nIHR5cGU6IGMtY29ubm9yIOKGkiBqLWpvZSAoYW5kIGNhc2UgdmFyaWFudHMpDQogICAgICAgIHN0MV9wYXQgPSByZS5jb21waWxlKHJmIlxiKFt7Zl9vbGQubG93ZXIoKX17Zl9vbGQudXBwZXIoKX1dKS0oP2k6KHtvX2VzY30pKVxiIikNCiAgICAgICAgZGVmIHN0MV9yZXBsKG0pOg0KICAgICAgICAgICAgcHJlZiA9IG0uZ3JvdXAoMSkgICAgICAgIyBwcmVmaXggbGV0dGVyIChjL0MpDQogICAgICAgICAgICBvbGRfcGFydCA9IG0uZ3JvdXAoMikgICAjIHdvcmQgKGNvbm5vci9Db25ub3IvQ09OTk9SKQ0KICAgICAgICAgICAgbmV3X3dvcmQgPSBfY2FzZV9saWtlKG5ldywgb2xkX3BhcnQpDQogICAgICAgICAgICBuZXdfZmlyc3QgPSBmX25ldy51cHBlcigpIGlmIHByZWYuaXN1cHBlcigpIGVsc2UgZl9uZXcubG93ZXIoKQ0KICAgICAgICAgICAgcmV0dXJuIGYie25ld19maXJzdH0te25ld193b3JkfSINCiAgICAgICAgdCA9IHN0MV9wYXQuc3ViKHN0MV9yZXBsLCB0KQ0KDQogICAgICAgICMgMykgU3R1dHRlcmluZyB0eXBlOiBjby1jb25ub3Ig4oaSIGpvLWpvZSAoYW5kIGNhc2UgdmFyaWFudHMpDQogICAgICAgIHN0Ml9wYXQgPSByZS5jb21waWxlKHJmIlxiKFt7Zl9vbGQubG93ZXIoKX17Zl9vbGQudXBwZXIoKX1dKShbb09dKS0oP2k6KHtvX2VzY30pKVxiIikNCiAgICAgICAgZGVmIHN0Ml9yZXBsKG0pOg0KICAgICAgICAgICAgcHJlZiA9IG0uZ3JvdXAoMSkgICAgICAgIyBwcmVmaXggbGV0dGVyIChjL0MpDQogICAgICAgICAgICBvY2hhciA9IG0uZ3JvdXAoMikgICAgICAjICdvJyBvciAnTycNCiAgICAgICAgICAgIG9sZF9wYXJ0ID0gbS5ncm91cCgzKSAgICMgd29yZCAoY29ubm9yL0Nvbm5vci9DT05OT1IpDQogICAgICAgICAgICBuZXdfd29yZCA9IF9jYXNlX2xpa2UobmV3LCBvbGRfcGFydCkNCiAgICAgICAgICAgIG5ld19maXJzdCA9IGZfbmV3LnVwcGVyKCkgaWYgcHJlZi5pc3VwcGVyKCkgZWxzZSBmX25ldy5sb3dlcigpDQogICAgICAgICAgICAjIEtlZXAgdGhlIGNhc2Ugb2YgdGhlICdvJyBsZXR0ZXIgYXMgZW5jb3VudGVyZWQNCiAgICAgICAgICAgIHJldHVybiBmIntuZXdfZmlyc3R9e29jaGFyfS17bmV3X3dvcmR9Ig0KICAgICAgICB0ID0gc3QyX3BhdC5zdWIoc3QyX3JlcGwsIHQpDQoNCiAgICAgICAgcmV0dXJuIHQNCg0KICAgIGNvbmZpZy5yZXBsYWNlX3RleHQgPSByZXBsYWNlX3RleHQNCiAgICBkZWwgcmVwbGFjZV90ZXh0DQo="
)
call :elog .
call :pwsh_exp "!choicel.%LNG%!.." "%unr-unkonwn%"
if not exist "%unr-unkonwn%" (
    call :elog "%NOK%" "!FNOTFOUND.%LNG%! %YEL%!unr-unkonwn!%RES%"
    call :elog .
    goto :anynameend
) else (
    del /f /q "%unr-unkonwn%.b64" %DEBUGREDIR%
    if %DEBUGLEVEL% GEQ 1 echo "%PWRSHELL%" -NoProfile -Command "(Get-Content '%unr-unkonwn%.tmp') -replace 'newname', '%newname%' | Set-Content '%unr-unkonwn%'" >> "%UNRENLOG%"
    "%PWRSHELL%" -NoProfile -Command "(Get-Content '%unr-unkonwn%.tmp') -replace 'newname', '%newname%' | Set-Content '%unr-unkonwn%'" %DEBUGREDIR%
    if %DEBUGLEVEL% GEQ 1 echo "%PWRSHELL%" -NoProfile -Command "(Get-Content '%unr-unkonwn%') -replace 'oldname', '%oldname%' | Set-Content '%unr-unkonwn%'" >> "%UNRENLOG%"
    "%PWRSHELL%" -NoProfile -Command "(Get-Content '%unr-unkonwn%') -replace 'oldname', '%oldname%' | Set-Content '%unr-unkonwn%'" %DEBUGREDIR%
    if not exist "%unr-unkonwn%" (
        call :elog "%NOK%" "!FNOTFOUND.%LNG%! %YEL%!unr-unkonwn!%RES%"
        call :elog .
        goto :anynameend
    ) else (
        set "rename4.en=Renamed character from %YEL%!oldname!%RES% to %YEL%!newname!%RES%"
        set "rename4.fr=Personnage renommé de %YEL%!oldname!%RES% à %YEL%!newname!%RES%"
        set "rename4.es=Personaje renombrado de %YEL%!oldname!%RES% a %YEL%!newname!%RES%"
        set "rename4.it=Personaggio rinominato da %YEL%!oldname!%RES% a %YEL%!newname!%RES%"
        set "rename4.de=Charakter umbenannt von %YEL%!oldname!%RES% zu %YEL%!newname!%RES%"
        set "rename4.ru=Персонаж переименован с %YEL%!oldname!%RES% на %YEL%!newname!%RES%"
        set "rename4.zh=角色已从 %YEL%!oldname!%RES% 重命名为 %YEL%!newname!%RES%"

        call :elog "%OK%" "!rename4.%LNG%!"
    )
    :anynameend
    del /f /q "%unr-unkonwn%.tmp" %DEBUGREDIR%
)

:anynameend
timeout /T 1 %DEBUGREDIR%
goto :finish


:: Remove nasty sync folder
:nasty_sync
set "unren-nsync=%WORKDIR%\game\unren-nsync.rpy"

call :elog .
call :elog "!TWADD.%LNG%! %YEL%%unren-nsync%.%RES%"
call :elog .
call :elog "!INCASEDEL.%LNG%!"
call :elog "%YEL%%unren-nsync%%RES%"
call :elog "%YEL%%unren-nsync%c%RES%"

if exist "%unren-nsync%" (
    call :elog .
    call :elog "%SKIP%" "!APRESENT.%LNG%!"
    call :elog .
) else (
    >"%unren-nsync%" (
        echo # Made by ^(SM^) aka JoeLurmel @ f95zone.to
        echo.
        echo init 9999 python:
        echo     renpy.config.has_sync = False
        echo     renpy.config.extra_savedirs = []
        echo.
    )
    call :elog .
    call :elog -n "%EMPTY%" "!choicen.%LNG%!.."
    if not exist "%unren-nsync%" (
        call :elog "%NOK%" "!FCREATE.%LNG%! %YEL%%unren-nsync%%RES%"
        call :elog .
    ) else (
        call :elog "%OK%"
    )
)
timeout /T 1 %DEBUGREDIR%
goto :eof


:: Restore .org files into their original name
:restore_files
setlocal disabledelayedexpansion
for /f "delims=" %%A in ("%WORKDIR%") do (
    endlocal
    cd /d "%%A"
)

call :elog .
call :elog "!choicer.%LNG%!"

set "file_found=0"
set "prevDir="
for /R ".\game" %%f in (*.rpa.org *.rpy.org *.rpyc.org) do (
    set "currDir=%%~dpf"
    set "orgfile=%%f"
    set "filename=%%~nxf"
    set "dstfilename=!filename:.org=!"
    set "dstfile=!orgfile:.org=!"

    set "rmsg.en=Moving %YEL%!filename!%RES% to %YEL%!dstfilename!%RES%"
    set "rmsg.fr=Renommage de %YEL%!filename!%RES% en %YEL%!dstfilename!%RES%"
    set "rmsg.es=Cambio de nombre de %YEL%!filename!%RES% a %YEL%!dstfilename!%RES%"
    set "rmsg.it=Rinominare %YEL%!filename!%RES% in %YEL%!dstfilename!%RES%"
    set "rmsg.de=Umbenennung von %YEL%!filename!%RES% in %YEL%!dstfilename!%RES%"
    set "rmsg.tu=Переименование %YEL%!filename!%RES% в %YEL%!dstfilename!%RES%"
    set "rmsg.zh=將 %YEL%!filename!%RES% 重新命名為 %YEL%!dstfilename!%RES%"

    if not "!prevDir!" == "!currDir!" (
        call :elog .
        call :elog "!MTITLE.%LNG%! %YEL%!currDir!%RES%"
        set "prevDir=!currDir!"
    )

    if exist "!orgfile!" (
        set "file_found=1"
    )

    call :elog -n "%EMPTY%" "!rmsg.%LNG%!"
    move /y "!orgfile!" "!dstfile!" %DEBUGREDIR%
    if not exist "!dstfile!" (
        call :elog "%NOK%" "!FMOVE.%LNG%! %YEL%!filename!%RES% -> %YEL%!dstfilename!%RES%"
    ) else (
        call :elog "%OK%"
    )
)

if %file_found% EQU 0 (
    call :elog .
    call :elog "%SKIP%" "!NOTFOUND.%LNG%!."
    call :elog .
)
timeout /T 1 %DEBUGREDIR%
goto :finish


:: Delete .org files made by the script
:delete_backups
setlocal disabledelayedexpansion
for /f "delims=" %%A in ("%WORKDIR%") do (
    endlocal
    cd /d "%%A"
)

call :elog .
call :elog "!choices.%LNG%!"

set "file_found=0"
set "prevDir="
for /R ".\game" %%f in (*.rpa.org *.rpy.org *.rpyc.org) do (
    set "orgfile=%%f"
    set "currDir=%%~dpf"
    set "filename=%%~nxf"

    set "dmsg.en=Deleting %YEL%!filename!%RES%"
    set "dmsg.fr=Suppression de %YEL%!filename!%RES%"
    set "dmsg.es=Eliminación de %YEL%!filename!%RES%"
    set "dmsg.it=Eliminazione de %YEL%!filename!%RES%"
    set "dmsg.de=Löschen von %YEL%!filename!%RES%"
    set "dmsg.ru=Удаление %YEL%!filename!%RES%"
    set "dmsg.zh=刪除 %YEL%!filename!%RES%"

    if not "!prevDir!" == "!currDir!" (
        call :elog .
        call :elog "!MTITLE.%LNG%! %YEL%!currDir!%RES%"
        set "prevDir=!currDir!"
    )

    if exist "!orgfile!" (
        set "file_found=1"
    )

    call :elog -n "%EMPTY%" "!dmsg.%LNG%!"
    del /f /q "!orgfile!" %DEBUGREDIR%
    if exist "!orgfile!" (
        call :elog "%NOK%" "!FDELETE.%LNG%! %YEL%!orgfile!%RES%"
    ) else (
        call :elog "%OK%"
    )
)

call :elog .
if !file_found! EQU 0 (
    call :elog .
    call :elog "%SKIP%" "!NOTFOUND.%LNG%!."
    call :elog .
    exit /b 1
)
timeout /T 1 %DEBUGREDIR%
goto :finish


:: All your choices in one shot
:multiChoice
if not defined MDEFS (
    set "MDEFS=acefg"
)

set "muquest.en=Your choice (a-l,t,+,- by default [%MDEFS%]):"
set "muquest.fr=Votre choix (a-l,t,+,- par défaut [%MDEFS%]) :"
set "muquest.es=Su elección (a-l,t,+,- por defecto [%MDEFS%]):"
set "muquest.it=La tua scelta (a-l,t,+,- predefinita [%MDEFS%]):"
set "muquest.de=Ihre Auswahl (a-l,t,+,- standardmäßig [%MDEFS%]):"
set "muquest.ru=Ваш выбор (a-l,t,+,- по умолчанию [%MDEFS%]):"
set "muquest.zh=你的选择 (a-l,t,+,-, 默认为 [%MDEFS%]):"

:: Ask user to enter multiple choices (e.g. a b c or abc)
echo.
echo.
set /p "mchoice=!muquest.%LNG%! "
if "%mchoice%" == "" set "mchoice=%MDEFS%"
set "mchoice=%mchoice: =%"

:: First, check for invalid characters
set "VALID=abctdefghijklt+-x"
for /L %%I in (0,1,15) do (
    set "CHAR=!mchoice:~%%I,1!"
    if "!CHAR!"=="" goto end_check
    echo "!VALID!" | findstr /C:"!CHAR!" >nul || (
        echo.
        echo.
        echo %RED%!uchoice.%LNG%! %YEL%!CHAR!%RES%
        timeout /t 2 %DEBUGREDIR%
        echo.
    )
)
:end_check

:: Loop through each character and call corresponding label
for %%C in (a b c d e f g h i j k l t + -) do (
    echo %mchoice% | find /i "%%C" >nul
    if !errorlevel! EQU 0 (
        if /i "%%C" == "a" call :console
        if /i "%%C" == "b" call :debug
        if /i "%%C" == "c" call :skip
        if /i "%%C" == "d" call :skipall
        if /i "%%C" == "e" call :rollback
        if /i "%%C" == "f" call :quick
        if /i "%%C" == "g" call :qmenu
        if /i "%%C" == "h" call :add_ugu
        if /i "%%C" == "i" call :add_ucd
        if /i "%%C" == "j" call :add_utbox
        if /i "%%C" == "k" call :add_urm
        if /i "%%C" == "l" call :replace_anyname
        if /i "%%C" == "t" call :extract_text

        if "%%C" == "+" call :add_reg
        if "%%C" == "-" call :remove_reg
    )
)

echo.
echo.
pause
goto :menu


:: Extract text for translation purpose
:extract_text
if "%LNG%" == "en"  set translation_lang=english
if "%LNG%" == "fr"  set translation_lang=french
if "%LNG%" == "es"  set translation_lang=spanish
if "%LNG%" == "it"  set translation_lang=italian
if "%LNG%" == "de"  set translation_lang=german
if "%LNG%" == "ru"  set translation_lang=russian
if "%LNG%" == "zh"  set translation_lang=chinese

setlocal disabledelayedexpansion
for /f "delims=" %%A in ("%WORKDIR%") do (
    endlocal
    cd /d "%%A"
)

set "etext1.en=Searching for game name"
set "etext1.fr=Recherche du nom du jeu"
set "etext1.es=Buscando el nombre del juego"
set "etext1.it=Cercando il nome del gioco"
set "etext1.de=Suche nach dem Spieletitel"
set "etext1.ru=Поиск названия игры"
set "etext1.zh=正在搜索游戏名称"

set "etext2.en=No game files found with .exe or .py extensions."
set "etext2.fr=Aucun fichier de jeu trouvé avec les extensions .exe ou .py."
set "etext2.es=No se encontraron archivos de juego con las extensiones .exe -o .py."
set "etext2.it=Nessun file di gioco trovato con le estensioni .exe -o .py."
set "etext2.de=Keine Spieldateien mit den Erweiterungen .exe oder .py gefunden."
set "etext2.ru=Не найдено игровых файлов с расширениями .exe или .py."
set "etext2.zh=未找到带有 .exe 或 .py 扩展名的游戏文件。"

set "etext3.en=Enter the target translation language (%YEL%%translation_lang%%RES% by default): "
set "etext3.fr=Entrez la langue de traduction cible (%YEL%%translation_lang%%RES% par défaut) : "
set "etext3.es=Ingrese el idioma de traducción objetivo (%YEL%%translation_lang%%RES% por defecto): "
set "etext3.it=Inserisci la lingua di traduzione di destinazione (%YEL%%translation_lang%%RES% per impostazione predefinita): "
set "etext3.de=Geben Sie die Zielsprache für die Übersetzung ein (%YEL%%translation_lang%%RES% standardmäßig): "
set "etext3.ru=Введите целевой язык перевода (%YEL%%translation_lang%%RES% по умолчанию): "
set "etext3.zh=输入目标翻译语言（默认 %YEL%%translation_lang%%RES%）："

set "etext4.en=Unable to extract text for translation."
set "etext4.fr=Impossible d'extraire le texte pour la traduction."
set "etext4.es=No se pudo extraer el texto para la traducción."
set "etext4.it=Impossibile estrarre il testo per la traduzione."
set "etext4.de=Fehler beim Extrahieren des Textes für die Übersetzung."
set "etext4.ru=Не удалось извлечь текст для перевода."
set "etext4.zh=无法提取文本用于翻译。"

set "etext5.en=Please input the game name (without extension): "
set "etext5.fr=Veuillez saisir le nom du jeu (sans extension) : "
set "etext5.es=Por favor, ingrese el nombre del juego (sin extensión): "
set "etext5.it=Si prega di inserire il nome del gioco (senza estensione): "
set "etext5.de=Bitte geben Sie den Namen des Spiels ein (ohne Erweiterung): "
set "etext5.ru=Пожалуйста, введите название игры (без расширения): "
set "etext5.zh=请输入游戏名称（不带扩展名）："

set "etext6.en=No *.rpy files found in the game directory."
set "etext6.fr=Aucun fichier *.rpy trouvé dans le répertoire du jeu."
set "etext6.es=No se encontraron archivos *.rpy en el directorio del juego."
set "etext6.it=Nessun file *.rpy trovato nella directory del gioco."
set "etext6.de=Keine *.rpy-Dateien im Spielverzeichnis gefunden."
set "etext6.ru=Не удалось найти *.rpy-файлы в каталоге игры."
set "etext6.zh=未找到游戏目录中的 *.rpy 文件。"

set "etext7.en=Please use option 2 to decompile the game first."
set "etext7.fr=Veuillez utiliser l'option 2 pour décompiler le jeu d'abord."
set "etext7.es=Por favor, use la opción 2 para descompilar el juego primero."
set "etext7.it=Si prega di utilizzare l'opzione 2 per decompilare il gioco prima."
set "etext7.de=Bitte verwenden Sie zuerst Option 2, um das Spiel zudekompilieren."
set "etext7.ru=Пожалуйста, сначала используйте опцию 2, чтобы декомпилировать игру."
set "etext7.zh=请先使用选项 2 来反编译游戏。"

set "etext8.en=Please use option 1 to unpack the game first."
set "etext8.fr=Veuillez utiliser l'option 1 pour désarchiver le jeu d'abord."
set "etext8.es=Por favor, use la opcion 1 para descomprimir el juego primero."
set "etext8.it=Si prega di utilizzare l'opzione 1 per disarchivare il gioco prima."
set "etext8.de=Bitte verwenden Sie zuerst Option 1, um das Spiel zu entpacken."
set "etext8.ru=Пожалуйста, сначала используйте опцию 1, чтобы распаковать игру."
set "etext8.zh=请先使用选项 1 来解压游戏。"

:: Check if needed files for extraction are present
set "RpysFound=0"
for /r ".\game" %%F in (*.rpy) do (
    echo %%F | "%SystemRoot%\System32\findstr.exe" /i /c:"\\tl\\" >nul 2>&1
    if errorlevel 1 set /a RpysFound+=1
)
if %RpysFound% LEQ 3 (
    call :elog .
    call :elog "%NOK%" "!etext6.%LNG%!"
    set "RpycFound=0"
    for /r ".\game" %%F in (*.rpyc) do (
        echo %%F | "%SystemRoot%\System32\findstr.exe" /i /c:"\\tl\\" >nul 2>&1
        if errorlevel 1 set /a RpycFound+=1
    )
    if !RpycFound! GTR 0 (
        call :elog "%NOK%" "!etext7.%LNG%!"
    ) else (
        call :elog "%NOK%" "!etext8.%LNG%!"
    )
    timeout /T 1 %DEBUGREDIR%
    exit /b 1
)

call :elog .
if not "%OPTION%" == "m" echo.
call :elog -n "%EMPTY%" "!etext1.%LNG%!..."

:: find the current game name by checking the presence of same name with .exe, .py and .sh extension
set "processed="
set "fname="
:: Do not test with sh, it can be not shipped
for %%e in (exe py) do (
    for %%f in (*.%%e) do (
        set "tempfname=%%~nf"

        REM Check if this name has already been processed
        echo !processed! | "%SystemRoot%\System32\findstr.exe" /i "\!tempfname!" >nul
        if errorlevel 1 (
            REM Count how many files with this name exist
            set /a count=0
            for %%x in (exe py) do (
                if exist "%%~dpf!tempfname!.%%x" (
                    set /a count+=1
                )
            )
            if !count! EQU 2 (
                call :elog "%OK%" "%YEL%!tempfname!%RES%"
                set "processed=!processed! !tempfname!"
                set "fname=!tempfname!"
                goto :found_name
            )
        )
    )
)

:: If no name found, ask user to input the name
if "%fname%"  == "" (
    call :elog "%NOK%" "!etext2.%LNG%!"
    goto :input_name
)

:input_name
call :elog .
set /p "fname=!etext5.%LNG%!"
if "%fname%" == "" (
    call :elog "%NOK%" "!etext2.%LNG%!"
    goto :input_name
) else (
    if not exist "%WORKDIR%\%fname%.exe" (
        call :elog "%NOK%" "!etext2.%LNG%!"
        goto :input_name
    )
)

:found_name
call :elog .
set /p "translation_lang=!etext3.%LNG%!"

if not defined translation_lang (
	set "translation_lang=french"
)

if not exist "%WORKDIR%\game\tl\" (
	mkdir "%WORKDIR%\game\tl"
)

call :elog .
call :elog -n "%EMPTY%" "!choicet.%LNG%!..."

setlocal disabledelayedexpansion
for /f "delims=" %%A in ("%WORKDIR%") do (
    endlocal
    cd /d "%%A"
)
if %DEBUGLEVEL% GEQ 1 echo "%PYTHONHOME%python.exe" %PYNOASSERT% "%fname%.py" game translate "%translation_lang%" >> "%UNRENLOG%"
"%PYTHONHOME%python.exe" %PYNOASSERT% "%fname%.py" game translate "%translation_lang%" %DEBUGREDIR%
if %errorlevel% NEQ 0 (
	call :elog "%NOK%" "!etext4.%LNG%!"
) else (
    call :elog "%OK%"
)
timeout /T 1 %DEBUGREDIR%
goto :finish


:: Check if old registry key is present and require Administrator rights to remove it
:check_old_reg
"%SystemRoot%\System32\reg.exe" query "HKLM\Software\Classes\Directory\shell\Run%SCRIPTNAME%" %DEBUGREDIR%
if %errorlevel% EQU 0 (
    set OLDREG=1
) else (
    set OLDREG=0
)
goto :eof


:: Add entry to registry
:add_reg
set "reg=%SystemRoot%\System32\reg.exe"

set "areg1.en=This will add an entry to the right-click menu for folders."
set "areg1.fr=Cela ajoutera une entrée au menu contextuel pour les dossiers."
set "areg1.es=Esto añadirá una entrada al menú contextual para las carpetas."
set "areg1.it=Questo aggiungerà una voce al menu contestuale per le cartelle."
set "areg1.de=Dies wird einen Eintrag zum Rechtsklick-Menü für Ordner hinzufügen."
set "areg1.ru=Это добавит элемент в контекстное меню для папок."
set "areg1.zh=这将为文件夹添加右键菜单项。"

set "areg2.en=When you select this option,"
set "areg2.fr=Lorsque vous sélectionnez cette option,"
set "areg2.es=Cuando seleccione esta opción,"
set "areg2.it=Quando selezioni questa opzione,"
set "areg2.de=Wenn Sie diese Option auswählen,"
set "areg2.ru=Когда вы выберете эту опцию,"
set "areg2.zh=当您选择此选项时，"

set "areg2a.en=the script %YEL%%SCRIPTDIR%%SCRIPTNAME%%RES% will be executed."
set "areg2a.fr=le script %YEL%%SCRIPTDIR%%SCRIPTNAME%%RES% sera exécuté."
set "areg2a.es=se ejecutará el script %YEL%%SCRIPTDIR%%SCRIPTNAME%%RES%."
set "areg2a.it=verrà eseguito lo script %YEL%%SCRIPTDIR%%SCRIPTNAME%%RES%."
set "areg2a.de=wird das Skript %YEL%%SCRIPTDIR%%SCRIPTNAME%%RES% ausgeführt."
set "areg2a.ru=будет выполнен скрипт %YEL%%SCRIPTDIR%%SCRIPTNAME%%RES%."
set "areg2a.zh=脚本 %YEL%%SCRIPTDIR%%SCRIPTNAME%%RES% 将被执行。"

set "areg3.en=Adding the right-click menu entry to the registry"
set "areg3.fr=Ajout de l'entrée de menu contextuel au registre"
set "areg3.es=Adding the right-click menu entry to the registry"
set "areg3.it=Aggiunta della voce del menu contestuale al registro"
set "areg3.de=Hinzufügen des Rechtsklick-Menüeintrags zur Registrierung"
set "areg3.ru=Добавление элемента контекстного меню в реестр"
set "areg3.zh=正在向注册表添加右键菜单项"

set "areg4.en=Run %SCRIPTNAME% Script"
set "areg4.fr=Exécuter le script %SCRIPTNAME%"
set "areg4.es=Ejecutar el script %SCRIPTNAME%"
set "areg4.it=Esegui lo script %SCRIPTNAME%"
set "areg4.de=Führen Sie das Skript %SCRIPTNAME% aus"
set "areg4.ru=Запустить скрипт %SCRIPTNAME%"
set "areg4.zh=运行 %SCRIPTNAME% 脚本"

set "areg5.en=You need to first remove the old registry key with the - option."
set "areg5.fr=Vous deez d'abord supprimer l'ancienne clé du registre avec l'option -."
set "areg5.es=Primero debe eliminar la clave de registro antigua con la opción -."
set "areg5.it=Devi prima rimuovere la vecchia chiave di registro con l'opzione -."
set "areg5.de=Sie müssen zuerst den alten Registrierungsschlüssel mit der - Option entfernen."
set "areg5.ru=Сначала вам нужно удалить старый ключ реестра с помощью опции -. "
set "areg5.zh=您需要先使用 - 选项删除旧的注册表键。"

call :check_old_reg
if %OLDREG% EQU 1 (
    call :elog .
    call :elog "%YEL%!areg5.%LNG%!%RES%"
    call :elog .
    pause>nul|set /p=".      !ANYKEY.%LNG%!..."
    exit /b
)

call :elog .
call :elog "!areg1.%LNG%!"
call :elog "!areg2.%LNG%!"
call :elog "!areg2a.%LNG%!%RES%"
call :elog .
call :elog -n "%EMPTY%" "!areg3.%LNG%!..."

"%regexe%" add "HKCU\Software\Classes\Directory\shell\Run%SCRIPTNAME%" /ve /d "!areg4.%LNG%!" /f %DEBUGREDIR%
set error=%errorlevel%
"%regexe%" add "HKCU\Software\Classes\Directory\shell\Run%SCRIPTNAME%" /v "Icon" /d "%SystemRoot%\System32\shell32.dll,-154" /f %DEBUGREDIR%
set /a error=%error%+%errorlevel%
"%regexe%" add "HKCU\Software\Classes\Directory\shell\Run%SCRIPTNAME%\command" /ve /d "%SystemRoot%\System32\cmd.exe /c cd /d \"%%V\" && \"%SCRIPTDIR%%SCRIPTNAME%\" \"%%V\"" /f %DEBUGREDIR%
set /a error=%error%+%errorlevel%
"%regexe%" add "HKCU\Software\Classes\Directory\Background\shell\Run%SCRIPTNAME%" /ve /d "!areg4.%LNG%!" /f %DEBUGREDIR%
set error=%errorlevel%
"%regexe%" add "HKCU\Software\Classes\Directory\Background\shell\Run%SCRIPTNAME%" /v "Icon" /d "%SystemRoot%\System32\shell32.dll,-154" /f %DEBUGREDIR%
set /a error=%error%+%errorlevel%
"%regexe%" add "HKCU\Software\Classes\Directory\Background\shell\Run%SCRIPTNAME%\command" /ve /d "%SystemRoot%\System32\cmd.exe /c cd /d \"%%V\" && \"%SCRIPTDIR%%SCRIPTNAME%\" \"%%V\"" /f %DEBUGREDIR%
set /a error=%error%+%errorlevel%
if %error% EQU 0 (
	call :elog "%OK%"
) else (
	call :elog "%NOK%" "!LOGCHK.%LNG%!"
)
call :elog .

timeout /T 1 %DEBUGREDIR%
goto :finish


:: Remove entry from registry
:remove_reg
set "regexe=%SystemRoot%\System32\reg.exe"

set "rreg1.en=This will remove the previously added entry from the right-click menu for folders."
set "rreg1.fr=Cela supprimera l'entrée précédemment ajoutée du menu contextuel pour les dossiers."
set "rreg1.es=Esto eliminará la entrada previamente añadida del menú contextual para las carpetas."
set "rreg1.it=Questo rimuoverà la voce precedentemente aggiunta dal menu contestuale per le cartelle."
set "rreg1.de=Dies wird den zuvor hinzugefügten Eintrag aus dem Rechtsklick-Menü für Ordner entfernen."
set "rreg1.ru=Это удалит ранее добавленный элемент из контекстного меню для папок."
set "rreg1.zh=这将移除先前为文件夹添加的右键菜单项。"

set "rreg2.en=Removing the right-click menu entry from the registry"
set "rreg2.fr=Suppression de l'entrée de menu contextuel du registre"
set "rreg2.es=Eliminando la entrada del menú contextual del registro"
set "rreg2.it=Rimozione della voce del menu contestuale dal registro"
set "rreg2.de=Entfernen des Rechtsklick-Menüeintrags aus der Registrierung"
set "rreg2.ru=Удаление элемента контекстного меню из реестра"
set "rreg2.zh=正在从注册表中移除右键菜单项"

:: Remove registry key with Administrator rights if old registry key is present,
:: otherwise remove registry key with current user rights
set OLDREG=0
call :check_old_reg
if %OLDREG% EQU 1 (
    call :check_admin
)

call :elog .
call :elog .
call :elog "!rreg1.%LNG%!"
call :elog .
call :elog -n "%EMPTY%" "!rreg2.%LNG%!..."

set error=0
if %OLDREG% EQU 1 (
    "!regexe!" query "HKLM\SOFTWARE\Classes\Directory\shell\RunUnrenForAll" %DEBUGREDIR%
    if !errorlevel! EQU 0 (
        "!regexe!" delete "HKLM\SOFTWARE\Classes\Directory\shell\RunUnrenForAll" /f %DEBUGREDIR%
        set error=!errorlevel!
    )
    "!regexe!" query "HKLM\SOFTWARE\Classes\Directory\shell\Run%SCRIPTNAME%" %DEBUGREDIR%
    if !errorlevel! EQU 0 (
        "!regexe!" delete "HKLM\SOFTWARE\Classes\Directory\shell\Run%SCRIPTNAME%" /f %DEBUGREDIR%
        set /a error=!error!+!errorlevel!
    )
    "!regexe!" query "HKLM\SOFTWARE\Classes\Directory\Background\shell\Run%SCRIPTNAME%" %DEBUGREDIR%
    if !errorlevel! EQU 0 (
        "!regexe!" delete "HKLM\SOFTWARE\Classes\Directory\Background\shell\Run%SCRIPTNAME%" /f %DEBUGREDIR%
        set /a error=!error!+!errorlevel!
    )
    if !error! NEQ 0 (
        call :elog "%NOK%" "!ARIGHT.%LNG%!"
        call :elog .
        pause>nul|set /p=".      !ANYKEY.%LNG%!..."

        call :exitn 3
    )
) else (
    "!regexe!" query "HKCU\Software\Classes\Directory\shell\Run%SCRIPTNAME%" %DEBUGREDIR%
    if !errorlevel! EQU 0 (
        "!regexe!" delete "HKCU\Software\Classes\Directory\shell\Run%SCRIPTNAME%" /f %DEBUGREDIR%
        set error=!errorlevel!
    )
    "!regexe!" query "HKCU\Software\Classes\Directory\Background\shell\Run%SCRIPTNAME%" %DEBUGREDIR%
    if !errorlevel! EQU 0 (
        "!regexe!" delete "HKCU\Software\Classes\Directory\Background\shell\Run%SCRIPTNAME%" /f %DEBUGREDIR%
        set /a error=!error!+!errorlevel!
    )
    if !error! NEQ 0 (
        call :elog "%NOK%"
    )
)
if !error! EQU 0 (
    call :elog "%OK%"
    set OLDREG=0
)

timeout /T 1 %DEBUGREDIR%
goto :finish


:: Check for administrative privileges
:check_admin
setlocal
set "admright.en=Check Admin right"
set "admright.fr=Vérification des droits administrateur"
set "admright.es=Comprobando derechos de administrador"
set "admright.it=Controllo dei diritti di amministratore"
set "admright.de=Überprüfung der Administratorrechte"
set "admright.ru=Проверка прав администратора"
set "admright.zh=检查管理员权限"

set "admright2.en=You did not run this script with administrator privileges."
set "admright2.fr=Vous n'avez pas lancé ce script avec des droits administrateur."
set "admright2.es=No ha iniciado este script con derechos de administrador."
set "admright2.it=Non hai avviato questo script con diritti di amministratore."
set "admright2.de=Sie haben dieses Skript nicht mit Administratorrechten gestartet."
set "admright2.ru=Вы не запустили этот скрипт с правами администратора."
set "admright2.zh=您没有以管理员权限运行此脚本。"

set "admright3.en=Restart the script with administrator rights."
set "admright3.fr=Relance du script avec des droits administrateur."
set "admright3.es=Reinicie el script con derechos de administrador."
set "admright3.it=Riavvia lo script con diritti di amministratore."
set "admright3.de=Starten Sie das Skript mit Administratorrechten neu."
set "admright3.ru=Перезапустите скрипт с правами администратора."
set "admright3.zh=请以管理员权限重新启动脚本。"

call :elog .
call :elog .
call :elog -n "%EMPTY%" "!admright.%LNG%!..."

net session %DEBUGREDIR%
if %errorlevel% EQU 0 (
    call :elog "%OK%"
) else (
	call :elog "%NOK%"
    call :elog .
    call :elog "!admright2.%LNG%!"
    call :elog "!admright3.%LNG%!"
    call :elog .
    timeout /T 2 %DEBUGREDIR%
    if %DEBUGLEVEL% GEQ 1 echo "%PWRSHELL%" -NoProfile -Command "Start-Process '%~f0' -ArgumentList '%WORKDIR%' -Verb RunAs" >> "%UNRENLOG%"
    "%PWRSHELL%" -NoProfile -Command "Start-Process '%~f0' -ArgumentList '%WORKDIR%' -Verb RunAs" %DEBUGREDIR%

    goto :exitn
)
endlocal
goto :eof


:: Replace batch file if updated an set relauch if needed
:update_file
set "updating.en=Updating batch file: "
set "updating.fr=Mise à jour du fichier batch : "
set "updating.es=Actualizando archivo por lotes: "
set "updating.it=Aggiornamento del file batch: "
set "updating.de=Aktualisierung der Batch-Datei: "
set "updating.ru=Обновление пакетного файла: "
set "updating.zh=正在更新批处理文件："

set "rupdating.en=Updating the running batch file: "
set "rupdating.fr=Mise à jour du fichier batch en cours : "
set "rupdating.es=Actualizando el archivo por lotes en ejecución: "
set "rupdating.it=Aggiornamento del file batch in esecuzione: "
set "rupdating.de=Aktualisierung der laufenden Batch-Datei: "
set "rupdating.ru=Обновление запущенного пакетного файла: "
set "rupdating.zh=正在更新运行中的批处理文件："

set "batch_name=%~1"
set "running_batch=%~nx0"

:: If no difference do nothing
"%SystemRoot%\System32\fc.exe" "%UPD_TDIR%\%batch_name%.bat" "%SCRIPTDIR%%batch_name%.bat" %DEBUGREDIR%
if %errorlevel% EQU 0 (
    goto :eof
)

:: Check if the new batch file is different from the running one
if "%batch_name%.bat" == "%running_batch%" goto :special_upd

call :elog -n "%EMPTY%" "!updating.%LNG%! %YEL%%SCRIPTDIR%%batch_name%.bat%RES%"
move /y "%SCRIPTDIR%%batch_name%.bat" "%SCRIPTDIR%%batch_name%.old" %DEBUGREDIR%
if %errorlevel% NEQ 0 (
    call :elog "%NOK%" "!LOGCHK.%LNG%!"
    call :elog .
    pause>nul|set /p=".      !ANYKEY.%LNG%!..."

    call :exitn 2
)
copy /y "%UPD_TDIR%\%batch_name%.bat" "%SCRIPTDIR%%batch_name%.bat" %DEBUGREDIR%
if %errorlevel% NEQ 0 (
    call :elog "%NOK%" "!LOGCHK.%LNG%!"
    call :elog .
    pause>nul|set /p=".      !ANYKEY.%LNG%!..."

    call :exitn 2
) else (
    call :elog "%OK%"
)
timeout /T 2 %DEBUGREDIR%
goto :eof


:special_upd
call :elog -n "%EMPTY%" "!rupdating.%LNG%! %YEL%%SCRIPTDIR%%batch_name%.bat %RES%"
copy /y "%SCRIPTDIR%%batch_name%.bat" "%SCRIPTDIR%%batch_name%.old" %DEBUGREDIR%
if %errorlevel% NEQ 0 (
    call :elog "%NOK%" "!LOGCHK.%LNG%!"
    call :elog .
    pause>nul|set /p=".      !ANYKEY.%LNG%!..."

    call :exitn 2
)
copy /y "%UPD_TDIR%\%batch_name%.bat" "%SCRIPTDIR%%batch_name%-new.bat" %DEBUGREDIR%
if %errorlevel% NEQ 0 (
    call :elog "%NOK%" "!LOGCHK.%LNG%!"
    call :elog .
    pause>nul|set /p=".      !ANYKEY.%LNG%!..."

    call :exitn 2
) else (
    call :elog "%OK%"
)
set "relaunch=1"
goto :eof


:: When it's not unavailable, show message and exit
:unavailable
setlocal
if "%RENPYVERSION%" == "7" (
    set "unavailable.en=This feature is unavailable in this version."
    set "unavailable.fr=Cette fonctionnalité n'est pas disponible dans cette version."
    set "unavailable.es=Esta función no está disponible en esta versión."
    set "unavailable.it=Questa funzione non è disponibile in questa versione."
    set "unavailable.de=Diese Funktion ist in dieser Version nicht verfügbar."
    set "unavailable.ru=Эта функция недоступна в этой версии."
    set "unavailable.zh=此功能在此版本中不可用。"
)
if "%RENPYVERSION%" == "8" (
    set "unavailable.en=This feature is unavailable for now, need more coding."
    set "unavailable.fr=Cette fonctionnalité n'est pas disponible pour le moment, nécessite plus de codage."
    set "unavailable.es=Esta función no está disponible por ahora, necesita más codificación."
    set "unavailable.it=Questa funzione non è disponibile per ora, necessita di più codice."
    set "unavailable.de=Diese Funktion ist derzeit nicht verfügbar, es wird mehr Programmierung benötigt."
    set "unavailable.ru=Эта функция недоступна, требуется больше кода."
    set "unavailable.zh=此功能暂不可用，需要更多编码。"
)

call :elog .
call :elog "%WARN%" "!unavailable.%LNG%!"

timeout /T 2 %DEBUGREDIR%
endlocal
goto :menu


:: Verify if an update is necessary
:check_update
:: This URL should point to a text file containing the latest version link
set "upd_url=https://github.com/Lurmel/UnRen-forall/blob/main/UnRen-link.txt?raw=true"
set "upd_link=UnRen-link"
set "upd_file=UnRen-new"
set "upd_clog=UnRen-Changelog"
set "new_upd=0"
set "relaunch=0"

set "cupd1.en=Checking for updates"
set "cupd1.fr=Vérification des mises à jour"
set "cupd1.es=Comprobando si hay actualizaciones"
set "cupd1.it=Controllo degli aggiornamenti"
set "cupd1.de=Überprüfung auf Updates"
set "cupd1.ru=Проверка обновлений"
set "cupd1.zh=正在检查更新"

set "cupd2.en=No updates found."
set "cupd2.fr=Aucune mise à jour trouvée."
set "cupd2.es=No se encontraron actualizaciones."
set "cupd2.it=Nessun aggiornamento trovato."
set "cupd2.de=Keine Updates gefunden."
set "cupd2.ru=Обновлений не найдено."
set "cupd2.zh=未找到更新。"

set "cupd3.en=An update is available."
set "cupd3.fr=Une mise à jour est disponible."
set "cupd3.es=Una actualización está disponible."
set "cupd3.it=Un aggiornamento è disponibile."
set "cupd3.de=Ein Update ist verfügbar."
set "cupd3.ru=Доступно обновление."
set "cupd3.zh=有可用的更新。"

set "cupd4.en=Downloading the latest version from:"
set "cupd4.fr=Téléchargement de la dernière version depuis :"
set "cupd4.es=Descargando la última versión desde:"
set "cupd4.it=Download dell'ultima versione da:"
set "cupd4.de=Herunterladen der neuesten Version von:"
set "cupd4.ru=Загрузка последней версии с:"
set "cupd4.zh=正在从以下位置下载最新版本："

set "cupd5.en=Update complete."
set "cupd5.fr=Mise à jour terminée."
set "cupd5.es=Actualización completa."
set "cupd5.it=Aggiornamento completato."
set "cupd5.de=Update abgeschlossen."
set "cupd5.ru=Обновление завершено."
set "cupd5.zh=更新完成。"

set "cupd6.en=Error downloading update."
set "cupd6.fr=Erreur lors du téléchargement de la mise à jour."
set "cupd6.es=Error al descargar la actualización."
set "cupd6.it=Errore durante il download dell'aggiornamento."
set "cupd6.de=Fehler beim Herunterladen des Updates."
set "cupd6.ru=Ошибка при загрузке обновления."
set "cupd6.zh=下载更新时出错。"

set "cupd7.en=Do you want to update now? [Y/N] (default: N):"
set "cupd7.fr=Voulez-vous faire la mise à jour maintenant ? [O/N] (défaut : N) :"
set "cupd7.es=¿Desea actualizar ahora? [S/N] (predeterminado: N):"
set "cupd7.it=Vuoi aggiornare adesso? [S/N] (impostazione predefinita: N):"
set "cupd7.de=Möchten Sie jetzt aktualisieren? [Y/N] (Standard: N):"
set "cupd7.ru=Хотите обновиться сейчас? [Y/N] (по умолчанию: N):"
set "cupd7.zh=是否立即更新？[Y/N]（默认 N）："

set "cupd8.en=No download update link found."
set "cupd8.fr=Aucun lien de téléchargement de mise à jour trouvé."
set "cupd8.es=No se encontró el enlace de descarga de la actualización."
set "cupd8.it=Non è stato trovato il link per il download dell'aggiornamento."
set "cupd8.de=Kein Download-Update-Link gefunden."
set "cupd8.ru=Ссылка для загрузки обновления не найдена."
set "cupd8.zh=未找到下载更新链接。"

call :elog .
call :elog -n "%EMPTY%" "!cupd1.%LNG%!..."
del /f /q "%TEMP%\%upd_link%.tmp" %DEBUGREDIR%
if %DEBUGLEVEL% GEQ 1 echo "%PWRSHELL%" -NoProfile -Command "(New-Object System.Net.WebClient).DownloadFile('%upd_url%', '%TEMP%\%upd_link%.tmp')" >> "%UNRENLOG%"
"%PWRSHELL%" -NoProfile -Command "(New-Object System.Net.WebClient).DownloadFile('%upd_url%', '%TEMP%\%upd_link%.tmp')" %DEBUGREDIR%
if not exist "%TEMP%\%upd_link%.tmp" (
    call :elog "%NOK%" "!cupd6.%LNG%!"
    goto :eof
) else (
    REM First time
    if not exist "%SCRIPTDIR%%upd_link%.txt" (
        copy /y nul "%SCRIPTDIR%%upd_link%.txt" %DEBUGREDIR%
    )
    "%SystemRoot%\System32\fc.exe" "%TEMP%\%upd_link%.tmp" "%SCRIPTDIR%%upd_link%.txt" %DEBUGREDIR%
    if !errorlevel! GEQ 1 (
        call :elog "%OK%" "%YEL%!cupd3.%LNG%!%RES%"

        REM Rename and launch %upd_link%.bat to generate UnRen-Changelog.txt
        copy /y "%TEMP%\%upd_link%.tmp" "%SCRIPTDIR%%upd_link%.bat" %DEBUGREDIR%
        set "forall_url="
        call "%SCRIPTDIR%%upd_link%.bat" %DEBUGREDIR%
        del /f /q "%SCRIPTDIR%%upd_link%.bat" %DEBUGREDIR%
        if not defined forall_url (
            call :elog "%NOK%" "%YEL%!cupd8.%LNG%!%RES%"
            call :elog .
            timeout /T 1 %DEBUGREDIR%
            goto :eof
        )
        move /y "%SCRIPTDIR%%upd_clog%.txt" "%SCRIPTDIR%%upd_clog%.b64" %DEBUGREDIR%
        if %DEBUGLEVEL% GEQ 1 echo "%PWRSHELL%" -NoProfile -Command "[IO.File]::WriteAllBytes('%SCRIPTDIR%%upd_clog%.tmp', [Convert]::FromBase64String((Get-Content '%SCRIPTDIR%%upd_clog%.b64' -Raw)))" >> "%UNRENLOG%"
        "%PWRSHELL%" -NoProfile -Command "[IO.File]::WriteAllBytes('%SCRIPTDIR%%upd_clog%.tmp', [Convert]::FromBase64String((Get-Content '%SCRIPTDIR%%upd_clog%.b64' -Raw)))" %DEBUGREDIR%
        call :elog .
        type "%SCRIPTDIR%%upd_clog%.tmp"
        del /f /q "%SCRIPTDIR%%upd_clog%.b64" %DEBUGREDIR%
        del /f /q "%SCRIPTDIR%%upd_clog%.tmp" %DEBUGREDIR%

        call :elog .
        call :elog .
        call :choiceEx "!cupd7.%LNG%!" "OSJYN" "N" "%CTIME%" "-rawMsg"
        if !errorlevel! EQU 5 goto :eof
        set "new_upd=1"
    ) else (
        call :elog "%SKIP%" "%YEL%!cupd2.%LNG%!%RES%"

        goto :eof
    )
)

call :elog .
call :elog "!INCASEOF.%LNG%!%RES%"
call :elog "%MAG%%URL_REF%%RES%"
if %new_upd% EQU 1 (
    call :elog .
    call :elog -n "%EMPTY%" "!cupd4.%LNG%! %YEL%%forall_url%%RES%..."
    if %DEBUGLEVEL% GEQ 1 echo "%PWRSHELL%" -NoProfile -Command "(New-Object System.Net.WebClient).DownloadFile('%forall_url%','%TEMP%\%upd_file%.tmp')" >> "%UNRENLOG%"
    "%PWRSHELL%" -NoProfile -Command "(New-Object System.Net.WebClient).DownloadFile('%forall_url%','%TEMP%\%upd_file%.tmp')" %DEBUGREDIR%
    if not exist "%TEMP%\%upd_file%.tmp" (
        call :elog "%NOK%" "%YEL%!cupd6.%LNG%!%RES%"
        call :elog .
        timeout /T 1 %DEBUGREDIR%

        goto :eof
    ) else (
        move /y "%TEMP%\%upd_file%.tmp" "%TEMP%\%upd_file%.zip" %DEBUGREDIR%
        if not exist "%TEMP%\%upd_file%.zip" (
            call :elog "%NOK%" "%YEL%!cupd6.%LNG%!%RES%"
            call :elog .
            timeout /T 1 %DEBUGREDIR%

            goto :eof
        ) else (
            if exist "%UPD_TDIR%" rd /s /q "%UPD_TDIR%" %DEBUGREDIR%
            mkdir "%UPD_TDIR%" %DEBUGREDIR%
            echo "%PWRSHELL%" -NoProfile -Command "Expand-Archive -Path '%TEMP%\%upd_file%.zip' -DestinationPath '%UPD_TDIR%' -Force" >> "%UNRENLOG%"
            "%PWRSHELL%" -NoProfile -Command "Expand-Archive -Path '%TEMP%\%upd_file%.zip' -DestinationPath '%UPD_TDIR%' -Force" %DEBUGREDIR%
            if !errorlevel! NEQ 0 (
                call :elog "%NOK%" "%YEL%!cupd6.%LNG%!%RES%"
                call :elog .
                timeout /T 1 %DEBUGREDIR%

                goto :eof
            ) else (
                del /f /q "%TEMP%\%upd_file%.zip" %DEBUGREDIR%
            )
            for %%f in (forall legacy current) do (
                call :update_file "UnRen-%%~f"
            )
            copy /y "%TEMP%\%upd_link%.tmp" "%SCRIPTDIR%%upd_link%.txt" %DEBUGREDIR%
            rd /s /q "%UPD_TDIR%" %DEBUGREDIR%
            if !relaunch! EQU 1 (
                call :elog .
                timeout /T 1 %DEBUGREDIR%
                call "%SCRIPTDIR%!BASENAME!-new.bat" "%WORKDIR%"

                call :exitn 0
            )
            call :elog .
            call :elog "%OK%" "%YEL%!cupd5.%LNG%!%RES%"
            call :elog .
        )
    )
)
timeout /T 2 %DEBUGREDIR%
goto :eof


:: Check if all files were downloaded successfully
:check_all_files
set "cfile.en=Verification that all files are present"
set "cfile.fr=Vérification que tous les fichiers sont présents"
set "cfile.es=Verificación de que todos los archivos están presentes"
set "cfile.it=Verifica che tutti i file siano presenti"
set "cfile.de=Überprüfung, ob alle Dateien vorhanden sind"
set "cfile.ru=Проверка наличия всех файлов"
set "cfile.zh=验证所有文件是否存在"

set "cdwnld.en=Download the missing file from:"
set "cdwnld.fr=Télécharger le fichier manquant depuis :"
set "cdwnld.es=Descargar el archivo faltante de:"
set "cdwnld.it=Scarica il file mancante da:"
set "cdwnld.de=Fehlende Datei herunterladen von:"
set "cdwnld.ru=Скачать недостающий файл с:"
set "cdwnld.zh=从以下位置下载缺失的文件："

call :elog -n "%EMPTY%" "!cfile.%LNG%!..."
for %%F in (legacy current forall) do (
    if not exist "%SCRIPTDIR%UnRen-%%~F.bat" (
        call :elog "%NOK%" "%YEL%!FNOTFOUND.%LNG%! %YEL%UnRen-%%~F %RES%"
        call :elog .
        call :elog "!cdwnld.%LNG%! %RES%"
        call :elog "%MAG%%URL_REF% %RES%"
        call :elog .
        pause>nul|set /p=".      !ANYKEY.%LNG%!..."

        call :exitn 3
    ) else (
        <nul set /p="."
    )
)

:: Cleaning after an update
set "BASENAMENONEW=%BASENAME:-new=%"
if exist "%SCRIPTDIR%%BASENAMENONEW%-new.bat" (
    if "%SCRIPTNAME%" == "%BASENAMENONEW%-new.bat" (
        copy /y "%SCRIPTDIR%%BASENAMENONEW%-new.bat" "%SCRIPTDIR%%BASENAMENONEW%.bat" %DEBUGREDIR%
    ) else (
        del /f /q "%SCRIPTDIR%%BASENAME%-new.bat" %DEBUGREDIR%
    )
)
del /f /q "%SCRIPTDIR%%BASENAMENONEW%.old" %DEBUGREDIR%

call :elog "%OK%"
exit /b


:: We are done and go back to menu
:finish
if "%OPTION%" == "m" goto :eof
echo.
timeout /t 2 %DEBUGREDIR%
if "%nocls%" EQU 0 cls

goto :menu


:: Params:
:: 1 - Message to display
:: 2 - Choices list (e.g. "YN" for Yes/No)
:: 3 - Default choice (e.g. "N" for No)
:: 4 - Timeout in seconds (e.g. "10" for 10 seconds)
:: 5 - Additional options (optional) (e.g. "-rawMsg" to not encapsulate the default choice in the choice list)
:choiceEx
set "choiceEx=%TEMP%\choiceEx.py"
if not exist "%choiceEx%" if not defined AlreadyCreated (
    >"%choiceEx%.b64" (
        <nul set /p="IyEvdXNyL2Jpbi9lbnYgcHl0aG9uDQojIC0qLSBjb2Rpbmc6IHV0Zi04IC0qLQ0KDQppbXBvcnQgc3lzDQppbXBvcnQgdGltZQ0KaW1wb3J0IG1zdmNydA0KaW1wb3J0IGNvZGVjcw0KDQppZiBzeXMudmVyc2lvbl9pbmZvWzBdIDwgMzoNCiAgICBpbXBvcnQgY3R5cGVzDQogICAgIyBGb3JjZSBsYSBjb25zb2xlIFdpbmRvd3MgZW4gVVRGLTgNCiAgICBjdHlwZXMud2luZGxsLmtlcm5lbDMyLlNldENvbnNvbGVDUCg2NTAwMSkNCiAgICBjdHlwZXMud2luZGxsLmtlcm5lbDMyLlNldENvbnNvbGVPdXRwdXRDUCg2NTAwMSkNCg0KICAgICMgQ1JVQ0lBTDogRW52ZWxvcHBlIHN0ZG91dCBhdmVjIHVuIHdyaXRlciBVVEYtOA0KICAgIHN5cy5zdGRvdXQgPSBjb2RlY3MuZ2V0d3JpdGVyKCd1dGYtOCcpKHN5cy5zdGRvdXQpDQogICAgc3lzLnN0ZGVyciA9IGNvZGVjcy5nZXR3cml0ZXIoJ3V0Zi04Jykoc3lzLnN0ZGVycikNCg0KIyBHw6hyZSBsZXMgZGV1eCBQeXRob24gMiBldCAzDQppZiBzeXMudmVyc2lvbl9pbmZvWzBdIDwgMzoNCiAgICBtc2cgPSBzeXMuYXJndlsxXS5kZWNvZGUoJ2xhdGluLTEnKSBpZiBpc2luc3RhbmNlKHN5cy5hcmd2WzFdLCBzdHIpIGVsc2Ugc3lzLmFyZ3ZbMV0NCmVsc2U6DQogICAgbXNnID0gc3lzLmFyZ3ZbMV0NCg0KY2hvaWNlcyAgICAgPSBzeXMuYXJndlsyXQ0KZGVmYXVsdCAgICAgPSBzeXMuYXJndlszXQ0KdGltZW91dCAgICAgPSBpbnQoc3lzLmFyZ3ZbNF0pDQpyYXcgICAgICAgICA9IChsZW4oc3lzLmFyZ3YpID4gNSBhbmQgc3lzLmFyZ3ZbNV0gPT0gIi1yYXdNc2ciKQ0KDQppZiByYXc6DQogICAgZGlzcGxheSA9IG1zZw0KZWxzZToNCiAgICBkaXNwID0gWyJbJXNdIiAlIGMgaWYgYyA9PSBkZWZhdWx0IGVsc2UgYyBmb3IgYyBpbiBjaG9pY2VzXQ0KICAgIGRpc3BsYXkgPSAiJXMgKCVzLCB0aW1lb3V0ICVzcykgOiAiICUgKG1zZywgJy8nLmpvaW4oZGlzcCksIHRpbWVvdXQpDQoNCnN5cy5zdGRvdXQud3JpdGUoZGlzcGxheSkNCnN5cy5zdGRvdXQuZmx1c2goKQ0KDQplbmQgPSB0aW1lLnRpbWUoKSArIHRpbWVvdXQNCnJlc3VsdCA9IGRlZmF1bHQNCg0Kd2hpbGUgdGltZS50aW1lKCkgPCBlbmQ6DQogICAgaWYgbXN2Y3J0LmtiaGl0KCk6DQogICAgICAgIGtleSA9IG1zdmNydC5nZXR3Y2goKQ0KICAgICAgICBpZiBrZXkgPT0gIlxyIjogICMgRW50ZXINCiAgICAgICAgICAgIGJyZWFrDQogICAgICAgIGtleSA9IGtleS51cHBlcigpDQogICAgICAgIGlmIGtleSBpbiBjaG9pY2VzOg0KICAgICAgICAgICAgcmVzdWx0ID0ga2V5DQogICAgICAgICAgICBicmVhaw0KICAgIHRpbWUuc2xlZXAoMC4wNSkNCg0Kc3lzLnN0ZG91dC53cml0ZShyZXN1bHQpDQpzeXMuc3Rkb3V0LndyaXRlKCJcbiIpDQpzeXMuZXhpdChjaG9pY2VzLmluZGV4KHJlc3VsdCkgKyAxKQ=="
    )
    if defined PYTHONHOME (
        if %DEBUGLEVEL% GEQ 1 echo "%PYTHONHOME%python.exe" %PYNOASSERT% "%TEMP%\b64decode.py" "%choiceEx%.b64" "%choiceEx%.tmp" >> "%UNRENLOG%"
        "%PYTHONHOME%python.exe" %PYNOASSERT% "%TEMP%\b64decode.py" "%choiceEx%.b64" "%choiceEx%.tmp" %DEBUGREDIR%
    ) else (
        if %DEBUGLEVEL% GEQ 1 echo "%PWRSHELL%" -NoProfile -Command "& { [IO.File]::WriteAllBytes('%choiceEx%.tmp', [Convert]::FromBase64String([IO.File]::ReadAllText('%choiceEx%.b64')))}" >> "%UNRENLOG%"
        "%PWRSHELL%" -NoProfile -Command "& { [IO.File]::WriteAllBytes('%choiceEx%.tmp', [Convert]::FromBase64String([IO.File]::ReadAllText('%choiceEx%.b64')))}" %DEBUGREDIR%
    )
    if %DEBUGLEVEL% GEQ 1 echo move /y "%choiceEx%.tmp" "%choiceEx%" >> "%UNRENLOG%"
    move /y "%choiceEx%.tmp" "%choiceEx%" %DEBUGREDIR%
    if %DEBUGLEVEL% GEQ 1 del /f /q "%choiceEx%.b64" >> "%UNRENLOG%"
    del /f /q "%choiceEx%.b64" %DEBUGREDIR%
    set "AlreadyCreated=1"
)

if %DEBUGLEVEL% GEQ 1 echo "%PYTHONHOME%python.exe" %PYNOASSERT% "%choiceEx%" "%~1" "%~2" "%~3" "%~4" "%~5" >> "%UNRENLOG%"
"%PYTHONHOME%python.exe" %PYNOASSERT% "%choiceEx%" "%~1" "%~2" "%~3" "%~4" "%~5"

exit /b %errorlevel%


:: For debugging help
:DisplayVars
set "emsg=%~1"

>> "%UNRENLOG%" echo.
echo "%emsg%" >> "%UNRENLOG%"
echo SCRIPTDIR      = %SCRIPTDIR% >> "%UNRENLOG%"
echo WORKDIR        = %WORKDIR% >> "%UNRENLOG%"
echo PYTHONHOME     = %PYTHONHOME% >> "%UNRENLOG%"
echo PYTHONPATH     = %PYTHONPATH% >> "%UNRENLOG%"
echo PYTHONEXE      = %PYTHONEXE% >> "%UNRENLOG%"
echo PYNOASSERT     = [%PYNOASSERT%] >> "%UNRENLOG%"
echo PYVERSION      = [%PYVERSION%] >> "%UNRENLOG%"
echo PYVERSION2     = [%PYVERSION2%] >> "%UNRENLOG%"
echo PYVERSION3     = [%PYVERSION3%] >> "%UNRENLOG%"
echo PYTHONSYSTEM   = [%PYTHONSYSTEM%] >> "%UNRENLOG%"
echo PYTHONVERS     = [%PYTHONVERS%] >> "%UNRENLOG%"
echo RPATOOL_NEW    = %RPATOOL_NEW% >> "%UNRENLOG%"
echo UNRPYC_NEW     = %UNRPYC_NEW% >> "%UNRENLOG%"
echo RENPYVERSION   = [%RENPYVERSION%] >> "%UNRENLOG%"
echo OFFSET         = [%OFFSET%] >> "%UNRENLOG%"
>> "%UNRENLOG%" echo.
goto :eof


:: Expand a b64-encoded and save it as a file
:: Usage:
::   call :pwsh_exp "Message to display while expanding" "path\to\file_to_expand"
:pwsh_exp
set "expmsg=%~1"
set "f2expand=%~2"
::set DEBUGLEVEL=1

if %DEBUGLEVEL% GEQ 1 (
    echo "expmsg=%expmsg%" >> "%UNRENLOG%"
    echo "f2expand=%f2expand%" >> "%UNRENLOG%"
    echo "PREVMSG=%PREVMSG%" >> "%UNRENLOG%"
    echo "PREVMOD=%PREVMOD%" >> "%UNRENLOG%"
)

call :elog -n "%EMPTY%" "%expmsg%"
if not exist "%f2expand%.b64" (
    call :elog "%NOK%" "!FCREATE.%LNG%! %YEL%!f2expand!.b64%RES%"
    goto :eof
) else (
    set "f2ps=!f2expand:'=''!"
    if defined PYTHONHOME (
        if %DEBUGLEVEL% GEQ 1 echo "%PYTHONHOME%python.exe" %PYNOASSERT% "%TEMP%\b64decode.py" "!f2ps!.b64" "!f2ps!.tmp" >> "%UNRENLOG%"
        "%PYTHONHOME%python.exe" %PYNOASSERT% "%TEMP%\b64decode.py" "!f2ps!.b64" "!f2ps!.tmp"
    ) else (
        if %DEBUGLEVEL% GEQ 1 echo "%PWRSHELL%" -NoProfile -Command "& { $src='!f2ps!.b64'; $dst='!f2ps!.tmp'; [IO.File]::WriteAllBytes($dst, [Convert]::FromBase64String([IO.File]::ReadAllText($src)))}" >> "%UNRENLOG%"
        "%PWRSHELL%" -NoProfile -Command "& { $src='!f2ps!.b64'; $dst='!f2ps!.tmp'; [IO.File]::WriteAllBytes($dst, [Convert]::FromBase64String([IO.File]::ReadAllText($src)))}" %DEBUGREDIR%
    )
    if %DEBUGLEVEL% GEQ 1 echo del /f /q "!f2expand!.b64" >> "%UNRENLOG%"
    del /f /q "!f2expand!.b64" %DEBUGREDIR%
    if not exist "%f2expand%.tmp" (
        call :elog "%NOK%" "!FCREATE.%LNG%! %YEL%!f2expand!.tmp%RES%"
        goto :eof
    ) else (
        if %DEBUGLEVEL% GEQ 1 echo move /y "!f2expand!.tmp" "!f2expand!" >> "%UNRENLOG%"
        move /y "!f2expand!.tmp" "!f2expand!" %DEBUGREDIR%
    )
)
set "expmsg=" & set "f2expand=" & set "f2ps="
::set DEBUGLEVEL=0
goto :eof


:: elog  —  Enhanced echo with optional no-newline mode
::
:: Usage:
::   call :elog .                         Print an empty line
::   call :elog "msg"                     Print msg with newline
::   call :elog "msg" "msg2"              Print msg and msg2 with newline
::   call :elog -n "module" "msg"         Print [module] msg without newline, store module and msg for next call
::   call :elog "status"                  After -n: replace [module] with [status], reprint msg, add newline
::   call :elog "status" "supplement"     After -n: replace [module] with [status], reprint msg and supplement, add newline
::   call :elog .                         After -n: clear the line and reprint msg alone, without the module
::
:: Where module/status is one of: %EMPTY%, %OK%, %NOK%, %SKIP%
::
:: ANSI codes are stripped when writing to the log file.
:elog
setlocal EnableDelayedExpansion

if %DEBUGLEVEL% GEQ 1 (
    setlocal enabledelayedexpansion
    set "arg2=%~2"
    set "arg2=!arg2:(=^(!"
    set "arg2=!arg2:)=^)!"
    echo arg2=!arg2! >> "%UNRENLOG%"
    endlocal
)
if "%~1" == "-n" (
    <nul set /p="[2K[1000D%~2 %~3"
    endlocal & set "PREVMOD=%~2" & set "PREVMSG=%~3"
    goto :eof
)

set "msg=%~1"
set "msg2=%~2"

:: Calculation of cleanmsg (without ANSI codes)
if defined PREVMOD (
    if defined msg2 (
        set "cleanmsg=%~1 %PREVMSG% %~2"
    ) else (
        set "cleanmsg=%~1 %PREVMSG%"
    )
) else (
    if defined msg2 (
        set "cleanmsg=%~1 %~2"
    ) else (
        set "cleanmsg=%~1"
    )
)

:: Strip ANSI codes from cleanmsg
setlocal EnableDelayedExpansion
for %%C in (GRY RED ORA GRE YEL MAG CYA RES) do (
    call set "cleanmsg=%%cleanmsg:!%%C!=%%"
)

:: Console display
if "!msg!" == "." (
    if defined PREVMOD (
        <nul set /p="[2K[1000D!PREVMSG!"
        echo.
        if exist "%UNRENLOG%" >> "%UNRENLOG%" echo !cleanmsg!
    ) else (
        echo.
        if exist "%UNRENLOG%" >> "%UNRENLOG%" echo.
    )
    endlocal & endlocal & set "PREVMOD=" & set "PREVMSG="
    goto :eof
)

if defined PREVMOD (
    if defined msg2 (
        <nul set /p="[2K[1000D!msg! !PREVMSG! !msg2!"
    ) else (
        <nul set /p="[2K[1000D!msg! !PREVMSG!"
    )
    echo.
    if exist "%UNRENLOG%" >> "%UNRENLOG%" echo !cleanmsg!
    endlocal & endlocal & set "PREVMOD=" & set "PREVMSG="
    goto :eof
)

if defined msg2 (
    echo !msg! !msg2!
) else (
    echo !msg!
)
if exist "%UNRENLOG%" >> "%UNRENLOG%" echo !cleanmsg!
endlocal & endlocal & set "PREVMOD=" & set "PREVMSG="
goto :eof


:: Auto centering message
:center
setlocal Enabledelayedexpansion
set "msg=%~1"

:: Strip color variables for logging
set "cleanmsg=%msg%"
for %%C in (GRY RED ORA GRE YEL MAG CYA RES) do (
    call set "cleanmsg=%%cleanmsg:!%%C!=%%"
)

set "len=0"
for /l %%i in (0,1,300) do (
    if "!cleanmsg:~%%i,1!"=="" (
        set "len=%%i"
        goto :len_done
    )
)

:len_done
:: Calculating left padding
set /a pad=(%NEW_COLS% - len) / 2
if !pad! LSS 0 set "pad=0"

:: Space Design
set "spaces="
for /l %%i in (1,1,!pad!) do set "spaces=!spaces! "

echo(!spaces!!msg!
endlocal
goto :eof


:: Call :exitn for cleanup only or goto :exitn for ending script
:exitn
set "val=%~1"

if exist "%TEMP%\b64decode.py" (
    if %DEBUGLEVEL% GEQ 1 echo del /f /q "%TEMP%\b64decode.py" >> "%UNRENLOG%"
    del /f /q "%TEMP%\b64decode.py" %DEBUGREDIR%
)
if exist "%TEMP%\choiceEx.py" (
    if %DEBUGLEVEL% GEQ 1 echo del /f /q "%TEMP%\choiceEx.py" >> "%UNRENLOG%"
    del /f /q "%TEMP%\choiceEx.py" %DEBUGREDIR%
)

if %DEBUGLEVEL% GEQ 1 (
    echo === Variables ===
    set
    echo === Variables ===
)

:: Restore modified configuration and we exit with the appropriate code
"%SystemRoot%\System32\chcp.com" %OLD_CP% %DEBUGREDIR%

:: Restore original console mode
if not defined WT_SESSION (
    if %DEBUGLEVEL% GEQ 1 echo "%SystemRoot%\System32\mode.com" con: cols=%ORIG_COLS% lines=%ORIG_LINES% >> "%UNRENLOG%"
    "%SystemRoot%\System32\mode.com" con: cols=%ORIG_COLS% lines=%ORIG_LINES% %DEBUGREDIR%
)

:: Remove old bug entries
"%SystemRoot%\System32\reg.exe" delete "HKCU\Console\MyScript" /f %DEBUGREDIR%
"%SystemRoot%\System32\reg.exe" delete "HKCU\Console\UnRen-forall.bat" /f %DEBUGREDIR%

if defined val exit !val!

exit 0
