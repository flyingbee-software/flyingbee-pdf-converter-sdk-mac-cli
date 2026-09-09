# Task Checklist: macOS CLI Demo (Flyingbee PDF Converter SDK)

**Spec ID:** 001-macos-cli-demo
**Status:** In progress

Legend: `[x]` done, `[ ]` pending, `[-]` not applicable.

---

## Specification

- [x] T001 Write `specs/001-macos-cli-demo/spec.md` (requirements, FR-1..FR-10, NFR-1..NFR-5, AC-1..AC-6)
- [x] T002 Write `specs/001-macos-cli-demo/plan.md` (environment facts, decisions D-1..D-7, risks)
- [x] T003 Write `specs/001-macos-cli-demo/tasks.md` (this file)

## Scripts

- [x] T004 Create `FPPDFFramework_CLI/converter.sh` — batch conversion, script-dir resolution, exec-bit and quarantine checks, `%PDF` validation, per-file timing, summary, log file
- [x] T005 Create `FPPDFFramework_CLI/converter-ocr.sh` — same as T004 plus `-r 1 -g <lang>` and separate log file
- [x] T006 `chmod 755` both scripts

## Package content

- [x] T007 Copy `Test.pdf` from the Linux package into `FPPDFFramework_CLI/`
- [x] T008 Copy `legal.txt` from the Linux package into `FPPDFFramework_CLI/`

## Documentation

- [x] T009 Write `FPPDFFramework_CLI/readme.txt` — in-package plain-text quick start
- [x] T010 Write root `README.md` — features, system requirements, quick start, command reference, examples, batch conversion, FAQ, release notes, support

## Repository hygiene

- [x] T011 Update `.gitignore` — macOS metadata (`.DS_Store`, `._*`, `__MACOSX/`), conversion output (`converted/`, `output/`), editor junk; keep all SDK runtime files tracked
- [x] T012 Update `.gitattributes` — `*.sh text eol=lf`, binary payload marked

## Verification

- [x] T013 `bash -n` syntax check on both scripts (AC-1)
- [x] T014 `git check-ignore` sweep over `FPPDFFramework_CLI/` — only `.DS_Store`, `converted/` and `*.log` are ignored (AC-3)
- [x] T015 Smoke run of `./converter.sh` and `./converter-ocr.sh` inside `FPPDFFramework_CLI` — both produced `converted/Test.docx` (AC-2)
- [x] T016 Confirm command reference matches `./FPPDFConverter -a <command> -h` (AC-5)

## Deferred (requested later by the maintainer)

- [x] T017 Remove the `flyingbee-pdf-converter-sdk-linux-cli/` reference folder (owner: maintainer) — done 2026-09-09
- [ ] T018 Optional macOS GitHub Actions workflow on `macos-latest` runners
