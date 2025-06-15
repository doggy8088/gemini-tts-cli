# Basic Text-to-Speech Example
# This script demonstrates the simplest usage of Gemini TTS CLI

Write-Host "=== Basic Text-to-Speech Example ===" -ForegroundColor Cyan
Write-Host "Converting text to speech with default settings..." -ForegroundColor White
Write-Host ""

# Check if API key is set
if (-not $env:GEMINI_API_KEY) {
    Write-Host "❌ Error: GEMINI_API_KEY environment variable is not set." -ForegroundColor Red
    Write-Host "Please set your API key first:" -ForegroundColor Yellow
    Write-Host '  $env:GEMINI_API_KEY = "your-api-key-here"' -ForegroundColor Yellow
    exit 1
}

# Simple text-to-speech conversion with default settings
$Text = "Hello world! This is a basic text-to-speech example using Gemini TTS."

Write-Host "Text to convert: $Text" -ForegroundColor White
Write-Host "Running: gemini-tts --text `"$Text`"" -ForegroundColor Gray
Write-Host ""

# Run the TTS command
& gemini-tts --text $Text

# Check if output file was created
if (Test-Path "output.wav") {
    Write-Host ""
    Write-Host "✅ Success! Generated audio file: output.wav" -ForegroundColor Green
    Write-Host "You can play the file using your system's audio player." -ForegroundColor White
    
    # Get file size for verification
    $FileInfo = Get-Item "output.wav"
    Write-Host "File size: $($FileInfo.Length) bytes" -ForegroundColor Gray
} else {
    Write-Host ""
    Write-Host "❌ Error: Output file was not created. Check the error messages above." -ForegroundColor Red
    exit 1
}