# Batch Processing with Merge Example

This example demonstrates how to process multiple text lines from a file and merge all outputs into a single WAV file.

## What This Example Does

- Reads text lines from a sample text file
- Converts each line to speech
- Automatically merges all audio into one continuous WAV file
- Demonstrates the `--merge` option for batch processing

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

- Creates a single merged WAV file: `story-merged.wav`
- Contains continuous audio of all text lines spoken in sequence
- Console output showing the processing and merging steps

## Input File Format

The example uses `story.txt` with a short story broken into paragraphs:
- Each line represents a paragraph or sentence
- Lines are processed sequentially and merged into one audio file
- Empty lines are automatically filtered out

## Command Explanation

The example runs:
```bash
gemini-tts --file "story.txt" --speaker1 "callirrhoe" --merge --outputfile "story-merged.wav" --instructions "Read aloud in a warm, storytelling voice"
```

Parameters used:
- `--file` (or `-f`): Input text file path
- `--merge` (or `-m`): Merge all audio outputs into one file
- `--outputfile` (or `-o`): Custom name for the merged output
- `--speaker1` (or `-s`): Voice for the entire story
- `--instructions` (or `-i`): Reading style instructions

## Merge vs. No Merge

**Without --merge** (regular batch processing):
- Creates: `story-01.wav`, `story-02.wav`, `story-03.wav`, etc.
- Each file contains one line of text

**With --merge** (this example):
- Creates: `story-merged.wav` (or custom filename)
- Single file contains all lines in continuous sequence

## Use Cases

Perfect for:
- **Audio books**: Convert entire chapters or stories
- **Presentations**: Create continuous narration from script
- **Podcasts**: Generate audio content from written material
- **Educational content**: Convert lessons into audio format

## Audio Quality

- All individual audio segments use the same voice and settings
- Segments are seamlessly concatenated without gaps
- Maintains consistent audio format throughout

## Next Steps

- Try the [concurrent-batch](../concurrent-batch/) example for faster processing with multiple API calls
- See the [file-merging](../file-merging/) example to merge existing WAV files