# Custom Voice and Instructions Example
# This script demonstrates how to use specific voices and custom instructions

Write-Host "=== Custom Voice and Instructions Example ===" -ForegroundColor Cyan
Write-Host "Demonstrating different voices and instruction styles..." -ForegroundColor White
Write-Host ""

# Check if API key is set
if (-not $env:GEMINI_API_KEY) {
    Write-Host "❌ Error: GEMINI_API_KEY environment variable is not set." -ForegroundColor Red
    Write-Host "Please set your API key first:" -ForegroundColor Yellow
    Write-Host '  $env:GEMINI_API_KEY = "your-api-key-here"' -ForegroundColor Yellow
    exit 1
}

# Example 1: Female voice with enthusiastic instructions
Write-Host "1. Generating enthusiastic female voice example..." -ForegroundColor Yellow
$Instructions1 = "Read aloud in an enthusiastic, energetic, and engaging tone as if presenting to an audience"
$Text1 = "Welcome to this amazing demonstration of custom voice selection! This example shows how you can control both the voice and the speaking style."
$Output1 = "female-enthusiastic.wav"

Write-Host "   Voice: zephyr (female)" -ForegroundColor Gray
Write-Host "   Style: Enthusiastic presentation" -ForegroundColor Gray
Write-Host "   Output: $Output1" -ForegroundColor Gray

& gemini-tts --instructions $Instructions1 --speaker1 "zephyr" --text $Text1 --outputfile $Output1

if (Test-Path $Output1) {
    Write-Host "   ✅ Generated: $Output1" -ForegroundColor Green
} else {
    Write-Host "   ❌ Failed to generate: $Output1" -ForegroundColor Red
}

Write-Host ""

# Example 2: Male voice with professional instructions
Write-Host "2. Generating professional male voice example..." -ForegroundColor Yellow
$Instructions2 = "Read aloud in a calm, professional, and authoritative tone suitable for business presentations"
$Text2 = "This demonstration showcases the professional capabilities of the Gemini TTS system. The voice selection and instruction customization provide excellent control over the output quality."
$Output2 = "male-professional.wav"

Write-Host "   Voice: achird (male)" -ForegroundColor Gray
Write-Host "   Style: Professional business tone" -ForegroundColor Gray
Write-Host "   Output: $Output2" -ForegroundColor Gray

& gemini-tts --instructions $Instructions2 --speaker1 "achird" --text $Text2 --outputfile $Output2

if (Test-Path $Output2) {
    Write-Host "   ✅ Generated: $Output2" -ForegroundColor Green
} else {
    Write-Host "   ❌ Failed to generate: $Output2" -ForegroundColor Red
}

Write-Host ""

# Example 3: Female voice with storytelling instructions
Write-Host "3. Generating storytelling female voice example..." -ForegroundColor Yellow
$Instructions3 = "Read aloud in a warm, expressive, and captivating tone as if telling a story to children"
$Text3 = "Once upon a time, there was a magical text-to-speech system that could transform any written words into beautiful, natural-sounding speech with just a simple command."
$Output3 = "female-storytelling.wav"

Write-Host "   Voice: callirrhoe (female)" -ForegroundColor Gray
Write-Host "   Style: Warm storytelling" -ForegroundColor Gray
Write-Host "   Output: $Output3" -ForegroundColor Gray

& gemini-tts --instructions $Instructions3 --speaker1 "callirrhoe" --text $Text3 --outputfile $Output3

if (Test-Path $Output3) {
    Write-Host "   ✅ Generated: $Output3" -ForegroundColor Green
} else {
    Write-Host "   ❌ Failed to generate: $Output3" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Summary ===" -ForegroundColor Cyan
Write-Host "Generated files:" -ForegroundColor White

$Files = @($Output1, $Output2, $Output3)
foreach ($File in $Files) {
    if (Test-Path $File) {
        Write-Host "✅ $File" -ForegroundColor Green
    } else {
        Write-Host "❌ $File (failed)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "You can play these files to hear the difference between:" -ForegroundColor White
Write-Host "- Different voices (zephyr, achird, callirrhoe)" -ForegroundColor Gray
Write-Host "- Different instruction styles (enthusiastic, professional, storytelling)" -ForegroundColor Gray