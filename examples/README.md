# Gemini TTS CLI Examples

This folder contains comprehensive examples demonstrating all features and use cases of the Gemini TTS CLI tool. Each example includes detailed documentation, cross-platform scripts (bash and PowerShell), and sample data files.

## 📂 Available Examples

### [1. Basic TTS](./basic-tts/)
**Simple text-to-speech conversion with default settings**
- Convert a single text string to speech
- Uses default voice and instructions
- Perfect for getting started
- Files: `README.md`, `run.sh`, `run.ps1`

### [2. Custom Voice and Instructions](./custom-voice-and-instructions/)
**Demonstrates voice selection and custom instructions**
- Shows different voice options (male/female)
- Custom instruction examples for different tones
- Multiple audio outputs with different styles
- Files: `README.md`, `run.sh`, `run.ps1`

### [3. Voice Listing](./voice-listing/)
**Lists all available voices**
- Shows all female and male voices
- Provides voice selection reference
- No API key required
- Files: `README.md`, `run.sh`, `run.ps1`

### [4. Batch Processing](./batch-processing/)
**Process multiple text lines from a file**
- Converts text file to multiple audio files
- Demonstrates file input processing
- Automatic line filtering and numbering
- Files: `README.md`, `run.sh`, `run.ps1`, `sample-text.txt`

### [5. Batch with Merge](./batch-with-merge/)
**Batch processing with merged output**
- Processes multiple lines and combines into one file
- Perfect for audio books and presentations
- Continuous audio playback
- Files: `README.md`, `run.sh`, `run.ps1`, `story.txt`

### [6. File Merging](./file-merging/)
**Merge existing WAV files using glob patterns**
- Demonstrates the standalone merge command
- Shows different glob pattern examples
- Useful for combining audio segments
- Files: `README.md`, `run.sh`, `run.ps1`

### [7. Concurrent Batch](./concurrent-batch/)
**High-performance batch processing with concurrency**
- Demonstrates concurrent API requests
- Performance comparison between different concurrency levels
- Optimal for large-scale audio generation
- Files: `README.md`, `run.sh`, `run.ps1`, `content.txt`

### [8. Multilingual](./multilingual/)
**Text-to-speech in multiple languages**
- Supports various languages and scripts
- Language-specific instructions and voices
- Handles Unicode characters properly
- Files: `README.md`, `run.sh`, `run.ps1`

## 🚀 Quick Start

1. **Install the tool:**
   ```bash
   dotnet tool install -g GeminiTtsCli
   ```

2. **Set your API key:**
   ```bash
   # Linux/macOS
   export GEMINI_API_KEY="your-api-key-here"
   
   # Windows PowerShell
   $env:GEMINI_API_KEY = "your-api-key-here"
   ```

3. **Choose an example and run it:**
   ```bash
   cd examples/basic-tts
   chmod +x run.sh
   ./run.sh
   ```

## 📋 Example Categories

### **Beginner Examples**
- [Basic TTS](./basic-tts/) - Start here for simple conversion
- [Voice Listing](./voice-listing/) - Explore available voices
- [Custom Voice and Instructions](./custom-voice-and-instructions/) - Learn customization

### **Intermediate Examples**
- [Batch Processing](./batch-processing/) - Process multiple texts
- [Batch with Merge](./batch-with-merge/) - Create continuous audio
- [Multilingual](./multilingual/) - Work with different languages

### **Advanced Examples**
- [File Merging](./file-merging/) - Combine existing audio files
- [Concurrent Batch](./concurrent-batch/) - High-performance processing

## 🔧 Prerequisites

### Required for All Examples
- .NET 8.0 or later
- Gemini TTS CLI tool installed
- Internet connection for API calls

### Required for TTS Generation
- Google AI Studio API key set as `GEMINI_API_KEY` environment variable
- API key available from [Google AI Studio](https://makersuite.google.com/app/apikey)

### Optional Tools
- Audio player for testing generated WAV files
- Text editor for modifying sample content

## 📁 File Structure

Each example follows this consistent structure:
```
example-name/
├── README.md           # Detailed documentation
├── run.sh             # Bash script (Linux/macOS/WSL)
├── run.ps1            # PowerShell script (Windows/Cross-platform)
└── data-file.txt      # Sample data (if needed)
```

## 🎯 Use Case Guide

### **Creating Audio Books**
1. Start with [Batch Processing](./batch-processing/)
2. Try [Batch with Merge](./batch-with-merge/) for chapters
3. Use [Concurrent Batch](./concurrent-batch/) for performance
4. Apply [File Merging](./file-merging/) to combine chapters

### **Educational Content**
1. Use [Multilingual](./multilingual/) for international content
2. Apply [Custom Voice and Instructions](./custom-voice-and-instructions/) for different subjects
3. Try [Batch Processing](./batch-processing/) for lesson series

### **Presentations and Podcasts**
1. Start with [Custom Voice and Instructions](./custom-voice-and-instructions/)
2. Use [File Merging](./file-merging/) to combine intro/content/outro
3. Apply [Batch with Merge](./batch-with-merge/) for seamless content

### **Accessibility Applications**
1. Use [Batch Processing](./batch-processing/) for document conversion
2. Apply [Multilingual](./multilingual/) for international accessibility
3. Try [Concurrent Batch](./concurrent-batch/) for large document sets

## 🌐 Cross-Platform Support

All examples work on:
- **Linux** (bash scripts)
- **macOS** (bash scripts)
- **Windows** (PowerShell scripts)
- **WSL** (bash scripts on Windows)

## 📚 Learning Path

### Recommended Order for New Users:
1. [Voice Listing](./voice-listing/) - Explore available options
2. [Basic TTS](./basic-tts/) - Learn basic usage
3. [Custom Voice and Instructions](./custom-voice-and-instructions/) - Master customization
4. [Batch Processing](./batch-processing/) - Handle multiple texts
5. [Batch with Merge](./batch-with-merge/) - Create continuous audio
6. [Multilingual](./multilingual/) - Work with different languages
7. [File Merging](./file-merging/) - Combine existing files
8. [Concurrent Batch](./concurrent-batch/) - Optimize performance

## 🤝 Contributing

To add new examples:
1. Create a new folder with a descriptive name
2. Include `README.md`, `run.sh`, and `run.ps1`
3. Add sample data files if needed
4. Update this main README
5. Follow the existing documentation style

## 🆘 Troubleshooting

### Common Issues:
- **API Key Not Set**: Ensure `GEMINI_API_KEY` environment variable is set
- **Permission Denied**: Run `chmod +x run.sh` on Linux/macOS
- **Audio Not Playing**: Check your system's audio player and file associations
- **Script Execution Policy**: Run `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser` on Windows

### Getting Help:
- Check individual example README files for specific guidance
- Review the main [project README](../README.md) for general information
- Open issues on the [GitHub repository](https://github.com/doggy8088/gemini-tts-cli/issues)

## 📄 License

These examples are part of the Gemini TTS CLI project and are licensed under the MIT License.