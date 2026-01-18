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


