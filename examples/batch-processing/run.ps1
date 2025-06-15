# Batch Processing Example
# This script demonstrates how to process multiple text lines from a file

Write-Host "=== Batch Processing Example ===" -ForegroundColor Cyan
Write-Host "Processing text lines from a file into separate audio files..." -ForegroundColor White
Write-Host ""

# Check if API key is set
if (-not $env:GEMINI_API_KEY) {
    Write-Host "❌ Error: GEMINI_API_KEY environment variable is not set." -ForegroundColor Red
    Write-Host "Please set your API key first:" -ForegroundColor Yellow
    Write-Host '  $env:GEMINI_API_KEY = "your-api-key-here"' -ForegroundColor Yellow
    exit 1
}

# Input file and parameters
$InputFile = "sample-text.txt"
$Voice = "zephyr"
$Instructions = "Read aloud in a clear, pleasant voice"

# Check if input file exists
if (-not (Test-Path $InputFile)) {
    Write-Host "❌ Error: Input file '$InputFile' not found." -ForegroundColor Red
    Write-Host "Make sure you're running this script from the example directory." -ForegroundColor Yellow
    exit 1
}

Write-Host "Input file: $InputFile" -ForegroundColor Gray
Write-Host "Voice: $Voice" -ForegroundColor Gray
Write-Host "Instructions: $Instructions" -ForegroundColor Gray
Write-Host ""

# Show the content that will be processed
Write-Host "=== File Content ===" -ForegroundColor Cyan
Get-Content $InputFile | ForEach-Object { Write-Host $_ -ForegroundColor White }
Write-Host ""
Write-Host "=== Processing ===" -ForegroundColor Cyan

# Count lines for progress tracking
$TotalLines = (Get-Content $InputFile | Measure-Object -Line).Lines
Write-Host "Processing $TotalLines lines from $InputFile..." -ForegroundColor White
Write-Host ""

# Run batch processing
Write-Host "Running: gemini-tts --file `"$InputFile`" --speaker1 `"$Voice`" --instructions `"$Instructions`"" -ForegroundColor Gray
Write-Host ""

& gemini-tts --file $InputFile --speaker1 $Voice --instructions $Instructions

Write-Host ""
Write-Host "=== Results ===" -ForegroundColor Cyan

# Check generated files
$Files = Get-ChildItem -Path "sample-text-*.wav" -ErrorAction SilentlyContinue

if ($Files) {
    Write-Host "✅ Successfully generated audio files:" -ForegroundColor Green
    foreach ($File in $Files) {
        $Size = $File.Length
        Write-Host "  📄 $($File.Name) ($Size bytes)" -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "💡 Tips:" -ForegroundColor Green
    Write-Host "  - Each line from the input file becomes a separate audio file" -ForegroundColor Gray
    Write-Host "  - Files are numbered sequentially (01, 02, 03, etc.)" -ForegroundColor Gray
    Write-Host "  - Empty lines and symbol-only lines are automatically filtered" -ForegroundColor Gray
    Write-Host "  - You can play these files individually or use them in presentations" -ForegroundColor Gray
} else {
    Write-Host "❌ No audio files were generated. Check the error messages above." -ForegroundColor Red
    exit 1
}