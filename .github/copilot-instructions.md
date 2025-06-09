# Gemini TTS CLI Development Guidelines

This is a .NET 8.0 C# command-line application that provides text-to-speech functionality using Google's Gemini TTS API. The tool supports multiple voice options, cross-platform deployment, and both NuGet distribution and self-contained executables. Please follow these guidelines when contributing:

## Code Standards

### Required Before Each Commit
- Run `dotnet build` to ensure the project compiles without errors
- Test basic functionality with `dotnet run -- --help` to verify CLI interface works
- For major changes, test with actual API calls using `dotnet run -- --text "test" --speaker1 zephyr`

### Development Flow
- Restore dependencies: `dotnet restore`
- Build: `dotnet build`
- Run: `dotnet run -- [options]`
- Pack for NuGet: `dotnet pack --configuration Release`
- Test cross-platform builds: Use the provided GitHub Actions workflows

## Repository Structure
- `gemini-tts-cli.cs`: Main application file containing all CLI logic, API integration, and audio processing
- `gemini-tts-cli.csproj`: Project configuration with package metadata and build settings
- `scripts/`: Batch processing scripts for generating multiple TTS files
  - `generate-all.sh`: Bash script for Unix/Linux systems
  - `generate-all.ps1`: PowerShell script for Windows systems
- `.github/workflows/`: CI/CD automation
  - `test.yml`: Cross-platform build and basic functionality tests
  - `publish.yml`: Automated publishing to NuGet and GitHub releases
- `README.md`: Comprehensive documentation including installation and usage
- `LICENSE`: MIT license

## Key Technologies & Dependencies
- **Framework**: .NET 8.0 with C# top-level programs
- **CLI Framework**: System.CommandLine (v2.0.0-beta4.22272.1) for argument parsing
- **Audio Processing**: NAudio (v2.2.1) for WAV file generation and PCM audio handling
- **API Integration**: Google Gemini 2.5 Flash Preview TTS model
- **Serialization**: System.Text.Json for API request/response handling

## Architecture Guidelines

### Single-File Design
- The application uses a single-file architecture (`gemini-tts-cli.cs`) for simplicity
- All functionality is contained in one file: CLI setup, API calls, audio processing, and error handling
- Maintain this pattern when adding new features

### Voice Management
- Voices are categorized into `femaleVoices` and `maleVoices` arrays
- Always validate voice names against the `allowedVoices` HashSet
- When adding new voices, update both the categorization arrays and ensure case-insensitive matching

### Error Handling & Retry Logic
- Implement retry mechanisms for API calls (currently 3 attempts with 1-second delays)
- Provide clear, user-friendly error messages with actionable guidance
- Use appropriate exit codes for different error scenarios

### API Integration
- Use the Gemini 2.5 Flash Preview TTS model (`gemini-2.5-flash-preview-tts`)
- Maintain the existing JSON payload structure for API requests
- Handle Base64 audio data conversion and PCM format requirements

## Development Guidelines

1. **Follow .NET Best Practices**
   - Use implicit usings and nullable reference types (already enabled)
   - Leverage top-level programs for simplicity
   - Use proper async/await patterns for HTTP operations

2. **Maintain CLI Consistency**
   - Keep existing command structure and option aliases
   - Ensure help text is clear and comprehensive
   - Maintain backward compatibility with existing parameters

3. **Audio Processing Standards**
   - Use 24kHz sample rate, 16-bit depth, mono channel format
   - Properly handle PCM to WAV conversion using NAudio
   - Validate audio output before writing to files

4. **Configuration Management**
   - API key must be provided via `GEMINI_API_KEY` environment variable
   - Support both global tool and self-contained deployment modes
   - Maintain cross-platform compatibility

5. **Testing & Quality Assurance**
   - Test CLI help and basic commands without API key requirements
   - Verify build artifacts for all target platforms
   - Ensure proper exit codes and error handling

## Distribution & Deployment

### Dual Distribution Strategy
- **NuGet Global Tool**: For easy installation via `dotnet tool install -g GeminiTtsCli`
- **Self-Contained Executables**: For standalone distribution across platforms

### Supported Platforms
- Windows x64
- Linux x64 and ARM64
- macOS x64 and ARM64

### Release Process
- Version updates are managed in `gemini-tts-cli.csproj`
- GitHub Actions automatically handles cross-platform builds and publishing
- Tags trigger automated releases to both NuGet and GitHub

## Common Operations

### Adding New Voices
1. Add voice name to appropriate `femaleVoices` or `maleVoices` array
2. Test with the new voice using `dotnet run -- --text "test" --speaker1 [newvoice]`
3. Update documentation if needed

### Modifying API Integration
1. Maintain backward compatibility with existing API structure
2. Test with various input scenarios including edge cases
3. Ensure proper error handling for API failures

### Updating Dependencies
1. Use compatible versions that support .NET 8.0
2. Test cross-platform builds after dependency updates
3. Update both regular and self-contained deployment configurations

## Scripts Usage
The `scripts/` directory contains batch processing examples:
- Use as reference for bulk TTS generation
- Maintain consistency with main CLI interface
- Support both PowerShell and Bash environments

## Security Considerations
- Never commit API keys or sensitive data
- Validate all user inputs, especially file paths
- Use secure HTTP clients with proper timeout handling
- Maintain secure defaults for all configuration options