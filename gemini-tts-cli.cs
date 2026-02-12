
// dotnet run -- --text "Hello world" [--instructions "Custom instructions"] [--speaker1 zephyr] [--outputfile output.wav]

using System.CommandLine;
using System.CommandLine.Invocation;
using System.Globalization;
using System.Net.Http.Headers;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;

using NAudio.Wave;

// Voice categorization
var femaleVoices = new[] { "achernar", "aoede", "autonoe", "callirrhoe", "despina", "erinome", "gacrux", "kore", "laomedeia", "leda", "sulafat", "zephyr", "pulcherrima", "vindemiatrix" };
var maleVoices = new[] { "achird", "algenib", "algieba", "alnilam", "charon", "enceladus", "fenrir", "iapetus", "orus", "puck", "rasalgethi", "sadachbia", "sadaltager", "schedar", "umbriel", "zubenelgenubi" };

var allowedVoices = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
allowedVoices.UnionWith(femaleVoices);
allowedVoices.UnionWith(maleVoices);

// ---------- CLI Interface ----------
var voiceList = string.Join(", ", allowedVoices.OrderBy(v => v));
var instructionsOpt = new Option<string>("--instructions", () => "Read aloud in a warm, professional and friendly tone", "Input instruction text (optional)");
instructionsOpt.AddAlias("-i");
var speaker1Opt = new Option<string>("--speaker1", () => allowedVoices.OrderBy(x => Guid.NewGuid()).First(), $"Speaker 1 voice name (optional, random if not specified)\nAvailable voices: {voiceList}");
speaker1Opt.AddAlias("-s");
var textOpt = new Option<string>("--text", "Text to convert to speech (required if no -f <file>)") { IsRequired = false };
textOpt.AddAlias("-t");
var fileOpt = new Option<string?>("--file", "File path for batch processing (.txt or .md files)");
fileOpt.AddAlias("-f");
var outputOpt = new Option<string>("--outputfile", () => "output.wav", "Output WAV filename (default: output.wav)");
outputOpt.AddAlias("-o");
var concurrencyOpt = new Option<int>("--concurrency", () => 1, "Concurrent API requests for batch processing (default: 1)");
concurrencyOpt.AddAlias("-c");
var mergeOpt = new Option<bool>("--merge", () => false, "Merge all outputs into single file for batch processing");
mergeOpt.AddAlias("-m");
var noCacheOpt = new Option<bool>("--no-cache", () => false, "Disable cache feature and force regeneration");

var root = new RootCommand("Gemini TTS CLI - Convert text to speech using Google Gemini API");
root.AddOption(instructionsOpt);
root.AddOption(speaker1Opt);
root.AddOption(textOpt);
root.AddOption(fileOpt);
root.AddOption(outputOpt);
root.AddOption(concurrencyOpt);
root.AddOption(mergeOpt);
root.AddOption(noCacheOpt);

// Add validation to ensure either text or file is provided
root.AddValidator(result =>
{
    var text = result.GetValueForOption(textOpt);
    var file = result.GetValueForOption(fileOpt);
    
    if (string.IsNullOrEmpty(text) && string.IsNullOrEmpty(file))
    {
        result.ErrorMessage = "Either --text or --file option must be provided.";
    }
    else if (!string.IsNullOrEmpty(text) && !string.IsNullOrEmpty(file))
    {
        result.ErrorMessage = "Cannot specify both --text and --file options. Use one or the other.";
    }
});

// Add list-voices command
var listVoicesCommand = new Command("list-voices", "List all available voices");
listVoicesCommand.SetHandler(() =>
{
    Console.WriteLine("Available voice list:");
    Console.WriteLine("Female voices:");
    foreach (var voice in femaleVoices.OrderBy(v => v))
    {
        Console.WriteLine($"  {voice}");
    }

    Console.WriteLine("\nMale voices:");
    foreach (var voice in maleVoices.OrderBy(v => v))
    {
        Console.WriteLine($"  {voice}");
    }
});
root.AddCommand(listVoicesCommand);

// Add merge command
var mergeCommand = new Command("merge", "Merge multiple WAV files into one WAV file");
var patternArg = new Argument<string>("pattern", "Glob pattern for WAV files (e.g., '*.wav', 'trial03-*.wav', '**/*.wav')");
var mergeOutputOpt = new Option<string?>("--outputfile", "Output WAV filename (optional)");
mergeOutputOpt.AddAlias("-o");

