#!/usr/bin/env bash
# ==============================================================================
#  Flyingbee PDF Converter SDK - macOS CLI demo
#  Batch-convert every PDF in a folder to DOCX / PPTX / XLSX / HTML / CSV / TXT.
#
#  Compatible with the stock macOS /bin/bash 3.2 (no Bash 4+ syntax is used).
#  Usage:
#      ./converter.sh
# ==============================================================================

# ============ Configuration Section (please modify to fit your setup) =========
PDF_DIR=""                     # Folder holding the PDFs. Empty = this script's folder.
OUTPUT_DIR="converted"         # Output folder (relative paths resolve under PDF_DIR).
OUTPUT_FORMAT="docx"           # docx, pptx, xlsx, html, csv, txt, jpeg, png, ...
NUM_THREADS="4"                # Number of processing threads (1 - 10).
PAGE_RANGES="all"              # Pages to convert, e.g. "all" or "1-3,5,8-10".
LOG_FILE="conversion.log"      # Log file (relative paths resolve under the script folder).
SUCCESS_MARKER="Successfully converted!"
# ==============================================================================

# ------------------------------------------------------------------------------
# Resolve the folder this script lives in. The SDK loads FPPDFFramework.framework
# and Resources.bundle relative to the executable, so we always work with an
# absolute path instead of relying on the caller's working directory.
# ------------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOL_PATH="$SCRIPT_DIR/FPPDFConverter"

if [[ -z "$PDF_DIR" ]]; then
    PDF_DIR="$SCRIPT_DIR"
