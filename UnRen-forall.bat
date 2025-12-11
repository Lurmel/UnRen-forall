@echo off
setlocal EnableDelayedExpansion

:: UnRen-forall.bat - UnRen Launcher Script named UnRen-forall.bat for compatibility
:: Made by (SM) aka JoeLurmel @ f95zone.to
:: This script is licensed under GNU GPL v3 — see LICENSE for details

:: DO NOT MODIFY BELOW THIS LINE unless you know what you're doing
:: Define various global names
set "NAME=forall"
set "VERSION=(v0.38) (12/01/25)"
title UnRen-%NAME%.bat - %VERSION%
set "URL_REF=https://f95zone.to/threads/unrengui-unren-forall-v9-4-unren-powershell-forall-v9-4-unren-old.92717/post-17110063/"
set "SCRIPTDIR=%~dp0"
set "UPD_TDIR=%TEMP%\UnRenUpdate"
set "SCRIPTNAME=%~nx0"
set "BASENAME=%SCRIPTNAME:.bat=%"

:: External configuration file for LNG, MDEFS and MDEFS2.
set "UNREN_CFG=%SCRIPTDIR%UnRen-cfg.bat"
:: Load external configuration
if exist "%UNREN_CFG%" (
    call "%UNREN_CFG%"
    if defined LNG goto lngtest
) else (
    :: Set default values in case of missing configuration
    set "MDEFS=acefg"
)