mergeCommand.AddArgument(patternArg);
mergeCommand.AddOption(mergeOutputOpt);

mergeCommand.SetHandler((string pattern, string? outputFile) =>
{
    try
    {
        // Validate pattern has .wav extension
        if (!pattern.Contains(".wav"))
        {
            Console.WriteLine("❌ Error: Pattern must include '*.wav' file extension.");
            Environment.Exit(1);
        }

        // Find WAV files matching the pattern
        var wavFiles = GeminiTtsHelpers.FindWavFiles(pattern);
        
        if (wavFiles.Length == 0)
        {
            Console.WriteLine($"❌ Error: No WAV files found matching pattern '{pattern}'.");
            Environment.Exit(1);
        }

        // Determine output filename
        var finalOutputFile = outputFile ?? GeminiTtsHelpers.GetDefaultOutputFileName(pattern);
        
        Console.WriteLine($"🔍 Found {wavFiles.Length} WAV files to merge:");
        foreach (var file in wavFiles)
        {
            Console.WriteLine($"  📄 {file}");
        }
        Console.WriteLine($"📁 Output file: {finalOutputFile}");

        // Merge WAV files
        GeminiTtsHelpers.MergeWavFiles(wavFiles, finalOutputFile);
        
        Console.WriteLine($"✅ Successfully merged {wavFiles.Length} files into {finalOutputFile}");
    }
    catch (Exception ex)
    {
        Console.WriteLine($"❌ Error: {ex.Message}");
        Environment.Exit(1);
    }
}, patternArg, mergeOutputOpt);

root.AddCommand(mergeCommand);

root.SetHandler(async (string instructions, string speaker1, string? text, string? file, string output, int concurrency, bool merge, bool noCache) =>
{
    try
    {
        if (instructions.Contains(":"))
        {
            instructions = instructions.Replace(":", "");
        }

        // ---------- Validate voice early for both single and batch processing ----------
        if (!allowedVoices.Contains(speaker1))
        {
            if (output != "-")
            {
                Console.WriteLine($"❌ Error: Invalid voice '{speaker1}'. Use 'list-voices' command to see available voices.");
            }
            Environment.Exit(1);
        }

        // Check if this is a file reference first (before API key validation for better error messages)
        if (!string.IsNullOrEmpty(file) || GeminiTtsHelpers.IsFileReference(text))
        {
            var filePath = !string.IsNullOrEmpty(file) ? file : (text!.StartsWith("\"@") ? text.Substring(2).TrimEnd('"') : text!.Substring(1)); // Remove @ or "@" prefix and trailing quote
            
            // Validate file extension first
            var extension = Path.GetExtension(filePath).ToLowerInvariant();
            if (extension != ".txt" && extension != ".md")
            {
                if (output != "-")
                {
                    Console.WriteLine($"❌ Error: File must have .txt or .md extension. Found: {extension}");
                }
                Environment.Exit(1);
            }

            if (!File.Exists(filePath))
            {
                if (output != "-")
                {
                    Console.WriteLine($"❌ Error: File not found: {filePath}");
                }
                Environment.Exit(1);
            }

            // ---------- Check environment variables ----------
            var apiKey = Environment.GetEnvironmentVariable("GEMINI_API_KEY");
            if (string.IsNullOrWhiteSpace(apiKey))
            {
                if (output != "-")
                {
                    Console.WriteLine("❌ Error: Missing API key. Please set the GEMINI_API_KEY environment variable.");
                    Console.WriteLine("💡 You can get your API key from: https://makersuite.google.com/app/apikey");
                }
                Environment.Exit(1);
            }
            
            try
            {
                var textLines = GeminiTtsHelpers.ReadAndFilterFileLines(filePath);
                
                if (textLines.Length == 0)
                {
                    Console.WriteLine($"❌ Error: No valid text lines found in file '{filePath}'.");
                    Environment.Exit(1);
                }

                Console.WriteLine($"📁 Processing file: {filePath}");
                Console.WriteLine($"📝 Found {textLines.Length} valid text lines");
                Console.WriteLine($"🎤 Using voice: {speaker1}");
                Console.WriteLine($"⚡ Concurrency level: {concurrency}");
                Console.WriteLine($"🔗 Merge mode: {(merge ? "Yes" : "No")}");
                Console.WriteLine($"🗂️ Cache mode: {(noCache ? "Disabled" : "Enabled")}");
                
                await GeminiTtsHelpers.ProcessBatchTts(instructions, speaker1, textLines, output, concurrency, merge, apiKey, noCache);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Error processing file: {ex.Message}");
                Environment.Exit(1);
            }
        }
        else
        {
            // ---------- Check environment variables ----------
            var apiKey = Environment.GetEnvironmentVariable("GEMINI_API_KEY");
            if (string.IsNullOrWhiteSpace(apiKey))
            {
                if (output != "-")
                {
                    Console.WriteLine("❌ Error: Missing API key. Please set the GEMINI_API_KEY environment variable.");
                    Console.WriteLine("💡 You can get your API key from: https://makersuite.google.com/app/apikey");
                }
                Environment.Exit(1);
            }

            // Single text processing (existing logic)
            // Determine voice gender
            var voiceGender = femaleVoices.Contains(speaker1, StringComparer.OrdinalIgnoreCase) ? "Female" : "Male";
            bool isStdout = output == "-";

            if (!isStdout)
            {
                System.Console.WriteLine($"📜 Instructions: {instructions}");
                System.Console.WriteLine($"🎤 Select voice: {speaker1} ({voiceGender})");
                System.Console.WriteLine($"📝 The TTS Text: {text}");
                System.Console.WriteLine($"🗂️ Cache mode: {(noCache ? "Disabled" : "Enabled")}");
            }

            try
            {
                await GeminiTtsHelpers.GenerateSingleTts(instructions, speaker1, text!, output, apiKey, noCache: noCache);
                if (!isStdout)
                {
                    Console.WriteLine($"✅ Generated {output}");
                }
            }
            catch (Exception ex)
            {
                if (!isStdout)
                {
                    Console.WriteLine($"❌ Error: Failed to generate audio. {ex.Message}");
                }
                Environment.Exit(1);
            }
        }

    }
    catch (Exception ex)
    {
        Console.WriteLine($"❌ Error: An unexpected error occurred. {ex.Message}");
        Environment.Exit(1);
    }

}, instructionsOpt, speaker1Opt, textOpt, fileOpt, outputOpt, concurrencyOpt, mergeOpt, noCacheOpt);

