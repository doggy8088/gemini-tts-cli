#!/bin/bash

# Multilingual Text-to-Speech Example
# This script demonstrates TTS with multiple languages and scripts

echo "=== Multilingual Text-to-Speech Example ==="
echo "Demonstrating text-to-speech in multiple languages..."
echo ""

# Check if API key is set
if [ -z "$GEMINI_API_KEY" ]; then
    echo "❌ Error: GEMINI_API_KEY environment variable is not set."
    echo "Please set your API key first:"
    echo "  export GEMINI_API_KEY=\"your-api-key-here\""
    exit 1
fi

echo "This example will generate audio in multiple languages:"
echo "🇺🇸 English - Professional technology description"
echo "🇹🇼 Chinese (Traditional) - Educational content about AI"
echo "🇯🇵 Japanese - Polite introduction and explanation"
echo "🇪🇸 Spanish - Friendly greeting and description"
echo "🇫🇷 French - Elegant introduction to TTS technology"
echo ""

# Example 1: English
echo "1. Generating English audio..."
ENGLISH_TEXT="Welcome to this multilingual demonstration of the Gemini Text-to-Speech system. This technology can convert written text into natural-sounding speech across many different languages and writing systems."
ENGLISH_INSTRUCTIONS="Read aloud in a professional, clear American English accent with appropriate pacing"
ENGLISH_VOICE="zephyr"
ENGLISH_OUTPUT="english.wav"

echo "   Language: English"
echo "   Voice: $ENGLISH_VOICE (female)"
echo "   Output: $ENGLISH_OUTPUT"

gemini-tts --text "$ENGLISH_TEXT" --speaker1 "$ENGLISH_VOICE" --instructions "$ENGLISH_INSTRUCTIONS" --outputfile "$ENGLISH_OUTPUT"

if [ -f "$ENGLISH_OUTPUT" ]; then
    echo "   ✅ Generated: $ENGLISH_OUTPUT"
else
    echo "   ❌ Failed to generate: $ENGLISH_OUTPUT"
fi

echo ""

# Example 2: Chinese (Traditional)
echo "2. Generating Chinese audio..."
CHINESE_TEXT="歡迎使用 Gemini 文字轉語音系統！這個強大的人工智慧技術可以將任何文字內容轉換成自然流暢的語音，支援多種語言和聲音選項。"
CHINESE_INSTRUCTIONS="以溫暖、自然的語調朗讀，適合教學使用，語速適中"
CHINESE_VOICE="callirrhoe"
CHINESE_OUTPUT="chinese.wav"

echo "   Language: Chinese (Traditional)"
echo "   Voice: $CHINESE_VOICE (female)"
echo "   Output: $CHINESE_OUTPUT"

gemini-tts --text "$CHINESE_TEXT" --speaker1 "$CHINESE_VOICE" --instructions "$CHINESE_INSTRUCTIONS" --outputfile "$CHINESE_OUTPUT"

if [ -f "$CHINESE_OUTPUT" ]; then
    echo "   ✅ Generated: $CHINESE_OUTPUT"
else
    echo "   ❌ Failed to generate: $CHINESE_OUTPUT"
fi

echo ""

# Example 3: Japanese
echo "3. Generating Japanese audio..."
JAPANESE_TEXT="こんにちは。Gemini テキスト読み上げシステムのマルチ言語デモンストレーションにようこそ。この技術は、様々な言語の文章を自然な音声に変換することができます。"
JAPANESE_INSTRUCTIONS="丁寧で分かりやすい日本語で、適切な間を取りながら読み上げてください"
JAPANESE_VOICE="leda"
JAPANESE_OUTPUT="japanese.wav"

echo "   Language: Japanese"
echo "   Voice: $JAPANESE_VOICE (female)"
echo "   Output: $JAPANESE_OUTPUT"

gemini-tts --text "$JAPANESE_TEXT" --speaker1 "$JAPANESE_VOICE" --instructions "$JAPANESE_INSTRUCTIONS" --outputfile "$JAPANESE_OUTPUT"

if [ -f "$JAPANESE_OUTPUT" ]; then
    echo "   ✅ Generated: $JAPANESE_OUTPUT"
else
    echo "   ❌ Failed to generate: $JAPANESE_OUTPUT"
fi

echo ""

# Example 4: Spanish
echo "4. Generating Spanish audio..."
SPANISH_TEXT="¡Hola y bienvenidos a esta demostración multilingüe del sistema de texto a voz Gemini! Esta increíble tecnología puede convertir texto escrito en discurso natural en muchos idiomas diferentes."
SPANISH_INSTRUCTIONS="Lee en voz alta con un tono amigable y claro en español, con pronunciación natural"
SPANISH_VOICE="erinome"
SPANISH_OUTPUT="spanish.wav"

echo "   Language: Spanish"
echo "   Voice: $SPANISH_VOICE (female)"
echo "   Output: $SPANISH_OUTPUT"

gemini-tts --text "$SPANISH_TEXT" --speaker1 "$SPANISH_VOICE" --instructions "$SPANISH_INSTRUCTIONS" --outputfile "$SPANISH_OUTPUT"

if [ -f "$SPANISH_OUTPUT" ]; then
    echo "   ✅ Generated: $SPANISH_OUTPUT"
else
    echo "   ❌ Failed to generate: $SPANISH_OUTPUT"
fi

echo ""

# Example 5: French
echo "5. Generating French audio..."
FRENCH_TEXT="Bonjour et bienvenue à cette démonstration multilingue du système de synthèse vocale Gemini. Cette technologie sophistiquée peut transformer n'importe quel texte écrit en parole naturelle."
FRENCH_INSTRUCTIONS="Lisez à haute voix avec un accent français authentique et une diction claire et élégante"
FRENCH_VOICE="gacrux"
FRENCH_OUTPUT="french.wav"

echo "   Language: French"
echo "   Voice: $FRENCH_VOICE (female)"
echo "   Output: $FRENCH_OUTPUT"

gemini-tts --text "$FRENCH_TEXT" --speaker1 "$FRENCH_VOICE" --instructions "$FRENCH_INSTRUCTIONS" --outputfile "$FRENCH_OUTPUT"

if [ -f "$FRENCH_OUTPUT" ]; then
    echo "   ✅ Generated: $FRENCH_OUTPUT"
else
    echo "   ❌ Failed to generate: $FRENCH_OUTPUT"
fi

echo ""
echo "=== Results Summary ==="
echo ""

echo "Generated multilingual audio files:"
for file in english.wav chinese.wav japanese.wav spanish.wav french.wav; do
    if [ -f "$file" ]; then
        if command -v stat >/dev/null 2>&1; then
            SIZE=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null)
            echo "✅ $file ($SIZE bytes)"
        else
            echo "✅ $file"
        fi
    else
        echo "❌ $file (failed)"
    fi
done

echo ""
echo "🌍 Language Support:"
echo "  • Latin scripts: English, Spanish, French, German, Italian, Portuguese"
echo "  • Chinese: Traditional and Simplified characters with proper tones"
echo "  • Japanese: Hiragana, Katakana, and Kanji with correct pronunciation"
echo "  • Other scripts: Korean, Arabic, Russian, and many more"
echo ""
echo "💡 Tips for multilingual TTS:"
echo "  ✓ Use language-appropriate instructions for best results"
echo "  ✓ Test different voices to find the best match for each language"
echo "  ✓ Ensure text files use UTF-8 encoding for proper character support"
echo "  ✓ Process each language separately for optimal pronunciation"
echo ""
echo "🎧 Listen to the generated files to experience multilingual TTS capabilities!"