# Implementation Plan: macOS CLI Demo (Flyingbee PDF Converter SDK)

**Spec ID:** 001-macos-cli-demo
**Status:** Draft
**Created:** 2026-09-09

---

## 0. Inputs gathered from the environment

| Fact | Value | Source |
| :--- | :--- | :--- |
| Executable | `FPPDFConverter`, Mach-O universal (x86_64 + arm64) | `file FPPDFConverter` |
| Linked dependency | `@rpath/FPPDFFramework.framework/Versions/A/FPPDFFramework` | `otool -L` |
| Min OS | 11.0 (arm64 slice) / 10.13 (x86_64 slice) | `otool -l` |
| Code signature | ad-hoc signed, Team ID `3H8C8HR656` | `codesign -dv` |
| Tool version | `FPPDFConverter v10.3.6.0` | `./FPPDFConverter -h` |
| Framework version | `FPPDFFramework v10.3.6.0` | `./FPPDFConverter -h` |
| System shell | GNU bash 3.2.57 (arm64-apple-darwin25) | `/bin/bash --version` |
| Commands | `PDF2Files`, `Images2PDF`, `Text2Word` | `./FPPDFConverter -h` |
| Package size | ~161 MB (framework + OCR tessdata + CMaps) | `du -sh` |

## 1. Approach

Port the Linux batch scripts line-for-line in *behaviour*, while fixing three classes of
macOS/Linux differences:

1. **Executable shape** — one universal binary instead of three `.out` files, so the
   rename step disappears from the quick start.
2. **Path resolution** — resolve the SDK folder from `BASH_SOURCE`, so the demo works
   no matter where the terminal is; the SDK locates its framework next to the executable.
3. **Platform friction** — Gatekeeper quarantine attributes and the missing `+x` bit are
   the two reasons a customer's first run fails; detect both and print the exact remedy.

## 2. File layout after this change

```
flyingbee-pdf-converter-sdk-mac-cli/
├── .gitattributes                     # *.sh text eol=lf
├── .gitignore                         # + macOS metadata, output, logs
├── LICENSE
├── README.md                          # rewritten (FR-10)
├── specs/001-macos-cli-demo/
│   ├── plan.md
│   ├── spec.md
│   └── tasks.md
└── FPPDFFramework_CLI/
    ├── FPPDFConverter                 # universal binary (unchanged, +x)
    ├── FPPDFFramework.framework/      # runtime dependency (unchanged)
    ├── Resources.bundle/              # runtime dependency (unchanged)
    ├── Test.pdf                       # sample input
    ├── converter.sh                   # new (FR-1..FR-7, FR-9)
    ├── converter-ocr.sh               # new (FR-8)
    ├── legal.txt                      # copied from Linux package
    └── readme.txt                     # new (FR-10)
```

## 3. Technical decisions

| # | Decision | Why |
| :--- | :--- | :--- |
| D-1 | `#!/usr/bin/env bash` on **line 1** | The Linux script has a comment on line 1 and the shebang on line 2, so the kernel never sees it. Fixed here. |
| D-2 | Bash 3.2 feature set only | `/bin/bash` on macOS is frozen at 3.2; Bash 4+ syntax would break on a clean customer machine. |
| D-3 | `SCRIPT_DIR` from `BASH_SOURCE`, default `PDF_DIR="$SCRIPT_DIR"` | Satisfies FR-1 and keeps the "double-click-free, one command" demo feeling. |
| D-4 | Success detected via `Successfully converted!` marker, not exit code | The expired trial license makes the tool return non-zero even when a file is produced. |
| D-5 | `head -c 4` magic-byte check | Available on BSD/macOS `head`; rejects LFS pointers and empty files. |
| D-6 | Keep two scripts instead of one parameterised script | Preserves parity with the Linux package and with what the customer already knows. |
| D-7 | `set -u` omitted, `set -o pipefail` omitted | Bash 3.2 supports both, but the Linux script's style is intentionally forgiving; error handling stays explicit at each step. |
| D-8 | Never place a multi-byte character directly after a variable expansion in one word (`echo "【$name】"`). Use `printf '【%s】\n' "$name"` instead. | **macOS bash 3.2 bug (fixed 2026-09-09):** in a UTF-8 locale (`LC_ALL=en_US.UTF-8` / `zh_CN.UTF-8`) the expansion loses its value and the following multi-byte character loses its first byte. `echo "【$pdf_name】"` wrote `e3 80 90 80 91` — an invalid UTF-8 log line and a garbled file name. The bug does not appear in the C/POSIX locale, which is why it was invisible in a non-UTF-8 shell. See "Known pitfall" below. |

## 4. Known pitfall: bash 3.2 + UTF-8 + multi-byte character after an expansion

Verified on macOS 26.x with `/bin/bash` 3.2.57:

| Construct | `LC_ALL=C` | `LC_ALL=en_US.UTF-8` |
| :--- | :--- | :--- |
| `printf "%s" "【$N】"` | correct | **corrupt** (`e3 80 90 80 91`) |
| `printf "%s" "📦 $N ok"` | correct | correct (nothing multi-byte follows the expansion) |
| `printf "%s" "[$N]"` | correct | correct |
| `printf '【%s】' "$N"` | correct | **correct** |
| `printf "%s%s%s" "【" "$N" "】"` | correct | **correct** |

Rule: keep multi-byte characters either **before** every expansion in the word, or out of the word entirely (printf format string / separate argument).

## 5. Risks

| Risk | Mitigation |
| :--- | :--- |
| Gatekeeper blocks an unsigned/ad-hoc binary downloaded from a zip | FR-3 prints `xattr -dr com.apple.quarantine`; README FAQ covers it. |
| Customer loses the `+x` bit when unzipping on Windows and copying over | FR-2 prints `chmod +x`. |
| 161 MB of binaries in git | Accepted for a customer-facing demo; the Linux package does the same. Output folders stay ignored. |
| Expired license confuses the customer | README FAQ + scripts explain the message is expected in the evaluation build. |

## 5. Verification

1. `bash -n` on both scripts (AC-1).
2. `git check-ignore -v` over every file under `FPPDFFramework_CLI/` (AC-3).
3. `git ls-files -s` mode check for `100755` (AC-4).
4. Compare README option tables against `./FPPDFConverter -a <cmd> -h` (AC-5).
