# 📜 Changelog — UnRen Toolkit

All dates are in the format MM/DD/YY.

---

## 🟢 12/30/25:
	UnRen-forall.bat 0.42, UnRen-current.bat 9.7.38 & UnRen-legacy.bat 9.7.18

	Common modifications for all scripts:
	- Microsoft has removed wmic from certain versions of Windows because it can be used by malware.
	  I have therefore added powershell code to replace it so that UnRen scripts can be displayed in your language.
	- Correction of the code page that was not applied to UnRen scripts calls from forall.
	  This could cause Latin or Slavic characters to display incorrectly.
	-

	Common modifications for UnRen-current.bat & UnRen-legacy.bat:
	- Minor bug & typo fixes
	- Add the CTIME option in UnRen-cfg.bat if you want to stay longer on the choice questions (Default 5s).
	- Unrpyc print now the version number and issue/PR applied by me.
	- Removed Cyrillic character from choice and updated sentences to remove bug in a non UTF-8 system.
	- Activation of option 6 to chain deobfuscation and decompilation.
	- Added option 7 to force extraction of RPA archives that still have an intact header.
	- Added processing in the order you enter it, whereas previously it was processed alphanumerically.
	  Now you can enter 72k1 for a game where the RPA archives would be encrypted,
	  follow up with decompilation, add 0x52_urm, then decompress it if the game no longer supports
	  standard RPAs. All in one go.
	- The choice.exe command is now launched with the full path to avoid using another program.
	- I have improved the altrpatool.py for extracting RPA archives crypted.

---

## 🟢 12/24/25:
	UnRen-forall.bat 0.40, UnRen-current.bat 9.7.27b & UnRen-legacy.bat 9.7.6b

	Common modifications for all scripts:
	- Fixed a bug that sometimes prevented the entered game directory from being processed correctly.
	- Added detection of prohibited characters when used with a Windows batch file
	  However, the characters & ! ^ are completely prohibited and cannot be included in the detection

	Common modifications for UnRen-current.bat & UnRen-legacy.bat:
  - Bug correction about the improper detection of the extension RPA archive name
	- Add the ability to force RPA archive unpack if it's not properly identified
	- Fixed bug with RPA archive type detection not working with Python 2.7
	- A better Python script for detectng RPA extensin archive name, even if dev have modified the Ren'Py shipped
	- Added code to prohibit the use of UnRen[legacy|current].bat in the wrong environment.
	- Added more infos in the UnRen-forall.log

---

## 🟢 12/11/25: My biggest update since the beginning !
	UnRen-forall.bat 0.38, UnRen-current.bat 9.7.23 & UnRen-legacy.bat 9.7.4

	Common modifications for all scripts:
	- Minor bug fixes, like Developer mode and the installation of TextBox mod...
	- Code optimization and convergence of the three scripts for common parts.
	- Added new code for changing MC name when you can't change it in the game.
	  (works with MidnightParadise-1.1b-pc-elite and several other tested games)
	- New code for extracting text, it now provide your language by default instead of French
	- Added full support for spaces and () in the directory tree (very difficult)

	UnRen-legacy.bat 9.7.4:
	- Is now based from the same code as UnRen-current.bat (provisional situation before final version)

	Common modifications for UnRen-current.bat & UnRen-legacy.bat:
	- Script authors are now notified internally
	- New code for decrypting base64 for all Python scripts
	- Moving RPYC decompilation messages out of the loop to improve speed
	- Use the download link on F95zone for 0x52_urm to avoid interception by antivirus software
	  on the original dynamic download.
	- Add 3 new Python scripts for the extract RPA fonction
	- The 1st to detect the extension name more quickly
	- The 2nd to determine whether the header is modified by the developer
	- the 3rd to extract modified RPA files (tested with Jason & Lab Rats)

---

## 🟢 09/30/25 — UnRen-forall.bat (launcher) version 0.35 and UnRen-current.bat version 9.7.15:
  - minor bugs fixes and optimizations
  - More robust mcname change
  - URLlink for UnRen-link.txt moved to Google Drive
  - No more colors for Windows 7
  - The Add entry to registry will now add the script currently running. So i you have only Ren'Py game version >= 8 just add it and you will skip the laucher.

