# Concurrent Batch Processing Example
# This script demonstrates the performance benefits of concurrent processing

Write-Host "=== Concurrent Batch Processing Example ===" -ForegroundColor Cyan
Write-Host "Demonstrating performance improvements with concurrent API requests..." -ForegroundColor White
Write-Host ""

# Check if API key is set
if (-not $env:GEMINI_API_KEY) {
    Write-Host "❌ Error: GEMINI_API_KEY environment variable is not set." -ForegroundColor Red
    Write-Host "Please set your API key first:" -ForegroundColor Yellow
    Write-Host '  $env:GEMINI_API_KEY = "your-api-key-here"' -ForegroundColor Yellow
    exit 1
}

# Input file and parameters
$InputFile = "content.txt"
$Voice = "erinome"
$Instructions = "Read aloud in a clear, informative voice"

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

# Count lines for context
$TotalLines = (Get-Content $InputFile | Measure-Object -Line).Lines
Write-Host "Total lines to process: $TotalLines" -ForegroundColor White
Write-Host ""

# Function to clean up previous runs
function Cleanup-Files {
    Get-ChildItem -Path "content-*.wav" -ErrorAction SilentlyContinue | Remove-Item
    Write-Host "Cleaned up previous output files." -ForegroundColor Gray
}

# Function to measure time and run TTS
function Run-TtsTest {
    param(
        [int]$Concurrency,
        [string]$TestName
    )
    
    Write-Host "=== $TestName (Concurrency: $Concurrency) ===" -ForegroundColor Yellow
    Cleanup-Files
    
    Write-Host "Running: gemini-tts --file `"$InputFile`" --speaker1 `"$Voice`" --concurrency $Concurrency --instructions `"$Instructions`"" -ForegroundColor Gray
    
    # Measure processing time
    $StartTime = Get-Date
    
    & gemini-tts --file $InputFile --speaker1 $Voice --concurrency $Concurrency --instructions $Instructions
    
    $EndTime = Get-Date
    $Duration = ($EndTime - $StartTime).TotalSeconds
    
    # Count generated files
    $GeneratedFiles = Get-ChildItem -Path "content-*.wav" -ErrorAction SilentlyContinue
    $GeneratedCount = $GeneratedFiles.Count
    
    Write-Host "⏱️  Processing time: $([math]::Round($Duration, 1)) seconds" -ForegroundColor Blue
    Write-Host "📁 Generated files: $GeneratedCount/$TotalLines" -ForegroundColor Blue
    
    if ($GeneratedCount -eq $TotalLines) {
        Write-Host "✅ All files generated successfully" -ForegroundColor Green
        
        # Calculate average time per file
        if ($TotalLines -gt 0) {
            $AvgTime = [math]::Round($Duration / $TotalLines, 2)
            Write-Host "📊 Average time per file: $AvgTime seconds" -ForegroundColor Blue
        }
    } else {
        Write-Host "⚠️  Some files may not have been generated" -ForegroundColor Yellow
    }
    
    # Store results for comparison
    "$TestName,$Concurrency,$([math]::Round($Duration, 1)),$GeneratedCount" | Add-Content -Path "performance_results.csv"
    
    Write-Host ""
    return $Duration
}

# Initialize results file
"Test,Concurrency,Duration,Files" | Set-Content -Path "performance_results.csv"

Write-Host "This example will run the same batch processing job with different concurrency levels." -ForegroundColor White
Write-Host "You'll see the performance difference between sequential and concurrent processing." -ForegroundColor White
Write-Host ""

# Test 1: Sequential processing (baseline)
$SeqTime = Run-TtsTest -Concurrency 1 -TestName "Sequential Processing"

# Test 2: Low concurrency
$LowTime = Run-TtsTest -Concurrency 3 -TestName "Low Concurrency"

# Test 3: High concurrency
$HighTime = Run-TtsTest -Concurrency 5 -TestName "High Concurrency"

Write-Host "=== Performance Comparison ===" -ForegroundColor Cyan
Write-Host ""

if (Test-Path "performance_results.csv") {
    Write-Host "Results summary:" -ForegroundColor White
    $Results = Import-Csv -Path "performance_results.csv"
    $Results | Format-Table -Property Test, Concurrency, @{Name="Duration"; Expression={"$($_.Duration)s"}}, Files -AutoSize
}

Write-Host ""
Write-Host "💡 Performance Insights:" -ForegroundColor Green

if ($SeqTime -gt 0 -and $HighTime -gt 0) {
    $Improvement = [math]::Round($SeqTime / $HighTime, 1)
    Write-Host "  • High concurrency is ${Improvement}x faster than sequential processing" -ForegroundColor Gray
}

Write-Host "  • Sequential (concurrency=1): Most conservative, slower but reliable" -ForegroundColor Gray
Write-Host "  • Low concurrency (concurrency=3): Good balance of speed and resource usage" -ForegroundColor Gray
Write-Host "  • High concurrency (concurrency=5): Fastest processing for large batches" -ForegroundColor Gray
Write-Host ""
Write-Host "🎯 Recommendations:" -ForegroundColor Blue
Write-Host "  • For small batches (1-10 lines): Use concurrency 1-2" -ForegroundColor Gray
Write-Host "  • For medium batches (10-50 lines): Use concurrency 3-5" -ForegroundColor Gray
Write-Host "  • For large batches (50+ lines): Use concurrency 5-10" -ForegroundColor Gray
Write-Host "  • Always consider API rate limits when choosing concurrency levels" -ForegroundColor Gray

# Clean up
Cleanup-Files
Remove-Item "performance_results.csv" -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "🎧 Test completed! Concurrent processing can significantly improve batch TTS performance." -ForegroundColor Yellow