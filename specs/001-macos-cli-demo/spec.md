# Feature Specification: macOS CLI Demo (Flyingbee PDF Converter SDK)

**Spec ID:** 001-macos-cli-demo
**Status:** Draft
**Created:** 2026-09-09
**Reference implementation:** `flyingbee-pdf-converter-sdk-linux-cli/FPPDFFramework_CLI` (Linux CLI demo — ported from, and removed from this repository on 2026-09-09)

---

## 1. Goal

Deliver a self-contained, runnable command-line demo of the Flyingbee PDF Converter SDK
for **macOS**, so that prospective customers can:

1. Unzip the package,
2. Run one or two shell commands in Terminal,
3. See a PDF converted to Word / Excel / PowerPoint / HTML / CSV / TXT / images.

The demo must feel identical in shape to the existing Linux CLI demo (same script names,
same log format, same banner style) so that a customer who evaluated the Linux build can
reuse their knowledge.

## 2. Background

* The Linux demo ships one executable per CPU architecture (`FPPDFConverter-x64.out`,
  `FPPDFConverter-arm64.out`, `FPPDFConverter-x86.out`) and the operator must rename the
  matching one to `FPPDFConverter.out`.
* The macOS build ships a **single universal (x86_64 + arm64) Mach-O executable**
  `FPPDFConverter`, plus two runtime dependencies that must sit next to it:
  `FPPDFFramework.framework` and `Resources.bundle`.
* The Linux reference folder will be deleted from this repository after the macOS demo is
  complete, so the macOS demo must not depend on any file inside it.

## 3. Scope

### In scope

| # | Item | Location |
| :--- | :--- | :--- |
| 1 | Batch conversion script (PDF -> Office/HTML/CSV/TXT/image) | `FPPDFFramework_CLI/converter.sh` |
| 2 | Batch conversion script with OCR | `FPPDFFramework_CLI/converter-ocr.sh` |
| 3 | In-package plain-text quick start | `FPPDFFramework_CLI/readme.txt` |
| 4 | Repository documentation | `README.md` (repo root) |
| 5 | Git ignore / attributes hygiene | `.gitignore`, `.gitattributes` |
| 6 | Sample input document for an out-of-the-box run | `FPPDFFramework_CLI/Test.pdf` |
| 7 | Third-party legal notices shipped with the SDK | `FPPDFFramework_CLI/legal.txt` |

### Out of scope

* Rebuilding or re-signing `FPPDFConverter` / `FPPDFFramework.framework`.
* GUI / Swift / Objective-C sample applications.
* CI workflows (may be added by a later change request).
* License activation tooling — the shipped build carries an expired trial license.

## 4. Functional Requirements

### FR-1 Executable discovery

* The scripts SHALL locate `FPPDFConverter` relative to the **script's own directory**,
  not the caller's working directory.
  * Rationale: the SDK resolves `FPPDFFramework.framework` and `Resources.bundle`
    relative to the executable folder, so the working directory must not change which
    framework is loaded.

### FR-2 Executable permission check

* Before the first conversion the script SHALL verify the binary is executable; if not,
  it SHALL print the exact fix (`chmod +x FPPDFConverter`) and exit non-zero.

### FR-3 Quarantine hint (macOS specific)

* If the binary carries the `com.apple.quarantine` extended attribute (typical after
  downloading a zip with Safari/Chrome), macOS blocks execution with an opaque error.
  The script SHALL detect this and print the exact fix
  (`xattr -dr com.apple.quarantine <folder>`).

### FR-4 Input discovery and validation

* The script SHALL collect every `*.pdf` in the configured input directory.
* A file SHALL be skipped unless its first four bytes are `%PDF`, so that zero-byte
  files, Git LFS pointers and mis-named files do not abort the batch.
* Skipped files SHALL be reported on the console and in the log.

### FR-5 Output handling

* Output SHALL be written to `<input dir>/converted/` (configurable).
* Stale files of the target format SHALL be removed before the run starts.
* `-o` SHALL receive a **full output file path**, because the SDK treats the value as a
  file name rather than a directory.

### FR-6 Logging

