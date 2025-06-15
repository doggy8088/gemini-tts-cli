# Voice Listing Example
# This script demonstrates how to list all available voices

Write-Host "=== Voice Listing Example ===" -ForegroundColor Cyan
Write-Host "Displaying all available voices in Gemini TTS CLI..." -ForegroundColor White
Write-Host ""

# Note: This command does not require API key authentication
Write-Host "Running: gemini-tts list-voices" -ForegroundColor Gray
Write-Host ""

# List all available voices
& gemini-tts list-voices

Write-Host ""
Write-Host "=== Voice Usage Information ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "You can use any of these voices in your TTS commands:" -ForegroundColor White
Write-Host ""
Write-Host "Examples:" -ForegroundColor Yellow
Write-Host "  # Using a female voice" -ForegroundColor Gray
Write-Host '  gemini-tts --speaker1 "zephyr" --text "Hello from a female voice"' -ForegroundColor White
Write-Host ""
Write-Host "  # Using a male voice" -ForegroundColor Gray
Write-Host '  gemini-tts --speaker1 "achird" --text "Hello from a male voice"' -ForegroundColor White
Write-Host ""
Write-Host "  # Random voice (default behavior)" -ForegroundColor Gray
Write-Host '  gemini-tts --text "Hello with a random voice"' -ForegroundColor White
Write-Host ""
Write-Host "Voice categories:" -ForegroundColor Yellow
Write-Host "  • Female voices: Generally higher pitched, softer tones" -ForegroundColor Gray
Write-Host "  • Male voices: Generally lower pitched, deeper tones" -ForegroundColor Gray
Write-Host ""
Write-Host "💡 Tips:" -ForegroundColor Green
Write-Host "  - Voice names are case-insensitive" -ForegroundColor Gray
Write-Host "  - Each voice has unique characteristics" -ForegroundColor Gray
Write-Host "  - Try different voices for different content types" -ForegroundColor Gray
Write-Host "  - Combine with custom instructions for best results" -ForegroundColor Gray