Specific for UnRen-current.bat:
  - Added multi-lingual support
  - Some options are grayed out because I haven't done enough testing with unrpa, which allows extraction with a special key
  -  I started putting locks in place to limit usage on Ren'Py >= 8. So if all goes well, this will serve as the basis for the new UnRen-legacy.bat. This will make it easier for me to remove what is no longer necessary in each UnRen.
  -  You can select multiple options from main menu. By default you have the equivalent of option 9 from the old UnReb-forall.bat
  -  You can manage the default execution by downloading UnRen-cfg.zip, extract to where the scripts are and edit to modify MDEFS2 to reflect what you want to be the default action when UnRen-current.bat is launched
  -  After the first execution, the default entry for main menu will be x (Exit).

---

## 🟢 09/12/25 — Launcher Version 0.28

  - Important change to the update procedure
  - Users can now choose whether or not to perform the update
  - `UnRen-link.txt` now points to a GitHub repository
  - Archive hosted on Google Drive to avoid false [VIRUS] warnings on f95zone.to

---

## 🟢 09/01/25 — Launcher Version 0.25

  - Fixed Python 3.x bug introduced by previous fix for Python 2.7
  - Added option: Universal Choice Descriptor ZLZK (for games without WT-mod)
  - Added option: Universal Textbox mod by Penfold Mole
  - External files now downloaded from source automatically
  - Auto-update function added (runs at each launch)
  - Improved debug mode, especially with `powershell.exe`
  - Reorganized menu option letters

---

## 🟢 08/21/25 — Launcher Version 0.14

  - Fixed bug preventing Universal Gallery Unlocker installation
  - Fixed Extract Text bug with Python 2.7
  - Code optimizations
  - Added minimal hints for menu actions and reference URLs

---

## 🟢 08/20/25 — Launcher v0.9, Legacy v9.6.43, Current v9.6.57

  - Created multilingual launcher with new features:
  - Force Quick Menu
  - Universal Unlock Gallery (ZLZK)
  - Change MC name if named `mcname`
  - Renamed:
    - `UnRen-forall.bat v9.6.43` → `UnRen-legacy.bat`
    - `UnRen-forall.bat v9.6.57` → `UnRen-current.bat`
  - Minor bug fixes and initial cleanup (not finalized)

---

## 🟢 08/13/25 — Version 9.6.57

  - Added support for renamed RPA extensions
  - Added ability to select which RPA archive to extract

---

## 🟢 08/12/25 — Version 9.6.53

  - Minor bug fixes
  - Added checks for `script_version.txt` and `renpy_version.txt`
  - Added download/extract of `0x52_URM` (thanks InfiniteCanvas)
  - Added text extraction for translation purposes

---

## 🟢 08/09/25 — Version 9.6.50

  - Integrated PR #251 (Madeddy) and PR #248
  - Added `.rpy.org` backup for original files before rewriting
  - Allows comparison between original and decompiled versions

---

## 🟢 08/07/25 — Version 9.6.48

  - Improved decompiler logic for `else` statements

---

## 🟢 07/28/25 — Version 9.6.47

  - Temporary support for Ren'Py 8.4
  - Added decompilation for Inceton games (option 7)

---

## 🟢 07/27/25 bis — Version 9.6.44

  - Temporary solution from dev branch (CensoredUsername)

---

## 🟢 07/27/25 — Version 9.6.42

  - Added support for LittleMan (Python without multiprocessing)

---

## 🟢 07/25/25 — Version 9.6.41

  - Support for Ren'Py 8.4.1 (Python 3.12)
  - Scalable code for future Python versions

---

## 🔧 Initial Public Release — Version 9.6.39

  - Integrated Shizmob’s latest `rpatool` (RPA v3 support, not yet implemented)
  - Replaced `unrpyc` with latest versions:
    - v1.3.2 for Ren'Py ≤ 7
    - v2.0.2 for Ren'Py ≥ 8
  - Fixed bug with spaces in folder paths (e.g. MyBimbo Beta)
  - Improved Python version detection (e.g. Milfania)
  - Verified command execution
  - RPA files moved to `game/rpa` to avoid duplicate labels
  - Option to skip rewriting `.rpy` files if already present
  - Added 5-second timeout on Y/N prompts (default: No)
  - Color-coded output:
    - 🟩 Green = success
    - 🟨 Yellow = info/warning
    - 🟥 Red = error
  - Created `UnRen-forall.log` in game directory
  - Added right-click registry add/remove (admin rights required)
  - Total of 39 changes in this version

---

If you encounter any issues, please refer to the `UnRen-forall.log` file and let me know. I’ll make corrections as needed.
