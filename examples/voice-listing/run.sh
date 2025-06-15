#!/bin/bash

# Voice Listing Example
# This script demonstrates how to list all available voices

echo "=== Voice Listing Example ==="
echo "Displaying all available voices in Gemini TTS CLI..."
echo ""

# Note: This command does not require API key authentication
echo "Running: gemini-tts list-voices"
echo ""

# List all available voices
gemini-tts list-voices

echo ""
echo "=== Voice Usage Information ==="
echo ""
echo "You can use any of these voices in your TTS commands:"
echo ""
echo "Examples:"
echo "  # Using a female voice"
echo '  gemini-tts --speaker1 "zephyr" --text "Hello from a female voice"'
echo ""
echo "  # Using a male voice"
echo '  gemini-tts --speaker1 "achird" --text "Hello from a male voice"'
echo ""
echo "  # Random voice (default behavior)"
echo '  gemini-tts --text "Hello with a random voice"'
echo ""
echo "Voice categories:"
echo "  • Female voices: Generally higher pitched, softer tones"
echo "  • Male voices: Generally lower pitched, deeper tones"
echo ""
echo "💡 Tips:"
echo "  - Voice names are case-insensitive"
echo "  - Each voice has unique characteristics"
echo "  - Try different voices for different content types"
echo "  - Combine with custom instructions for best results"