// ---------- Execute ----------
return await root.InvokeAsync(args);

// ---------- Helper functions class ----------
public static class GeminiTtsHelpers
{
    private static readonly HttpClient _httpClient = new HttpClient { BaseAddress = new Uri("https://generativelanguage.googleapis.com/") };

    // ---------- Constants ----------
    public const string ModelId = "gemini-2.5-flash-preview-tts";
    public const string ApiPath = "streamGenerateContent";
    public const int SampleHz = 24_000; // 24 kHz
    public const int Bits = 16;
    public const int Channels = 1;
    
    // Cache methods
    public static string GenerateCacheKey(string instructions, string speaker1, string text)
    {
        var combinedInput = $"{instructions}|{speaker1}|{text}";
        using var sha256 = SHA256.Create();
        var hash = sha256.ComputeHash(Encoding.UTF8.GetBytes(combinedInput));
        return "GeminiTtsCli_" + Convert.ToHexString(hash);
    }
    
    public static string GetCacheFilePath(string cacheKey)
    {
        return Path.Combine(Path.GetTempPath(), cacheKey + ".wav");
    }
    
    public static bool TryGetCachedFile(string cacheKey, out string cachedFilePath)
    {
        cachedFilePath = GetCacheFilePath(cacheKey);
        return File.Exists(cachedFilePath);
    }
    
    public static void SaveToCache(string cacheKey, string sourceFilePath)
    {
        try
        {
            var cacheFilePath = GetCacheFilePath(cacheKey);
            File.Copy(sourceFilePath, cacheFilePath, true);
        }
        catch
        {
            // Ignore cache save errors
        }
    }

    public static bool IsFileReference(string? text) => !string.IsNullOrEmpty(text) && (text.StartsWith("@") || text.StartsWith("\"@"));

    public static string[] ReadAndFilterFileLines(string filePath)
    {
        var lines = File.ReadAllLines(filePath);
        
        // Filter out empty lines and lines with only symbols/whitespace
        return lines
            .Where(line => !string.IsNullOrWhiteSpace(line))
            .Where(line => line.Any(char.IsLetterOrDigit))
            .ToArray();
    }

