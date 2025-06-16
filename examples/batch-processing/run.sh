#!/bin/bash

# Batch Processing Example
# This script demonstrates how to process multiple text lines from a file

echo "=== Batch Processing Example ==="
echo "Processing text lines from a file into separate audio files..."
echo ""

# Check if API key is set
if [ -z "$GEMINI_API_KEY" ]; then
    echo "❌ Error: GEMINI_API_KEY environment variable is not set."
    echo "Please set your API key first:"
    echo "  export GEMINI_API_KEY=\"your-api-key-here\""
    exit 1
fi

# Input file and parameters
INPUT_FILE="sample-text.txt"
VOICE="zephyr"
INSTRUCTIONS="Read aloud in a clear, pleasant voice"

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "❌ Error: Input file '$INPUT_FILE' not found."
    echo "Make sure you're running this script from the example directory."
    exit 1
fi

echo "Input file: $INPUT_FILE"
echo "Voice: $VOICE"
echo "Instructions: $INSTRUCTIONS"
echo ""

# Show the content that will be processed
echo "=== File Content ==="
cat "$INPUT_FILE"
echo ""
echo "=== Processing ==="

# Count lines for progress tracking
TOTAL_LINES=$(grep -c . "$INPUT_FILE" 2>/dev/null || wc -l < "$INPUT_FILE")
echo "Processing $TOTAL_LINES lines from $INPUT_FILE..."
echo ""

# Run batch processing
echo "Running: gemini-tts --file \"$INPUT_FILE\" --speaker1 \"$VOICE\" --instructions \"$INSTRUCTIONS\""
echo ""

gemini-tts --file "$INPUT_FILE" --speaker1 "$VOICE" --instructions "$INSTRUCTIONS"

echo ""
echo "=== Results ==="

# Check generated files
PATTERN="sample-text-*.wav"
FILES=(sample-text-*.wav)

if [ -e "${FILES[0]}" ]; then
    echo "✅ Successfully generated audio files:"
    for file in sample-text-*.wav; do
        if [ -f "$file" ]; then
            # Get file size for verification
            if command -v stat >/dev/null 2>&1; then
                SIZE=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null)
                echo "  📄 $file ($SIZE bytes)"
            else
                echo "  📄 $file"
            fi
        fi
    done
    
    echo ""
    echo "💡 Tips:"
    echo "  - Each line from the input file becomes a separate audio file"
    echo "  - Files are numbered sequentially (01, 02, 03, etc.)"
    echo "  - Empty lines and symbol-only lines are automatically filtered"
    echo "  - You can play these files individually or use them in presentations"
else
    echo "❌ No audio files were generated. Check the error messages above."
    exit 1
fi