:: Set the cmd screen size with backup of old settings
set "count=0"
:: Read the lines of mode con
for /f "tokens=*" %%A in ('mode con') do (
    :: Split the line into tokens
    for %%B in (%%A) do (
        set "val=%%B"
        :: Check if it's a number
        echo !val! | findstr /r "[0-9][0-9]" >nul
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
set "NEW_COLS=110"
mode con: cols=%NEW_COLS% lines=60

if defined LNG goto lngtest
:: Get the current code page
for /f "tokens=2 delims=:" %%a in ('chcp') do set "OLD_CP=%%a"
:: Switch to code page 65001 for UTF-8
chcp 65001 >nul

:: Clean retrieval of language code via WMIC
for /f "skip=1 tokens=1" %%l in ('wmic os get oslanguage') do (
    set LNGID=%%l
    goto found_lcid
)

:found_lcid
:: LCID correspondences
if "!LNGID!" == "1033" set LNG=en
if "!LNGID!" == "1036" set LNG=fr
if "!LNGID!" == "3082" set LNG=es
if "!LNGID!" == "1040" set LNG=it
if "!LNGID!" == "1031" set LNG=de
if "!LNGID!" == "1049" set LNG=ru

if not defined LNG set LNG=en

:lngtest
:: Language support test
set "SUPPORTED= de es en fr it ru "
set "FIND= !LNG! "
echo !SUPPORTED! | find /i "%FIND%" >nul
if %errorlevel% NEQ 0 set LNG=en

:: To be able to take screenshots for F95zone
if not "%~2" == "" (
    set "LNG=%~2"
)


:: Definition of reusable texts
set "ANYKEY.en=Press any key to exit..."
set "ANYKEY.fr=Appuyez sur une touche pour quitter..."
set "ANYKEY.es=Presione cualquier tecla para salir..."
set "ANYKEY.it=Premere un tasto per uscire..."
set "ANYKEY.de=Drücken Sie eine beliebige Taste, um zu beenden..."
set "ANYKEY.ru=Нажмите любую клавишу для выхода..."

set "ARIGHT.en=Please run this script as an administrator to add the entry."
set "ARIGHT.fr=Veuillez exécuter ce script en tant qu'administrateur pour ajouter l'entrée."
set "ARIGHT.es=Por favor, ejecute este script como administrador para agregar la entrada."
set "ARIGHT.it=Per favore, esegui questo script come amministratore per aggiungere la voce."
set "ARIGHT.de=Bitte führen Sie dieses Skript als Administrator aus, um den Eintrag hinzuzufügen."
set "ARIGHT.ru=Пожалуйста, запустите этот скрипт от имени администратора, чтобы добавить элемент."

set "PASS.en=Pass"
set "PASS.fr=Réussi"
set "PASS.es=Paso"
set "PASS.it=Passato"
set "PASS.de=Bestanden"
set "PASS.ru=Успех"

set "FAIL.en=Fail"
set "FAIL.fr=Échoué"
set "FAIL.es=Fallo"
set "FAIL.it=Fallito"
set "FAIL.de=Fehlgeschlagen"
set "FAIL.ru=Ошибка"

set "APRESENT.en=Option already presented."
set "APRESENT.fr=Option déjà présentée."
set "APRESENT.it=Opzione già presentata."
set "APRESENT.es=Opción ya presentada."
set "APRESENT.de=Option bereits präsentiert."
set "APRESENT.ru=Опция уже представлена."

set "TWADD.en=This will add:"
set "TWADD.fr=Cela ajoutera:"
set "TWADD.it=Questo aggiungerà:"
set "TWADD.es=Esto añadirá:"
set "TWADD.de=Dies wird hinzufügen:"
set "TWADD.ru=Это добавит:"

set "INCASEOF.en=In case of problem, please refer to:"
set "INCASEOF.fr=En cas de problème, veuillez vous référer à :"
set "INCASEOF.it=In caso di problemi, si prega di fare riferimento a:"
set "INCASEOF.es=En caso de problemas, consulte:"
set "INCASEOF.de=Im Falle von Problemen wenden Sie sich bitte an:"
set "INCASEOF.ru=В случае проблемы обратитесь к:"

set "INCASEDEL.en=In case of problem, delete the following files/dirs:"
set "INCASEDEL.fr=En cas de problème, supprimez le.s fichier.s/répertoire.s suivants :"
set "INCASEDEL.it=In caso di problemi, eliminare i seguenti file/directory:"
set "INCASEDEL.es=En caso de problemas, elimine los siguientes archivos/directorios:"
set "INCASEDEL.de=Im Falle von Problemen löschen Sie die folgenden Dateien/Verzeichnisse:"
set "INCASEDEL.ru=В случае проблемы удалите следующие файлы/каталоги:"

set "UNDWNLD.en=Unable to download:"
set "UNDWNLD.fr=Impossible de télécharger :"
set "UNDWNLD.es=No se puede descargar:"
set "UNDWNLD.it=Impossibile scaricare:"
set "UNDWNLD.de=Download nicht möglich:"
set "UNDWNLD.ru=Не удалось загрузить:"

set "UNINSTALL.en=Unable to install:"
set "UNINSTALL.fr=Impossible d'installer :"
set "UNINSTALL.es=No se puede instalar:"
set "UNINSTALL.it=Impossibile installare:"
set "UNINSTALL.de=Installation nicht möglich:"
set "UNINSTALL.ru=Не удалось установить:"

set "UNEXTRACT.en=Unable to extract:"
set "UNEXTRACT.fr=Impossible d'extraire :"
set "UNEXTRACT.es=No se puede extraer:"
set "UNEXTRACT.it=Impossibile estrarre:"
set "UNEXTRACT.de=Fehler beim Herunterladen von:"
set "UNEXTRACT.ru=Не удалось извлечь:"

set "MISSING.en=File not found:"
set "MISSING.fr=Fichier introuvable :"
set "MISSING.es=Archivo no encontrado:"
set "MISSING.it=File non trovato:"
set "MISSING.de=Datei nicht gefunden:"
set "MISSING.ru=Файл не найден:"


set "UNACONT.en=Unable to continue."
set "UNACONT.fr=Impossible de continuer."
set "UNACONT.es=No se puede continuar."
set "UNACONT.it=Impossibile continuare."
set "UNACONT.de=Kann nicht fortgesetzt werden."
set "UNACONT.ru=Не удалось продолжить."

set "GRY=[90m"
set "RED=[91m"
set "GRE=[92m"
set "YEL=[93m"
set "MAG=[95m"
set "CYA=[96m"
set "RES=[0m"
for /f "tokens=4-5 delims=. " %%i in ('ver') do set OSVERS=%%i.%%j
if "%OSVERS%" == "6.1" (
    set "GRY="
    set "RED="
    set "GRE="
    set "YEL="
    set "MAG="
    set "CYA="
    set "RES="
)
:: End of reusable texts


set "initialized=0"
set "nocls=0"
:menu
set "sscreen1.en=is no longer a script for processing RPYC and RPA but a launcher,"
set "sscreen1.fr=n'est plus un script pour les traitements des RPYC et RPA mais un lanceur,"
set "sscreen1.es=ya no es un script para procesar RPYC y RPA, sino un lanzador."
set "sscreen1.it=Non è più uno script per elaborare RPYC e RPA, ma un launcher,"
set "sscreen1.de=ist kein Skript mehr zur Verarbeitung von RPYC und RPA, sondern ein Launcher,"
set "sscreen1.ru=больше не является скриптом для обработки RPYC и RPA, а является программой запуска,"

set "sscreen2.en=to launch UnRen-legacy.bat or UnRen-current.bat."
set "sscreen2.fr=pour exécuter UnRen-legacy.bat ou UnRen-current.bat."
set "sscreen2.es=para lanzar UnRen-legacy.bat o UnRen-current.bat."
set "sscreen2.it=per lanciare UnRen-legacy.bat o UnRen-current.bat."
set "sscreen2.de=um UnRen-legacy.bat oder UnRen-current.bat zu starten."
set "sscreen2.ru=для запуска UnRen-legacy.bat или UnRen-current.bat."

set "sscreen3.en=Made with <3 for the fans - by JoeLurmel @ f95zone.to"
set "sscreen3.fr=Fait avec <3 pour les fans - par JoeLurmel @ f95zone.to"
set "sscreen3.es=Hecho con <3 para los fans - por JoeLurmel @ f95zone.to"
set "sscreen3.it=Fatto con <3 per i fan - di JoeLurmel @ f95zone.to"
set "sscreen3.de=Hergestellt mit <3 für die Fans - von JoeLurmel @ f95zone.to"
set "sscreen3.ru=Сделано с <3 для фанатов - JoeLurmel @ f95zone.to"

:: Splash screen
if "%nocls%" == "0" cls
echo.
echo           %YEL%  --------------------------------------------------------------------------------%RES%
echo           %YEL%     __  __      ____                  __          __%RES%
echo           %YEL%    / / / /___  / __ \___  ____       / /_  ____ _/ /_%RES%
echo           %YEL%   / / / / __ \/ /_/ / _ \/ __ \     / __ \/ __ ^`/ __/%RES%
echo           %YEL%  / /_/ / / / / _   /  __/ / / / _  / /_/ / /_/ / /_%RES%
echo           %YEL%  \____/_/ /_/_/ \_\\___/_/ /_/ (_) \_.__/\__^,_/\__/ - %NAME% %VERSION%%RES%
echo.
echo           %YEL%  !sscreen1.%LNG%!%RES%
echo           %YEL%  !sscreen2.%LNG%!%RES%
echo.
echo           %YEL%  !INCASEOF.%LNG%!%RES%
echo           %MAG%  %URL_REF%%RES%
echo.
echo           %YEL%  !sscreen3.%LNG%!%RES%
echo.
set /a rand=%random% %%17
if %rand% == 0 echo           %GRY%  "Hack the planet!" – Dade Murphy%RES%
if %rand% == 1 echo           %GRY%  "Resistance is futile." – Borg%RES%
if %rand% == 2 echo           %GRY%  "There is no spoon." – Neo%RES%
if %rand% == 3 echo           %GRY%  "I'm in." – Mr. Robot%RES%
if %rand% == 4 echo           %GRY%  "All your base are belong to us." – CATS%RES%
if %rand% == 5 echo           %GRY%  "Would you like to know more?" – Various%RES%
if %rand% == 6 echo           %GRY%  "This message will self-destruct in 5... 4... 3..."%RES%
if %rand% == 7 echo           %GRY%  "If you're reading this, you're already better than 90%% of users..."%RES%
if %rand% == 8 echo           %GRY%  "I'm not a hacker. I'm a code poet."%RES%
if %rand% == 9 echo           %GRY%  "Welcome to the command line. Abandon all GUIs, ye who enter here."%RES%
if %rand% == 10 echo          %GRY%  "rm -rf / — because chaos is an art form."%RES%
if %rand% == 11 echo          %GRY%  "This script runs faster than your Wi-Fi on a Monday."%RES%
if %rand% == 12 echo          %GRY%  "The cake is a lie." – Portal%RES%
if %rand% == 13 echo          %GRY%  "I am Groot." – Groot%RES%
if %rand% == 14 echo          %GRY%  "Do or do not. There is no try." – Yoda%RES%
if %rand% == 15 echo          %GRY%  "I know kung fu." – Neo%RES%
if %rand% == 16 echo          %GRY%  "You have been recruited by the Star League to defend the frontier." – The Last Starfighter%RES%
echo           %YEL%  --------------------------------------------------------------------------------%RES%
echo.

if "%initialized%" == "1" goto skipInit

:: Initializing debug mode
set "debugredir=>nul 2>&1"
set "debuglevel=0"
set "nocls=0"

:: We need PowerShell for later, make sure it exists
set "pshell.en=Checking for availability of PowerShell... "
set "pshell.fr=Vérification de la disponibilité de PowerShell... "
set "pshell.es=Comprobando la disponibilidad de PowerShell... "
set "pshell.it=Verifica della disponibilità di PowerShell... "
set "pshell.de=Überprüfung der Verfügbarkeit von PowerShell... "
set "pshell.ru=Проверка доступности PowerShell... "

set "pshell1.en=Powershell is required. !UNACONT.%LNG%!"
set "pshell1.fr=Erreur Powershell est requis. !UNACONT.%LNG%!"
set "pshell1.es=Error Se requiere Powershell. !UNACONT.%LNG%!"
set "pshell1.it=Errore Powershell è richiesto. !UNACONT.%LNG%!"
set "pshell1.de=Fehler Powershell ist erforderlich. !UNACONT.%LNG%!"
set "pshell1.ru=Ошибка требуется PowerShell. !UNACONT.%LNG%!"

set "pshell2.en=This is included in Windows 7, 8 and 10. XP/Vista users can"
set "pshell2.fr=Ce programme est inclus dans Windows 7, 8 et 10. Les utilisateurs de XP/Vista peuvent"
set "pshell2.es=Esto está incluido en Windows 7, 8 y 10. Los usuarios de XP/Vista pueden"
set "pshell2.it=Questo programma è incluso in Windows 7, 8 e 10. Gli utenti di XP/Vista possono"
set "pshell2.de=Dieses Programm ist in Windows 7, 8 und 10 enthalten. XP/Vista-Benutzer können"
set "pshell2.ru=Это включено в Windows 7, 8 и 10. Пользователи XP/Vista могут"

set "pshell3.en=download it here: %MAG%https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.5%RES%"
set "pshell3.fr=le télécharger ici : %MAG%https://learn.microsoft.com/fr-fr/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.5%RES%"
set "pshell3.es=descargarlo aquí: %MAG%https://learn.microsoft.com/es-es/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.5%RES%"
set "pshell3.it=scaricarlo qui: %MAG%https://learn.microsoft.com/it-it/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.5%RES%"
set "pshell3.de=es hier herunterladen: %MAG%https://learn.microsoft.com/de-de/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.5%RES%"
set "pshell3.ru=скачать его здесь: %MAG%https://learn.microsoft.com/ru-ru/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.5%RES%"
<nul set /p=!pshell.%LNG%!
if not exist "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" (
    call :elog "%RED%!FAIL.%LNG%!%RES%"
    call :elog .
    call :elog "    !pshell1.%LNG%!"
    call :elog "    !pshell2.%LNG%!"
    call :elog "    !pshell3.%LNG%!"
    call :elog .
    pause>nul|set/p=.      !ANYKEY.%LNG%!

    goto exitn
) else (
    call :elog "%GRE%!PASS.%LNG%!%RES%"
)

:: Analysis of debug arguments
if /i "%~3" == "-d" (
    set "debugredir="
    set "debuglevel=1"
    set "nocls=1"
    powershell.exe -Command "$h = Get-Host; $h.UI.RawUI.BufferSize = New-Object Management.Automation.Host.Size(%NEW_COLS%,3000)"
)
if /i "%~3" == "-dd" (
    echo on
    set "debugredir="
    set "debuglevel=2"
    set "nocls=1"
    powershell.exe -Command "$h = Get-Host; $h.UI.RawUI.BufferSize = New-Object Management.Automation.Host.Size(%NEW_COLS%,5000)"
)


:: Set the working directory
set "setpath1.en=Enter the path to the game, drag'n'drop it here,"
set "setpath1.fr=Entrez le chemin vers le jeu, faites-le glisser ici,"
set "setpath1.es=Introduzca la ruta al juego, arrástrelo aquí,"
set "setpath1.it=Inserisci il percorso del gioco, trascinalo qui,"
set "setpath1.de=Geben Sie den Pfad zum Spiel ein, ziehen Sie es hierher,"
set "setpath1.ru=Введите путь к игре, перетащите его сюда,"

set "setpath2.en=or press Enter if this tool is already in the desired folder."
set "setpath2.fr=ou appuyez sur Entrée si cet outil se trouve déjà dans le dossier souhaité."
set "setpath2.es=o presione Entrar si esta herramienta ya se encuentra en la carpeta deseada."
set "setpath2.it=oppure premi Invio se questo strumento si trova già nella cartella desiderata."
set "setpath2.de=oder drücken Sie die Eingabetaste, wenn sich dieses Tool bereits im gewünschten Ordner befindet."
set "setpath2.ru=или нажмите Enter, если этот инструмент уже находится в нужной папке."

set "setpath3.en=If drag'n'drop does not work, please copy/paste the path instead: "
set "setpath3.fr=Si le glisser-déposer ne fonctionne pas, veuillez copier/coller le chemin à la place : "
set "setpath3.es=Si arrastrar y soltar no funciona, copie/pegue la ruta en su lugar: "
set "setpath3.it=Se il trascinamento della selezione non funziona, copia/incolla il percorso invece: "
set "setpath3.de=Wenn das Ziehen und Ablegen nicht funktioniert, kopieren Sie den Pfad bitte stattdessen hierher: "
set "setpath3.ru=Если перетаскивание не работает, пожалуйста, скопируйте/вставьте путь вместо этого: "

:: Check if game path is provided and set it
if "%~1" == "" (
    call :elog .
    call :elog "!setpath1.%LNG%!"
    call :elog "!setpath2.%LNG%!"
    call :elog .
    set /p "WORKDIR=!setpath3.%LNG%!"
) else (
    set "WORKDIR=%~1"
)

if not defined WORKDIR (
    set "WORKDIR=%cd%"
)

if "%WORKDIR%" == "." (
    set "WORKDIR=%cd%"
)

:: Check if an update is available
call :check_update

:: Check for required files
call :check_all_files


set "wdir1.en=Error The specified directory does not exist."
set "wdir1.fr=Erreur Le répertoire spécifié n'existe pas."
set "wdir1.es=Error El directorio especificado no existe."
set "wdir1.it=Errore la directory specificata non esiste."
set "wdir1.de=Fehler Das angegebene Verzeichnis existiert nicht."
set "wdir1.ru=Ошибка Указанный каталог не существует."

set "wdir2.en=Are you sure we're in the game's root directory?"
set "wdir2.fr=Êtes-vous sûr que nous sommes dans le répertoire racine du jeu ?"
set "wdir2.es=¿Está seguro de que estamos en el directorio raíz del juego?"
set "wdir2.it=Sei sicuro che siamo nella directory principale del gioco?"
set "wdir2.de=Sind Sie sicher, dass wir uns im Stammverzeichnis des Spiels befinden?"
set "wdir2.ru=Вы уверены, что находимся в корневом каталоге игры?"

set "wdir3.en=Testing write access to game directory"
set "wdir3.fr=Test de l'accès en écriture au répertoire du jeu"
set "wdir3.es=Prueba de acceso de escritura al directorio del juego"
set "wdir3.it=Verifica l'accesso in scrittura alla directory di gioco"
set "wdir3.de=Testen des Schreibzugriffs auf das Spieledirectory"
set "wdir3.ru=Проверка доступа на запись в каталог игры"

set "wdir4.en=You can't write in game directory."
set "wdir4.fr=Vous ne pouvez pas écrire dans le répertoire du jeu."
set "wdir4.es=No puedes escribir en el directorio del juego."
set "wdir4.it=Non puoi scrivere nella directory di gioco."
set "wdir4.de=Sie können nicht im Spieledirectory schreiben."
set "wdir4.ru=Вы не можете писать в каталоге игры."

:: Remove surrounding quotes if any
set "WORKDIR=%WORKDIR:"=%"
if not exist "%WORKDIR%\" (
    call :elog .
    call :elog "    %RED%!wdir1.%LNG%!%RES%"
    call :elog "    !wdir2.%LNG%!"
    call :elog .
    pause>nul|set/p=.      !ANYKEY.%LNG%!

    goto exitn
)


set "reqdir1.en=Checking if game, lib, renpy directories exist... "
set "reqdir1.fr=Vérification de l'existence des répertoires game, lib et renpy... "
set "reqdir1.es=Comprobando si existen los directorios game, lib, renpy... "
set "reqdir1.it=Controllo dell'esistenza delle directory game, lib, renpy... "
set "reqdir1.de=Überprüfung der Existenz der Verzeichnisse game, lib, renpy... "
set "reqdir1.ru=Проверка наличия каталогов game, lib, renpy... "

set "reqdir2.en=Cannot locate game, lib or renpy directories. !UNACONT.%LNG%!"
set "reqdir2.fr=Erreur Impossible de localiser les répertoires game, lib ou renpy. !UNACONT.%LNG%!"
set "reqdir2.es=Error No se pueden localizar los directorios game, lib o renpy. !UNACONT.%LNG%!"
set "reqdir2.it=Errore Impossibile localizzare le directory game, lib o renpy. !UNACONT.%LNG%!"
set "reqdir2.de=Fehler Unmöglich, die Verzeichnisse game, lib oder renpy zu finden. !UNACONT.%LNG%!"
set "reqdir2.ru=Ошибка Не удалось найти каталоги game, lib или renpy. !UNACONT.%LNG%!"

:: Check that you are in the root directory of the game.
cd /d "%WORKDIR%"
<nul set /p=!reqdir1.%LNG%!
set missing=0
if not exist "game\" (
    set missing=1
) else (
	set "GAMEDIR=%WORKDIR%\game\"
)
if not exist "lib\" (
    set missing=1
)
if not exist "renpy\" (
    set missing=1
) else (
	set "RENPYDIR=%WORKDIR%\renpy\"
)
if %missing% EQU 1 (
    call :elog "%RED%!FAIL.%LNG%!%RES%"
    call :elog "    !reqdir2.%LNG%!"
    call :elog "    !wdir2.%LNG%!"
    call :elog .
    pause>nul|set/p=.      !ANYKEY.%LNG%!

    goto exitn
) else (
    call :elog "%GRE%!PASS.%LNG%!%RES%"
)

:: Check if %WORKDIR%\game is writable
<nul set /p="!wdir3.%LNG%!... "
copy nul "%WORKDIR%\game\test.txt" %debugredir%
if %errorlevel% NEQ 0 (
    call :elog "%RED%!FAIL.%LNG%! !wdir4.%LNG%!%RES%"
    call :elog .
    call :elog "    !wdir2.%LNG%!"
    call :elog .
    pause>nul|set/p=.      !ANYKEY.%LNG%!

    goto exitn
) else (
    del /f /q "%WORKDIR%\game\test.txt"
    call :elog "%GRE%!PASS.%LNG%!%RES%"
)


:: Check for Python
set "python1.en=Checking if Python is available..."
set "python1.fr=Vérification de la disponibilité de Python..."
set "python1.es=Comprobando si Python está disponible..."
set "python1.it=Controllo della disponibilità di Python..."
set "python1.de=Überprüfung der Verfügbarkeit von Python..."
set "python1.ru=Проверка наличия Python..."

set "python2.en=Cannot locate python directory. !UNACONT.%LNG%!"
set "python2.fr=Impossible de localiser le répertoire python. !UNACONT.%LNG%!"
set "python2.es=No se puede localizar el directorio de Python. !UNACONT.%LNG%!"
set "python2.it=Impossibile localizzare la directory di Python. !UNACONT.%LNG%!"
set "python2.de=Python-Verzeichnis kann nicht gefunden werden. !UNACONT.%LNG%!"
set "python2.ru=Не удалось найти каталог Python. !UNACONT.%LNG%!"

<nul set /p=!python1.%LNG%!

:: Doublecheck to avoid issues with Milfania games
if exist "lib\py3-windows-x86_64\pythonw.exe" if exist "lib\py3-windows-x86_64\python.exe" (
    if not "%PROCESSOR_ARCHITECTURE%" == "x86" (
        <nul set /p=.
        set "pythondir=%WORKDIR%\lib\py3-windows-x86_64\"
    ) else if exist "lib\py3-windows-i686\python.exe" (
        <nul set /p=.
        set "pythondir=%WORKDIR%\lib\py3-windows-i686\"
    )
) else if exist "lib\py3-windows-i686\python.exe" (
    <nul set /p=.
    set "pythondir=%WORKDIR%\lib\py3-windows-i686\"
)
if exist "lib\py2-windows-x86_64\python.exe" (
    if not "%PROCESSOR_ARCHITECTURE%" == "x86" (
        <nul set /p=.
        set "pythondir=%WORKDIR%\lib\py2-windows-x86_64\"
    ) else if exist "lib\py2-windows-i686\python.exe" (
        <nul set /p=.
        set "pythondir=%WORKDIR%\lib\py2-windows-i686\"
    )
) else if exist "lib\py2-windows-i686\python.exe" (
    <nul set /p=.
    set "pythondir=%WORKDIR%\lib\py2-windows-i686\"
)
if exist "lib\windows-x86_64\python.exe" (
    if not "%PROCESSOR_ARCHITECTURE%" == "x86" (
        <nul set /p=.
        set "pythondir=%WORKDIR%\lib\windows-x86_64\"
    ) else if exist "lib\windows-i686\python.exe" (
        <nul set /p=.
        set "pythondir=%WORKDIR%\lib\windows-i686\"
    )
) else if exist "lib\windows-i686\python.exe" (
    <nul set /p=.
    set "pythondir=%WORKDIR%\lib\windows-i686\"
)

:: Set the PYNOASSERT according to “%pythondir%Lib”.
if exist "%pythondir%Lib" (
    set "PYNOASSERT=-O"
) else (
    set "PYNOASSERT="
)

set "PYTHONHOME=%pythondir%"
set "PYTHONPATH="
set "latest="
set "latestver="

:: Priority to Python 2.7 if present
if exist "!WORKDIR!\lib\pythonlib2.7" (
    <nul set /p=.
    set "PYTHONPATH=!WORKDIR!\lib\pythonlib2.7"
    set "PYVERS=2.7"
    goto pyend
) else if exist "!WORKDIR!\lib\python2.7" (
    <nul set /p=.
    set "PYTHONPATH=!WORKDIR\lib\python2.7"
    set "PYVERS=2.7"
    goto pyend
)

:: Searching for the latest version of Python 3.x
for /D %%D in ("%WORKDIR%\lib\python3.*") do (
    <nul set /p=.
    set "ver=%%~nxD"
    set "found="
    for %%M in (os importlib encodings) do (
        if exist "%%D\%%M" (
            set "found=1"
        )
    )
    if defined found (
        for /f "tokens=2 delims=." %%V in ("!ver!") do (
            <nul set /p=.
            if not defined latest (
                set "latest=%%D"
                set "latestver=%%V"
                set "PYVERS=3.%%V"
            ) else (
                if %%V GTR !latestver! (
                    set "latest=%%D"
                    set "latestver=%%V"
                    set "PYVERS=3.%%V"
                )
            )
        )
    )
)

if defined latest (
    <nul set /p=.
    set "PYTHONPATH=!latest!"
)

:pyend
if not exist "%pythondir%\python.exe" (
    call :elog " %RED% !FAIL.%LNG%!%RES%"
    call :elog .
    call :elog "    %RED%!python2.%LNG%!%RES%"
    call :elog "    !wdir2.%LNG%!"
    call :elog .
    pause>nul|set/p=.      !ANYKEY.%LNG%!

    goto exitn
) else (
    call :elog " %GRE%!PASS.%LNG%!%YEL% Python %PYVERS%%RES%"
)

:: Check for Ren'Py version
set "renpyvers1.en=Ren'Py version found: "
set "renpyvers1.fr=Version Ren'Py trouvée : "
set "renpyvers1.es=Versión de Ren'Py encontrada: "
set "renpyvers1.it=Versione Ren'Py rilevata: "
set "renpyvers1.de=Ren'Py-Version gefunden: "
set "renpyvers1.ru=Найдена версия Ren'Py: "

set "renpyvers2.en=Failed to create detect_renpy_version.py. !UNACONT.%LNG%!"
set "renpyvers2.fr=Erreur Impossible de créer detect_renpy_version.py. !UNACONT.%LNG%!"
set "renpyvers2.es=Error No se pudo crear detect_renpy_version.py. !UNACONT.%LNG%!"
set "renpyvers2.it=Errore Impossibile creare detect_renpy_version.py. !UNACONT.%LNG%!"
set "renpyvers2.de=Fehler Die Erstellung von detect_renpy_version.py ist fehlgeschlagen. !UNACONT.%LNG%!"
set "renpyvers2.ru=Ошибка Не удалось создать detect_renpy_version.py. !UNACONT.%LNG%!"

set "renpyvers3.en=Unable to detect Ren'Py version,"
set "renpyvers3.fr=Impossible de détecter la version de Ren'Py,"
set "renpyvers3.es=No se puede detectar la versión de Ren'Py,"
set "renpyvers3.it=Impossibile rilevare la versione di Ren'Py,"
set "renpyvers3.de=Unmöglich, die Ren'Py-Version zu erkennen, bitte sicherstellen,"
set "renpyvers3.ru=Не удалось обнаружить версию Ren'Py, пожалуйста,"

set "renpyvers4.en=        please ensure the game is compatible with UnRen."
set "renpyvers4.fr=        es-tu sûr que le jeu est compatible avec UnRen ?"
set "renpyvers4.es=        asegúrese de que el juego sea compatible con UnRen."
set "renpyvers4.it=        assicurati che il gioco sia compatibile con UnRen."
set "renpyvers4.de=        dass das Spiel mit UnRen kompatibel ist."
set "renpyvers4.ru=        убедитесь, что игра совместима с UnRen."

<nul set /p=!renpyvers1.%LNG%!

cd /d "%WORKDIR%"
set "detect_renpy_versionb64=IiIiDQogICAgVGhpcyBzY3JpcHQgZGV0ZWN0cyB0aGUgUmVuJ1B5IHZlcnNpb24NCiIiIg0KdHJ5Og0KICAgIGltcG9ydCByZW5weQ0KICAgIHZlcnNpb24gPSByZW5weS52ZXJzaW9uX3R1cGxlWzBdDQogICAgcHJpbnQodmVyc2lvbikNCmV4Y2VwdCBFeGNlcHRpb246DQogICAgcHJpbnQoIkVSUk9SIikNCg=="
set "detect_renpy_version_tmp=detect_renpy_version.py.tmp"
set "detect_renpy_version_py=detect_renpy_version.py"

del /f /q "%detect_renpy_version_py%" %debugredir%

powershell.exe -nologo -noprofile -noninteractive -command "[IO.File]::WriteAllText('%detect_renpy_version_tmp%', [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('%detect_renpy_versionb64%')))" %debugredir%
if exist "!detect_renpy_version_tmp!" (
    move /y "!detect_renpy_version_tmp!" "!detect_renpy_version_py!" %debugredir%
) else (
    call :elog "%RED%!FAIL.%LNG%!%RES%"
    call :elog .
    call :elog "%RED%!renpyvers2.%LNG%!%RES%"
    call :elog .
    pause>nul|set/p=.      !ANYKEY.%LNG%!

    goto exitn
)

if not exist "%detect_renpy_version_py%" (
    call :elog "%RED%!FAIL.%LNG%!%RES%"
    call :elog .
    call :elog "!renpyvers2.%LNG%!"
    call :elog .
    pause>nul|set/p=.      !ANYKEY.%LNG%!

    goto exitn
) else (
    for /f "delims=" %%A in ('"%PYTHONHOME%\python.exe" %PYNOASSERT% %detect_renpy_version_py%') do (
        echo %%A | findstr /r "[0-9]" >nul
        if !errorlevel! EQU 0 (
            set "RENPYVERSION=%%A"
        )
    )
    if not defined RENPYVERSION (
        call :elog "%RED%!FAIL.%LNG%!%RES%"
        call :elog .
        call :elog "    %RED%!renpyvers3.%LNG%!%RES%"
        call :elog "    %RED%!renpyvers4.%LNG%!%RES%"
    ) else (
        call :elog "%YEL%!RENPYVERSION!%RES%"
    )
)
del /f /q "%detect_renpy_version_py%" %debugredir%

:: Set the colors and default choice
if %renpyversion% GEQ 8 (
    set "ESC1=%RED%"
    set "ESC2=%GRE%"
    set "def=2"
) else if %renpyversion% LEQ 7 (
    set "ESC1=%GRE%"
    set "ESC2=%RED%"
    set "def=1"
) else (
    set "ESC1=%YEL%"
    set "ESC2=%YEL%"
    set "def=x"
)

set initialized=1

:SkipInit
set "mtitle.en=Working directory: "
set "mtitle.fr=Répertoire de travail : "
set "mtitle.es=Directorio de trabajo: "
set "mtitle.it=Directory di lavoro: "
set "mtitle.de=Aktuelles Verzeichnis: "
set "mtitle.ru=Рабочий каталог: "

set "choice1.en=Launch UnRen-legacy.bat."
set "choice1.fr=Lancer UnRen-legacy.bat."
set "choice1.es=Lanzar UnRen-legacy.bat."
set "choice1.it=Eseguire UnRen-legacy.bat."
set "choice1.de=UnRen-legacy.bat ausführen."
set "choice1.ru=Запустить UnRen-legacy.bat."

set "choice2.en=Launch UnRen-current.bat."
set "choice2.fr=Lancer UnRen-current.bat."
set "choice2.es=Lanzar UnRen-current.bat."
set "choice2.it=Eseguire UnRen-current.bat."
set "choice2.de=UnRen-current.bat ausführen."
set "choice2.ru=Запустить UnRen-current.bat."

set "minfo1.en=The following options are independent of the Ren'Py version."
set "minfo1.fr=Les options suivantes sont indépendantes de la version de Ren'Py."
set "minfo1.es=Las siguientes opciones son independientes de la versión de Ren'Py."
set "minfo1.it=Le seguenti opzioni sono indipendenti dalla versione di Ren'Py."
set "minfo1.de=Die folgenden Optionen sind unabhängig von der Ren'Py-Version."
set "minfo1.ru=Следующие параметры независимы от версии Ren'Py."

set "choicea.en=Enable Console (Shift+O) and Developer menu (Shift+D)"
set "choicea.fr=Activer la Console (Maj+O) et le menu Développeur (Maj+D)"
set "choicea.es=Activar la Consola (Mayús+O) y el menú de desarrollador (Mayús+D)"
set "choicea.it=Attiva la Console (Maiusc+O) e il menu sviluppatore (Maiusc+D)"
set "choicea.de=Aktiviert die Konsole (Umschalt+O) und das Entwicklermenü (Umschalt+D)."
set "choicea.ru=Активируйте консоль (Shift+O) и меню «Разработчик» (Shift+D)."

set "choiceb.en=Enable debug mode %YEL%(Can break your game)"
set "choiceb.fr=Activer le mode debug %YEL%(peut casser le jeu)"
set "choiceb.es=Activar el modo debug %YEL%(puede romper el juego)"
set "choiceb.it=Attiva la modalità debug %YEL%(può rompere il gioco)"
set "choiceb.de=Aktiviert Sie den Debug-Modus %YEL%(kann Ihr Spiel beschädigen)"
set "choiceb.ru=Включить режим отладки %YEL%(может сломать игру)"

set "choicec.en=Force Skip (Unseen Text, After Choices)"
set "choicec.fr=Forcer Skip (Unseen Text, After Choices)"
set "choicec.es=Forzar Skip (Unseen Text, After Choices)"
set "choicec.it=Forza Skip (Unseen Text, After Choices)"
set "choicec.de=Zwangsweise überspringen (Unseen Text, After Choices)"
set "choicec.ru=Принудить Skip (Unseen Text, After Choices)"

set "choiced.en=Force all Skip (Unseen Text, After Choices, Transitions)"
set "choiced.fr=Forcer tous les Skip (Unseen Text, After Choices, Transitions)"
set "choiced.es=Forzar todos los Skip (Unseen Text, After Choices, Transitions)"
set "choiced.it=Forza tutti gli Skip (Unseen Text, After Choices, Transitions)"
set "choiced.de=Zwangsweise überspringen (Unseen Text, After Choices, Transitions)"
set "choiced.ru=Принудить все пропуски (Unseen Text, After Choices, Transitions)"

set "choicee.en=Force enable rollback (scroll wheel)"
set "choicee.fr=Activer le "Rollback" (molette de défilement)"
set "choicee.es=Forzar la activación del "Rollback" (rueda de desplazamiento)"
set "choicee.it=Forza l'attivazione del "Rollback" (rotella di scorrimento)"
set "choicee.de=Aktivieren Sie "Rollback" (Scrollrad)"
set "choicee.ru=Принудить активацию "Rollback" (колесо прокрутки)"

set "choicef.en=Enable Quick Save and Quick Load (Shift+S F5, Shift+L F9)"
set "choicef.fr=Activer "Quick Save" et "Quick Load" (Maj+S F5, Maj+L F9)"
set "choicef.es=Activar "Quick Save" y "Quick Load" (Mayús+S F5, Mayús+L F9)"
set "choicef.it=Attiva "Quick Save" e "Quick Load" (Maiusc+S F5, Maiusc+L F9)"
set "choicef.de=Aktivieren Sie "Quick Save" und "Quick Load" (Umschalt+S F5, Umschalt+L F9)"
set "choicef.ru=Включить "Quick Save" и "Quick Load" (Shift+S F5, Shift+L F9)"

set "choiceg.en=Try forcing the Quick Menu to display."
set "choiceg.fr=Essayer de forcer l'affichage du "Quick Menu""
set "choiceg.es=Intenta forzar la visualización del "Quick Menu""
set "choiceg.it=Prova a forzare la visualizzazione del "Quick Menu""
set "choiceg.de=Versuche, die Anzeige des "Quick Menu" zu erzwingen"
set "choiceg.ru=Попробуй заставить отобразиться "Quick Menu""

set "choiceh.en=Download and add Universal Gallery Unlocker ZLZK"
set "choiceh.fr=Télécharger et ajouter le "Universal Gallery Unlocker ZLZK""
set "choiceh.es=Descargar y agregar el "Universal Gallery Unlocker ZLZK""
set "choiceh.it=Scarica e aggiungi il "Universal Gallery Unlocker ZLZK""
set "choiceh.de="Universal Gallery Unlocker ZLZK" herunterladen und hinzufügen"
set "choiceh.ru=Скачать и добавить "Universal Gallery Unlocker ZLZK""

set "choicei.en=Download and add Universal Choice Descriptor ZLZK"
set "choicei.fr=Télécharger et ajouter le "Universal Choice Descriptor ZLZK""
set "choicei.es=Descargar y agregar el "Universal Choice Descriptor ZLZK""
set "choicei.it=Scarica e aggiungi il "Universal Choice Descriptor ZLZK""
set "choicei.de="Universal Choice Descriptor ZLZK" herunterladen und hinzufügen"
set "choicei.ru=Скачать и добавить "Universal Choice Descriptor" ZLZK"

set "choicej.en=Download and add Universal Transparent Text Box Mod by Penfold Mole"
set "choicej.fr=Télécharger et ajouter le "Universal Transparent Text Box Mod" par Penfold Mole"
set "choicej.es=Descargar y agregar el "Universal Transparent Text Box Mod" de Penfold Mole"
set "choicej.it=Scarica e aggiungi il "Universal Transparent Text Box Mod" di Penfold Mole"
set "choicej.de="Universal Transparent Text Box Mod" von Penfold Mole herunterladen und hinzufügen"
set "choicej.ru=Скачать и добавить "Universal Transparent Text Box Mod" от Penfold Mole"

set "choicek.en=Download and add "0x52_URM by 0x52""
set "choicek.fr=Télécharger et ajouter "0x52_URM by 0x52""
set "choicek.es=Descargar y agregar "0x52_URM by 0x52""
set "choicek.it=Scarica e aggiungi "0x52_URM by 0x52""
set "choicek.de="0x52_URM by 0x52" herunterladen und hinzufügen"
set "choicek.ru=Скачать и добавить "0x52_URM by 0x52""

set "choicel.en=Rename MC name with a new name"
set "choicel.fr=Renommer le MC name avec un nouveau nom"
set "choicel.es=Renombrar el nombre de MC con un nuevo nombre"
set "choicel.it=Rinomina il nome di MC con un nuovo nome"
set "choicel.de=Den MC-Namen mit einem neuen Namen umbenennen"
set "choicel.ru=Переименовать имя MC с новым именем"

set "choicem.en=Multiple choice in one shot"
set "choicem.fr=Choix multiples en une seule fois"
set "choicem.es=Selección múltiple de una sola vez"
set "choicem.it=Scelta multipla in un colpo solo"
set "choicem.de=Mehrfachauswahl auf einmal"
set "choicem.ru=Множественный выбор за один раз"

set "choicet.en=Extract text for translation purposes"
set "choicet.fr=Extraire le texte à des fins de traduction"
set "choicet.es=Extraer texto con fines de traducción"
set "choicet.it=Estrai il testo a scopo di traduzione"
set "choicet.de=Text zum Übersetzen extrahieren"
set "choicet.ru=Извлечь текст для перевода"

set "minfo2.en=The following choices require administrative privileges."
set "minfo2.fr=Les choix suivants nécessitent des privilèges administrateurs."
set "minfo2.es=Las siguientes opciones requieren privilegios administrativos."
set "minfo2.it=Le seguenti opzioni richiedono privilegi amministrativi."
set "minfo2.de=Die folgenden Optionen erfordern administrative Berechtigungen."
set "minfo2.ru=Следующие варианты требуют административных прав."

set "choice+.en=Add a right-click menu entry for folders to run the script."
set "choice+.fr=Ajouter une entrée de menu contextuel pour les dossiers afin d'exécuter le script."
set "choice+.es=Agregar una entrada de menú contextual para las carpetas para ejecutar el script."
set "choice+.it=Aggiungere una voce al menu contestuale delle cartelle per eseguire lo script."
set "choice+.de=Einträge im Kontextmenü für Ordner hinzufügen, um das Skript auszuführen."
set "choice+.ru=Добавить элемент контекстного меню для папок для запуска скрипта."

set "choice-.en=Remove the right-click menu entry from the registry."
set "choice-.fr=Supprimer l'entrée de menu contextuel du registre."
set "choice-.es=Eliminar la entrada de menú contextual del registro."
set "choice-.it=Rimuovi la voce del menu contestuale dal registro."
set "choice-.de=Einträge im Kontextmenü aus der Registrierung entfernen."
set "choice-.ru=Удалить элемент контекстного меню из реестра."

set "mquest.en=Your choice (1,2,a-m,t,+,-,x by default "
set "mquest.fr=Votre choix (1,2,a-m,t,+,-,x par défaut "
set "mquest.es=Su elección (1,2,a-m,t,+,-,x por defecto "
set "mquest.it=La tua scelta (1,2,a-m,t,+,-,x predefinito "
set "mquest.de=Ihre Wahl (1,2,a-m,t,+,-,x für Standard "
set "mquest.ru=Ваш выбор (1,2,a-m,t,+,-,x по умолчанию "

set "choicex.en=Exit"
set "choicex.fr=Quitter"
set "choicex.es=Salir"
set "choicex.it=Esci"
set "choicex.de=Beenden"
set "choicex.ru=Выход"

set "uchoice.en=Unknown choice:"
set "uchoice.fr=Choix inconnu :"
set "uchoice.es=Opción desconocida:"
set "uchoice.it=Scelta sconosciuta:"
set "uchoice.de=Unbekannte Wahl:"
set "uchoice.ru=Неизвестный выбор:"

:: Menu display
echo.
echo.
echo !mtitle.%LNG%!%YEL%%WORKDIR% %RES%
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
echo        t) %CYA%!choicet.%LNG%!%RES%
echo.
echo        %YEL%!minfo2.%LNG%!%RES%
echo        +) %CYA%!choice+.%LNG%!%RES%
echo        -) %CYA%!choice-.%LNG%!%RES%
echo.
echo        x) %YEL%!choicex.%LNG%!%RES%

set "def.en=[%def%]: "
set "def.fr=[%def%] : "
set "def.es=[%def%]: "
set "def.it=[%def%]: "
set "def.de=[%def%]: "
set "def.ru=[%def%]: "

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
    call :exitn
    call "%SCRIPTDIR%UnRen-legacy.bat" "%WORKDIR%"
    goto exitn
)
if "%OPTION%" == "2" (
    call :exitn
    call "%SCRIPTDIR%UnRen-current.bat" "%WORKDIR%"
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
if /i "%OPTION%" == "l" call :replace_mcname
if /i "%OPTION%" == "m" call :multiChoice
if /i "%OPTION%" == "t" call :extract_text

if "%OPTION%" == "+" call :add_reg
if "%OPTION%" == "-" call :remove_reg

if /i "%OPTION%" == "x" goto exitn

echo.
echo.
<nul set /p="%RED%!uchoice.%LNG%! %OPTION%%RES%"
timeout /t 2 >nul
goto menu

:: Drop our console/dev mode enabler into the game folder
:console
set "unren-console=%WORKDIR%\game\unren-console.rpy"
echo %YEL%!TWADD.%LNG%! %unren-console%.%RES%
echo %YEL%!INCASEDEL.%LNG%!%RES%
echo %YEL%%unren-console%%RES%
echo %YEL%%unren-console%c%RES%
echo.
if not "%OPTION%" == "m" echo.
<nul set /p="!choicea.%LNG%!... "
if exist "%unren-console%" (
    call :elog "%YEL%!APRESENT.%LNG%!%RES%"
) else (
    >"%unren-console%.b64" (
        echo IyBNYWRlIGJ5IChTTSkgYWthIEpvZUx1cm1lbCBAIGY5NXpvbmUudG8NCg0KZGVmaW5lIDk5OSBjb25maWcuY29uc29sZSA9IFRydWUNCmRlZmluZSA5OTkgY29uZmlnLmRldmVsb3BlciA9IFRydWUNCg==
    )
    powershell.exe -nologo -noprofile -noninteractive -command "[IO.File]::WriteAllText('%unren-console%.tmp', [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String((Get-Content '%unren-console%.b64'))))" %debugredir%
    if not exist "%unren-console%.tmp" (
        call :elog "%RED%!FAIL.%LNG%!%RES%"
    ) else (
        move /y "%unren-console%.tmp" "%unren-console%" %debugredir%
        del /f /q "%unren-console%.b64" %debugredir%
        call :elog "%GRE%!PASS.%LNG%!%RES%"
    )
)

goto finish


:: Drop our debug mode enabler into the game folder
:debug
set "unren-debug=%WORKDIR%\game\unren-debug.rpy"
echo %YEL%!TWADD.%LNG%! %unren-debug%.%RES%
echo %YEL%!INCASEDEL.%LNG%!%RES%
echo %YEL%%unren-debug%%RES%
echo %YEL%%unren-debug%c%RES%
echo.
if not "%OPTION%" == "m" echo.
<nul set /p="!choiceb.%LNG%!... "

if exist "%unren-debug%" (
    call :elog "%YEL%!APRESENT.%LNG%!%RES%"
) else (
    >"%unren-debug%.b64" (
        echo IyBNYWRlIGJ5IChTTSkgYWthIEpvZUx1cm1lbCBAIGY5NXpvbmUudG8NCg0KZGVmaW5lIDk5OSBjb25maWcuZGVidWcgPSBUcnVlDQo=
    )
    powershell.exe -nologo -noprofile -noninteractive -command "[IO.File]::WriteAllText('%unren-debug%.tmp', [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String((Get-Content '%unren-debug%.b64'))))" %debugredir%
    if not exist "%unren-debug%.tmp" (
        call :elog "%RED%!FAIL.%LNG%!%RES%"
    ) else (
        move /y "%unren-debug%.tmp" "%unren-debug%" %debugredir%
        del /f /q "%unren-debug%.b64" %debugredir%
        call :elog "%GRE%!PASS.%LNG%!%RES%"
    )
)

goto finish


:: Drop our skip file into the game folder
:skip
set "unren-skip=%WORKDIR%\game\unren-skip.rpy"
echo %YEL%!TWADD.%LNG%! %unren-skip%.%RES%
echo %YEL%!INCASEDEL.%LNG%!%RES%
echo %YEL%%unren-skip%%RES%
echo %YEL%%unren-skip%c%RES%
echo.
if not "%OPTION%" == "m" echo.
<nul set /p="!choicec.%LNG%!... "

if exist "%unren-skip%" (
    call :elog "%YEL%!APRESENT.%LNG%!%RES%"
) else (
    >"%unren-skip%.b64" (
        echo IyBNYWRlIGJ5IChTTSkgYWthIEpvZUx1cm1lbCBAIGY5NXpvbmUudG8NCg0KaW5pdCA5OTkgcHl0aG9uOg0KICAgIF9wcmVmZXJlbmNlcy5za2lwX3Vuc2VlbiA9IFRydWUNCiAgICBjb25maWcuYWxsb3dfc2tpcHBpbmcgPSBUcnVlDQogICAgcmVucHkuZ2FtZS5wcmVmZXJlbmNlcy5za2lwX3Vuc2VlbiA9IFRydWUNCiAgICByZW5weS5nYW1lLnByZWZlcmVuY2VzLnNraXBfYWZ0ZXJfY2hvaWNlcyA9IFRydWUNCiAgICByZW5weS5jb25maWcuZmFzdF9za2lwcGluZyA9IFRydWUNCiAgICB0cnk6DQogICAgICAgIGNvbmZpZy5rZXltYXBbJ3NraXAnXSA9IFsgJ0tfTENUUkwnLCAnS19SQ1RSTCcgXQ0KICAgIGV4Y2VwdDoNCiAgICAgICAgcGFzcw0K
    )
    powershell.exe -nologo -noprofile -noninteractive -command "[IO.File]::WriteAllText('%unren-skip%.tmp', [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String((Get-Content '%unren-skip%.b64'))))" %debugredir%
    if not exist "%unren-skip%.tmp" (
        call :elog "%RED%!FAIL.%LNG%!%RES%"
    ) else (
        move /y "%unren-skip%.tmp" "%unren-skip%" %debugredir%
        del /f /q "%unren-skip%.b64" %debugredir%
        call :elog "%GRE%!PASS.%LNG%!%RES%"
    )
)

goto finish


:: Drop our skip file into the game folder
:skipall
set "unren-skipall=%WORKDIR%\game\unren-skipall.rpy"
echo %YEL%!TWADD.%LNG%! %unren-skipall%.%RES%
echo %YEL%!INCASEDEL.%LNG%!%RES%
echo %YEL%%unren-skipall%%RES%
echo %YEL%%unren-skipall%c%RES%
echo.
if not "%OPTION%" == "m" echo.
<nul set /p="!choiced.%LNG%!... "

if exist "%unren-skipall%" (
    echo %YEL%!APRESENT.%LNG%!%RES%
) else (
    >"%unren-skipall%.b64" (
        echo IyBNYWRlIGJ5IChTTSkgYWthIEpvZUx1cm1lbCBAIGY5NXpvbmUudG8NCg0KaW5pdCA5OTkgcHl0aG9uOg0KICAgIF9wcmVmZXJlbmNlcy5za2lwX3Vuc2VlbiA9IFRydWUNCiAgICBjb25maWcuYWxsb3dfc2tpcHBpbmcgPSBUcnVlDQogICAgcmVucHkuZ2FtZS5wcmVmZXJlbmNlcy5za2lwX3Vuc2VlbiA9IFRydWUNCiAgICByZW5weS5nYW1lLnByZWZlcmVuY2VzLnNraXBfYWZ0ZXJfY2hvaWNlcyA9IFRydWUNCiAgICByZW5weS5jb25maWcuZmFzdF9za2lwcGluZyA9IFRydWUNCiAgICBwcmVmZXJlbmNlcy50cmFuc2l0aW9ucyA9IDANCiAgICB0cnk6DQogICAgICAgIGNvbmZpZy5rZXltYXBbJ3NraXAnXSA9IFsgJ0tfTENUUkwnLCAnS19SQ1RSTCcgXQ0KICAgIGV4Y2VwdDoNCiAgICAgICAgcGFzcw0K
    )
    powershell.exe -nologo -noprofile -noninteractive -command "[IO.File]::WriteAllText('%unren-skipall%.tmp', [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String((Get-Content '%unren-skipall%.b64'))))" %debugredir%
    if not exist "%unren-skipall%.tmp" (
        call :elog "%RED%!FAIL.%LNG%!%RES%"
    ) else (
        move /y "%unren-skipall%.tmp" "%unren-skipall%" %debugredir%
        del /f /q "%unren-skipall%.b64" %debugredir%
        call :elog "%GRE%!PASS.%LNG%!%RES%"
    )
)

goto finish


:: Drop our rollback file into the game folder
:rollback
set "unren-rollback=%WORKDIR%\game\unren-rollback.rpy"
echo %YEL%!TWADD.%LNG%! %unren-rollback%.%RES%
echo %YEL%!INCASEDEL.%LNG%!%RES%
echo %YEL%%unren-rollback%%RES%
echo %YEL%%unren-rollback%c%RES%
echo.
if not "%OPTION%" == "m" echo.
<nul set /p="!choicee.%LNG%!... "

if exist "%unren-rollback%" (
    call :elog "%YEL%!APRESENT.%LNG%!%RES%"
) else (
    > "%unren-rollback%.b64" (
        echo IyBNYWRlIGJ5IChTTSkgYWthIEpvZUx1cm1lbCBAIGY5NXpvbmUudG8NCg0KaW5pdCA5OTkgcHl0aG9uOg0KICAgIHJlbnB5LmNvbmZpZy5yb2xsYmFja19lbmFibGVkID0gVHJ1ZQ0KICAgIHJlbnB5LmNvbmZpZy5oYXJkX3JvbGxiYWNrX2xpbWl0ID0gMjU2DQogICAgcmVucHkuY29uZmlnLnJvbGxiYWNrX2xlbmd0aCA9IDI1Ng0KICAgIGRlZiB1bnJlbl9ub2Jsb2NrKCphcmdzLCAqKmt3YXJncyk6DQogICAgICAgIHJldHVybg0KICAgIHJlbnB5LmJsb2NrX3JvbGxiYWNrID0gdW5yZW5fbm9ibG9jaw0KICAgIHRyeToNCiAgICAgICAgY29uZmlnLmtleW1hcFsncm9sbGJhY2snXSA9IFsgJ0tfUEFHRVVQJywgJ3JlcGVhdF9LX1BBR0VVUCcsICdLX0FDX0JBQ0snLCAnbW91c2Vkb3duXzQnIF0NCiAgICBleGNlcHQ6DQogICAgICAgIHBhc3MNCg==
    )
    powershell.exe -nologo -noprofile -noninteractive -command "[IO.File]::WriteAllText('%unren-rollback%.tmp', [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String((Get-Content '%unren-rollback%.b64'))))" %debugredir%
    if not exist "%unren-rollback%.tmp" (
        call :elog "%RED%!FAIL.%LNG%!%RES%"
    ) else (
        move /y "%unren-rollback%.tmp" "%unren-rollback%" %debugredir%
        del /f /q "%unren-rollback%.b64" %debugredir%
        call :elog "%GRE%!PASS.%LNG%!%RES%"
    )
)

goto finish


:: Drop our Quick Save/Load file into the game folder
:quick
set "unren-quick=%WORKDIR%\game\unren-quick.rpy"
echo %YEL%!TWADD.%LNG%! %unren-quick%.%RES%
echo %YEL%!INCASEDEL.%LNG%!%RES%
echo %YEL%%unren-quick%%RES%
echo %YEL%%unren-quick%c%RES%
echo.
if not "%OPTION%" == "m" echo.
<nul set /p="!choicef.%LNG%!... "

if exist "%unren-quick%" (
    call :elog "%YEL%!APRESENT.%LNG%!%RES%"
) else (
    >"%unren-quick%.b64" (
        echo IyBNYWRlIGJ5IChTTSkgYWthIEpvZUx1cm1lbCBAIGY5NXpvbmUudG8NCg0KaW5pdCA5OTkgcHl0aG9uOg0KICAgIHRyeToNCiAgICAgICAgY29uZmlnLnVuZGVybGF5WzBdLmtleW1hcFsncXVpY2tTYXZlJ10gPSBRdWlja1NhdmUoKQ0KICAgICAgICBjb25maWcua2V5bWFwWydxdWlja1NhdmUnXSA9ICdLX0Y1Jw0KICAgICAgICBjb25maWcudW5kZXJsYXlbMF0ua2V5bWFwWydxdWlja0xvYWQnXSA9IFF1aWNrTG9hZCgpDQogICAgICAgIGNvbmZpZy5rZXltYXBbJ3F1aWNrTG9hZCddID0gJ0tfRjknDQogICAgZXhjZXB0Og0KICAgICAgICBwYXNzDQo=
    )
    powershell.exe -nologo -noprofile -noninteractive -command "[IO.File]::WriteAllText('%unren-quick%.tmp', [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String((Get-Content '%unren-quick%.b64'))))" %debugredir%
    if not exist "%unren-quick%.tmp" (
        call :elog "%RED%!FAIL.%LNG%!%RES%"
    ) else (
        move /y "%unren-quick%.tmp" "%unren-quick%" %debugredir%
        del /f /q "%unren-quick%.b64" %debugredir%
        call :elog "%GRE%!PASS.%LNG%!%RES%"
    )
)

goto finish


:: Drop our Quick Menu file into the game folder
:qmenu
set "unren-qmenu=%WORKDIR%\game\unren-qmenu.rpy"
echo %YEL%!TWADD.%LNG%! %unren-qmenu%.%RES%
echo %YEL%!INCASEDEL.%LNG%!%RES%
echo %YEL%%unren-qmenu%%RES%
echo %YEL%%unren-qmenu%c%RES%
echo.
if not "%OPTION%" == "m" echo.
<nul set /p="!choiceg.%LNG%!... "

if exist "%unren-qmenu%" (
    call :elog "%YEL%!APRESENT.%LNG%!%RES%"
) else (
    >"%unren-qmenu%.b64" (
        echo IyBNYWRlIGJ5IChTTSkgYWthIEpvZUx1cm1lbCBAIGY5NXpvbmUudG8NCg0KaW5pdCBweXRob246DQogICAgZGVmIGFsd2F5c19lbmFibGVfcXVpY2tfbWVudSgpOg0KICAgICAgICBzdG9yZS5xdWlja19tZW51ID0gVHJ1ZQ0KICAgICAgICByZW5weS5zaG93X3NjcmVlbigicXVpY2tfbWVudSIpDQogICAgY29uZmlnLm92ZXJsYXlfZnVuY3Rpb25zLmFwcGVuZChhbHdheXNfZW5hYmxlX3F1aWNrX21lbnUpDQoNCiAgICBkZWYgZm9yY2VfcXVpY2tfbWVudV9vbl9pbnRlcmFjdCgpOg0KICAgICAgICBzdG9yZS5xdWlja19tZW51ID0gVHJ1ZQ0KICAgIGNvbmZpZy5pbnRlcmFjdF9jYWxsYmFja3MuYXBwZW5kKGZvcmNlX3F1aWNrX21lbnVfb25faW50ZXJhY3Qp
    )
    powershell.exe -nologo -noprofile -noninteractive -command "[IO.File]::WriteAllText('%unren-qmenu%.tmp', [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String((Get-Content '%unren-qmenu%.b64'))))" %debugredir%
    if not exist "%unren-qmenu%.tmp" (
        call :elog "%RED%!FAIL.%LNG%!%RES%"
    ) else (
        move /y "%unren-qmenu%.tmp" "%unren-qmenu%" %debugredir%
        del /f /q "%unren-qmenu%.b64" %debugredir%
        call :elog "%GRE%!PASS.%LNG%!%RES%"
    )
)

goto finish


:: Add the Universal Gallery Unlocker to the game folder
:add_ugu
set "ugu_name=Universal_Gallery_Unlocker ZLZK"
set "url=https://attachments.f95zone.to/2024/01/3314515_Universal_Gallery_Unlocker_2024-01-24_ZLZK.zip"
set "uguzip=%TEMP%\Universal_Gallery_Unlocker.zip"
set "uguhardzip=%TEMP%\hard.zip"
set "ugusoftzip=%TEMP%\soft.zip"
set "ugudir=%WORKDIR%\game\_mods\"
del /f /q "%uguzip%" %debugredir%
del /f /q "%uguhardzip%" %debugredir%
del /f /q "%ugusoftzip%" %debugredir%

echo %YEL%!TWADD.%LNG%! %ugudir%.%RES%
echo %YEL%!INCASEOF.%LNG%! %RES%
echo %MAG%https://f95zone.to/threads/universal-gallery-unlocker-2024-01-24-zlzk.136812/%RES%
echo %YEL%!INCASEDEL.%LNG%!%RES%
echo %YEL%%ugudir%\ZLZK_UGU_soft%RES%
echo.
if not "%OPTION%" == "m" echo.
<nul set /p="!choiceh.%LNG%!... "

if %debuglevel% GEQ 1 (
    call :elog .
    echo powershell.exe -nologo -noprofile -noninteractive -command "(New-Object System.Net.WebClient).DownloadFile('%url%','%uguzip%')"
)
powershell.exe -nologo -noprofile -noninteractive -command "(New-Object System.Net.WebClient).DownloadFile('%url%','%uguzip%')" %debugredir%
if %errorlevel% NEQ 0 (
    call :elog "%RED%!FAIL.%LNG%!%RES%"
) else (
    if %debuglevel% GEQ 1 (
        call :elog .
        echo powershell.exe -nologo -noprofile -noninteractive -command "Expand-Archive -Force '%uguzip%' '%TEMP%'"
    )
    powershell.exe -nologo -noprofile -noninteractive -command "Expand-Archive -Force '%uguzip%' '%TEMP%'" %debugredir%
    if not exist "%uguhardzip%" (
        echo %RED%!FAIL.%LNG%! !MISSING.%LNG%! %uguhardzip% %RES%
        goto skip_ugu
    )
    if not exist "%ugusoftzip%" (
        echo %RED%!FAIL.%LNG%! !MISSING.%LNG%! %ugusoftzip% %RES%
        goto skip_ugu
    )
    if %debuglevel% GEQ 1 (
        call :elog .
        echo powershell.exe -nologo -noprofile -noninteractive -command "Expand-Archive -Force '%ugusoftzip%' '!WORKDIR!'"
    )
    powershell.exe -nologo -noprofile -noninteractive -command "Expand-Archive -Force '%ugusoftzip%' '!WORKDIR!'" %debugredir%
    if %errorlevel% NEQ 0 (
        call :elog "%RED%!FAIL.%LNG%! !UNEXTRACT.%LNG%! %ugusoftzip% %RES%"
        goto skip_ucd
    ) else (
        call :elog "%GRE%!PASS.%LNG%!%RES%"
    )
    del /f /q "%ugusoftzip%" %debugredir%
    del /f /q "%uguhardzip%" %debugredir%
    del /f /q "%uguzip%" %debugredir%
    del /f /q "%TEMP%\readme.txt" %debugredir%
)

goto finish


:: Add the Universal Choice Descriptor to the game folder
:add_ucd
set "ucd_name=Universal_Choice_Descriptor ZLZK"
set "url=https://attachments.f95zone.to/2024/01/3314453_Universal_Choice_Descriptor.zip"
set "ucdzip=%TEMP%\Universal_Choice_Descriptor.zip"
set "ucdzip_part1=%TEMP%\Universal_Choice_Descriptor_[2024-01-24]_[ZLZK].zip"
set "ucdzip_part2=%TEMP%\ZLZK_[2024-01-24]_[ZLZK].zip"

set "ucddir=%WORKDIR%\game\_mods\"
del /f /q "%ucdzip%" %debugredir%
del /f /q "%ucdzip_part1%" %debugredir%
del /f /q "%ucdzip_part2%" %debugredir%
del /f /q "%TEMP%\Readme.txt" %debugredir%

echo %YEL%!TWADD.%LNG%! %ucddir%.%RES%
echo %YEL%!INCASEOF.%LNG%! %RES%
echo %MAG%https://f95zone.to/threads/universal-gallery-unlocker-2024-01-24-zlzk.136812/%RES%
echo %YEL%!INCASEDEL.%LNG%!%RES%
echo %YEL%%ucddir%%RES%
echo.
if not "%OPTION%" == "m" echo.
<nul set /p="!choicei.%LNG%!... "
if %debuglevel% GEQ 1 (
    call :elog .
    echo powershell.exe -nologo -noprofile -noninteractive -command "(New-Object System.Net.WebClient).DownloadFile('%url%','%ucdzip%')"
)
powershell.exe -nologo -noprofile -noninteractive -command "(New-Object System.Net.WebClient).DownloadFile('%url%','%ucdzip%')" %debugredir%
if not exist "%ucdzip%" (
	call :elog "%RED%!FAIL.%LNG%! !UNDWNLD.%LNG%! %url% %RES%"
	goto skip_ucd
) else (
	if %debuglevel% GEQ 1 (
        call :elog .
        echo powershell.exe -nologo -noprofile -noninteractive -command "Expand-Archive -Force '%ucdzip%' '%TEMP%'"
    )
	powershell.exe -nologo -noprofile -noninteractive -command "Expand-Archive -Force '%ucdzip%' '%TEMP%'" %debugredir%
    if not exist "%ucdzip_part1%" (
        call :elog "%RED%!FAIL.%LNG%! !MISSING.%LNG%! %ucdzip_part1% %RES%"
        goto skip_ucd
    ) else (
        move /y "%ucdzip_part1%" %TEMP%\part1.zip %debugredir%
    )
    if not exist "%ucdzip_part2%" (
        call :elog "%RED%!FAIL.%LNG%! !MISSING.%LNG%! %ucdzip_part2% %RES%"
        goto skip_ucd
    ) else (
        move /y "%ucdzip_part2%" %TEMP%\part2.zip %debugredir%
    )
    if %debuglevel% GEQ 1 (
        call :elog .
        echo powershell.exe -nologo -noprofile -noninteractive -command "Expand-Archive -Force '%TEMP%\part1.zip' '!WORKDIR!'"
    )
    powershell.exe -nologo -noprofile -noninteractive -command "Expand-Archive -Force '%TEMP%\part1.zip' '!WORKDIR!'" %debugredir%
    if %errorlevel% NEQ 0 (
        call :elog "%RED%!FAIL.%LNG%! !UNEXTRACT.%LNG%! %ucdzip_part1% %RES%"
        goto skip_ucd
    )
    if %debuglevel% GEQ 1 (
        call :elog .
        echo powershell.exe -nologo -noprofile -noninteractive -command "Expand-Archive -Force '%TEMP%\part2.zip' '!WORKDIR!'"
    )
    powershell.exe -nologo -noprofile -noninteractive -command "Expand-Archive -Force '%TEMP%\part2.zip' '!WORKDIR!'" %debugredir%
    if %errorlevel% NEQ 0 (
        call :elog "%RED%!FAIL.%LNG%! !UNEXTRACT.%LNG%! %ucdzip_part2% %RES%"
        goto skip_ucd
    )
    call :elog "%GRE%!PASS.%LNG%!%RES%"
    :skip_ucd
	del /f /q "%ucdzip%" %debugredir%
    del /f /q "%ucdzip_part1%" %debugredir%
    del /f /q "%TEMP%\part1.zip" %debugredir%
    del /f /q "%ucdzip_part2%" %debugredir%
    del /f /q "%TEMP%\part2.zip" %debugredir%
    del /f /q "%TEMP%\readme.txt" %debugredir%
)

goto finish


:: Download and install Universal Transparent Text Box Mod by Penfold Mole
:add_utbox
set "utbox_name=Universal Transparent Text Box Mod"
set "url=https://attachments.f95zone.to/2023/12/3214690_RenPy_universal_transparent_textbox_mod_v2.6.4_by_Penfold_Mole.7z"
set "utboxzip=%TEMP%\RenPy_Transparent_Text_Box_Mod.7z"
set "utbox_file=%WORKDIR%\game\y_outline.rpy"
set "utbox_tdir=%TEMP%\utbox"

:: Need 7z.exe for extraction
if not exist "%ProgramFiles%\7-Zip\7z.exe" (
    echo %RED%!FAIL.%LNG%! !MISSING.%LNG%! %YEL%%ProgramFiles%\7-Zip\7z.exe %RES%
    goto skip_utbox
)

del /f /q "!utbox_file!" %debugredir%

echo %YEL%!TWADD.%LNG%! !utbox_file! %RES%
echo %YEL%!INCASEOF.%LNG%! %RES%
echo %MAG%https://f95zone.to/threads/renpy-transparent-text-box-mod-v2-6-4.11925/%RES%
echo %YEL%!INCASEDEL.%LNG%!%RES%
echo %YEL%!utbox_file!%RES%
echo.
if not "%OPTION%" == "m" echo.
<nul set /p="!choicej.%LNG%!..."

del /f /q "!utboxzip!" %debugredir%
rd /s /q "!utbox_tdir!" %debugredir%

if %debuglevel% GEQ 1 (
    call :elog .
    echo powershell.exe -nologo -noprofile -noninteractive -command "(New-Object System.Net.WebClient).DownloadFile('%url%','%utboxzip%')"
)
powershell.exe -nologo -noprofile -noninteractive -command "(New-Object System.Net.WebClient).DownloadFile('%url%','%utboxzip%')" %debugredir%
if not exist "%utboxzip%" (
    echo %RED% !FAIL.%LNG%! !UNDWNLD.%LNG%! %url% %RES%
    goto skip_utbox
) else (
    if %debuglevel% GEQ 1 (
        call :elog .
        echo "%ProgramFiles%\7-Zip\7z.exe" x -y -o"!utbox_tdir!" "!utboxzip!"
    )
    "%ProgramFiles%\7-Zip\7z.exe" x -y -o"!utbox_tdir!" "!utboxzip!" %debugredir%
    if not exist "!utbox_tdir!\game\y_outline.rpy" (
        echo %RED% !FAIL.%LNG%! !UNEXTRACT.%LNG%! "!utboxzip!" %RES%
        goto skip_utbox
    ) else (
        move /y "!utbox_tdir!\game\y_outline.rpy" "!WORKDIR!\game" %debugredir%
        if exist "!utbox_file!" (
            echo %GRE% !PASS.%LNG%!%RES%
        ) else (
            echo %RED% !FAIL.%LNG%! !MISSING.%LNG%! %YEL%!utbox_file! %RES%
        )
    )
    :skip_utbox
    del /f /q "!utboxzip!" %debugredir%
    rd /s /q "!utbox_tdir!" %debugredir%
)

goto finish


:: Download 0x52_URM and add to the game
:add_urm
set "urm_name=0x52_URM"
set "url=https://attachments.f95zone.to/2025/07/5028578_0x52_URM.zip"
set "urm_zip=%TEMP%\0x52_URM.zip"
set "urm_rpa=%WORKDIR%\game\0x52_URM.rpa"
del /f /q "%urm_zip%" %debugredir%

echo %YEL%!TWADD.%LNG%! %urm_rpa%.%RES%
echo %YEL%!INCASEOF.%LNG%! %RES%
echo %MAG%https://f95zone.to/threads/universal-renpy-mod-urm-2-6-2-mod-any-renpy-game-yourself.48025/%RES%
echo %YEL%!INCASEDEL.%LNG%!%RES%
echo %YEL%%urm_rpa%%RES%

echo.
if not "%OPTION%" == "m" echo.
<nul set /p="!choicek.%LNG%!... "

if %debuglevel% GEQ 1 (
    call :elog .
    echo powershell.exe -nologo -noprofile -noninteractive -command "(New-Object System.Net.WebClient).DownloadFile('%url%','%urm_zip%.tmp')"
)
powershell.exe -nologo -noprofile -noninteractive -command "(New-Object System.Net.WebClient).DownloadFile('%url%','%urm_zip%.tmp')" %debugredir%
if not exist "%urm_zip%.tmp" (
	echo %RED%!FAIL.%LNG%! !UNDWNLD.%LNG%! %urm_name%.zip.%RES%
) else (
    move /y "%urm_zip%.tmp" "%urm_zip%" %debugredir%
    if %debuglevel% GEQ 1 (
        call :elog .
        echo powershell.exe -nologo -noprofile -noninteractive -command "Expand-Archive -Force '%urm_zip%' '!WORKDIR!\game'"
    )
	powershell.exe -nologo -noprofile -noninteractive -command "Expand-Archive -Force '%urm_zip%' '!WORKDIR!\game'" %debugredir%
	if %errorlevel% NEQ 0 (
		echo %RED%!FAIL.%LNG%! !UNINSTALL.%LNG%! %urm_name% %RES%
	) else (
		echo %GRE%!PASS.%LNG%!%RES%
	)
	del /f /q "%urm_zip%" %debugredir%
)

goto finish


:: Replace MCName in game files
:replace_mcname
set "unr-mcchange=%WORKDIR%\game\unren-mcchange.rpy"

set "rmcname.en=Please input the new name (without quotes): "
set "rmcname.fr=Veuillez saisir le nouveau nom (sans guillemets) : "
set "rmcname.es=Por favor ingrese el nuevo nombre (sin comillas): "
set "rmcname.it=Si prega di inserire il nuovo nome (senza virgolette): "
set "rmcname.de=Bitte geben Sie den neuen Namen (ohne Anführungszeichen) ein: "
set "rmcname.ru=Пожалуйста, введите новое имя (без кавычек): "

set "rmcname2.en=No name provided."
set "rmcname2.fr=Aucun nom fourni."
set "rmcname2.es=No se proporcionó ningún nombre."
set "rmcname2.it=Nome non fornito."
set "rmcname2.de=Kein Name angegeben."
set "rmcname2.ru=Имя не указано."

set "rmcname3.en=Please input the old name (without quotes): "
set "rmcname3.fr=Veuillez saisir l'ancien nom (sans guillemets) : "
set "rmcname3.es=Por favor ingrese el nombre antiguo (sin comillas): "
set "rmcname3.it=Si prega di inserire il vecchio nome (senza virgolette): "
set "rmcname3.de=Bitte geben Sie den alten Namen (ohne Anführungszeichen) ein: "
set "rmcname3.ru=Пожалуйста, введите старое имя (без кавычек): "

echo %YEL%!TWADD.%LNG%! %unr-mcchange%.%RES%
echo %YEL%!INCASEDEL.%LNG%!%RES%
echo %YEL%%unr-mcchange%%RES%
echo %YEL%%unr-mcchange%c%RES%

call :elog .
if not "%OPTION%" == "m" echo.
set "oldmcname="
set /p "oldmcname=!rmcname3.%LNG%!"
if "%oldmcname%" == "" (
    echo %RED%!FAIL.%LNG%! !rmcname2.%LNG%!.%RES%
    goto mcend
)

call :elog .
set "newmcname="
set /p "newmcname=!rmcname.%LNG%!"
if "%newmcname%" == "" (
    echo %RED%!FAIL.%LNG%! !rmcname2.%LNG%!.%RES%
    goto mcend
)

call :elog .
if not "%OPTION%" == "m" echo.
<nul set /p="!choicel.%LNG%!... "

>"%unr-mcchange%.b64" (
    echo IyBNYWRlIGJ5IChTTSkgYWthIEpvZUx1cm1lbCBAIGY5NXpvbmUudG8NCg0KZGVmaW5lIDk5OSBtY25hbWUgPSAibmV3bWNuYW1lIg0KZGVmaW5lIDk5OSBNQyA9ICJuZXdtY25hbWUiDQpkZWZpbmUgOTk5IE1DX25hbWUgPSAibmV3bWNuYW1lIg0KZGVmaW5lIDk5OSBtY19uYW1lID0gIm5ld21jbmFtZSINCg0KaW5pdCA5OTkgcHl0aG9uOg0KICAgIGltcG9ydCByZQ0KDQogICAgIyBQbGFjZWhvbGRlcnMgcmVwbGFjZWQgYnkgUG93ZXJTaGVsbCBiZWZvcmUgZXhlY3V0aW9uDQogICAgT0xEID0gIm9sZG1jbmFtZSINCiAgICBORVcgPSAibmV3bWNuYW1lIg0KDQogICAgZGVmIF9jYXNlX2xpa2UocywgbW9kZWwpOg0KICAgICAgICAjIEFsaWduIHRoZSBjYXNlIG9mIHMgd2l0aCB0aGF0IG9mIG1vZGVsICh1cHBlciwgVGl0bGUsIGxvd2VyKQ0KICAgICAgICBpZiBtb2RlbC5pc3VwcGVyKCk6DQogICAgICAgICAgICByZXR1cm4gcy51cHBlcigpDQogICAgICAgIGVsaWYgbW9kZWxbOjFdLmlzdXBwZXIoKSBhbmQgbW9kZWxbMTpdLmlzbG93ZXIoKToNCiAgICAgICAgICAgIHJldHVybiBzLmNhcGl0YWxpemUoKQ0KICAgICAgICBlbHNlOg0KICAgICAgICAgICAgcmV0dXJuIHMubG93ZXIoKQ0KDQogICAgZGVmIHJlcGxhY2VfdGV4dCh0KToNCiAgICAgICAgb2xkID0gT0xEDQogICAgICAgIG5ldyA9IE5FVw0KDQogICAgICAgIG9fZXNjID0gcmUuZXNjYXBlKG9sZCkNCiAgICAgICAgZl9vbGQgPSBvbGRbOjFdDQogICAgICAgIGZfbmV3ID0gbmV3WzoxXQ0KDQogICAgICAgICMgMSkgUmVwbGFjZW1lbnQgb2YgdGhlIGVudGlyZSB3b3JkIChjYXNlLWluc2Vuc2l0aXZlKSB3aXRoIGNhc2UgcmVzdG9yYXRpb24NCiAgICAgICAgYmFzZV9wYXQgPSByZS5jb21waWxlKHJmIlxiKD9pOih7b19lc2N9KSlcYiIpDQogICAgICAgIGRlZiBiYXNlX3JlcGwobSk6DQogICAgICAgICAgICByZXR1cm4gX2Nhc2VfbGlrZShuZXcsIG0uZ3JvdXAoMSkpDQogICAgICAgIHQgPSBiYXNlX3BhdC5zdWIoYmFzZV9yZXBsLCB0KQ0KDQogICAgICAgICMgMikgU3R1dHRlcmluZyB0eXBlOiBjLWNvbm5vciDihpIgai1qb2UgKGFuZCBjYXNlIHZhcmlhbnRzKQ0KICAgICAgICBzdDFfcGF0ID0gcmUuY29tcGlsZShyZiJcYihbe2Zfb2xkLmxvd2VyKCl9e2Zfb2xkLnVwcGVyKCl9XSktKD9pOih7b19lc2N9KSlcYiIpDQogICAgICAgIGRlZiBzdDFfcmVwbChtKToNCiAgICAgICAgICAgIHByZWYgPSBtLmdyb3VwKDEpICAgICAgICMgcHJlZml4IGxldHRlciAoYy9DKQ0KICAgICAgICAgICAgb2xkX3BhcnQgPSBtLmdyb3VwKDIpICAgIyB3b3JkIChjb25ub3IvQ29ubm9yL0NPTk5PUikNCiAgICAgICAgICAgIG5ld193b3JkID0gX2Nhc2VfbGlrZShuZXcsIG9sZF9wYXJ0KQ0KICAgICAgICAgICAgbmV3X2ZpcnN0ID0gZl9uZXcudXBwZXIoKSBpZiBwcmVmLmlzdXBwZXIoKSBlbHNlIGZfbmV3Lmxvd2VyKCkNCiAgICAgICAgICAgIHJldHVybiBmIntuZXdfZmlyc3R9LXtuZXdfd29yZH0iDQogICAgICAgIHQgPSBzdDFfcGF0LnN1YihzdDFfcmVwbCwgdCkNCg0KICAgICAgICAjIDMpIFN0dXR0ZXJpbmcgdHlwZTogY28tY29ubm9yIOKGkiBqby1qb2UgKGFuZCBjYXNlIHZhcmlhbnRzKQ0KICAgICAgICBzdDJfcGF0ID0gcmUuY29tcGlsZShyZiJcYihbe2Zfb2xkLmxvd2VyKCl9e2Zfb2xkLnVwcGVyKCl9XSkoW29PXSktKD9pOih7b19lc2N9KSlcYiIpDQogICAgICAgIGRlZiBzdDJfcmVwbChtKToNCiAgICAgICAgICAgIHByZWYgPSBtLmdyb3VwKDEpICAgICAgICMgcHJlZml4IGxldHRlciAoYy9DKQ0KICAgICAgICAgICAgb2NoYXIgPSBtLmdyb3VwKDIpICAgICAgIyAnbycgb3IgJ08nDQogICAgICAgICAgICBvbGRfcGFydCA9IG0uZ3JvdXAoMykgICAjIHdvcmQgKGNvbm5vci9Db25ub3IvQ09OTk9SKQ0KICAgICAgICAgICAgbmV3X3dvcmQgPSBfY2FzZV9saWtlKG5ldywgb2xkX3BhcnQpDQogICAgICAgICAgICBuZXdfZmlyc3QgPSBmX25ldy51cHBlcigpIGlmIHByZWYuaXN1cHBlcigpIGVsc2UgZl9uZXcubG93ZXIoKQ0KICAgICAgICAgICAgIyBLZWVwIHRoZSBjYXNlIG9mIHRoZSAnbycgbGV0dGVyIGFzIGVuY291bnRlcmVkDQogICAgICAgICAgICByZXR1cm4gZiJ7bmV3X2ZpcnN0fXtvY2hhcn0te25ld193b3JkfSINCiAgICAgICAgdCA9IHN0Ml9wYXQuc3ViKHN0Ml9yZXBsLCB0KQ0KDQogICAgICAgIHJldHVybiB0DQoNCiAgICBjb25maWcucmVwbGFjZV90ZXh0ID0gcmVwbGFjZV90ZXh0DQogICAgZGVsIHJlcGxhY2VfdGV4dA0K
)
powershell.exe -nologo -noprofile -noninteractive -command "[IO.File]::WriteAllBytes('!unr-mcchange!.tmp', [Convert]::FromBase64String((Get-Content '!unr-mcchange!.b64' -Raw)))" %debugredir%
if not exist "!unr-mcchange!.tmp" (
    echo %RED%!FAIL.%LNG%!%RES% !MISSING.%LNG%! !unr-mcchange!.tmp
    goto mcend
) else (
    del /f /q "!unr-mcchange!.b64" %debugredir%
    powershell.exe -nologo -noprofile -noninteractive -command "(Get-Content '!unr-mcchange!.tmp') -replace 'newmcname', '!newmcname!' | Set-Content '!unr-mcchange!'" %debugredir%
    powershell.exe -nologo -noprofile -noninteractive -command "(Get-Content '!unr-mcchange!') -replace 'oldmcname', '!oldmcname!' | Set-Content '!unr-mcchange!'" %debugredir%
    if not exist "!unr-mcchange!" (
        echo %RED%!FAIL.%LNG%!%RES% !MISSING.%LNG%! !unr-mcchange!
        goto mcend
    )
    del /f /q "!unr-mcchange!.tmp" %debugredir%
    echo %GRE%!PASS.%LNG%!%RES%
)

:mcend

goto finish


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
        timeout /t 2 >nul
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
        if /i "%%C" == "l" call :replace_mcname
        if /i "%%C" == "t" call :extract_text

        if "%%C" == "+" call :add_reg
        if "%%C" == "-" call :remove_reg
    )
)

echo.
echo.
pause
goto menu


:: Extract text for translation purpose
:extract_text
if "%LNG%" == "en"  set translation_lang=english
if "%LNG%" == "fr"  set translation_lang=french
if "%LNG%" == "es"  set translation_lang=spanish
if "%LNG%" == "it"  set translation_lang=italian
if "%LNG%" == "de"  set translation_lang=german
if "%LNG%" == "ru"  set translation_lang=russian

cd /d "%WORKDIR%"

set "etext1.en=Searching for game name"
set "etext1.fr=Recherche du nom du jeu"
set "etext1.es=Buscando el nombre del juego"
set "etext1.it=Cercando il nome del gioco"
set "etext1.de=Suche nach dem Spieletitel"
set "etext1.ru=Поиск названия игры"

set "etext2.en=No game files found with .exe, .py or .sh extensions."
set "etext2.fr=Aucun fichier de jeu trouvé avec les extensions .exe, .py ou .sh."
set "etext2.es=No se encontraron archivos de juego con las extensiones .exe, .py o .sh."
set "etext2.it=Nessun file di gioco trovato con le estensioni .exe, .py o .sh."
set "etext2.de=Keine Spieldateien mit den Erweiterungen .exe, .py oder .sh gefunden."
set "etext2.ru=Не найдено игровых файлов с расширениями .exe, .py или .sh."

set "etext3.en=Enter the target translation language (%YEL%%translation_lang%%RES% by default): "
set "etext3.fr=Entrez la langue de traduction cible (%YEL%%translation_lang%%RES% par défaut) : "
set "etext3.es=Ingrese el idioma de traducción objetivo (%YEL%%translation_lang%%RES% por defecto): "
set "etext3.it=Inserisci la lingua di traduzione di destinazione (%YEL%%translation_lang%%RES% per impostazione predefinita): "
set "etext3.de=Geben Sie die Zielsprache für die Übersetzung ein (%YEL%%translation_lang%%RES% standardmäßig): "
set "etext3.ru=Введите целевой язык перевода (%YEL%%translation_lang%%RES% по умолчанию): "

set "etext4.en=Unable to extract text for translation."
set "etext4.fr=Impossible d'extraire le texte pour la traduction."
set "etext4.es=No se pudo extraer el texto para la traducción."
set "etext4.it=Impossibile estrarre il testo per la traduzione."
set "etext4.de=Fehler beim Extrahieren des Textes für die Übersetzung."
set "etext4.ru=Не удалось извлечь текст для перевода."

set "etext5.en=Please input the game name (without extension): "
set "etext5.fr=Veuillez saisir le nom du jeu (sans extension) : "
set "etext5.es=Por favor, ingrese el nombre del juego (sin extensión): "
set "etext5.it=Si prega di inserire il nome del gioco (senza estensione): "
set "etext5.de=Bitte geben Sie den Namen des Spiels ein (ohne Erweiterung): "
set "etext5.ru=Пожалуйста, введите название игры (без расширения): "

:: find the current game name by checking the presence of same name with .exe, .py and .sh extension
call :elog .
if not "%OPTION%" == "m" echo.
<nul set /p="!etext1.%LNG%!... "

set "processed="
set "fname="

for %%e in (exe py sh) do (
    for %%f in (*.%%e) do (
        set "tempfname=%%~nf"

        :: Check if this name has already been processed
        echo !processed! | findstr /i "\!tempfname!" >nul
        if errorlevel 1 (
            :: Count how many files with this name exist
            set /a count=0
            for %%x in (exe py sh) do (
                if exist "%%~dpf!tempfname!.%%x" (
                    set /a count+=1
                )
            )
            if !count! EQU 3 (
                echo %YEL%!tempfname! %GRE%!PASS.%LNG%!%YEL%%RES%
                set "processed=!processed! !tempfname!"
                set "fname=!tempfname!"
                goto found_name
            )
        )
    )
)

:: If no name found, ask user to input the name
if "!fname!"  == "" (
    echo %RED%!FAIL.%LNG%! !etext2.%LNG%!%RES%
    goto input_name
)

:input_name
    call :elog .
    set /p "fname=!etext5.%LNG%!"
    if "!fname!" == "" (
        echo %RED%!FAIL.%LNG%! !etext2.%LNG%!%RES%
        goto input_name
    ) else (
        REM set "fname=%fname:.=%"
        if not exist "!WORKDIR!\!fname!.exe" (
            echo %RED%!FAIL.%LNG%! !etext2.%LNG%!%RES%
            goto input_name
        )
    )
)

:found_name
call :elog .
set /p "translation_lang=!etext3.%LNG%!"

if not defined translation_lang (
	set "translation_lang=french"
)

if not exist "!WORKDIR!\game\tl\" (
	mkdir "!WORKDIR!\game\tl"
)

call :elog .
if not "%OPTION%" == "m" echo.
<nul set /p="!choicet.%LNG%!... "

cd /d "!WORKDIR!"
if %debuglevel% GEQ 1 echo "!PYTHONHOME!python.exe" %PYNOASSERT% "!fname!.py" game translate !translation_lang!
"!PYTHONHOME!python.exe" %PYNOASSERT% "!fname!.py" game translate !translation_lang! %debugredir%
if %errorlevel% NEQ 0 (
	echo %RED%!FAIL.%LNG%! !etext4.%LNG%!%RES%
) else (
    echo %GRE%!PASS.%LNG%!%RES%
)
call :elog .

goto finish


:: Add entry to registry
:add_reg
set "areg1.en=This will add an entry to the right-click menu for folders."
set "areg1.fr=Cela ajoutera une entrée au menu contextuel pour les dossiers."
set "areg1.es=Esto añadirá una entrada al menú contextual para las carpetas."
set "areg1.it=Questo aggiungerà una voce al menu contestuale per le cartelle."
set "areg1.de=Dies wird einen Eintrag zum Rechtsklick-Menü für Ordner hinzufügen."
set "areg1.ru=Это добавит элемент в контекстное меню для папок."

set "areg2.en=When you select this option,"
set "areg2.fr=Lorsque vous sélectionnez cette option,"
set "areg2.es=Cuando seleccione esta opción,"
set "areg2.it=Quando selezioni questa opzione,"
set "areg2.de=Wenn Sie diese Option auswählen,"
set "areg2.ru=Когда вы выберете эту опцию,"

set "areg2a.en=the script "%SCRIPTDIR%%SCRIPTNAME%" will be executed."
set "areg2a.fr=le script "%SCRIPTDIR%%SCRIPTNAME%" sera exécuté."
set "areg2a.es=se ejecutará el script "%SCRIPTDIR%%SCRIPTNAME%"."
set "areg2a.it=verrà eseguito lo script "%SCRIPTDIR%%SCRIPTNAME%"."
set "areg2a.de=wird das Skript "%SCRIPTDIR%%SCRIPTNAME%" ausgeführt."
set "areg2a.ru=будет выполнен скрипт "%SCRIPTDIR%%SCRIPTNAME%"."

set "areg3.en=Adding the right-click menu entry to the registry... "
set "areg3.fr=Ajout de l'entrée de menu contextuel au registre... "
set "areg3.es=Adding the right-click menu entry to the registry... "
set "areg3.it=Aggiunta della voce del menu contestuale al registro... "
set "areg3.de=Hinzufügen des Rechtsklick-Menüeintrags zur Registrierung... "
set "areg3.ru=Добавление элемента контекстного меню в реестр... "

set "areg4.en=Run %SCRIPTNAME% Script"
set "areg4.fr=Exécuter le script %SCRIPTNAME%"
set "areg4.es=Ejecutar el script %SCRIPTNAME%"
set "areg4.it=Esegui lo script %SCRIPTNAME%"
set "areg4.de=Führen Sie das Skript %SCRIPTNAME% aus"
set "areg4.ru=Запустить скрипт %SCRIPTNAME%"

call :check_admin

call :elog .
echo %YEL%!areg1.%LNG%!%RES%
echo %YEL%!areg2.%LNG%!%RES%
echo %YEL%!areg2a.%LNG%!%RES%
call :elog .
<nul set /p="!areg3.%LNG%!"
:: Add registry key
reg add "HKCR\Directory\shell\Run%SCRIPTNAME%" /ve /d "!areg4.%LNG%!" /f %debugredir%
reg add "HKCR\Directory\shell\Run%SCRIPTNAME%" /v "Icon" /d "%SystemRoot%\System32\shell32.dll,-154" /f %debugredir%
reg add "HKCR\Directory\shell\Run%SCRIPTNAME%\command" /ve /d "cmd.exe /c cd /d \"%%V\" && \"%SCRIPTDIR%%SCRIPTNAME%\" \"%%V\"" /f %debugredir%
if %errorlevel% EQU 0 (
	echo %GRE%!PASS.%LNG%!%RES%
) else (
	echo %RED%!FAIL.%LNG%!%RES%
    call :elog .
    echo !ARIGHT.%LNG%!
    call :elog .
    pause>nul|set/p=.      !ANYKEY.%LNG%!
    call :exitn 3
)

goto finish


:: Remove entry from registry
:remove_reg
set "rreg1.en=This will remove the previously added entry from the right-click menu for folders."
set "rreg1.fr=Cela supprimera l'entrée précédemment ajoutée du menu contextuel pour les dossiers."
set "rreg1.es=Esto eliminará la entrada previamente añadida del menú contextual para las carpetas."
set "rreg1.it=Questo rimuoverà la voce precedentemente aggiunta dal menu contestuale per le cartelle."
set "rreg1.de=Dies wird den zuvor hinzugefügten Eintrag aus dem Rechtsklick-Menü für Ordner entfernen."
set "rreg1.ru=Это удалит ранее добавленный элемент из контекстного меню для папок."

set "rreg2.en=Removing the right-click menu entry from the registry... "
set "rreg2.fr=Suppression de l'entrée de menu contextuel du registre... "
set "rreg2.es=Eliminando la entrada del menú contextual del registro... "
set "rreg2.it=Rimozione della voce del menu contestuale dal registro... "
set "rreg2.de=Entfernen des Rechtsklick-Menüeintrags aus der Registrierung... "
set "rreg2.ru=Удаление элемента контекстного меню из реестра... "

call :check_admin

call :elog .
echo %YEL%!rreg1.%LNG%!%RES%
call :elog .
<nul set /p="!rreg2.%LNG%!"
:: Remove registry key
reg delete "HKCR\Directory\shell\RunUnrenForAll" /f %debugredir%
reg delete "HKCR\Directory\shell\Run%SCRIPTNAME%" /f %debugredir%
if %errorlevel% EQU 0 (
	echo %GRE%!PASS.%LNG%!%RES%
) else (
	echo %RED%!FAIL.%LNG%!.%RES%
    call :elog .
    echo !ARIGHT.%LNG%!
    call :elog .
    pause>nul|set/p=.      !ANYKEY.%LNG%!
    call :exitn 3
)

goto finish


:: Check for administrative privileges
:check_admin
set "admright.en=Check Admin right"
set "admright.fr=Vérification des droits administrateur"
set "admright.es=Comprobando derechos de administrador"
set "admright.it=Controllo dei diritti di amministratore"
set "admright.de=Überprüfung der Administratorrechte"
set "admright.ru=Проверка прав администратора"

set "admright2.en=You did not run this script with administrator privileges."
set "admright2.fr=Vous n'avez pas lancé ce script avec des droits administrateur."
set "admright2.es=No ha iniciado este script con derechos de administrador."
set "admright2.it=Non hai avviato questo script con diritti di amministratore."
set "admright2.de=Sie haben dieses Skript nicht mit Administratorrechten gestartet."
set "admright2.ru=Вы не запустили этот скрипт с правами администратора."

set "admright3.en=Restart the script with administrator rights."
set "admright3.fr=Relance du script avec des droits administrateur."
set "admright3.es=Reinicie el script con derechos de administrador."
set "admright3.it=Riavvia lo script con diritti di amministratore."
set "admright3.de=Starten Sie das Skript mit Administratorrechten neu."
set "admright3.ru=Перезапустите скрипт с правами администратора."

call :elog .
if not "%OPTION%" == "m" echo.
<nul set /p="!admright.%LNG%!... "

net session %debugredir%
if %errorlevel% EQU 0 (
    echo %GRE%!PASS.%LNG%!%RES%
) else (
	echo %RED%!FAIL.%LNG%!.%RES%
    call :elog .
    echo !admright2.%LNG%!
    echo !admright3.%LNG%!
    call :elog .
    pause
    powershell -Command "Start-Process '%~f0' -ArgumentList '%WORKDIR%' -Verb RunAs"
    goto exitn
)

goto :eof


:: Replace batch file if updated an set relauch if needed
:update_file
set "updating.en=Updating batch file: "
set "updating.fr=Mise à jour du fichier batch : "
set "updating.es=Actualizando archivo por lotes: "
set "updating.it=Aggiornamento del file batch: "
set "updating.de=Aktualisierung der Batch-Datei: "
set "updating.ru=Обновление пакетного файла: "

set "rupdating.en=Updating the running batch file: "
set "rupdating.fr=Mise à jour du fichier batch en cours : "
set "rupdating.es=Actualizando el archivo por lotes en ejecución: "
set "rupdating.it=Aggiornamento del file batch in esecuzione: "
set "rupdating.de=Aktualisierung der laufenden Batch-Datei: "
set "rupdating.ru=Обновление запущенного пакетного файла: "

set "batch_name=%~1"
set "running_batch=%~nx0"

:: If no difference do nothing
fc.exe "%UPD_TDIR%\%batch_name%.bat" "%SCRIPTDIR%%batch_name%.bat" %debugredir%
if %errorlevel% EQU 0 (
    goto :eof
)

:: Check if the new batch file is different from the running one
if "%batch_name%.bat" == "%running_batch%" goto special_upd

echo !updating.%LNG%! %YEL%%SCRIPTDIR%%batch_name%.bat %RES%
move /y "%SCRIPTDIR%%batch_name%.bat" "%SCRIPTDIR%%batch_name%.old" %debugredir%
if %errorlevel% NEQ 0 (
    echo %RED%!FAIL.%LNG%! %RES%
    call :elog .
    pause>nul|set/p=.      !ANYKEY.%LNG%!
    call :exitn 2
)
copy /y "%UPD_TDIR%\%batch_name%.bat" "%SCRIPTDIR%%batch_name%.bat" %debugredir%
if %errorlevel% NEQ 0 (
    echo %RED%!FAIL.%LNG%! %RES%
    call :elog .
    pause>nul|set/p=.      !ANYKEY.%LNG%!
    call :exitn 2
) else (
    echo %GRE%!PASS.%LNG%!%RES%
)

goto :eof

:special_upd
echo !rupdating.%LNG%! %YEL%%SCRIPTDIR%%batch_name%.bat %RES%
copy /y "%SCRIPTDIR%%batch_name%.bat" "%SCRIPTDIR%%batch_name%.old" %debugredir%
if %errorlevel% NEQ 0 (
    echo %RED%!FAIL.%LNG%! %RES%
    call :elog .
    pause>nul|set/p=.      !ANYKEY.%LNG%!
    call :exitn 2
)
copy /y "%UPD_TDIR%\%batch_name%.bat" "%SCRIPTDIR%%batch_name%-new.bat" %debugredir%
if %errorlevel% NEQ 0 (
    echo %RED%!FAIL.%LNG%! %RES%
    call :elog .
    pause>nul|set/p=.      !ANYKEY.%LNG%!
    call :exitn 2
) else (
    echo %GRE%!PASS.%LNG%!%RES%
)
set "relaunch=1"

goto :eof


:: When it's not unavailable, show message and exit
:unavailable
if "%RENPYVERSION%" == "7" (
    set "unavailable.en=This feature is unavailable in this version."
    set "unavailable.fr=Cette fonctionnalité n'est pas disponible dans cette version."
    set "unavailable.es=Esta función no está disponible en esta versión."
    set "unavailable.it=Questa funzione non è disponibile in questa versione."
    set "unavailable.de=Diese Funktion ist in dieser Version nicht verfügbar."
    set "unavailable.ru=Эта функция недоступна в этой версии."
)
if "%RENPYVERSION%" == "8" (
    set "unavailable.en=This feature is unavailable for now, need more coding."
    set "unavailable.fr=Cette fonctionnalité n'est pas disponible pour le moment, nécessite plus de codage."
    set "unavailable.es=Esta función no está disponible por ahora, necesita más codificación."
    set "unavailable.it=Questa funzione non è disponibile per ora, necessita di più codice."
    set "unavailable.de=Diese Funktion ist derzeit nicht verfügbar, es wird mehr Programmierung benötigt."
    set "unavailable.ru=Эта функция недоступна, требуется больше кода."
)

call :elog .
call :elog .
echo !unavailable.%LNG%! >> "%UNRENLOG%"
<nul set /p="%YEL%!unavailable.%LNG%!%RES%"

timeout /t 2 >nul

goto :menu

exit /b


:: Verify if an update is necessary
:check_update
:: This URL should point to a text file containing the latest version link
set "upd_url=https://github.com/Lurmel/UnRen-forall/releases/download/UnRen-forall-la_0.35-le_9.6.47-cu_9.7.17/UnRen-link.txt"
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

set "cupd2.en=No updates found."
set "cupd2.fr=Aucune mise à jour trouvée."
set "cupd2.es=No se encontraron actualizaciones."
set "cupd2.it=Nessun aggiornamento trovato."
set "cupd2.de=Keine Updates gefunden."
set "cupd2.ru=Обновлений не найдено."

set "cupd3.en=An update is available."
set "cupd3.fr=Une mise à jour est disponible."
set "cupd3.es=Una actualización está disponible."
set "cupd3.it=Un aggiornamento è disponibile."
set "cupd3.de=Ein Update ist verfügbar."
set "cupd3.ru=Доступно обновление."

set "cupd4.en=Downloading the latest version from:"
set "cupd4.fr=Téléchargement de la dernière version depuis :"
set "cupd4.es=Descargando la última versión desde:"
set "cupd4.it=Download dell'ultima versione da:"
set "cupd4.de=Herunterladen der neuesten Version von:"
set "cupd4.ru=Загрузка последней версии с:"

set "cupd5.en=Update complete."
set "cupd5.fr=Mise à jour terminée."
set "cupd5.es=Actualización completa."
set "cupd5.it=Aggiornamento completato."
set "cupd5.de=Update abgeschlossen."
set "cupd5.ru=Обновление завершено."

set "cupd6.en=Error downloading update."
set "cupd6.fr=Erreur lors du téléchargement de la mise à jour."
set "cupd6.es=Error al descargar la actualización."
set "cupd6.it=Errore durante il download dell'aggiornamento."
set "cupd6.de=Fehler beim Herunterladen des Updates."
set "cupd6.ru=Ошибка при загрузке обновления."

set "cupd7.en=Do you want to update now? [y/n] (default: y):"
set "cupd7.fr=Voulez-vous faire la mise à jour maintenant ? [o/n] (défaut : o) :"
set "cupd7.es=¿Desea actualizar ahora? [s/n] (predeterminado: s):"
set "cupd7.it=Vuoi aggiornare adesso? [s/n] (impostazione predefinita: s):"
set "cupd7.de=Möchten Sie jetzt aktualisieren? [y/n] (Standard: y):"
set "cupd7.ru=Хотите обновиться сейчас? [y/n] (по умолчанию: y):"

set "cupd8.en=No download update link found."
set "cupd8.fr=Aucun lien de téléchargement de mise à jour trouvé."
set "cupd8.es=No se encontró el enlace de descarga de la actualización."
set "cupd8.it=Non è stato trovato il link per il download dell'aggiornamento."
set "cupd8.de=Kein Download-Update-Link gefunden."
set "cupd8.ru=Ссылка для загрузки обновления не найдена."

<nul set /p="!cupd1.%LNG%!..."
del /f /q "%TEMP%\%upd_link%.tmp" %debugredir%
if %debuglevel% EQU 1 echo powershell.exe -nologo -noprofile -noninteractive -command "(New-Object System.Net.WebClient).DownloadFile('%upd_url%', '%TEMP%\%upd_link%.tmp')"
powershell.exe -nologo -noprofile -noninteractive -command "(New-Object System.Net.WebClient).DownloadFile('%upd_url%', '%TEMP%\%upd_link%.tmp')" %debugredir%
if not exist "%TEMP%\%upd_link%.tmp" (
    echo %RED% !FAIL.%LNG%! %YEL%!cupd6.%LNG%!%RES%
    exit /b
) else (
    :: First time
    if not exist "%SCRIPTDIR%%upd_link%.txt" (
        copy nul "%SCRIPTDIR%%upd_link%.txt" %debugredir%
    )
    fc.exe "%TEMP%\%upd_link%.tmp" "%SCRIPTDIR%%upd_link%.txt" %debugredir%
    if !errorlevel! GEQ 1 (
        echo %YEL% !cupd3.%LNG%!%RES%

        :: Rename and launch %upd_link%.bat to generate UnRen-Changelog.txt
        copy /y "%TEMP%\%upd_link%.tmp" "%SCRIPTDIR%%upd_link%.bat" %debugredir%
        set "forall_url="
        call "%SCRIPTDIR%%upd_link%.bat" %debugredir%
        del /f /q "%SCRIPTDIR%%upd_link%.bat" %debugredir%
        if not defined forall_url (
            echo %RED% !FAIL.%LNG%! %YEL%!cupd8.%LNG%!%RES%
            call :elog .
            pause
            goto :eof
        )
        move /y "%SCRIPTDIR%%upd_clog%.txt" "%SCRIPTDIR%%upd_clog%.b64" %debugredir%
        if %debuglevel% EQU 1 echo powershell.exe -nologo -noprofile -noninteractive -command "[IO.File]::WriteAllBytes('%SCRIPTDIR%%upd_clog%.tmp', [Convert]::FromBase64String((Get-Content '%SCRIPTDIR%%upd_clog%.b64' -Raw)))"
        powershell.exe -nologo -noprofile -noninteractive -command "[IO.File]::WriteAllBytes('%SCRIPTDIR%%upd_clog%.tmp', [Convert]::FromBase64String((Get-Content '%SCRIPTDIR%%upd_clog%.b64' -Raw)))" %debugredir%
        call :elog .
        type "%SCRIPTDIR%%upd_clog%.tmp"
        call :elog .

        set "coption="
        set /p "coption=!cupd7.%LNG%! "
        echo "!coption!" | find /i "n" >nul
        if !errorlevel! EQU 0 goto :eof
        set "new_upd=1"
        del /f /q "%SCRIPTDIR%%upd_clog%.b64" %debugredir%
        del /f /q "%SCRIPTDIR%%upd_clog%.tmp" %debugredir%
    ) else (
        echo %YEL% !cupd2.%LNG%!%RES%
        goto :eof
    )
)

echo %YEL%!INCASEOF.%LNG%! %RES%
echo %MAG%%URL_REF%%RES%
if %new_upd% EQU 1 (
    call :elog .
    <nul set /p="!cupd4.%LNG%! %YEL%%forall_url%%RES%... "
    if %debuglevel% EQU 1 echo powershell.exe -nologo -noprofile -noninteractive -command "(New-Object System.Net.WebClient).DownloadFile('!forall_url!','%TEMP%\%upd_file%.tmp')"
    powershell.exe -nologo -noprofile -noninteractive -command "(New-Object System.Net.WebClient).DownloadFile('!forall_url!','%TEMP%\%upd_file%.tmp')" %debugredir%
    if not exist "%TEMP%\%upd_file%.tmp" (
        echo %RED%!FAIL.%LNG%! %YEL%!cupd6.%LNG%!%RES%
        call :elog .
        pause
        goto :eof
    ) else (
        echo %GRE%!PASS.%LNG%!%RES%
        move /y "%TEMP%\%upd_file%.tmp" "%TEMP%\%upd_file%.zip" %debugredir%
        if not exist "%TEMP%\%upd_file%.zip" (
            echo %RED%!FAIL.%LNG%! %YEL%!cupd6.%LNG%!%RES%
            call :elog .
            pause
            goto :eof
        ) else (
            if not exist "%UPD_TDIR%" rd /s /q "%UPD_TDIR%" %debugredir%
            mkdir "%UPD_TDIR%" %debugredir%
            if %debuglevel% EQU 1 echo powershell.exe -nologo -noprofile -noninteractive -command "Expand-Archive -Path '%TEMP%\%upd_file%.zip' -DestinationPath '%UPD_TDIR%' -Force"
            powershell.exe -nologo -noprofile -noninteractive -command "Expand-Archive -Path '%TEMP%\%upd_file%.zip' -DestinationPath '%UPD_TDIR%' -Force" %debugredir%
            if %errorlevel% NEQ 0 (
                echo %RED%!FAIL.%LNG%! %YEL%!cupd6.%LNG%!%RES%
                call :elog .
                pause
                goto :eof
            ) else (
                del /f /q "%TEMP%\%upd_file%.zip" %debugredir%
            )
            for %%f in (forall legacy current) do (
                call :update_file "UnRen-%%~f"
            )
            copy /y "%TEMP%\%upd_link%.tmp" "%SCRIPTDIR%%upd_link%.txt" %debugredir%
            rd /s /q "%UPD_TDIR%" %debugredir%
            if !relaunch! EQU 1 (
                echo .
                pause
                call "%SCRIPTDIR%%BASENAME%-new.bat" "%WORKDIR%"
                goto exitn
            )
            call :elog .
            echo %YEL%!cupd5.%LNG%!%RES%
            call :elog .
        )
    )
)

goto :eof


:: Check if all files were downloaded successfully
:check_all_files
set "cfile.en=Verification that all files are present"
set "cfile.fr=Vérification que tous les fichiers sont présents"
set "cfile.es=Verificación de que todos los archivos están presentes"
set "cfile.it=Verifica che tutti i file siano presenti"
set "cfile.de=Überprüfung, ob alle Dateien vorhanden sind"
set "cfile.ru=Проверка наличия всех файлов"

set "cdwnld.en=Download the missing file from:"
set "cdwnld.fr=Télécharger le fichier manquant depuis :"
set "cdwnld.es=Descargar el archivo faltante de:"
set "cdwnld.it=Scarica il file mancante da:"
set "cdwnld.de=Fehlende Datei herunterladen von:"
set "cdwnld.ru=Скачать недостающий файл с:"

<nul set /p="!cfile.%LNG%!..."
for %%F in (legacy current forall) do (
    if not exist "%SCRIPTDIR%UnRen-%%~F.bat" (
        echo %RED% !FAIL.%LNG%! %YEL%!MISSING.%LNG%! UnRen-%%~F %RES%
        echo !cdwnld.%LNG%! %RES%
        echo %MAG%%URL_REF% %RES%
        call :elog .
        pause>nul|set/p=.      !ANYKEY.%LNG%!
        goto exitn
    ) else (
        <nul set /p="."
    )
)

:: Cleaning after an update
set "BASENAMENONEW=%BASENAME:-new=%"
if exist "%SCRIPTDIR%%BASENAMENONEW%-new.bat" (
    if "%SCRIPTNAME%" == "%BASENAMENONEW%-new.bat" (
        copy /y "%SCRIPTDIR%%BASENAMENONEW%-new.bat" "%SCRIPTDIR%%BASENAMENONEW%.bat" %debugredir%
    ) else (
        del /f /q "%SCRIPTDIR%%BASENAME%-new.bat" %debugredir%
    )
)
del /f /q "%SCRIPTDIR%%BASENAMENONEW%.old" %debugredir%

echo %GRE% !PASS.%LNG%!%RES%

exit /b


:: We are done and go back to menu
:finish
if "%OPTION%" == "m" goto :eof
echo.
echo.
pause
if "%nocls%" EQU 0 cls

goto menu


:: Define a function to log messages
:elog
:: Display msg (%~1) to console and "%UNRENLOG%"
set "msg=%~1"
if "!msg!" == "." (
    echo.
    if defined UNRENLOG (
       echo. >> "!UNRENLOG!"
    )
) else (
    echo !msg!

    if defined UNRENLOG (
        :: Strip color variables for logging
        set "cleanmsg=!msg!"
        for %%C in (GRY RED GRE YEL MAG CYA RES) do (
            call set "cleanmsg=%%cleanmsg:!%%C!=%%"
        )
        echo !cleanmsg! >> "!UNRENLOG!"
    )
)

exit /b


:: Call :exitn for cleanup only or goto exitn for ending script
:exitn
set "val=%~1"

if %debuglevel% GEQ 1 (
    echo === Variables ===
    set
    echo === Variables ===
)

:: Restore modified configuration and we exit with the appropriate code
chcp %OLD_CP% >nul

:: Restore original console mode
if %debuglevel% EQU 0 (
    mode con: cols=%ORIG_COLS% lines=%ORIG_LINES%
    reg delete "HKCU\Console\MyScript" /f %debugredir%
    reg delete "HKCU\Console\UnRen-forall.bat" /f %debugredir%
)

if defined val exit %val%

exit /b 0
