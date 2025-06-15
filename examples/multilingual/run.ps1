# Multilingual Text-to-Speech Example
# This script demonstrates TTS with multiple languages and scripts

Write-Host "=== Multilingual Text-to-Speech Example ===" -ForegroundColor Cyan
Write-Host "Demonstrating text-to-speech in multiple languages..." -ForegroundColor White
Write-Host ""

# Check if API key is set
if (-not $env:GEMINI_API_KEY) {
    Write-Host "❌ Error: GEMINI_API_KEY environment variable is not set." -ForegroundColor Red
    Write-Host "Please set your API key first:" -ForegroundColor Yellow
    Write-Host '  $env:GEMINI_API_KEY = "your-api-key-here"' -ForegroundColor Yellow
    exit 1
}

Write-Host "This example will generate audio in multiple languages:" -ForegroundColor White
Write-Host "🇺🇸 English - Professional technology description" -ForegroundColor Gray
Write-Host "🇹🇼 Chinese (Traditional) - Educational content about AI" -ForegroundColor Gray
Write-Host "🇯🇵 Japanese - Polite introduction and explanation" -ForegroundColor Gray
Write-Host "🇪🇸 Spanish - Friendly greeting and description" -ForegroundColor Gray
Write-Host "🇫🇷 French - Elegant introduction to TTS technology" -ForegroundColor Gray
Write-Host ""

# Example 1: English
Write-Host "1. Generating English audio..." -ForegroundColor Yellow
$EnglishText = "Welcome to this multilingual demonstration of the Gemini Text-to-Speech system. This technology can convert written text into natural-sounding speech across many different languages and writing systems."
$EnglishInstructions = "Read aloud in a professional, clear American English accent with appropriate pacing"
$EnglishVoice = "zephyr"
$EnglishOutput = "english.wav"

Write-Host "   Language: English" -ForegroundColor Gray
Write-Host "   Voice: $EnglishVoice (female)" -ForegroundColor Gray
Write-Host "   Output: $EnglishOutput" -ForegroundColor Gray

& gemini-tts --text $EnglishText --speaker1 $EnglishVoice --instructions $EnglishInstructions --outputfile $EnglishOutput

if (Test-Path $EnglishOutput) {
    Write-Host "   ✅ Generated: $EnglishOutput" -ForegroundColor Green
} else {
    Write-Host "   ❌ Failed to generate: $EnglishOutput" -ForegroundColor Red
}

Write-Host ""

# Example 2: Chinese (Traditional)
Write-Host "2. Generating Chinese audio..." -ForegroundColor Yellow
$ChineseText = "歡迎使用 Gemini 文字轉語音系統！這個強大的人工智慧技術可以將任何文字內容轉換成自然流暢的語音，支援多種語言和聲音選項。"
$ChineseInstructions = "以溫暖、自然的語調朗讀，適合教學使用，語速適中"
$ChineseVoice = "callirrhoe"
$ChineseOutput = "chinese.wav"

Write-Host "   Language: Chinese (Traditional)" -ForegroundColor Gray
Write-Host "   Voice: $ChineseVoice (female)" -ForegroundColor Gray
Write-Host "   Output: $ChineseOutput" -ForegroundColor Gray

& gemini-tts --text $ChineseText --speaker1 $ChineseVoice --instructions $ChineseInstructions --outputfile $ChineseOutput

if (Test-Path $ChineseOutput) {
    Write-Host "   ✅ Generated: $ChineseOutput" -ForegroundColor Green
} else {
    Write-Host "   ❌ Failed to generate: $ChineseOutput" -ForegroundColor Red
}

Write-Host ""

# Example 3: Japanese
Write-Host "3. Generating Japanese audio..." -ForegroundColor Yellow
$JapaneseText = "こんにちは。Gemini テキスト読み上げシステムのマルチ言語デモンストレーションにようこそ。この技術は、様々な言語の文章を自然な音声に変換することができます。"
$JapaneseInstructions = "丁寧で分かりやすい日本語で、適切な間を取りながら読み上げてください"
$JapaneseVoice = "leda"
$JapaneseOutput = "japanese.wav"

Write-Host "   Language: Japanese" -ForegroundColor Gray
Write-Host "   Voice: $JapaneseVoice (female)" -ForegroundColor Gray
Write-Host "   Output: $JapaneseOutput" -ForegroundColor Gray

