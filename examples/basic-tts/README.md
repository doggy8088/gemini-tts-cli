# Basic Text-to-Speech Example

This example demonstrates the simplest usage of the Gemini TTS CLI tool - converting a single text string to speech with default settings.

## What This Example Does

- Converts a simple text string to speech
- Uses default voice (randomly selected)
- Uses default instructions ("Read aloud in a warm, professional and friendly tone")
- Outputs to `output.wav` file

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

- Creates an `output.wav` file containing the spoken text
- Console output showing the TTS generation process

## Command Explanation

The example runs this command:
```bash
gemini-tts --text "Hello world! This is a basic text-to-speech example using Gemini TTS."
```

This uses:
- `--text` (or `-t`): The text to convert to speech
- Default voice: A randomly selected voice from available options
- Default instructions: "Read aloud in a warm, professional and friendly tone"
- Default output: `output.wav`

## Next Steps

- Try the [custom-voice-and-instructions](../custom-voice-and-instructions/) example to learn about voice selection and custom instructions
- See the [voice-listing](../voice-listing/) example to explore available voices