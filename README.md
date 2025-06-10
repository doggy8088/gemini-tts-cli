# Gemini TTS CLI

A command-line interface tool for text-to-speech conversion using Google's Gemini TTS API.

## Features

- Convert text to speech using Google Gemini TTS API
- Multiple voice options (male and female voices)
- Support for custom instructions
- Output to WAV format
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

```bash
gemini-tts --text "Text to convert" [--instructions "Your instructions"] [--speaker1 <voice-name>] [--outputfile output.wav]
```

### Parameters

- `--text` (required): Text to convert to speech
- `--instructions` (optional): Instructions for the TTS conversion (default: "Read aloud in a warm, professional and friendly tone")
- `--speaker1` (optional): Voice name for the speaker (default: random selection from available voices)
- `--outputfile` (optional): Output WAV filename (default: output.wav)

### Available Voices

#### Female Voices

- achernar, aoede, autonoe, callirrhoe, despina, erinome, gacrux, kore
- laomedeia, leda, sulafat, zephyr, pulcherrima, vindemiatrix

#### Male Voices

- achird, algenib, algieba, alnilam, charon, enceladus, fenrir, iapetus
- orus, puck, rasalgethi, sadachbia, sadaltager, schedar, umbriel, zubenelgenubi

### Examples

With custom instructions and specific voice:
```bash
gemini-tts --instructions "Read aloud in a warm, professional and friendly tone" --speaker1 achird --text "大家好，我是 Will 保哥。" --outputfile my-name-is-will.wav
```

With minimal required parameters (uses defaults):
```bash
gemini-tts --text "Hello, this is a test of the Gemini TTS system"
```

With specific voice but default instructions:
```bash
gemini-tts --speaker1 zephyr --text "Hello, this is a test of the Gemini TTS system" --outputfile greeting.wav
```

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
git tag v0.3.0
git push origin v0.3.0
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
