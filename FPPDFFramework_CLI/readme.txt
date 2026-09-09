⚠️ What Flyingbee PDF Conversion SDK Does?

It is a flexible, high-performance PDF to MS Office (.docx, .xlsx, .pptx) conversion library for Windows, macOS, Linux, and Web. It helps to convert PDFs into Word, PowerPoint, Excel files, convert them into editable and well formatted documents, and accurately preserve the original text, images, layouts, hyperlinks, tables, and Bezier graphics.

This package is the macOS command-line demo: one universal executable (Apple silicon + Intel) plus two runtime dependencies, driven by ready-to-run shell scripts.

Package contents (keep these three items together in the same folder):
    FPPDFConverter                 The command-line executable (universal binary).
    FPPDFFramework.framework       The conversion engine.
    Resources.bundle               Fonts, CMaps, OCR data, HTML templates.
    converter.sh                   Batch-convert every PDF in this folder.
    converter-ocr.sh               Batch-convert every PDF using OCR (scanned PDFs).
    Test.pdf                       Sample document used by the examples below.
    readme.txt                     This file.
    legal.txt                      Third-party license notices.

-----------------------------------------------------------------------------
🎉 Introduce how to deploy and use the PDF converter SDK on macOS, including system requirements and usage instructions
➡️ https://www.flyingbee.com/pdf-sdk/documentation/guides/desktop-mac/
-----------------------------------------------------------------------------


-----------------------------------------------------------------------------
🎉 Quick Start Guide
-----------------------------------------------------------------------------
1. Entering the Executable File Directory
$ cd "/Users/your-name/FPPDFFramework_CLI/"

2. ✅ Granting Executable Permission
$ chmod +x FPPDFConverter

2.1 ⚠️ Only if macOS says the file "cannot be opened because it is from an
    unidentified developer" — remove the download quarantine flag:
$ xattr -dr com.apple.quarantine "/Users/your-name/FPPDFFramework_CLI/"

3. 🔄 execute command
$ ./FPPDFConverter -h
$ ./FPPDFConverter -a PDF2Files -i "Test.pdf" -f docx -p all

Note: unlike the Linux package there is nothing to rename. FPPDFConverter is a
universal binary and runs on both Apple silicon (M-series) and Intel Macs.


-----------------------------------------------------------------------------
📦 PDF Converter (Batch)
-----------------------------------------------------------------------------
This command can convert all PDF files under the folder into Word files.
You can customize and modify the source folder and output format in this script.

1. Entering the Executable File Directory
$ cd "/Users/your-name/FPPDFFramework_CLI/"

2. ✅ Granting executable permissions
$ chmod +x converter.sh

3. 🔄 execute command
$ ./converter.sh

Results are written to the "converted" folder, and a full record of the run is
written to "conversion.log".

For scanned documents use the OCR variant instead:
$ chmod +x converter-ocr.sh
$ ./converter-ocr.sh

Open the script in any text editor to change the settings at the top:
    PDF_DIR         folder holding the PDFs (default: this script's folder)
    OUTPUT_DIR      output folder (default: converted)
    OUTPUT_FORMAT   docx, pptx, xlsx, html, csv, txt, jpeg, png, ...
    NUM_THREADS     number of processing threads (1-10)
    PAGE_RANGES     pages to convert, e.g. all or 1-3,5,8-10
    OCR_LANG        OCR language, e.g. eng, chi_sim, jpn (OCR script only)


-----------------------------------------------------------------------------
🕹️ More Commands
-----------------------------------------------------------------------------
Convert PDF to Excel with merged sheets:
$ ./FPPDFConverter -a PDF2Files -i "Test.pdf" -f xlsx -x -o "Test.xlsx"

Convert a password-protected PDF to PowerPoint:
$ ./FPPDFConverter -a PDF2Files -i "Test.pdf" -f pptx -w "MySecretPass" -o "Test.pptx"

Convert pages 1-10 to 300 DPI PNG images:
$ ./FPPDFConverter -a PDF2Files -i "Test.pdf" -f png -d 300 -p "1-10" -o "page_"

Convert a scanned PDF to a searchable DOCX (OCR, Simplified Chinese):
$ ./FPPDFConverter -a PDF2Files -i "Test.pdf" -f docx -r -g chi_sim -o "Test.docx"

Merge a folder of images into one PDF:
$ ./FPPDFConverter -a Images2PDF -i "./images/" -s A4 -n landscape -o "merged.pdf"

Convert a plain text file to Word:
$ ./FPPDFConverter -a Text2Word -i "notes.txt" -b Arial -d 14 -o "notes.docx"

Show all options of a command:
$ ./FPPDFConverter -a PDF2Files -h


----------------------------------------------------------
------ SUPPORT -------------------------------------------
Should you have any questions pertaining to the above information, kindly reach out to Flyingbee Support directly through:
Email: support@flyingbee.com
https://www.flyingbee.com/contact-us/
----------------------------


----------------------------------------------------------
------ RELEASE VERSION -----------------------------------
----------------------------
2026-09-09 v10.3.6.0
----------------------------