    public static async Task<string> GenerateSingleTts(string instructions, string speaker1, string text, string output, string apiKey, int? lineNumber = null, string? textPreview = null, bool noCache = false)
{
    // Compose the instruction for Gemini TTS
    string prompt = instructions + ": " + text;
    bool isStdout = output == "-";
    
    // Check cache first if not disabled
    if (!noCache)
    {
        var cacheKey = GenerateCacheKey(instructions, speaker1, text);
        if (TryGetCachedFile(cacheKey, out string cachedFilePath))
        {
            try
            {
                var contextInfo = lineNumber.HasValue ? $" (Line {lineNumber})" : "";
                if (!isStdout)
                    Console.WriteLine($"🗂️ Using cached result{contextInfo}");
                
                if (isStdout)
                {
                    // For stdout, read cached file and stream to stdout
                    using var cachedFile = File.OpenRead(cachedFilePath);
                    using var stdout = Console.OpenStandardOutput();
                    await cachedFile.CopyToAsync(stdout);
                    return "-";
                }
                else
                {
                    // For file output, copy cached file to output
                    File.Copy(cachedFilePath, output, true);
                    return output;
                }
            }
            catch
            {
                // If cache read fails, continue with normal generation
                if (!isStdout)
                    Console.WriteLine($"⚠️ Cache read failed, generating new audio");
            }
        }
    }

    // ---------- Compose JSON ----------
    var payload = new
    {
        contents = new[]
        {
            new
            {
                role  = "user",
                parts = new[] { new { text = prompt } }
            }
        },
        generationConfig = new
        {
            responseModalities = new[] { "audio" },
            temperature = 1,
            speech_config = new
            {
                voice_config = new
                {
                    prebuilt_voice_config = new { voice_name = Capitalize(speaker1) }
                }
            }
        }
    };

    var payloadJson = JsonSerializer.Serialize(payload);

    // ---------- Call API ----------
    const int maxRetries = 3;
    int attempt = 0;
    string? base64 = null;
    byte[]? pcmBytes = null;

    while (attempt < maxRetries)
    {
        string json = string.Empty;
        try
        {
            // Create a new request for each attempt
            var req = new HttpRequestMessage(HttpMethod.Post,
                $"v1beta/models/{ModelId}:{ApiPath}?key={apiKey}")
            {
                Content = new StringContent(payloadJson, Encoding.UTF8, "application/json")
            };

            using var res = await _httpClient.SendAsync(req, HttpCompletionOption.ResponseHeadersRead);
            res.EnsureSuccessStatusCode();

            json = await res.Content.ReadAsStringAsync();

            using var doc = JsonDocument.Parse(json);

            var finishReason = doc.RootElement[0]
                          .GetProperty("candidates")[0]
                          .GetProperty("finishReason");

            if (finishReason.GetString() != "STOP")
            {
                var contextInfo = lineNumber.HasValue ? $" (Line {lineNumber}: {textPreview})" : "";
                if (!isStdout)
                    Console.WriteLine($"⚠️ Retry attempt {attempt + 1}{contextInfo}: The service declined to generate audio for this request.");
                attempt++;
                await Task.Delay(1000);
                continue;
            }

            base64 = doc.RootElement[0]
                          .GetProperty("candidates")[0]
                          .GetProperty("content")
                          .GetProperty("parts")[0]
                          .GetProperty("inlineData")
                          .GetProperty("data")
                          .GetString();

            if (string.IsNullOrWhiteSpace(base64))
            {
                var contextInfo = lineNumber.HasValue ? $" (Line {lineNumber}: {textPreview})" : "";
                if (!isStdout)
                    Console.WriteLine($"⚠️ Retry attempt {attempt + 1}{contextInfo}: Received empty audio data from the service.");
                attempt++;
                await Task.Delay(1000);
                continue;
            }

            pcmBytes = Convert.FromBase64String(base64);
            break;
        }
        catch (HttpRequestException ex)
        {
            var contextInfo = lineNumber.HasValue ? $" (Line {lineNumber}: {textPreview})" : "";
            if (!isStdout)
                Console.WriteLine($"⚠️ Retry attempt {attempt + 1}{contextInfo}: Network error occurred. {ex.Message}");
            attempt++;
            if (attempt < maxRetries)
                await Task.Delay(1000);
        }
        catch (JsonException)
        {
            var contextInfo = lineNumber.HasValue ? $" (Line {lineNumber}: {textPreview})" : "";
            if (!isStdout)
                Console.WriteLine($"⚠️ Retry attempt {attempt + 1}{contextInfo}: Received invalid response from the service.");
            attempt++;
            if (attempt < maxRetries)
                await Task.Delay(1000);
        }
        catch (Exception ex)
        {
            var contextInfo = lineNumber.HasValue ? $" (Line {lineNumber}: {textPreview})" : "";
            if (!isStdout)
                Console.WriteLine($"⚠️ Retry attempt {attempt + 1}{contextInfo}: {ex.Message}");
            attempt++;
            if (attempt < maxRetries)
                await Task.Delay(1000);
        }
    }

    if (pcmBytes == null)
    {
        throw new Exception($"Failed to generate audio after {maxRetries} attempts");
    }

    // ---------- Convert RAW to WAV ----------
    using var ms = new MemoryStream(pcmBytes);
    using var raw = new RawSourceWaveStream(ms, new WaveFormat(SampleHz, Bits, Channels));
    
    if (isStdout)
    {
        // Write WAV data directly to stdout, but also save to cache
        using var stdout = Console.OpenStandardOutput();
        using var wavStream = new MemoryStream();
        using var writer = new WaveFileWriter(wavStream, raw.WaveFormat);
        await raw.CopyToAsync(writer);
        writer.Flush();
        wavStream.Position = 0;
        
        // Save to cache if not disabled
        if (!noCache)
        {
            var cacheKey = GenerateCacheKey(instructions, speaker1, text);
            var cacheFilePath = GetCacheFilePath(cacheKey);
            try
            {
                // Save the WAV data to cache file
                using var cacheFile = File.Create(cacheFilePath);
                wavStream.Position = 0;
                await wavStream.CopyToAsync(cacheFile);
                wavStream.Position = 0;  // Reset position for stdout output
            }
            catch
            {
                // Ignore cache save errors
            }
        }
        
        await wavStream.CopyToAsync(stdout);
        return "-";
    }
    else
    {
        WaveFileWriter.CreateWaveFile(output, raw);
        
        // Save to cache if not disabled
        if (!noCache)
        {
            var cacheKey = GenerateCacheKey(instructions, speaker1, text);
            SaveToCache(cacheKey, output);
        }
        
        return output;
    }
}