* Every run SHALL (re)write a log file (`conversion.log` / `conversion-ocr.log`)
  containing: start time, the **working directory** (the anchor for the relative paths
  below), the exact command line per file, full tool output, per-file duration, and a
  final summary (succeeded / failed / total / elapsed).
* Paths SHALL be shown **relative to the current working directory** when the file sits
  under it, otherwise relative to the script folder, otherwise absolute. The command is
  still *executed* with absolute paths; only the printed form is shortened.

### FR-7 Progress feedback

* Console output SHALL show per-file progress (`Converting (i/n)`), success/failure,
  per-file duration, and a final summary block identical in shape to the Linux demo.

### FR-8 OCR variant

* `converter-ocr.sh` SHALL behave exactly like `converter.sh`, plus pass
  `-r 1 -g <lang>` where `<lang>` is a configurable Tesseract language (`eng` default).

### FR-9 Configuration

* All tunables (input dir, output dir, format, thread count, OCR language) SHALL be
  grouped in a clearly marked "Configuration Section" at the top of each script.

### FR-10 Documentation

* `README.md` SHALL document: features, system requirements, quick start, the complete
  command-line reference for `PDF2Files`, `Images2PDF`, `Text2Word` (verified against
  `./FPPDFConverter -h`), usage examples, batch conversion, FAQ, release notes, support.
* `readme.txt` SHALL be a short, terminal-friendly quick start shipped inside the SDK
  folder.

## 5. Non-Functional Requirements

### NFR-1 Shell compatibility

* Scripts SHALL run on the **stock macOS `/bin/bash` 3.2** shipped with the OS.
  No Bash 4+/5+ features (`mapfile`, `declare -A`, `&>>`, `${var^^}`).

### NFR-2 Line endings

* Shell scripts SHALL be committed with LF endings and SHALL carry the executable bit.
* Scripts SHALL remain valid UTF-8.

### NFR-6 Multi-byte safety (macOS bash 3.2)

* Shell scripts SHALL NOT place a multi-byte character (emoji, CJK punctuation) directly
  after a variable expansion inside the same word. Use `printf '<text %s>\n' "$var"` or
  separate arguments instead.
  * Rationale: in a UTF-8 locale, bash 3.2 drops the expanded value and corrupts the
    following character (see `plan.md` section 4). The C/POSIX locale hides the defect,
    so it must be checked explicitly under `LC_ALL=en_US.UTF-8`.

### NFR-3 Architecture transparency

* No per-architecture renaming step: the universal binary runs on both Apple silicon and
  Intel Macs. Documentation SHALL state this explicitly, because it is the main
  difference from the Linux package.

### NFR-4 Language

* Everything committed to git (code, comments, docs) SHALL be in English.

### NFR-5 Repository hygiene

* `.gitignore` SHALL exclude macOS metadata, conversion output and logs, while keeping
  every SDK dependency (framework, bundles, `traineddata`, CMap, fonts) tracked.

## 6. Acceptance Criteria

| # | Criterion |
| :--- | :--- |
| AC-1 | `bash -n converter.sh` and `bash -n converter-ocr.sh` pass with **no** syntax errors on macOS bash 3.2. |
| AC-2 | Running `./converter.sh` inside `FPPDFFramework_CLI` produces `converted/` (or a clearly explained failure) and a `conversion.log`. |
| AC-3 | `git check-ignore` matches **no** file under `FPPDFFramework_CLI/` that belongs to the SDK runtime. |
| AC-4 | `git ls-files -s` shows mode `100755` for both shell scripts and for `FPPDFConverter`. |
| AC-5 | README command reference matches the output of `./FPPDFConverter -a <command> -h`. |
| AC-6 | All committed text is English. |

## 7. Assumptions

* macOS 11.0 (Big Sur) or newer on Apple silicon; macOS 10.13 or newer on Intel, as
  encoded in the Mach-O load commands of the shipped binary.
* The evaluation license in the shipped build is expired; the tool prints
  "The License period has expired!" yet still performs conversions for evaluation. The
  scripts decide success by the `Successfully converted!` marker in the tool output,
  never by exit code alone.
