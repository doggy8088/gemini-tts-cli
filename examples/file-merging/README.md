# File Merging Example

This example demonstrates how to merge existing WAV files using the Gemini TTS CLI merge command.

## What This Example Does

- Creates sample WAV files for demonstration
- Shows different glob patterns for file merging
- Demonstrates the standalone `merge` command
- Merges multiple WAV files into single outputs

## Prerequisites

1. Set your Gemini API key as an environment variable (for creating sample files):
   - **Windows (PowerShell):** `$env:GEMINI_API_KEY = "your-api-key-here"`
   - **Windows (CMD):** `set GEMINI_API_KEY=your-api-key-here`
   - **Linux/macOS:** `export GEMINI_API_KEY="your-api-key-here"`

2. Install the Gemini TTS CLI tool:
   ```bash
   dotnet tool install -g GeminiTtsCli
   ```

**Note:** The merge command itself does not require an API key, but this example creates sample files first.

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

The example creates sample files and then demonstrates merging:
- `intro-*.wav` files (sample introductions)
- `lesson-*.wav` files (sample lessons)
- `all-merged.wav` (all files combined)
- `intro-merged.wav` (intro files only)
- `lesson-merged.wav` (lesson files only)

## Merge Command Patterns

The example demonstrates different glob patterns:

### 1. Merge All WAV Files
```bash
gemini-tts merge '*.wav' --outputfile 'all-merged.wav'
```

### 2. Merge Specific Pattern
```bash
gemini-tts merge 'intro-*.wav' --outputfile 'intro-merged.wav'
gemini-tts merge 'lesson-*.wav' --outputfile 'lesson-merged.wav'
```

### 3. Recursive Pattern (searches subdirectories)
```bash
gemini-tts merge '**/*.wav' --outputfile 'recursive-merged.wav'
```

## Glob Pattern Reference

| Pattern | Description | Example Files Matched |
|---------|-------------|----------------------|
| `*.wav` | All WAV files in current directory | `file1.wav`, `file2.wav` |
| `intro-*.wav` | WAV files starting with "intro-" | `intro-01.wav`, `intro-02.wav` |
| `**/*.wav` | All WAV files recursively | Files in subdirectories too |
| `lesson??-*.wav` | More specific patterns | `lesson01-*.wav`, `lesson02-*.wav` |

## Command Explanation

The merge command syntax:
```bash
gemini-tts merge <pattern> [--outputfile <filename>]
```

Parameters:
- `<pattern>`: Glob pattern to match WAV files (required)
- `--outputfile` (or `-o`): Output filename (optional, defaults to `merged.wav`)

## Audio Processing Details

- Files are concatenated in alphabetical order
- All files are converted to match the first file's audio format
- Warning shown if files have different formats
- Output maintains audio quality of source files

## Use Cases

Perfect for:
- **Combining recordings**: Merge multiple recorded segments
- **Audio production**: Combine intro, content, and outro files
- **Podcast creation**: Merge different segments or episodes
- **Educational content**: Combine lessons into complete courses

## File Organization Tips

For best results with merging:
- Use numbered prefixes: `01-intro.wav`, `02-content.wav`, `03-outro.wav`
- Group by type: `intro-*.wav`, `lesson-*.wav`, `outro-*.wav`
- Consistent naming helps with pattern matching

## Next Steps

- Try the [batch-with-merge](../batch-with-merge/) example for automatic merging during TTS generation
- See the [concurrent-batch](../concurrent-batch/) example for faster processing