# Voice Listing Example

This example demonstrates how to list all available voices in the Gemini TTS CLI tool.

## What This Example Does

- Shows all available female voices
- Shows all available male voices
- Demonstrates the `list-voices` command
- Provides a reference for voice selection in other examples

## Prerequisites

1. Install the Gemini TTS CLI tool:
   ```bash
   dotnet tool install -g GeminiTtsCli
   ```

**Note:** This example does not require an API key since it only lists available voices without making API calls.

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

The command will display:
- A list of all female voices (14 voices)
- A list of all male voices (16 voices)
- Total count of available voices

## Voice Categories

### Female Voices (14 total)
- achernar, aoede, autonoe, callirrhoe, despina, erinome, gacrux
- kore, laomedeia, leda, pulcherrima, sulafat, vindemiatrix, zephyr

### Male Voices (16 total)
- achird, algenib, algieba, alnilam, charon, enceladus, fenrir
- iapetus, orus, puck, rasalgethi, sadachbia, sadaltager, schedar, umbriel, zubenelgenubi

## Command Explanation

The example runs:
```bash
gemini-tts list-voices
```

This command:
- Lists all available voices organized by gender
- Does not require API authentication
- Provides reference for the `--speaker1` parameter in other commands

## Using Voice Names

Once you know the available voices, you can use them in TTS commands:
```bash
# Using a female voice
gemini-tts --speaker1 "zephyr" --text "Hello from a female voice"

# Using a male voice  
gemini-tts --speaker1 "achird" --text "Hello from a male voice"
```

## Next Steps

- Try the [custom-voice-and-instructions](../custom-voice-and-instructions/) example to use specific voices
- See the [basic-tts](../basic-tts/) example for simple text conversion