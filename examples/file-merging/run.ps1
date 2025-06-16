# File Merging Example
# This script demonstrates how to merge existing WAV files using glob patterns

Write-Host "=== File Merging Example ===" -ForegroundColor Cyan
Write-Host "Demonstrating how to merge existing WAV files with different patterns..." -ForegroundColor White
Write-Host ""

# Check if API key is set (needed for creating sample files)
if (-not $env:GEMINI_API_KEY) {
    Write-Host "❌ Error: GEMINI_API_KEY environment variable is not set." -ForegroundColor Red
    Write-Host "This example needs to create sample WAV files first." -ForegroundColor Yellow
    Write-Host "Please set your API key:" -ForegroundColor Yellow
    Write-Host '  $env:GEMINI_API_KEY = "your-api-key-here"' -ForegroundColor Yellow
    exit 1
}

Write-Host "=== Step 1: Creating Sample WAV Files ===" -ForegroundColor Cyan
Write-Host "First, let's create some sample WAV files to demonstrate merging..." -ForegroundColor White
Write-Host ""

# Create sample intro files
Write-Host "Creating intro files..." -ForegroundColor Yellow
& gemini-tts --text "Welcome to our audio demonstration." --speaker1 "zephyr" --outputfile "intro-01.wav" --instructions "Read aloud in a welcoming, friendly tone"
& gemini-tts --text "This example shows how to merge audio files." --speaker1 "zephyr" --outputfile "intro-02.wav" --instructions "Read aloud in an informative tone"

# Create sample lesson files  
Write-Host "Creating lesson files..." -ForegroundColor Yellow
& gemini-tts --text "Lesson one covers the basics of file merging." --speaker1 "achird" --outputfile "lesson-01.wav" --instructions "Read aloud in a clear, educational tone"
& gemini-tts --text "Lesson two demonstrates advanced patterns." --speaker1 "achird" --outputfile "lesson-02.wav" --instructions "Read aloud in a clear, educational tone"

Write-Host ""
Write-Host "✅ Sample files created:" -ForegroundColor Green
$SampleFiles = Get-ChildItem -Path "intro-*.wav", "lesson-*.wav" -ErrorAction SilentlyContinue
foreach ($File in $SampleFiles) {
    Write-Host "  📄 $($File.Name)" -ForegroundColor White
}

Write-Host ""
Write-Host "=== Step 2: Demonstrating Merge Patterns ===" -ForegroundColor Cyan
Write-Host ""

# Example 1: Merge all intro files
Write-Host "1. Merging intro files with pattern 'intro-*.wav'..." -ForegroundColor Yellow
Write-Host "   Running: gemini-tts merge 'intro-*.wav' --outputfile 'intro-merged.wav'" -ForegroundColor Gray
& gemini-tts merge 'intro-*.wav' --outputfile 'intro-merged.wav'

if (Test-Path "intro-merged.wav") {
    Write-Host "   ✅ Created: intro-merged.wav" -ForegroundColor Green
} else {
    Write-Host "   ❌ Failed to create intro-merged.wav" -ForegroundColor Red
}

Write-Host ""

# Example 2: Merge all lesson files
Write-Host "2. Merging lesson files with pattern 'lesson-*.wav'..." -ForegroundColor Yellow
Write-Host "   Running: gemini-tts merge 'lesson-*.wav' --outputfile 'lesson-merged.wav'" -ForegroundColor Gray
& gemini-tts merge 'lesson-*.wav' --outputfile 'lesson-merged.wav'

if (Test-Path "lesson-merged.wav") {
    Write-Host "   ✅ Created: lesson-merged.wav" -ForegroundColor Green
} else {
    Write-Host "   ❌ Failed to create lesson-merged.wav" -ForegroundColor Red
}

Write-Host ""

# Example 3: Merge all WAV files
Write-Host "3. Merging all WAV files with pattern '*.wav'..." -ForegroundColor Yellow
Write-Host "   Running: gemini-tts merge '*.wav' --outputfile 'all-merged.wav'" -ForegroundColor Gray
Write-Host "   Note: This excludes previously merged files to avoid recursion" -ForegroundColor Gray

# First, move merged files temporarily to avoid including them
if (-not (Test-Path "temp_merged")) {
    New-Item -ItemType Directory -Name "temp_merged" | Out-Null
}
Get-ChildItem -Path "*-merged.wav" -ErrorAction SilentlyContinue | Move-Item -Destination "temp_merged"

& gemini-tts merge '*.wav' --outputfile 'all-merged.wav'

# Move the merged files back
Get-ChildItem -Path "temp_merged\*-merged.wav" -ErrorAction SilentlyContinue | Move-Item -Destination "."
Remove-Item "temp_merged" -ErrorAction SilentlyContinue

if (Test-Path "all-merged.wav") {
    Write-Host "   ✅ Created: all-merged.wav" -ForegroundColor Green
} else {
    Write-Host "   ❌ Failed to create all-merged.wav" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Results Summary ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "Original files:" -ForegroundColor White
$OriginalFiles = Get-ChildItem -Path "intro-*.wav", "lesson-*.wav" -ErrorAction SilentlyContinue | Where-Object { $_.Name -notmatch '-merged\.wav$' }
foreach ($File in $OriginalFiles) {
    Write-Host "  📄 $($File.Name) ($($File.Length) bytes)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Merged files:" -ForegroundColor White
$MergedFiles = Get-ChildItem -Path "*-merged.wav", "all-merged.wav" -ErrorAction SilentlyContinue
foreach ($File in $MergedFiles) {
    Write-Host "  🎵 $($File.Name) ($($File.Length) bytes)" -ForegroundColor Green
}

Write-Host ""
Write-Host "💡 Merge Pattern Examples:" -ForegroundColor Blue
Write-Host "  *.wav           - All WAV files in current directory" -ForegroundColor Gray
Write-Host "  intro-*.wav     - Files starting with 'intro-'" -ForegroundColor Gray
Write-Host "  lesson-*.wav    - Files starting with 'lesson-'" -ForegroundColor Gray
Write-Host "  **/*.wav        - All WAV files including subdirectories" -ForegroundColor Gray
Write-Host "  ??-*.wav        - Files with two-character prefix" -ForegroundColor Gray
Write-Host ""
Write-Host "🎧 You can now play the merged files to hear the combined audio!" -ForegroundColor Yellow