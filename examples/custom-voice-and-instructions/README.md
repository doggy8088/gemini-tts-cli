# Custom Voice and Instructions Example

This example demonstrates how to use specific voices and custom instructions with the Gemini TTS CLI tool.

## What This Example Does

- Converts text using a specific female voice (`zephyr`)
- Uses custom instructions to control the tone and style
- Demonstrates voice selection capabilities
- Outputs to a custom filename

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

- Creates multiple WAV files demonstrating different voices and instructions:
  - `female-enthusiastic.wav` - Female voice with enthusiastic tone
  - `male-professional.wav` - Male voice with professional tone
  - `female-storytelling.wav` - Female voice for storytelling

## Voice Categories

### Female Voices
- achernar, aoede, autonoe, callirrhoe, despina, erinome, gacrux, kore
- laomedeia, leda, sulafat, zephyr, pulcherrima, vindemiatrix

### Male Voices  
- achird, algenib, algieba, alnilam, charon, enceladus, fenrir, iapetus
- orus, puck, rasalgethi, sadachbia, sadaltager, schedar, umbriel, zubenelgenubi

## Custom Instructions Examples

The example shows how different instructions affect the speech output:

1. **Enthusiastic Presentation**: "Read aloud in an enthusiastic, energetic, and engaging tone as if presenting to an audience"
2. **Professional Narration**: "Read aloud in a calm, professional, and authoritative tone suitable for business presentations"
3. **Storytelling Style**: "Read aloud in a warm, expressive, and captivating tone as if telling a story to children"

## Command Explanation

The example runs commands like:
```bash
gemini-tts --instructions "Read aloud in an enthusiastic, energetic, and engaging tone" \
           --speaker1 "zephyr" \
           --text "Welcome to this amazing demonstration!" \
           --outputfile "female-enthusiastic.wav"
```

Parameters used:
- `--instructions` (or `-i`): Custom instructions for speech style
- `--speaker1` (or `-s`): Specific voice name
- `--text` (or `-t`): The text to convert
- `--outputfile` (or `-o`): Custom output filename

## Next Steps

- Try the [voice-listing](../voice-listing/) example to see all available voices
- Explore the [batch-processing](../batch-processing/) example for processing multiple texts