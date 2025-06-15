#!/bin/bash

# File Merging Example
# This script demonstrates how to merge existing WAV files using glob patterns

echo "=== File Merging Example ==="
echo "Demonstrating how to merge existing WAV files with different patterns..."
echo ""

# Check if API key is set (needed for creating sample files)
if [ -z "$GEMINI_API_KEY" ]; then
    echo "❌ Error: GEMINI_API_KEY environment variable is not set."
    echo "This example needs to create sample WAV files first."
    echo "Please set your API key:"
    echo "  export GEMINI_API_KEY=\"your-api-key-here\""
    exit 1
fi

echo "=== Step 1: Creating Sample WAV Files ==="
echo "First, let's create some sample WAV files to demonstrate merging..."
echo ""

# Create sample intro files
echo "Creating intro files..."
gemini-tts --text "Welcome to our audio demonstration." --speaker1 "zephyr" --outputfile "intro-01.wav" --instructions "Read aloud in a welcoming, friendly tone"
gemini-tts --text "This example shows how to merge audio files." --speaker1 "zephyr" --outputfile "intro-02.wav" --instructions "Read aloud in an informative tone"

# Create sample lesson files  
echo "Creating lesson files..."
gemini-tts --text "Lesson one covers the basics of file merging." --speaker1 "achird" --outputfile "lesson-01.wav" --instructions "Read aloud in a clear, educational tone"
gemini-tts --text "Lesson two demonstrates advanced patterns." --speaker1 "achird" --outputfile "lesson-02.wav" --instructions "Read aloud in a clear, educational tone"

echo ""
echo "✅ Sample files created:"
for file in intro-*.wav lesson-*.wav; do
    if [ -f "$file" ]; then
        echo "  📄 $file"
    fi
done

echo ""
echo "=== Step 2: Demonstrating Merge Patterns ==="
echo ""

# Example 1: Merge all intro files
echo "1. Merging intro files with pattern 'intro-*.wav'..."
echo "   Running: gemini-tts merge 'intro-*.wav' --outputfile 'intro-merged.wav'"
gemini-tts merge 'intro-*.wav' --outputfile 'intro-merged.wav'

if [ -f "intro-merged.wav" ]; then
    echo "   ✅ Created: intro-merged.wav"
else
    echo "   ❌ Failed to create intro-merged.wav"
fi

echo ""

# Example 2: Merge all lesson files
echo "2. Merging lesson files with pattern 'lesson-*.wav'..."
echo "   Running: gemini-tts merge 'lesson-*.wav' --outputfile 'lesson-merged.wav'"
gemini-tts merge 'lesson-*.wav' --outputfile 'lesson-merged.wav'

if [ -f "lesson-merged.wav" ]; then
    echo "   ✅ Created: lesson-merged.wav"
else
    echo "   ❌ Failed to create lesson-merged.wav"
fi

echo ""

# Example 3: Merge all WAV files
echo "3. Merging all WAV files with pattern '*.wav'..."
echo "   Running: gemini-tts merge '*.wav' --outputfile 'all-merged.wav'"
echo "   Note: This excludes previously merged files to avoid recursion"

# First, move merged files temporarily to avoid including them
mkdir -p temp_merged 2>/dev/null
mv *-merged.wav temp_merged/ 2>/dev/null

gemini-tts merge '*.wav' --outputfile 'all-merged.wav'

# Move the merged files back
mv temp_merged/*-merged.wav . 2>/dev/null
rmdir temp_merged 2>/dev/null

if [ -f "all-merged.wav" ]; then
    echo "   ✅ Created: all-merged.wav"
else
    echo "   ❌ Failed to create all-merged.wav"
fi

echo ""
echo "=== Results Summary ==="
echo ""

echo "Original files:"
for file in intro-*.wav lesson-*.wav; do
    if [ -f "$file" ] && [[ ! "$file" =~ -merged\.wav$ ]]; then
        if command -v stat >/dev/null 2>&1; then
            SIZE=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null)
            echo "  📄 $file ($SIZE bytes)"
        else
            echo "  📄 $file"
        fi
    fi
done

echo ""
echo "Merged files:"
for file in *-merged.wav all-merged.wav; do
    if [ -f "$file" ]; then
        if command -v stat >/dev/null 2>&1; then
            SIZE=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null)
            echo "  🎵 $file ($SIZE bytes)"
        else
            echo "  🎵 $file"
        fi
    fi
done

echo ""
echo "💡 Merge Pattern Examples:"
echo "  *.wav           - All WAV files in current directory"
echo "  intro-*.wav     - Files starting with 'intro-'"
echo "  lesson-*.wav    - Files starting with 'lesson-'"
echo "  **/*.wav        - All WAV files including subdirectories"
echo "  ??-*.wav        - Files with two-character prefix"
echo ""
echo "🎧 You can now play the merged files to hear the combined audio!"