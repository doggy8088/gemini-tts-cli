# Multilingual Text-to-Speech Example

This example demonstrates how the Gemini TTS CLI can handle multiple languages and different writing systems.

## What This Example Does

- Converts text in different languages to speech
- Demonstrates automatic language detection and pronunciation
- Shows how to handle various scripts (Latin, Chinese, Japanese, etc.)
- Uses appropriate voices and instructions for different languages

## Prerequisites

1. Set your Gemini API key as an environment variable:
   - **Windows (PowerShell):** `$env:GEMINI_API_KEY = "your-api-key-here"`
   - **Windows (CMD):** `set GEMINI_API_KEY=your-api-key-here`
   - **Linux/macOS:** `export GEMINI_API_KEY="your-api-key-here"`

2. Install the Gemini TTS CLI tool:
   ```bash
   dotnet tool install -g GeminiTtsCli
   ```

## Running the Example

### Using Bash (Linux/macOS/WSL)
```bash
chmod +x run.sh
./run.sh
```

### Using PowerShell (Windows/Cross-platform)
```powershell
.\run.ps1
```

## Expected Output

The example creates multiple WAV files for different languages:
- `english.wav` - English text with professional tone
- `chinese.wav` - Traditional Chinese text with warm tone
- `japanese.wav` - Japanese text with polite tone
- `spanish.wav` - Spanish text with friendly tone
- `french.wav` - French text with elegant tone

## Supported Languages

The Gemini TTS system can handle various languages automatically, including:

### Latin Script Languages
- **English**: Native pronunciation and intonation
- **Spanish**: Proper Spanish pronunciation and rhythm
- **French**: Correct French phonetics and accents
- **German**: German pronunciation rules and sounds
- **Italian**: Italian vowel sounds and consonant clusters

### Non-Latin Scripts
- **Chinese (Traditional/Simplified)**: Mandarin pronunciation with proper tones
- **Japanese**: Hiragana, Katakana, and Kanji with correct pronunciation
- **Korean**: Hangul script with Korean phonetics
- **Arabic**: Right-to-left text with Arabic pronunciation
- **Russian**: Cyrillic script with Russian sounds

## Language-Specific Instructions

The example shows how to customize instructions for different languages:

### English
```bash
--instructions "Read aloud in a professional, clear American English accent"
```

### Chinese
```bash
--instructions "以溫暖、自然的語調朗讀，適合教學使用"
```

### Japanese  
```bash
--instructions "丁寧で分かりやすい日本語で読み上げてください"
```

### Spanish
```bash
--instructions "Lee en voz alta con un tono amigable y claro en español"
```

## Voice Selection Tips

### For Different Languages
- Some voices may work better with certain languages
- Test different voices to find the best match for your content
- Consider the gender and tone that fits your content

### Recommended Approach
- **English content**: Any voice works well
- **Asian languages**: Try different voices to find natural pronunciation
- **European languages**: Most voices handle these well
- **Mixed content**: Use consistent voice throughout

## Sample Content

The example includes sample text in multiple languages:

- **English**: Technology and AI description
- **Chinese**: Educational content about NotebookLM (from existing scripts)
- **Japanese**: Polite introduction and explanation
- **Spanish**: Warm greeting and description
- **French**: Elegant introduction to TTS technology

## Command Examples

Basic multilingual conversion:
```bash
# English
gemini-tts --text "Hello world" --speaker1 "zephyr" --outputfile "hello-en.wav"

# Chinese
gemini-tts --text "你好世界" --speaker1 "callirrhoe" --outputfile "hello-zh.wav"

# Japanese
gemini-tts --text "こんにちは世界" --speaker1 "leda" --outputfile "hello-ja.wav"
```

With language-specific instructions:
```bash
gemini-tts --text "Bonjour le monde" --speaker1 "erinome" --instructions "Lisez à haute voix avec un accent français authentique" --outputfile "hello-fr.wav"
```

## Technical Notes

### Character Encoding
- Ensure your text files use UTF-8 encoding for proper character support
- The CLI handles Unicode characters correctly

### Audio Quality
- All languages produce the same high-quality 24kHz audio
- Pronunciation accuracy depends on the language and content complexity

### Mixing Languages
- Avoid mixing multiple languages in a single text line for best results
- Process each language separately for optimal pronunciation

## Use Cases

Perfect for:
- **Educational content**: Language learning materials
- **International presentations**: Multi-language audio versions
- **Accessibility**: Audio content for global audiences
- **Documentation**: User guides in multiple languages
- **Cultural content**: Preserving languages in audio format

## Next Steps

- Try creating audio content in your native language
- Experiment with different voices for the same language
- Combine with [batch-processing](../batch-processing/) for multilingual documents