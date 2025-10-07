### 🔖 Versions

![UnRen-forall](https://img.shields.io/badge/UnRen--forall-0.35-blue)
![UnRen-legacy](https://img.shields.io/badge/UnRen--legacy-9.6.43-green)
![UnRen-current](https://img.shields.io/badge/UnRen--current-9.7.14-purple)
![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)
![Downloads](https://img.shields.io/github/downloads/Lurmel/UnRen-forall/total)


## 📑 Table of Contents

- [🔧 Third-Party Tools Used](#-third-party-tools-used)
- [📦 Included Files](#-included-files)
- [📥 Download](#-download)
- [🚀 Features](#-features)
- [🛠️ How to Use](#how-to-use)
- [❓ FAQ](#-faq)
- [📜 Changelog](#-changelog)
- [⚠️ Disclaimer](#disclaimer)
- [⚖️ License](#license)

---

# 🎮 UnRen Toolkit — Multilingual Batch for Ren'Py Games

I've made these scripts with ❤️ to simplify the management of your favorite Ren'Py games.

What started as a simple launcher evolved into a multilingual toolkit with customizable options, version-aware execution, and update support. I hope it makes your experience smoother and more enjoyable.

---

<a name="third-party-tools-used"></a>
## 🔧 Third-Party Tools Used

UnRen relies on several external tools developed by the Ren'Py community to handle archive extraction and script decompilation. Full credit goes to their respective authors:

- [rpatool](https://github.com/Shizmob/rpatool) – A command-line utility for extracting `.rpa` archives.
- [unrpa](https://github.com/CensoredUsername/unrpa) – A Python-based extractor for Ren'Py `.rpa` files.
- [unrpyc](https://github.com/CensoredUsername/unrpyc) – A decompiler for Ren'Py `.rpyc` compiled scripts.

These tools are essential for UnRen's functionality and are used respectfully under their respective licenses.

---

## 📦 Included Files

- `UnRen-forall.bat` — Multilingual launcher (Version 0.35)
- `UnRen-legacy.bat` — For Ren'Py ≤ 7 (Version 9.6.43)
- `UnRen-current.bat` — For Ren'Py ≥ 8 (Version 9.7.14)
- `UnRen-cfg.zip` — Contains `UnRen-cfg.bat` to configure language and batch behavior
- `UnRen-link.txt` — Contains the download link for the full package and a changelog for updates

---

## 📥 Download

[⬇️ Download latest release](https://github.com/Lurmel/UnRen-forall/releases/download/UnRen-forall-la_0.35-le_9.6.47-cu_9.7.17/UnRen-forall-la_0.35-le_9.6.47-cu_9.7.14.zip)

---

## 🚀 Features

- Automatic detection of Ren'Py version
- Launches the appropriate batch script (`legacy` or `current`)
- Multilingual interface: 🇩🇪 🇬🇧 🇪🇸 🇫🇷 🇮🇹 🇷🇺
- Independent options not tied to Ren'Py (e.g. unpacking, extraction)
- Configurable behavior via `UnRen-cfg.bat`
- Update system with changelog display

---

<a name="how-to-use"></a>
## 🛠️ How to Use

1. Place the batch files in your Ren'Py game directory or a directory of your choice (preferably)
2. Run `UnRen-forall.bat`
3. Follow the prompts in your preferred language
4. (Optional) Use `UnRen-cfg.bat` to customize default options and language

---

## 📡 Updates

The launcher checks `UnRen-link.txt` for updates and displays a changelog if a new version is available. This allows you to keep your toolkit up to date without manual tracking.

---

## 🧠 Notes

This project is designed to be lightweight, user-friendly, and respectful of your time. No installation required, no dependencies — just run and go.

---

## ❓ FAQ

See [FAQ](FAQ) for answers to common questions.

---

## 📜 Changelog

See [Changelog.md](Changelog.md) for version history and updates.

---

<a name="disclaimer"></a>
## ⚠️ Disclaimer

This tool is intended for use with files on which the authors allowed modification of and/or extraction from ONLY and the unauthorized use on files where such consent was not given is highly discouraged, and most likely a license violation as well. Support requests for help with dealing with such files will not be answered.

---

<a name="license"></a>
## ⚖️ License

This project is licensed under the GNU General Public License v3.0.
You are free to use, modify, and distribute it under the same terms.
Commercial use is not permitted unless the source remains open and licensed under GPL.
See the [LICENSE](LICENSE) file for full details.


