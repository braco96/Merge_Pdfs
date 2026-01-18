# 📄 mergepdf.sh

A robust and user-friendly Bash script to merge multiple PDF files into a single document using **Ghostscript**. It features a smart sorting algorithm, a visual loading spinner, and a "God Mode" for recursive merging.

## ✨ Features

* **Two Operation Modes:**
    * **Normal Mode:** Merges all PDFs in the current directory.
    * **⚡ God Mode:** Recursively searches the current directory and **all subdirectories** for PDFs.
* **Smart Sorting:** Uses "Natural Sort" (Version Sort), ensuring that `Chapter 2` comes before `Chapter 10`.
* **Robust Filename Handling:** Perfectly handles filenames with **spaces**, accents, and special characters.
* **Visual Feedback:**
    * Lists all detected files before processing.
    * Displays a loading spinner while Ghostscript works.
    * Suppresses non-critical font warnings (common with LaTeX PDFs) for a clean output.
* **High Quality:** Uses Ghostscript's `/prepress` setting for high-quality output suitable for printing.

## 🛠️ Prerequisites

This script relies on **Ghostscript**. You must have it installed on your system.

### Installation

**Ubuntu / Debian / Linux Mint:**
```bash
sudo apt update
sudo apt install ghostscript
Fedora / RHEL:

Bash

sudo dnf install ghostscript
macOS (via Homebrew):

Bash

brew install ghostscript
🚀 Installation
Download the script or create a file named mergepdf.sh with the code.

Make the script executable:

Bash

chmod +x mergepdf.sh
📖 Usage
1. Normal Mode
Merges all .pdf files located in the current folder only.

Bash

./mergepdf.sh
2. God Mode (--god)
Scans the current folder and every subfolder recursively. Useful for merging entire courses or books organized in chapters/folders.

Bash

./mergepdf.sh --god
⚙️ How it works
Detection: The script scans for PDF files based on the selected mode.

Listing: It displays an ordered list of files to be merged and asks for your confirmation (Press ENTER).

Processing: It calls Ghostscript in the background. A spinner is shown while the heavy lifting is done.

Output: The final file is saved as PDF_Unido_Final.pdf.

📝 Configuration
You can easily change the output filename by editing the top variable in the script:

Bash

# --- Configuration ---
SALIDA="My_Custom_Name.pdf"
🤝 Contributing
Feel free to fork this script and improve it!

📄 License
Open Source. Use it however you like.