& gemini-tts --text $JapaneseText --speaker1 $JapaneseVoice --instructions $JapaneseInstructions --outputfile $JapaneseOutput

if (Test-Path $JapaneseOutput) {
    Write-Host "   ✅ Generated: $JapaneseOutput" -ForegroundColor Green
} else {
    Write-Host "   ❌ Failed to generate: $JapaneseOutput" -ForegroundColor Red
}

Write-Host ""

# Example 4: Spanish
Write-Host "4. Generating Spanish audio..." -ForegroundColor Yellow
$SpanishText = "¡Hola y bienvenidos a esta demostración multilingüe del sistema de texto a voz Gemini! Esta increíble tecnología puede convertir texto escrito en discurso natural en muchos idiomas diferentes."
$SpanishInstructions = "Lee en voz alta con un tono amigable y claro en español, con pronunciación natural"
$SpanishVoice = "erinome"
$SpanishOutput = "spanish.wav"

Write-Host "   Language: Spanish" -ForegroundColor Gray
Write-Host "   Voice: $SpanishVoice (female)" -ForegroundColor Gray
Write-Host "   Output: $SpanishOutput" -ForegroundColor Gray

& gemini-tts --text $SpanishText --speaker1 $SpanishVoice --instructions $SpanishInstructions --outputfile $SpanishOutput

if (Test-Path $SpanishOutput) {
    Write-Host "   ✅ Generated: $SpanishOutput" -ForegroundColor Green
} else {
    Write-Host "   ❌ Failed to generate: $SpanishOutput" -ForegroundColor Red
}

Write-Host ""

# Example 5: French
Write-Host "5. Generating French audio..." -ForegroundColor Yellow
$FrenchText = "Bonjour et bienvenue à cette démonstration multilingue du système de synthèse vocale Gemini. Cette technologie sophistiquée peut transformer n'importe quel texte écrit en parole naturelle."
$FrenchInstructions = "Lisez à haute voix avec un accent français authentique et une diction claire et élégante"
$FrenchVoice = "gacrux"
$FrenchOutput = "french.wav"

Write-Host "   Language: French" -ForegroundColor Gray
Write-Host "   Voice: $FrenchVoice (female)" -ForegroundColor Gray
Write-Host "   Output: $FrenchOutput" -ForegroundColor Gray

& gemini-tts --text $FrenchText --speaker1 $FrenchVoice --instructions $FrenchInstructions --outputfile $FrenchOutput

if (Test-Path $FrenchOutput) {
    Write-Host "   ✅ Generated: $FrenchOutput" -ForegroundColor Green
} else {
    Write-Host "   ❌ Failed to generate: $FrenchOutput" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Results Summary ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "Generated multilingual audio files:" -ForegroundColor White
$LanguageFiles = @("english.wav", "chinese.wav", "japanese.wav", "spanish.wav", "french.wav")
foreach ($File in $LanguageFiles) {
    if (Test-Path $File) {
        $FileInfo = Get-Item $File
        Write-Host "✅ $File ($($FileInfo.Length) bytes)" -ForegroundColor Green
    } else {
        Write-Host "❌ $File (failed)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "🌍 Language Support:" -ForegroundColor Blue
Write-Host "  • Latin scripts: English, Spanish, French, German, Italian, Portuguese" -ForegroundColor Gray
Write-Host "  • Chinese: Traditional and Simplified characters with proper tones" -ForegroundColor Gray
Write-Host "  • Japanese: Hiragana, Katakana, and Kanji with correct pronunciation" -ForegroundColor Gray
Write-Host "  • Other scripts: Korean, Arabic, Russian, and many more" -ForegroundColor Gray
Write-Host ""
Write-Host "💡 Tips for multilingual TTS:" -ForegroundColor Green
Write-Host "  ✓ Use language-appropriate instructions for best results" -ForegroundColor Gray
Write-Host "  ✓ Test different voices to find the best match for each language" -ForegroundColor Gray
Write-Host "  ✓ Ensure text files use UTF-8 encoding for proper character support" -ForegroundColor Gray
Write-Host "  ✓ Process each language separately for optimal pronunciation" -ForegroundColor Gray
Write-Host ""
Write-Host "🎧 Listen to the generated files to experience multilingual TTS capabilities!" -ForegroundColor Yellow