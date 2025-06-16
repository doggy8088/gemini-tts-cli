# Concurrent Batch Processing Example

This example demonstrates how to use concurrent processing for faster batch text-to-speech conversion.

## What This Example Does

- Processes multiple text lines from a file using concurrent API requests
- Demonstrates performance improvements with the `--concurrency` option
- Shows both sequential (slow) and concurrent (fast) processing
- Compares processing times between different concurrency levels

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

The example runs multiple tests showing:
- **Sequential processing** (concurrency = 1): Slower, one request at a time
- **Low concurrency** (concurrency = 3): Moderate improvement
- **High concurrency** (concurrency = 5): Significant speed improvement
- Processing time comparisons for each approach

## Concurrency Levels

### Sequential Processing (Default)
```bash
gemini-tts --file "content.txt" --concurrency 1
```
- Processes one line at a time
- Slower but more conservative on API usage
- Good for testing or small batches

### Low Concurrency
```bash
gemini-tts --file "content.txt" --concurrency 3
```
- Processes 3 lines simultaneously
- Balanced speed and resource usage
- Recommended for most use cases

### High Concurrency
```bash
gemini-tts --file "content.txt" --concurrency 5
```
- Processes 5 lines simultaneously  
- Fastest processing for large batches
- Use when you need maximum speed

## Performance Considerations

### Benefits of Concurrency
- **Faster processing**: Multiple API requests in parallel
- **Better resource utilization**: Less waiting time
- **Time savings**: Significant for large batches

### API Rate Limits
- Be mindful of Gemini API rate limits
- Higher concurrency = more API calls per second
- Start with lower values and increase as needed

### Recommended Settings
- **Small batches (1-10 lines)**: `--concurrency 1-2`
- **Medium batches (10-50 lines)**: `--concurrency 3-5`
- **Large batches (50+ lines)**: `--concurrency 5-10`

## Input File Format

The example uses `content.txt` with 10 sample lines:
- Educational content about different topics
- Each line represents one audio segment
- Realistic content length for testing performance

## Command Explanation

Sequential processing:
```bash
gemini-tts --file "content.txt" --speaker1 "erinome" --concurrency 1
```

Concurrent processing:
```bash
gemini-tts --file "content.txt" --speaker1 "erinome" --concurrency 5
```

Parameters:
- `--file` (or `-f`): Input text file
- `--concurrency` (or `-c`): Number of simultaneous API requests
- `--speaker1` (or `-s`): Voice for all segments
- Output files: Automatically named `content-01.wav`, `content-02.wav`, etc.

## Use Cases

Perfect for:
- **Large audio book production**: Convert entire books quickly
- **Educational content**: Process multiple lessons efficiently
- **Podcast production**: Generate multiple segments rapidly
- **Accessibility content**: Convert documents to audio faster

## Next Steps

- Try the [batch-with-merge](../batch-with-merge/) example to combine concurrent processing with merging
- Experiment with different concurrency values to find optimal performance for your use case