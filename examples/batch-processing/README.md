# Batch Processing Example

This example demonstrates how to process multiple text lines from a file using the Gemini TTS CLI tool.

## What This Example Does

- Reads text lines from a sample text file
- Converts each line to a separate WAV file
- Demonstrates batch processing capabilities
- Shows numbered output file naming

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

- Creates numbered WAV files: `sample-text-01.wav`, `sample-text-02.wav`, etc.
- Each file contains the spoken version of one line from the input file
- Console output showing the processing of each line

## Input File Format

The example uses `sample-text.txt` with these contents:
- Simple sentences for demonstration
- Each line becomes a separate audio file
- Empty lines and symbol-only lines are automatically filtered out

## Command Explanation

The example runs:
```bash
gemini-tts --file "sample-text.txt" --speaker1 "zephyr" --instructions "Read aloud in a clear, pleasant voice"
```

Parameters used:
- `--file` (or `-f`): Input text file path
- `--speaker1` (or `-s`): Voice to use for all lines
- `--instructions` (or `-i`): Reading style instructions
- Output files are automatically named based on input filename

## File Naming Convention

When using `--file` without `--merge`, output files are named:
- `{input-filename-without-extension}-01.wav`
- `{input-filename-without-extension}-02.wav`
- etc.

For input file `sample-text.txt`, outputs will be:
- `sample-text-01.wav`
- `sample-text-02.wav` 
- `sample-text-03.wav`

## Supported Input Formats

- `.txt` files: Plain text files
- `.md` files: Markdown files (text content is extracted)

## Text Processing Rules

The CLI automatically:
- Filters out empty lines
- Skips lines containing only symbols/punctuation
- Processes each remaining line as separate audio

## Next Steps

- Try the [batch-with-merge](../batch-with-merge/) example to combine all outputs into one file
- See the [concurrent-batch](../concurrent-batch/) example for faster processing with multiple API calls