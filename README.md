# Gemini TTS CLI

A command-line interface tool for text-to-speech conversion using Google's Gemini TTS API.

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/doggy8088/gemini-tts-cli)

## Features

- Convert text to speech using Google Gemini TTS API
- Multiple voice options (male and female voices)
- Support for custom instructions
- Output to WAV format or stdout
- Merge multiple WAV files into one with glob pattern support
- Batch processing from text/markdown files
- Concurrency support for batch TTS
- Cross-platform support (Windows, Linux, macOS)

## Installation

### Via .NET Global Tool (Recommended)

```bash
dotnet tool install -g GeminiTtsCli
```

### Manual Installation

Download the appropriate binary for your platform from the [releases page](https://github.com/doggy8088/gemini-tts-cli/releases).

## Prerequisites

1. **Google AI Studio API Key**: You need to obtain an API key from [Google AI Studio](https://makersuite.google.com/app/apikey)
2. **Environment Variable**: Set the `GEMINI_API_KEY` environment variable with your API key

### Setting up the API Key

#### Windows (PowerShell)

```powershell
$env:GEMINI_API_KEY = "your-api-key-here"
```

#### Windows (Command Prompt)

```cmd
set GEMINI_API_KEY=your-api-key-here
```

#### Linux/macOS

```bash
export GEMINI_API_KEY="your-api-key-here"
```

To make it permanent, add the export line to your shell profile (`.bashrc`, `.zshrc`, etc.).

## Usage

### Single Text to Speech

```bash
gemini-tts -t "Text to convert" [-i "Your instructions"] [-s <voice-name>] [-o output.wav]
```

### Batch Processing from File

```bash
gemini-tts -f "input.txt" [-i "Your instructions"] [-s <voice-name>] [-m] [-c 20] [-o output.wav]
```

### Merge WAV Files

```bash
gemini-tts merge <glob-pattern> [-o <output-file>]
```

### List Available Voices

```bash
gemini-tts list-voices
```

## Parameters

- `-t`, `--text` (optional): Text to convert to speech (required if no `-f`)
- `-f`, `--file` (optional): File path for batch processing (.txt or .md files, required if no `-t`)
- `-i`, `--instructions` (optional): Instructions for the TTS conversion (default: "Read aloud in a warm, professional and friendly tone")
- `-s`, `--speaker1` (optional): Voice name for the speaker (default: random selection from available voices)
- `-o`, `--outputfile` (optional): Output WAV filename (default: output.wav). Use "-" for stdout output
- `-c`, `--concurrency` (optional): Concurrent API requests for batch processing (default: 1)
- `-m`, `--merge` (optional): Merge all outputs into single file for batch processing

#### Merge Command Parameters

- `<glob-pattern>` (required): Pattern to match WAV files (e.g., `*.wav`, `trial03-*.wav`, `**/*.wav`)
- `-o`, `--outputfile` (optional): Output WAV filename

## Available Voices

### Female Voices

- achernar, aoede, autonoe, callirrhoe, despina, erinome, gacrux, kore
- laomedeia, leda, sulafat, zephyr, pulcherrima, vindemiatrix

### Male Voices

- achird, algenib, algieba, alnilam, charon, enceladus, fenrir, iapetus
- orus, puck, rasalgethi, sadachbia, sadaltager, schedar, umbriel, zubenelgenubi

## Examples

With custom instructions and specific voice:
```bash
gemini-tts -i "Read aloud in a warm, professional and friendly tone" -s achird -t "大家好，我是 Will 保哥。" -o my-name-is-will.wav
```

With minimal required parameters (uses defaults):
```bash
gemini-tts -t "Hello, this is a test of the Gemini TTS system"
```

With specific voice but default instructions:
```bash
gemini-tts -s zephyr -t "Hello, this is a test of the Gemini TTS system" -o greeting.wav
```

Batch processing from file, with merge and concurrency:
```bash
gemini-tts -f "test.txt" -s zephyr -m -c 5 -o batch-merged.wav
```

Batch processing from file, without merge (outputs numbered files):
```bash
gemini-tts -f "test.txt" -s zephyr -c 3
# Output: test-01.wav, test-02.wav, ...
```

List all available voices:
```bash
gemini-tts list-voices
```

Merge all WAV files in current directory:
```bash
gemini-tts merge '*.wav'
# Creates: merged.wav
```

Merge specific pattern with custom output:
```bash
gemini-tts merge 'trial03-*.wav' -o trial03-merged.wav
# Creates: trial03-merged.wav
```

Merge all WAV files recursively:
```bash
gemini-tts merge '**/*.wav' -o all-merged.wav
# Creates: all-merged.wav
```

Output to stdout (pipe to file or other processes):
```bash
gemini-tts -t "Hello world" -o - > output.wav
# or pipe to another command
gemini-tts -t "Hello world" -o - | aplay
```

## Notes

- All input files for batch must have `.txt` or `.md` extension
- All input files for merge must have `.wav` extension
- Files with different audio formats will be converted to match the first file's format
- The pattern must include `*.wav` to ensure only WAV files are processed
- Recursive patterns (`**/*.wav`) will search subdirectories
- Either `--text` or `--file` must be provided, but not both
- API key must be set in the `GEMINI_API_KEY` environment variable

## Development

### Building from Source

1. Clone the repository
2. Restore dependencies: `dotnet restore`
3. Build: `dotnet build`
4. Run: `dotnet run -- --text "Hello world"`

### Publishing

The project supports two types of builds:

#### 1. Global Tool (for NuGet distribution)

```bash
dotnet pack --configuration Release
```

This creates a .NET global tool package that can be installed via `dotnet tool install -g GeminiTtsCli`.

#### 2. Self-Contained Executables (for standalone distribution)

For Windows x64:

```bash
dotnet publish --configuration Release --self-contained true --runtime win-x64 -p:PublishSelfContained=true
```

For Linux x64:

```bash
dotnet publish --configuration Release --self-contained true --runtime linux-x64 -p:PublishSelfContained=true
```

For macOS x64:

```bash
dotnet publish --configuration Release --self-contained true --runtime osx-x64 -p:PublishSelfContained=true
```

For macOS ARM64:

```bash
dotnet publish --configuration Release --self-contained true --runtime osx-arm64 -p:PublishSelfContained=true
```

The project includes automated GitHub Actions workflows for:

- Building cross-platform binaries
- Publishing to NuGet Gallery
- Creating GitHub releases

To trigger a release, create and push a git tag:

```bash
git tag v0.7.0
git push origin v0.7.0
```

## License

MIT License - see LICENSE file for details.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## Support

If you encounter any issues or have questions, please [open an issue](https://github.com/doggy8088/gemini-tts-cli/issues) on GitHub.

## Acknowledgments

Google Cloud credits are provided for this project. #AISprint

We thank Google Cloud for supporting this project with credits that help make development and testing possible.