    public static string GenerateNumberedFilename(string baseOutput, int index)
    {
        var directory = Path.GetDirectoryName(baseOutput) ?? "";
        var nameWithoutExt = Path.GetFileNameWithoutExtension(baseOutput);
        var extension = Path.GetExtension(baseOutput);
        
        // If no extension provided, default to .wav
    if (string.IsNullOrEmpty(extension))
    {
        extension = ".wav";
    }
    
    var numberedName = $"{nameWithoutExt}-{index:D2}{extension}";
    return Path.Combine(directory, numberedName);
}

    public static async Task ProcessBatchTts(string instructions, string speaker1, string[] textLines, string baseOutput, int concurrency, bool merge, string apiKey, bool noCache = false)
    {
        Console.WriteLine($"📚 Processing {textLines.Length} lines with concurrency level {concurrency}");
        
        var semaphore = new SemaphoreSlim(concurrency, concurrency);
        var tasks = new List<Task<string>>();
        var tempFiles = new List<string>();
    
        for (int i = 0; i < textLines.Length; i++)
        {
            var index = i + 1;
            var text = textLines[i];
            var outputFile = merge ? Path.Combine(Path.GetTempPath(), Guid.NewGuid() + ".wav") : GenerateNumberedFilename(baseOutput, index);
            
            if (merge)
            {
                tempFiles.Add(outputFile);
            }
    
            var task = Task.Run(async () =>
            {
                await semaphore.WaitAsync();
                try
                {
                    Console.WriteLine($"🎵 Processing line {index}: {text.Substring(0, Math.Min(50, text.Length))}...");
                    var textPreview = text.Substring(0, Math.Min(30, text.Length)) + (text.Length > 30 ? "..." : "");
                    return await GenerateSingleTts(instructions, speaker1, text, outputFile, apiKey, index, textPreview, noCache);
                }
                finally
                {
                    semaphore.Release();
                }
            });
            
            tasks.Add(task);
        }
    
        var completedFiles = await Task.WhenAll(tasks);
        
        if (merge)
        {
            Console.WriteLine($"🔗 Merging {completedFiles.Length} files into {baseOutput}");
            MergeWavFiles(completedFiles.ToArray(), baseOutput);
            
            // Clean up temporary files
            foreach (var tempFile in tempFiles)
            {
                try
                {
                    File.Delete(tempFile);
                }
                catch
                {
                    // Ignore cleanup errors
                }
            }
            
            Console.WriteLine($"✅ Generated merged file: {baseOutput}");
        }
        else
        {
            Console.WriteLine($"✅ Generated {completedFiles.Length} numbered files");
            foreach (var file in completedFiles)
            {
                Console.WriteLine($"  📄 {file}");
            }
        }
}

