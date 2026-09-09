# PDF to Word, Excel & PowerPoint Conversion SDK for macOS (CLI)

Flyingbee PDF Converter for macOS is a high-performance, headless PDF converter that runs entirely from Terminal. This macOS PDF conversion SDK provides a command-line interface (CLI) to transform PDF documents into editable Microsoft Office formats. Whether you need a PDF to Word macOS CLI tool, a PDF to Excel command line utility, or a PDF to PowerPoint macOS solution, this library preserves original layouts, text, images, tables, hyperlinks, and Bezier graphics with high accuracy.

The package ships as a **single universal binary** (Apple silicon + Intel) plus its runtime dependencies, so there is nothing to compile and nothing to rename per architecture.

![Flyingbee PDF Converter](https://www.flyingbee.com/pdf-converter/images/FPPDFConverter-Console.jpg)

---

## 🕹️ Try It Online

Want to try before deploying? Use **Flyingbee PDF Converter Online** to convert PDFs to MS Office formats directly in your browser — no installation required.

[🚀 Launch Web Demo](https://www.flyingbee.com/pdf-converter/?utm_source=github_readme_conversion_sdk_mac_cli&utm_medium=referral&utm_campaign=github_readme_conversion_sdk_mac_cli)

---

## Features

* **High-Fidelity PDF2Files Conversion:** Accurately converts PDFs to Word (.docx), Excel (.xlsx), and PowerPoint (.pptx) while maintaining the original document structure.
* **Versatile Conversion Modes:** Supports `PDF2Files`, `Images2PDF`, and `Text2Word` command line processing in one executable.
* **Multi-Threaded Batch Conversion:** Accelerate processing on your Mac by utilizing up to 10 concurrent threads (`-t 1-10`).
* **Comprehensive Format Support:** Export to `docx`, `pptx`, `xlsx`, `html`, `csv`, `txt`, `jpeg`, `jpg`, `png`, `bmp`, `tif`, `tiff`, and `gif`.
* **Built-In OCR:** Turn scanned PDFs into searchable Office documents with Tesseract (`-r`, `-g eng|chi_sim|jpn|...`).
* **Universal Binary:** One executable for both Apple silicon (M-series) and Intel Macs — no per-architecture packages.
* **Headless Architecture:** Designed for automated, server-side or CI workflows without any graphical user interface.

## System Requirements

| Item | Requirement |
| :--- | :--- |
| Operating system | macOS 11.0 (Big Sur) or later on Apple silicon; macOS 10.13 or later on Intel |
| Architecture | arm64 (Apple silicon) and x86_64 (Intel), universal binary |
| Disk space | ~170 MB for the executable, framework and resource bundle |
| Recommended fonts | Arial, Times New Roman, Courier, Consolas. macOS ships Helvetica/Times/Courier; install Microsoft Office or the Microsoft core fonts when a PDF depends on Arial. |
| File path rules | Use forward slashes (`/`). Avoid Windows-illegal characters (`:`, `\`) in file and directory names. Paths containing spaces must be quoted. |

> **Note:** macOS file systems are case-insensitive by default. Do not rely on file names that differ only by letter case.

## Repository Layout

```
flyingbee-pdf-converter-sdk-mac-cli/
├── README.md                          # This document
├── LICENSE
├── specs/001-macos-cli-demo/          # Specification, plan and task checklist (SDD)
└── FPPDFFramework_CLI/
    ├── FPPDFConverter                 # Universal command-line executable
    ├── FPPDFFramework.framework       # Conversion engine (must stay next to the executable)
    ├── Resources.bundle               # Fonts, CMaps, OCR data, HTML templates
    ├── converter.sh                   # Batch-convert every PDF in the folder
    ├── converter-ocr.sh               # Batch-convert every PDF using OCR
    ├── Test.pdf                       # Sample document
    ├── readme.txt                     # In-package quick start
    └── legal.txt                      # Third-party license notices
```

`FPPDFConverter`, `FPPDFFramework.framework`, and `Resources.bundle` must always stay in the same folder: the executable resolves its framework and resources relative to itself.

## Quick Start

1. Open **Terminal** and navigate to the folder containing the executable:
   ```bash
   cd "/Users/your-name/FPPDFFramework_CLI"
   ```
2. Grant execution permission to the binary:
   ```bash
   chmod +x FPPDFConverter
   ```
3. If macOS reports *"FPPDFConverter cannot be opened because it is from an unidentified developer"*, remove the download quarantine flag:
   ```bash
   xattr -dr com.apple.quarantine "/Users/your-name/FPPDFFramework_CLI"
   ```
4. Execute a basic conversion command (convert a PDF to Word):
   ```bash
   ./FPPDFConverter -a PDF2Files -i "Test.pdf" -f docx -p all -o "Test.docx"
   ```

Console output of a successful run:

```
=== Welcome to use Flyingbee PDF Converter! ===
FPPDFConverter v10.3.6.0
The app exe folder: /Users/your-name/FPPDFFramework_CLI
Cmd: PDF2Files
Let's convert PDF to docx
The number of pages in this PDF document: 20
Number of threads: 4
The converter has started.
The conversion progress:  100%
The converter will save document to disk...
Successfully converted!
=== Thank you for using our product! ===
```

## Command Line Reference

Every invocation starts with an application command:

```bash
./FPPDFConverter -a <command> [options]
```

Run `./FPPDFConverter -h` for app-level help, or `./FPPDFConverter -a <command> -h` for options specific to a command. Available commands:

| Command | Description |
| :--- | :--- |
| `PDF2Files` | Convert PDF documents to Word, Excel, PPT, HTML, images, etc. |
| `Images2PDF` | Merge multiple images into a single PDF document. |
| `Text2Word` | Convert plain text files to formatted Word documents. |

> **Note:** Short flags are reused across commands with **different meanings** (e.g. `-z` means "package HTML to ZIP" under `PDF2Files`, but "scale mode" under `Images2PDF`). Always refer to the section for the command you are using.

### Global Options (All Commands)

| Option | Description |
| :--- | :--- |
| `-h` | Show this help message and exit. |
| `-c` | Open the converted file automatically upon completion. |

### PDF2Files — PDF to Word / Excel / PPT / HTML / Images

```bash
./FPPDFConverter -a PDF2Files -i <input.pdf> -o <output> [options]
```

| Option | Description |
| :--- | :--- |
| `-i <path>` | Input PDF file path (required). |
| `-o <path>` | Output file or directory path (required). |
| `-f <format>` | Target format: `docx` (default), `pptx`, `xlsx`, `html`, `csv`, `txt`, `jpeg`, `jpg`, `png`, `bmp`, `tif`, `tiff`, `gif`. |
| `-p <ranges>` | Page ranges to convert, e.g. `1-3,5,8-10`. |
| `-t <threads>` | Number of processing threads (1-10, default: 1). |
| `-x` | (XLSX only) Merge multiple sheets into a single sheet. |
| `-w <password>` | Password for opening encrypted PDF files. |

**HTML output options:**

| Option | Description |
| :--- | :--- |
| `-l <mode>` | Layout mode: `0` = exact page layout (default), `1` = text flow. |
| `-e <mode>` | Paragraph style: `0` = line break (default), `1` = indent. |
| `-b <mode>` | Navigation bar: `0` = disabled, `1` = enabled (default). |
| `-m <level>` | Resource merge: `0` = none (default), `1` = CSS/JS, `2` = CSS/JS/small images, `3` = CSS/JS/all images. |
| `-z` | Package the HTML output and its resources as a ZIP file. |

**Image output options (`jpeg`, `jpg`, `png`, `bmp`, `tif`, `tiff`, `gif`):**

| Option | Description |
| :--- | :--- |
| `-d <dpi>` | Image resolution (72-600, default: 144). |
| `-n <mode>` | Anti-aliasing: `0` = none, `1` = font smoothing (default). |

**OCR options:**

| Option | Description |
| :--- | :--- |
| `-r` | Enable OCR (Optical Character Recognition). |
| `-g <lang>` | OCR language for Tesseract, e.g. `eng`, `chi_sim`, `jpn`. |

### Images2PDF — Merge Images to PDF

```bash
./FPPDFConverter -a Images2PDF -i <folder> -o <output.pdf> [options]
```

| Option | Description |
| :--- | :--- |
| `-i <folder>` | Source folder containing images (required). |
| `-o <path>` | Output PDF file path (required). |
| `-s <size>` | Paper size: `A0`-`A10`, `Letter`, `Legal`, `Tabloid`, `4x6`, `5x7`, or `auto` (default: none). |
| `-n <orient>` | Orientation: `portrait`, `landscape`, `auto` (default: auto). |
| `-w <inches>` | Custom paper width in inches (used with a custom size). |
| `-l <inches>` | Custom paper height in inches (used with a custom size). |
| `-m <margin>` | Page margins in inches; append `mm` for millimeters. |
| `-z <scale>` | Scale mode: `fit` (default), `fw`, `fh`, `reduce`, `rw`, `rh`, `none`. |
| `-r <crop>` | Crop/expand: `none` (default), `height`, `width`, `both`. |

**Metadata options:**

| Option | Description |
| :--- | :--- |
| `-t <title>` | Document title. |
| `-A <author>` | Document author. |
| `-k <keywords>` | Document keywords. |
| `-S <subject>` | Document subject. |
| `-C <creator>` | Document creator. |

### Text2Word — Plain Text to Word

```bash
./FPPDFConverter -a Text2Word -i <input.txt> -o <output.docx> [options]
```

| Option | Description |
| :--- | :--- |
| `-i <path>` | Input plain text file path (required). |
| `-o <path>` | Output Word document path (required). |
| `-s <size>` | Paper size: `A0`-`A10`, `Letter`, `Legal`, `Tabloid`, `4x6`, `5x7`, or `auto` (default: none). |
| `-n <orient>` | Orientation: `portrait`, `landscape`, `auto` (default: auto). |
| `-w <inches>` | Custom paper width in inches (used with a custom size). |
| `-l <inches>` | Custom paper height in inches (used with a custom size). |
| `-m <margin>` | Page margins in inches; append `mm` for millimeters. |
| `-e <columns>` | Number of columns (1-10, default: 1). |
| `-b <font>` | Font name: `Arial` (default), `Calibri`, `Courier`, `Times New Roman`, `Helvetica`, `Verdana`, `Consolas`, `SimSun`, `SimHei`, `FangSong`, `KaiTi`, `Microsoft YaHei`. |
| `-d <size>` | Font size in points (8-72, default: 12). |

## Usage Examples

**Convert a PDF to Word (default format, all pages):**
```bash
./FPPDFConverter -a PDF2Files -i "/Users/me/Documents/report.pdf" -o "/Users/me/Documents/report.docx"
```

**Convert a PDF to Word with specific pages:**
```bash
./FPPDFConverter -a PDF2Files -i "./report.pdf" -f docx -p "1-3,5,8-10" -o "./report.docx"
```

**Convert a PDF to Excel with merged sheets using 4 threads:**
```bash
./FPPDFConverter -a PDF2Files -i "./invoice.pdf" -f xlsx -x -t 4 -o "./invoice.xlsx"
```

**Convert a password-protected PDF to PowerPoint:**
```bash
./FPPDFConverter -a PDF2Files -i "./presentation.pdf" -f pptx -w "MySecretPass" -o "./presentation.pptx"
```

**Convert selected pages of a PDF to 300 DPI PNG images:**
```bash
./FPPDFConverter -a PDF2Files -i "./book.pdf" -f png -d 300 -p "1-10" -o "./book_"
```

**Convert a PDF to a single HTML page and package it as a ZIP:**
```bash
./FPPDFConverter -a PDF2Files -i "./guide.pdf" -f html -l 0 -z -o "./guide.zip"
```

**Convert a scanned PDF to a searchable DOCX using OCR (Simplified Chinese):**
```bash
./FPPDFConverter -a PDF2Files -i "./contract.pdf" -f docx -r -g chi_sim -o "./contract.docx"
```

**Convert a directory of images to a single PDF (A4, landscape):**
```bash
./FPPDFConverter -a Images2PDF -i "./images/" -s A4 -n landscape -o "./combined.pdf"
```

**Convert plain text to a Word document with font and size settings:**
```bash
./FPPDFConverter -a Text2Word -i "./notes.txt" -b Arial -d 14 -o "./notes.docx"
```

## Batch Conversion

Two ready-to-run scripts convert every PDF in a folder in one go.

```bash
cd "/Users/your-name/FPPDFFramework_CLI"
chmod +x converter.sh
./converter.sh
```

* Results are written to the `converted/` folder.
* A complete record (command lines, tool output, timings) is written to `conversion.log`.
* Use `converter-ocr.sh` for scanned documents; it writes `conversion-ocr.log`.

Both scripts are plain Bash 3.2 and work with the `/bin/bash` shipped by macOS. Open the script in any editor and change the settings in the **Configuration Section** at the top:

| Variable | Meaning | Default |
| :--- | :--- | :--- |
| `PDF_DIR` | Folder holding the PDFs (empty = the script's own folder) | *(empty)* |
| `OUTPUT_DIR` | Output folder, relative paths resolve under `PDF_DIR` | `converted` |
| `OUTPUT_FORMAT` | `docx`, `pptx`, `xlsx`, `html`, `csv`, `txt`, image formats | `docx` |
| `NUM_THREADS` | Number of processing threads (1-10) | `4` |
| `PAGE_RANGES` | Pages to convert, e.g. `all` or `1-3,5,8-10` | `all` |
| `OCR_LANG` | OCR language (`converter-ocr.sh` only) | `eng` |

Example console output:

```
📦 Found 1 valid PDF file(s). Starting conversion to docx...
------------------
【Test.pdf】
🔄 Converting (1/1)...
▶️ Running: ./FPPDFConverter -a PDF2Files -i ./Test.pdf -f docx -o ./converted/Test.docx -t 4 -p all
✅ Succeeded (2 s)

------------------------------------------------
FINAL SUMMARY
------------------------------------------------
✅ 1 succeeded
❌ 0 failed
📤 1 total
⏱️ Total time: 0m 2s
🎉 All conversions completed successfully!
```

Under the hood the scripts call the same `PDF2Files` engine, walking the source folder, applying consistent parameters, and reporting a summary. They are suitable for `cron`, `launchd`, CI jobs, or your own automation scripts.

## FAQ

**1. How do I check my remaining trial license time?**
When running the trial version, the console displays the remaining license time. This demo package ships with an **expired evaluation license**: the tool prints `Error, The License period has expired!` and `The trial has expired, only convert PDF up to 3 pages!`, yet still converts the first 3 pages. Contact support for a full license.

**2. macOS says the executable cannot be opened / is from an unidentified developer.**
The file was quarantined when downloaded. Remove the attribute:
```bash
xattr -dr com.apple.quarantine "/Users/your-name/FPPDFFramework_CLI"
```

**3. I get "Permission denied" when running `./FPPDFConverter`.**
The executable bit was lost when the package was copied or unzipped. Run `chmod +x FPPDFConverter` (and `chmod +x converter.sh`).

**4. Can I run this on Apple silicon?**
Yes. `FPPDFConverter` is a universal binary containing both `arm64` and `x86_64` slices, so the same file runs natively on M-series Macs and under Rosetta 2 on Intel Macs.

**5. Why are my converted documents missing fonts or formatting?**
Make sure the fonts used by the PDF are installed on the Mac (Arial, Times New Roman, Courier, Consolas are the common ones). Install Microsoft Office or the Microsoft core fonts, then log out and back in to refresh the font cache.

**6. What is the maximum number of threads I can use?**
`-t` accepts 1 to 10 for `PDF2Files` (default: 1). Higher values increase throughput on many-core Macs, but watch memory usage on very large documents.

**7. How can I see all available options?**
Run `./FPPDFConverter -h` for the list of commands, or `./FPPDFConverter -a PDF2Files -h` for command-specific options.

**8. Why is my conversion failing with path errors?**
Use forward slashes (`/`), quote paths that contain spaces, and avoid Windows-illegal characters (`:`, `\`) in file names.

**9. Does the SDK preserve hyperlinks and tables?**
Yes. The conversion engine retains original text, images, layouts, hyperlinks, tables, and Bezier graphics during conversion.

**10. Do I have to keep all the files together?**
Yes. `FPPDFConverter`, `FPPDFFramework.framework`, and `Resources.bundle` must remain in the same folder; the executable loads its engine and resources relative to itself.

## Release Notes

| Version | Release Date | Notes |
| :--- | :--- | :--- |
| v10.3.6.0 | 2026-09-09 | First macOS CLI demo release on GitHub (universal binary, batch + OCR scripts) |

## Support

For technical assistance, licensing inquiries, or bug reports, please reach out to the Flyingbee team:

* **Email:** [support@flyingbee.com](mailto:support@flyingbee.com)
* **Contact Page:** [https://www.flyingbee.com/contact-us/](https://www.flyingbee.com/contact-us/?utm_source=github_readme_conversion_sdk_mac_cli&utm_medium=referral&utm_campaign=github_readme_conversion_sdk_mac_cli)
