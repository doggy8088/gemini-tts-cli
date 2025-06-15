#!/bin/bash

# Custom Voice and Instructions Example
# This script demonstrates how to use specific voices and custom instructions

echo "=== Custom Voice and Instructions Example ==="
echo "Demonstrating different voices and instruction styles..."
echo ""

# Check if API key is set
if [ -z "$GEMINI_API_KEY" ]; then
    echo "❌ Error: GEMINI_API_KEY environment variable is not set."
    echo "Please set your API key first:"
    echo "  export GEMINI_API_KEY=\"your-api-key-here\""
    exit 1
fi

# Example 1: Female voice with enthusiastic instructions
echo "1. Generating enthusiastic female voice example..."
INSTRUCTIONS1="Read aloud in an enthusiastic, energetic, and engaging tone as if presenting to an audience"
TEXT1="Welcome to this amazing demonstration of custom voice selection! This example shows how you can control both the voice and the speaking style."
OUTPUT1="female-enthusiastic.wav"

echo "   Voice: zephyr (female)"
echo "   Style: Enthusiastic presentation"
echo "   Output: $OUTPUT1"

gemini-tts --instructions "$INSTRUCTIONS1" --speaker1 "zephyr" --text "$TEXT1" --outputfile "$OUTPUT1"

if [ -f "$OUTPUT1" ]; then
    echo "   ✅ Generated: $OUTPUT1"
else
    echo "   ❌ Failed to generate: $OUTPUT1"
fi

echo ""

# Example 2: Male voice with professional instructions
echo "2. Generating professional male voice example..."
INSTRUCTIONS2="Read aloud in a calm, professional, and authoritative tone suitable for business presentations"
TEXT2="This demonstration showcases the professional capabilities of the Gemini TTS system. The voice selection and instruction customization provide excellent control over the output quality."
OUTPUT2="male-professional.wav"

echo "   Voice: achird (male)"
echo "   Style: Professional business tone"
echo "   Output: $OUTPUT2"

gemini-tts --instructions "$INSTRUCTIONS2" --speaker1 "achird" --text "$TEXT2" --outputfile "$OUTPUT2"

if [ -f "$OUTPUT2" ]; then
    echo "   ✅ Generated: $OUTPUT2"
else
    echo "   ❌ Failed to generate: $OUTPUT2"
fi

echo ""

# Example 3: Female voice with storytelling instructions
echo "3. Generating storytelling female voice example..."
INSTRUCTIONS3="Read aloud in a warm, expressive, and captivating tone as if telling a story to children"
TEXT3="Once upon a time, there was a magical text-to-speech system that could transform any written words into beautiful, natural-sounding speech with just a simple command."
OUTPUT3="female-storytelling.wav"

echo "   Voice: callirrhoe (female)"
echo "   Style: Warm storytelling"
echo "   Output: $OUTPUT3"

gemini-tts --instructions "$INSTRUCTIONS3" --speaker1 "callirrhoe" --text "$TEXT3" --outputfile "$OUTPUT3"

if [ -f "$OUTPUT3" ]; then
    echo "   ✅ Generated: $OUTPUT3"
else
    echo "   ❌ Failed to generate: $OUTPUT3"
fi

echo ""
echo "=== Summary ==="
echo "Generated files:"
for file in "$OUTPUT1" "$OUTPUT2" "$OUTPUT3"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ $file (failed)"
    fi
done

echo ""
echo "You can play these files to hear the difference between:"
echo "- Different voices (zephyr, achird, callirrhoe)"
echo "- Different instruction styles (enthusiastic, professional, storytelling)"