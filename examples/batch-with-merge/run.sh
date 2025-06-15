#!/bin/bash

# Batch Processing with Merge Example
# This script demonstrates how to process multiple text lines and merge into one audio file

echo "=== Batch Processing with Merge Example ==="
echo "Processing text file and merging all outputs into one continuous audio file..."
echo ""

# Check if API key is set
if [ -z "$GEMINI_API_KEY" ]; then
    echo "❌ Error: GEMINI_API_KEY environment variable is not set."
    echo "Please set your API key first:"
    echo "  export GEMINI_API_KEY=\"your-api-key-here\""
    exit 1
fi

# Input file and parameters
INPUT_FILE="story.txt"
OUTPUT_FILE="story-merged.wav"
VOICE="callirrhoe"
INSTRUCTIONS="Read aloud in a warm, storytelling voice with natural pauses between sentences"

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "❌ Error: Input file '$INPUT_FILE' not found."
    echo "Make sure you're running this script from the example directory."
    exit 1
fi

echo "Input file: $INPUT_FILE"
echo "Output file: $OUTPUT_FILE"
echo "Voice: $VOICE (female, storytelling)"
echo "Instructions: $INSTRUCTIONS"
echo ""

# Show the content that will be processed
echo "=== Story Content ==="
cat "$INPUT_FILE"
echo ""
echo "=== Processing ==="

# Count lines for progress tracking
TOTAL_LINES=$(grep -c . "$INPUT_FILE" 2>/dev/null || wc -l < "$INPUT_FILE")
echo "Processing $TOTAL_LINES lines from $INPUT_FILE and merging into $OUTPUT_FILE..."
echo ""

# Run batch processing with merge
echo "Running: gemini-tts --file \"$INPUT_FILE\" --speaker1 \"$VOICE\" --merge --outputfile \"$OUTPUT_FILE\" --instructions \"$INSTRUCTIONS\""
echo ""

gemini-tts --file "$INPUT_FILE" --speaker1 "$VOICE" --merge --outputfile "$OUTPUT_FILE" --instructions "$INSTRUCTIONS"

echo ""
echo "=== Results ==="

# Check if the merged file was created
if [ -f "$OUTPUT_FILE" ]; then
    # Get file size and duration info
    if command -v stat >/dev/null 2>&1; then
        SIZE=$(stat -c%s "$OUTPUT_FILE" 2>/dev/null || stat -f%z "$OUTPUT_FILE" 2>/dev/null)
        echo "✅ Successfully created merged audio file:"
        echo "  📄 $OUTPUT_FILE ($SIZE bytes)"
    else
        echo "✅ Successfully created merged audio file: $OUTPUT_FILE"
    fi
    
    echo ""
    echo "🎵 Audio Details:"
    echo "  - Contains all $TOTAL_LINES story lines in continuous sequence"
    echo "  - Single voice throughout (callirrhoe - female storytelling voice)"
    echo "  - Natural storytelling tone with appropriate pacing"
    echo ""
    echo "💡 Benefits of merging:"
    echo "  ✓ Single file instead of multiple numbered files"
    echo "  ✓ Continuous playback without interruption"
    echo "  ✓ Perfect for audio books, presentations, or podcasts"
    echo "  ✓ Easier to manage and distribute"
    echo ""
    echo "🎧 You can now play '$OUTPUT_FILE' to hear the complete story!"
else
    echo "❌ Merged audio file was not created. Check the error messages above."
    
    # Check if individual files were created instead
    if ls story-*.wav 1> /dev/null 2>&1; then
        echo ""
        echo "Individual files were created instead:"
        for file in story-*.wav; do
            echo "  📄 $file"
        done
        echo ""
        echo "💡 You can manually merge these using:"
        echo "  gemini-tts merge 'story-*.wav' --outputfile '$OUTPUT_FILE'"
    fi
    
    exit 1
fi