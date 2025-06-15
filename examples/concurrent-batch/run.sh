#!/bin/bash

# Concurrent Batch Processing Example
# This script demonstrates the performance benefits of concurrent processing

echo "=== Concurrent Batch Processing Example ==="
echo "Demonstrating performance improvements with concurrent API requests..."
echo ""

# Check if API key is set
if [ -z "$GEMINI_API_KEY" ]; then
    echo "❌ Error: GEMINI_API_KEY environment variable is not set."
    echo "Please set your API key first:"
    echo "  export GEMINI_API_KEY=\"your-api-key-here\""
    exit 1
fi

# Input file and parameters
INPUT_FILE="content.txt"
VOICE="erinome"
INSTRUCTIONS="Read aloud in a clear, informative voice"

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "❌ Error: Input file '$INPUT_FILE' not found."
    echo "Make sure you're running this script from the example directory."
    exit 1
fi

echo "Input file: $INPUT_FILE"
echo "Voice: $VOICE"
echo "Instructions: $INSTRUCTIONS"
echo ""

# Count lines for context
TOTAL_LINES=$(grep -c . "$INPUT_FILE" 2>/dev/null || wc -l < "$INPUT_FILE")
echo "Total lines to process: $TOTAL_LINES"
echo ""

# Function to clean up previous runs
cleanup_files() {
    rm -f content-*.wav
    echo "Cleaned up previous output files."
}

# Function to measure time and run TTS
run_tts_test() {
    local concurrency=$1
    local test_name=$2
    
    echo "=== $test_name (Concurrency: $concurrency) ==="
    cleanup_files
    
    echo "Running: gemini-tts --file \"$INPUT_FILE\" --speaker1 \"$VOICE\" --concurrency $concurrency --instructions \"$INSTRUCTIONS\""
    
    # Measure processing time
    START_TIME=$(date +%s)
    
    gemini-tts --file "$INPUT_FILE" --speaker1 "$VOICE" --concurrency $concurrency --instructions "$INSTRUCTIONS"
    
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    
    # Count generated files
    GENERATED_COUNT=$(ls content-*.wav 2>/dev/null | wc -l)
    
    echo "⏱️  Processing time: ${DURATION} seconds"
    echo "📁 Generated files: $GENERATED_COUNT/$TOTAL_LINES"
    
    if [ "$GENERATED_COUNT" -eq "$TOTAL_LINES" ]; then
        echo "✅ All files generated successfully"
        
        # Calculate average time per file
        if [ "$TOTAL_LINES" -gt 0 ]; then
            AVG_TIME=$(echo "scale=2; $DURATION / $TOTAL_LINES" | bc -l 2>/dev/null || awk "BEGIN {printf \"%.2f\", $DURATION / $TOTAL_LINES}")
            echo "📊 Average time per file: ${AVG_TIME} seconds"
        fi
    else
        echo "⚠️  Some files may not have been generated"
    fi
    
    # Store results for comparison
    echo "$test_name,$concurrency,$DURATION,$GENERATED_COUNT" >> performance_results.csv
    
    echo ""
    return $DURATION
}

# Initialize results file
echo "Test,Concurrency,Duration,Files" > performance_results.csv

echo "This example will run the same batch processing job with different concurrency levels."
echo "You'll see the performance difference between sequential and concurrent processing."
echo ""

# Test 1: Sequential processing (baseline)
run_tts_test 1 "Sequential Processing"
SEQ_TIME=$?

# Test 2: Low concurrency
run_tts_test 3 "Low Concurrency"
LOW_TIME=$?

# Test 3: High concurrency
run_tts_test 5 "High Concurrency"
HIGH_TIME=$?

echo "=== Performance Comparison ==="
echo ""

if [ -f "performance_results.csv" ]; then
    echo "Results summary:"
    printf "%-25s %-12s %-10s %-10s\n" "Test" "Concurrency" "Duration" "Files"
    printf "%-25s %-12s %-10s %-10s\n" "----" "-----------" "--------" "-----"
    tail -n +2 performance_results.csv | while IFS=, read -r test concurrency duration files; do
        printf "%-25s %-12s %-10s %-10s\n" "$test" "$concurrency" "${duration}s" "$files"
    done
fi

echo ""
echo "💡 Performance Insights:"

if [ "$SEQ_TIME" -gt 0 ] && [ "$HIGH_TIME" -gt 0 ]; then
    IMPROVEMENT=$(awk "BEGIN {printf \"%.1f\", ($SEQ_TIME / $HIGH_TIME)}")
    echo "  • High concurrency is ${IMPROVEMENT}x faster than sequential processing"
fi

echo "  • Sequential (concurrency=1): Most conservative, slower but reliable"
echo "  • Low concurrency (concurrency=3): Good balance of speed and resource usage"
echo "  • High concurrency (concurrency=5): Fastest processing for large batches"
echo ""
echo "🎯 Recommendations:"
echo "  • For small batches (1-10 lines): Use concurrency 1-2"
echo "  • For medium batches (10-50 lines): Use concurrency 3-5"
echo "  • For large batches (50+ lines): Use concurrency 5-10"
echo "  • Always consider API rate limits when choosing concurrency levels"

# Clean up
cleanup_files
rm -f performance_results.csv

echo ""
echo "🎧 Test completed! Concurrent processing can significantly improve batch TTS performance."