# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Core Development
- `dotnet restore` - Restore dependencies
- `dotnet build gemini-tts-cli.csproj` - Build the project (run before each commit)
- `dotnet run -- [options]` - Run the CLI tool directly
- `dotnet run -- --help` - Test CLI interface
- `dotnet run -- --text "test" --speaker1 zephyr` - Test with actual API calls

### Testing
- `dotnet test` - Run all tests
- `dotnet test --filter "ClassName=AudioProcessingTests"` - Run specific test class
- `dotnet test --logger trx --collect:"XPlat Code Coverage"` - Run with coverage

### Publishing
- `dotnet pack --configuration Release` - Create NuGet package
- `dotnet publish --configuration Release --self-contained true --runtime win-x64 -p:PublishSelfContained=true` - Self-contained Windows build
- `dotnet publish --configuration Release --self-contained true --runtime linux-x64 -p:PublishSelfContained=true` - Self-contained Linux build
- `dotnet publish --configuration Release --self-contained true --runtime osx-x64 -p:PublishSelfContained=true` - Self-contained macOS x64 build
- `dotnet publish --configuration Release --self-contained true --runtime osx-arm64 -p:PublishSelfContained=true` - Self-contained macOS ARM64 build

## Architecture Overview

This is a single-file .NET 8.0 CLI application (`gemini-tts-cli.cs`) that provides text-to-speech functionality using Google's Gemini TTS API. The architecture is intentionally simple with all functionality contained in one file.

### Key Components

**Main Application (`gemini-tts-cli.cs`)**:
- CLI command setup using System.CommandLine
- Voice management with predefined male/female voice arrays
- API integration with Google Gemini 2.5 Flash Preview TTS
- Audio processing using NAudio for WAV file generation
- Batch processing with concurrency support
- WAV file merging capabilities
- Stdout output support for piping

**Helper Class (`GeminiTtsHelpers`)**:
- `GenerateSingleTts()` - Core TTS API integration with retry logic
- `ProcessBatchTts()` - Batch processing with concurrency control
- `MergeWavFiles()` - WAV file concatenation
- Audio format constants (24kHz, 16-bit, mono)

### Dual Distribution Strategy

The project supports two build modes controlled by `PublishSelfContained`:
1. **Global Tool**: NuGet package installed via `dotnet tool install -g GeminiTtsCli`
2. **Self-Contained**: Standalone executables for Windows, Linux, macOS (x64/ARM64)

### Voice Management System

Voices are organized in predefined arrays:
- `femaleVoices`: 14 voices (achernar, aoede, autonoe, etc.)
- `maleVoices`: 16 voices (achird, algenib, algieba, etc.)
- `allowedVoices`: HashSet for case-insensitive validation

### API Integration Pattern

- Uses Google Gemini 2.5 Flash Preview TTS model
- Implements retry logic (3 attempts with 1-second delays)
- Handles Base64 PCM audio data conversion
- Supports batch processing with configurable concurrency
- Environment variable configuration via `GEMINI_API_KEY`

### Command Structure

- **Root Command**: Main TTS conversion with text/file input validation
- **list-voices**: Subcommand for voice enumeration
- **merge**: Subcommand for WAV file merging with glob pattern support

### Audio Processing

- Standard format: 24kHz sample rate, 16-bit depth, mono channel
- PCM to WAV conversion using NAudio's `RawSourceWaveStream`
- File merging with format compatibility checking
- Stdout output support for piping (`-o -`)

## Testing Structure

The test project (`tests/GeminiTtsCli.Tests.csproj`) includes:
- **Unit Tests**: Individual component testing
- **Integration Tests**: End-to-end scenarios
- **Audio Processing Tests**: WAV file manipulation
- **Mock Testing**: HTTP client mocking for API calls

Test dependencies: xUnit, Moq, NAudio, System.CommandLine

## Environment Requirements

- .NET 8.0 runtime
- `GEMINI_API_KEY` environment variable for API access
- Cross-platform compatibility (Windows, Linux, macOS)

## Development Guidelines from Copilot Instructions

### Required Before Each Commit
- Run `dotnet build` to ensure compilation
- Test basic functionality with `dotnet run -- --help`
- For major changes, test with actual API calls

### Code Standards
- Single-file architecture maintained in `gemini-tts-cli.cs`
- Voice validation against `allowedVoices` HashSet
- Retry mechanisms for API calls (3 attempts)
- Clear error messages with actionable guidance
- Async/await patterns for HTTP operations

### Audio Processing Standards
- Use 24kHz sample rate, 16-bit depth, mono channel format
- Proper PCM to WAV conversion using NAudio
- Validate audio output before writing to files

### Configuration Management
- API key via `GEMINI_API_KEY` environment variable only
- Support both global tool and self-contained deployment modes
- Maintain cross-platform compatibility

## CI/CD Integration

GitHub Actions workflows:
- **test.yml**: Cross-platform build and basic functionality tests
- **publish.yml**: Automated publishing to NuGet and GitHub releases

Releases are triggered by git tags following pattern `v*.*.*` (e.g., `git tag v0.7.0 && git push origin v0.7.0`).

## Important Files

- `gemini-tts-cli.cs` - Main application (single file containing all logic)
- `gemini-tts-cli.csproj` - Project configuration with dual build support
- `scripts/generate-all.sh` - Bash script for batch processing examples
- `scripts/generate-all.ps1` - PowerShell equivalent for Windows
- `examples/` - Comprehensive usage examples for different scenarios
- `.github/copilot-instructions.md` - Detailed development guidelines
