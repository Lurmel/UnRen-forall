# 📜 Changelog — UnRen Toolkit

All dates are in the format MM/DD/YY.

---

## 🟢 09/30/25 — UnRen-forall.bat (launcher) version 0.35 and UnRen-current.bat version 9.7.15:
  - minor bugs fixes and optimizations
  - More robust mcname change
  - URLlink for UnRen-link.txt moved to Google Drive
  - No more colors for Windows 7

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

