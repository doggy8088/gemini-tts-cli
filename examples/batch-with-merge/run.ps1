# Batch Processing with Merge Example
# This script demonstrates how to process multiple text lines and merge into one audio file

Write-Host "=== Batch Processing with Merge Example ===" -ForegroundColor Cyan
Write-Host "Processing text file and merging all outputs into one continuous audio file..." -ForegroundColor White
Write-Host ""

# Check if API key is set
if (-not $env:GEMINI_API_KEY) {
    Write-Host "❌ Error: GEMINI_API_KEY environment variable is not set." -ForegroundColor Red
    Write-Host "Please set your API key first:" -ForegroundColor Yellow
    Write-Host '  $env:GEMINI_API_KEY = "your-api-key-here"' -ForegroundColor Yellow
    exit 1
}

# Input file and parameters
$InputFile = "story.txt"
$OutputFile = "story-merged.wav"
$Voice = "callirrhoe"
$Instructions = "Read aloud in a warm, storytelling voice with natural pauses between sentences"

# Check if input file exists
if (-not (Test-Path $InputFile)) {
    Write-Host "❌ Error: Input file '$InputFile' not found." -ForegroundColor Red
    Write-Host "Make sure you're running this script from the example directory." -ForegroundColor Yellow
    exit 1
}

Write-Host "Input file: $InputFile" -ForegroundColor Gray
Write-Host "Output file: $OutputFile" -ForegroundColor Gray
Write-Host "Voice: $Voice (female, storytelling)" -ForegroundColor Gray
Write-Host "Instructions: $Instructions" -ForegroundColor Gray
Write-Host ""

# Show the content that will be processed
Write-Host "=== Story Content ===" -ForegroundColor Cyan
Get-Content $InputFile | ForEach-Object { Write-Host $_ -ForegroundColor White }
Write-Host ""
Write-Host "=== Processing ===" -ForegroundColor Cyan

# Count lines for progress tracking
$TotalLines = (Get-Content $InputFile | Measure-Object -Line).Lines
Write-Host "Processing $TotalLines lines from $InputFile and merging into $OutputFile..." -ForegroundColor White
Write-Host ""

# Run batch processing with merge
Write-Host "Running: gemini-tts --file `"$InputFile`" --speaker1 `"$Voice`" --merge --outputfile `"$OutputFile`" --instructions `"$Instructions`"" -ForegroundColor Gray
Write-Host ""

& gemini-tts --file $InputFile --speaker1 $Voice --merge --outputfile $OutputFile --instructions $Instructions

Write-Host ""
Write-Host "=== Results ===" -ForegroundColor Cyan

# Check if the merged file was created
if (Test-Path $OutputFile) {
    $FileInfo = Get-Item $OutputFile
    $Size = $FileInfo.Length
    
    Write-Host "✅ Successfully created merged audio file:" -ForegroundColor Green
    Write-Host "  📄 $OutputFile ($Size bytes)" -ForegroundColor White
    
    Write-Host ""
    Write-Host "🎵 Audio Details:" -ForegroundColor Blue
    Write-Host "  - Contains all $TotalLines story lines in continuous sequence" -ForegroundColor Gray
    Write-Host "  - Single voice throughout (callirrhoe - female storytelling voice)" -ForegroundColor Gray
    Write-Host "  - Natural storytelling tone with appropriate pacing" -ForegroundColor Gray
    Write-Host ""
    Write-Host "💡 Benefits of merging:" -ForegroundColor Green
    Write-Host "  ✓ Single file instead of multiple numbered files" -ForegroundColor Gray
    Write-Host "  ✓ Continuous playback without interruption" -ForegroundColor Gray
    Write-Host "  ✓ Perfect for audio books, presentations, or podcasts" -ForegroundColor Gray
    Write-Host "  ✓ Easier to manage and distribute" -ForegroundColor Gray
    Write-Host ""
    Write-Host "🎧 You can now play '$OutputFile' to hear the complete story!" -ForegroundColor Yellow
} else {
    Write-Host "❌ Merged audio file was not created. Check the error messages above." -ForegroundColor Red
    
    # Check if individual files were created instead
    $IndividualFiles = Get-ChildItem -Path "story-*.wav" -ErrorAction SilentlyContinue
    if ($IndividualFiles) {
        Write-Host ""
        Write-Host "Individual files were created instead:" -ForegroundColor Yellow
        foreach ($File in $IndividualFiles) {
            Write-Host "  📄 $($File.Name)" -ForegroundColor Gray
        }
        Write-Host ""
        Write-Host "💡 You can manually merge these using:" -ForegroundColor Green
        Write-Host "  gemini-tts merge 'story-*.wav' --outputfile '$OutputFile'" -ForegroundColor Gray
    }
    
    exit 1
}