fi
if [[ "$PDF_DIR" != /* ]]; then
    PDF_DIR="$SCRIPT_DIR/$PDF_DIR"
fi
if [[ "$OUTPUT_DIR" != /* ]]; then
    OUTPUT_DIR="$PDF_DIR/$OUTPUT_DIR"
fi
if [[ "$LOG_FILE" != /* ]]; then
    LOG_FILE="$SCRIPT_DIR/$LOG_FILE"
fi

# ------------------------------------------------------------------------------
# Shorten an absolute path for display: when the file sits under the current
# working directory (or, failing that, under the script folder) the log shows
# "./Test.pdf" instead of the full "/Users/.../Test.pdf". The command itself is
# still executed with absolute paths, so the output is unaffected.
# ------------------------------------------------------------------------------
short_path() {
    local path="$1" base rel
    for base in "$PWD" "$SCRIPT_DIR"; do
        case "$path" in
            "$base"/*)
                rel="${path#$base/}"
                printf './%s' "$rel"
                return 0
                ;;
        esac
    done
    printf '%s' "$path"
}

# ------------------------------------------------------------------------------
# Print a command line with shell-style quoting before running it.
# `printf %q` on macOS bash 3.2 rewrites non-ASCII characters as octal escapes,
# which turns readable paths into gibberish, so quote only when it is needed.
# ------------------------------------------------------------------------------
print_cmd() {
    local out="" arg
    for arg in "$@"; do
        case "$arg" in
            /*) arg="$(short_path "$arg")" ;;
        esac
        case "$arg" in
            *[[:space:]]*|*'"'*|*"'"*) out="$out \"$arg\"" ;;
            *)                         out="$out $arg" ;;
        esac
    done
    printf '▶️ Running:%s\n' "$out"
}

echo "========================================"
echo "Flyingbee PDF Converter - macOS CLI demo"
echo "========================================"
echo "📂 Working directory: $PWD"

# ------------------------------------------------------------------------------
# Pre-flight checks. These two failures are the only reasons a freshly unzipped
# package does not start on macOS, so report them with the exact fix.
# ------------------------------------------------------------------------------
if [[ ! -f "$TOOL_PATH" ]]; then
    echo "❌ Executable not found: $TOOL_PATH"
    echo "   Keep FPPDFConverter, FPPDFFramework.framework and Resources.bundle together."
    exit 1
fi

if [[ ! -x "$TOOL_PATH" ]]; then
    echo "❌ FPPDFConverter is not executable. Fix it with:"
    echo "   chmod +x \"$TOOL_PATH\""
    exit 1
fi

# macOS Gatekeeper: a binary downloaded with Safari/Chrome carries the quarantine
# attribute and is blocked with an opaque error. Detect it and print the remedy.
if command -v xattr >/dev/null 2>&1; then
    if xattr "$TOOL_PATH" 2>/dev/null | grep -q "com.apple.quarantine"; then
        echo "❌ macOS quarantined this file because it was downloaded from the internet."
        echo "   Fix it with:"
        echo "   xattr -dr com.apple.quarantine \"$SCRIPT_DIR\""
        exit 1
    fi
fi

if [[ ! -d "$PDF_DIR" ]]; then
    echo "❌ Failed to enter directory: $PDF_DIR"
    exit 1
fi

# ------------------------------------------------------------------------------
# Initialise the log file.
# ------------------------------------------------------------------------------
echo "========================================" > "$LOG_FILE"
echo "📄 PDF to $OUTPUT_FORMAT Conversion Log" >> "$LOG_FILE"
echo "📅 Started at: $(date)" >> "$LOG_FILE"
echo "📂 Working directory: $PWD" >> "$LOG_FILE"
echo "========================================" >> "$LOG_FILE"
echo "" >> "$LOG_FILE"

# Create the output folder and remove stale files of the target format.
mkdir -p "$OUTPUT_DIR"
rm -f "$OUTPUT_DIR"/*."$OUTPUT_FORMAT"
echo "✅ Output folder ready: $(short_path "$OUTPUT_DIR")"

# ------------------------------------------------------------------------------
# Collect the PDF files.
# ------------------------------------------------------------------------------
pdf_files=()
while IFS= read -r f; do
    pdf_files+=("$f")
done < <(find "$PDF_DIR" -maxdepth 1 -type f -iname '*.pdf' | sort)

if (( ${#pdf_files[@]} == 0 )); then
    echo "⚠️ No PDF files found in: $PDF_DIR"
    echo "⚠️ No PDF files found." >> "$LOG_FILE"
    exit 0
fi

# Keep only valid PDFs: verify the "%PDF" magic header so files that merely carry
# a .pdf name (empty files, Git LFS pointers, etc.) are skipped instead of failing.
valid_pdfs=()
skipped_count=0
for f in "${pdf_files[@]}"; do
    if [[ "$(head -c 4 "$f" 2>/dev/null)" == "%PDF" ]]; then
        valid_pdfs+=("$f")
    else
        echo "⚠️ Skipping invalid PDF file: $(basename "$f")"
        echo "⚠️ Skipping invalid PDF file: $f" >> "$LOG_FILE"
        skipped_count=$((skipped_count + 1))
    fi
done

if (( ${#valid_pdfs[@]} == 0 )); then
    echo "⚠️ No valid PDF files found (all *.pdf files failed the %PDF check)."
    echo "⚠️ No valid PDF files found (all *.pdf files failed the %PDF check)." >> "$LOG_FILE"
    exit 0
fi

total=${#valid_pdfs[@]}
echo "📦 Found $total valid PDF file(s). Starting conversion to $OUTPUT_FORMAT..."
echo "📦 Found $total valid PDF file(s)." >> "$LOG_FILE"
if (( skipped_count > 0 )); then
    echo "⚠️ Skipped $skipped_count invalid file(s)."
    echo "⚠️ Skipped $skipped_count invalid file(s)." >> "$LOG_FILE"
fi

# ------------------------------------------------------------------------------
# Conversion loop.
# ------------------------------------------------------------------------------
success_count=0
fail_count=0
start_total=$(date +%s)

for i in "${!valid_pdfs[@]}"; do
    pdf_file="${valid_pdfs[$i]}"
    pdf_name="$(basename "$pdf_file")"
    index=$((i + 1))

    echo "------------------"
    # Print the file name with printf, not `echo "【$pdf_name】"`: on macOS bash 3.2
    # in a UTF-8 locale, a variable expansion that is immediately followed by a
    # multi-byte character loses its value and corrupts that character. Passing the
    # value as a printf argument keeps both the name and the brackets intact.
    printf '【%s】\n' "$pdf_name"
    echo "🔄 Converting ($index/$total)..."

    echo "------------------" >> "$LOG_FILE"
    printf '【%s】\n' "$pdf_name" >> "$LOG_FILE"
    echo "🔄 Converting ($index/$total)..." >> "$LOG_FILE"

    start_file=$(date +%s)

    # NOTE: -o expects a full output file path (the SDK treats it as a file name),
    # so pass "<output dir>/<name>.<format>" rather than just the directory.
    out_path="$OUTPUT_DIR/${pdf_name%.*}.${OUTPUT_FORMAT}"
    cmd=( "$TOOL_PATH" -a PDF2Files -i "$pdf_file" -f "$OUTPUT_FORMAT" -o "$out_path" -t "$NUM_THREADS" -p "$PAGE_RANGES" )

    # Echo the exact command line to the console and to the log before running it.
    print_cmd "${cmd[@]}" | tee -a "$LOG_FILE"
    output=$( "${cmd[@]}" 2>&1 )
    echo "$output" >> "$LOG_FILE"

    end_file=$(date +%s)
    duration=$((end_file - start_file))

    if echo "$output" | grep -q "$SUCCESS_MARKER"; then
        echo "✅ Succeeded ($duration s)"
        echo "✅ Succeeded in $duration seconds." >> "$LOG_FILE"
        success_count=$((success_count + 1))
    else
        echo "❌ Failed ($duration s)"
        echo "❌ Failed: '$SUCCESS_MARKER' not found." >> "$LOG_FILE"
        echo "➡️  Output preview:" >> "$LOG_FILE"
        echo "$output" | head -n 5 >> "$LOG_FILE"
        fail_count=$((fail_count + 1))

        # The evaluation build ships with an expired license; it still converts but
        # reports an error. Say so, otherwise a customer thinks the SDK is broken.
        if echo "$output" | grep -q -i "license"; then
            echo "ℹ️  The tool mentioned a license problem. This demo build ships with an"
            echo "    expired evaluation license; contact support@flyingbee.com for a full one."
        fi
    fi

    echo "" >> "$LOG_FILE"
done

# ------------------------------------------------------------------------------
# Final summary.
# ------------------------------------------------------------------------------
end_total=$(date +%s)
duration_total=$((end_total - start_total))
minutes=$((duration_total / 60))
seconds=$((duration_total % 60))

echo ""
echo "------------------------------------------------"
echo "FINAL SUMMARY"
echo "------------------------------------------------"
echo "✅ $success_count succeeded"
echo "❌ $fail_count failed"
echo "📤 $total total"
echo "⏱️ Total time: ${minutes}m ${seconds}s"
echo "📁 Output folder: $(short_path "$OUTPUT_DIR")"
echo "📄 Log file: $(short_path "$LOG_FILE")"

if (( fail_count == 0 && total > 0 )); then
    echo "🎉 All conversions completed successfully!"
elif (( success_count > 0 )); then
    echo "⚠️ Some conversions failed, check $LOG_FILE for details."
else
    echo "💥 All conversions failed! Check $LOG_FILE for details."
fi
echo "========================================"
echo ""

# Append the same summary to the log.
{
    echo "------------------------------------------------"
    echo "FINAL SUMMARY"
    echo "------------------------------------------------"
    echo "✅ $success_count succeeded"
    echo "❌ $fail_count failed"
    echo "📤 $total total"
    echo "⏱️ Total time: ${minutes}m ${seconds}s"
    echo "📅 Finished at: $(date)"
    echo "========================================"
    echo ""
} >> "$LOG_FILE"
