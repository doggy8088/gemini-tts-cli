#!/bin/bash

# Basic Text-to-Speech Example
# This script demonstrates the simplest usage of Gemini TTS CLI

echo "=== Basic Text-to-Speech Example ==="
echo "Converting text to speech with default settings..."
echo ""

# Check if API key is set
if [ -z "$GEMINI_API_KEY" ]; then
    echo "❌ Error: GEMINI_API_KEY environment variable is not set."
    echo "Please set your API key first:"
    echo "  export GEMINI_API_KEY=\"your-api-key-here\""
    exit 1
fi

# Simple text-to-speech conversion with default settings
TEXT="Hello world! This is a basic text-to-speech example using Gemini TTS."

echo "Text to convert: $TEXT"
echo "Running: gemini-tts --text \"$TEXT\""
echo ""

# Run the TTS command
gemini-tts --text "$TEXT"

# Check if output file was created
if [ -f "output.wav" ]; then
    echo ""
    echo "✅ Success! Generated audio file: output.wav"
    echo "You can play the file using your system's audio player."
    
    # Try to get file size for verification
    if command -v stat >/dev/null 2>&1; then
        SIZE=$(stat -c%s "output.wav" 2>/dev/null || stat -f%z "output.wav" 2>/dev/null)
        if [ ! -z "$SIZE" ]; then
            echo "File size: $SIZE bytes"
        fi
    fi
else
    echo ""
    echo "❌ Error: Output file was not created. Check the error messages above."
    exit 1
fi