    public static string[] FindWavFiles(string pattern)
    {
        var currentDir = Directory.GetCurrentDirectory();
        
        // Handle recursive patterns (**/*.wav)
        if (pattern.StartsWith("**/"))
        {
            var searchPattern = pattern[3..]; // Remove "**/"
            return Directory.GetFiles(currentDir, searchPattern, SearchOption.AllDirectories)
                           .Where(f => f.EndsWith(".wav", StringComparison.OrdinalIgnoreCase))
                           .OrderBy(f => f)
                           .ToArray();
        }
        
        // Handle regular patterns (*.wav, trial03-*.wav)
        return Directory.GetFiles(currentDir, pattern, SearchOption.TopDirectoryOnly)
                       .Where(f => f.EndsWith(".wav", StringComparison.OrdinalIgnoreCase))
                       .OrderBy(f => f)
                       .ToArray();
}

    public static string GetDefaultOutputFileName(string pattern)
    {
        // Extract base name from pattern for default output
        if (pattern.StartsWith("**/"))
        {
            return "all-merged.wav";
        }
        
        if (pattern == "*.wav")
        {
            return "merged.wav";
        }
        
        // For patterns like "trial03-*.wav", generate "trial03-merged.wav"
        var baseName = Path.GetFileNameWithoutExtension(pattern).Replace("*", "").TrimEnd('-');
        return string.IsNullOrEmpty(baseName) ? "merged.wav" : $"{baseName}-merged.wav";
}

    public static void MergeWavFiles(string[] inputFiles, string outputFile)
    {
        var audioStreams = new List<WaveStream>();
        
        try
        {
            // Load all input files
            foreach (var inputFile in inputFiles)
            {
                var reader = new WaveFileReader(inputFile);
                audioStreams.Add(reader);
            }
            
            // Check if all files have the same format
            var firstFormat = audioStreams[0].WaveFormat;
            bool allSameFormat = audioStreams.All(s => 
                s.WaveFormat.SampleRate == firstFormat.SampleRate &&
                s.WaveFormat.BitsPerSample == firstFormat.BitsPerSample &&
                s.WaveFormat.Channels == firstFormat.Channels);
            
            if (!allSameFormat)
            {
                Console.WriteLine("⚠️ Warning: Input files have different formats. Using first file's format for output.");
            }
            
            // Create concatenated wave provider
            var concatenated = new ConcatenatingWaveProvider(audioStreams);
            
            // Write to output file
            WaveFileWriter.CreateWaveFile(outputFile, concatenated);
        }
        finally
        {
            // Clean up streams
            foreach (var stream in audioStreams)
            {
                stream?.Dispose();
            }
        }
}

    public static string Capitalize(string voice) =>
        char.ToUpper(voice[0], CultureInfo.InvariantCulture) + voice[1..].ToLowerInvariant();
}

// Simple wave provider that concatenates multiple wave streams  
public class ConcatenatingWaveProvider : IWaveProvider
    {
        private readonly WaveStream[] sources;
        private int currentSourceIndex = 0;
        private readonly WaveFormat waveFormat;
    
        public ConcatenatingWaveProvider(IEnumerable<WaveStream> sources)
        {
            this.sources = sources.ToArray();
            if (this.sources.Length == 0)
                throw new ArgumentException("Must provide at least one source");
            
            this.waveFormat = this.sources[0].WaveFormat;
        }
    
        public WaveFormat WaveFormat => waveFormat;
    
        public int Read(byte[] buffer, int offset, int count)
        {
            int totalRead = 0;
            
            while (totalRead < count && currentSourceIndex < sources.Length)
            {
                int read = sources[currentSourceIndex].Read(buffer, offset + totalRead, count - totalRead);
                totalRead += read;
                
                if (read == 0)
                {
                    // Current source is exhausted, move to next
                    currentSourceIndex++;
                }
            }
            
            return totalRead;
        }
    }
