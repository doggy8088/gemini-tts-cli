
// dotnet run -- --text "Hello world" [--instructions "Custom instructions"] [--speaker1 zephyr] [--outputfile output.wav]

using System.CommandLine;
using System.CommandLine.Invocation;
using System.Globalization;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;

using NAudio.Wave;

// ---------- Parameters and constants ----------
const string ModelId = "gemini-2.5-flash-preview-tts";
const string ApiPath = "streamGenerateContent";
const int SampleHz = 24_000; // 24 kHz
const int Bits = 16;
const int Channels = 1;

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
var textOpt = new Option<string>("--text", "Text to convert to speech (required)") { IsRequired = true };
textOpt.AddAlias("-t");
var outputOpt = new Option<string>("--outputfile", () => "output.wav", "Output WAV filename (default: output.wav)");
outputOpt.AddAlias("-o");

var root = new RootCommand("Gemini TTS CLI - Convert text to speech using Google Gemini API");
root.AddOption(instructionsOpt);
root.AddOption(speaker1Opt);
root.AddOption(textOpt);
root.AddOption(outputOpt);

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

mergeCommand.SetHandler(async (string pattern, string? outputFile) =>
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
        var wavFiles = FindWavFiles(pattern);
        
        if (wavFiles.Length == 0)
        {
            Console.WriteLine($"❌ Error: No WAV files found matching pattern '{pattern}'.");
            Environment.Exit(1);
        }

        // Determine output filename
        var finalOutputFile = outputFile ?? GetDefaultOutputFileName(pattern);
        
        Console.WriteLine($"🔍 Found {wavFiles.Length} WAV files to merge:");
        foreach (var file in wavFiles)
        {
            Console.WriteLine($"  📄 {file}");
        }
        Console.WriteLine($"📁 Output file: {finalOutputFile}");

        // Merge WAV files
        MergeWavFiles(wavFiles, finalOutputFile);
        
        Console.WriteLine($"✅ Successfully merged {wavFiles.Length} files into {finalOutputFile}");
    }
    catch (Exception ex)
    {
        Console.WriteLine($"❌ Error: {ex.Message}");
        Environment.Exit(1);
    }
}, patternArg, mergeOutputOpt);

root.AddCommand(mergeCommand);

root.SetHandler(async (string instructions, string speaker1, string text, string output) =>
{
    try
    {
        if (instructions.Contains(":"))
        {
            instructions = instructions.Replace(":", "");
        }

        // Determine voice gender
        var voiceGender = femaleVoices.Contains(speaker1, StringComparer.OrdinalIgnoreCase) ? "Female" : "Male";

        System.Console.WriteLine($"📜 Instructions: {instructions}");
        System.Console.WriteLine($"🎤 Select voice: {speaker1} ({voiceGender})");
        System.Console.WriteLine($"📝 The TTS Text: {text}");

        // Compose the instruction for Gemini TTS
        string prompt = instructions + ": " + text;

        // ---------- Check environment variables ----------
        var apiKey = Environment.GetEnvironmentVariable("GEMINI_API_KEY");
        if (string.IsNullOrWhiteSpace(apiKey))
        {
            Console.WriteLine("❌ Error: Missing API key. Please set the GEMINI_API_KEY environment variable.");
            Console.WriteLine("💡 You can get your API key from: https://makersuite.google.com/app/apikey");
            Environment.Exit(1);
        }

        // ---------- Validate voice ----------
        if (!allowedVoices.Contains(speaker1))
        {
            Console.WriteLine($"❌ Error: Invalid voice '{speaker1}'. Use 'list-voices' command to see available voices.");
            Environment.Exit(1);
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

    using var http = new HttpClient { BaseAddress = new Uri("https://generativelanguage.googleapis.com/") };
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

            using var res = await http.SendAsync(req, HttpCompletionOption.ResponseHeadersRead);
            res.EnsureSuccessStatusCode();

            json = await res.Content.ReadAsStringAsync();

            // Console.WriteLine($"🎃 JSON: {json}");

            using var doc = JsonDocument.Parse(json);

            var finishReason = doc.RootElement[0]
                          .GetProperty("candidates")[0]
                          .GetProperty("finishReason");

            if (finishReason.GetString() != "STOP")
            {
                Console.WriteLine($"⚠️ Retry attempt {attempt + 1}: The service declined to generate audio for this request.");
                attempt++;
                await Task.Delay(1000);
                continue; // 不是 STOP，重試
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
                Console.WriteLine($"⚠️ Retry attempt {attempt + 1}: Received empty audio data from the service.");
                attempt++;
                await Task.Delay(1000);
                continue;
            }

            pcmBytes = Convert.FromBase64String(base64);
            break; // 成功則跳出 retry 迴圈
        }
        catch (HttpRequestException ex)
        {
            Console.WriteLine($"⚠️ Retry attempt {attempt + 1}: Network error occurred. {ex.Message}");
            attempt++;
            if (attempt < maxRetries)
                await Task.Delay(1000);
        }
        catch (JsonException)
        {
            Console.WriteLine($"⚠️ Retry attempt {attempt + 1}: Received invalid response from the service.");
            attempt++;
            if (attempt < maxRetries)
                await Task.Delay(1000);
        }
        catch (Exception ex)
        {
            Console.WriteLine($"⚠️ Retry attempt {attempt + 1}: {ex.Message}");
            attempt++;
            if (attempt < maxRetries)
                await Task.Delay(1000);
        }
    }

    if (pcmBytes == null)
    {
        Console.WriteLine($"❌ Error: Failed to generate audio after {maxRetries} attempts. Please try again later.");
        Environment.Exit(1);
    }
    else
    {
        // ---------- Convert RAW to WAV ----------
        using var ms = new MemoryStream(pcmBytes);
        using var raw = new RawSourceWaveStream(ms, new WaveFormat(SampleHz, Bits, Channels));
        WaveFileWriter.CreateWaveFile(output, raw);

        Console.WriteLine($"✅ Generated {output}");
    }

    }
    catch (Exception ex)
    {
        Console.WriteLine($"❌ Error: An unexpected error occurred. {ex.Message}");
        Environment.Exit(1);
    }

}, instructionsOpt, speaker1Opt, textOpt, outputOpt);

// ---------- Execute ----------
return await root.InvokeAsync(args);

// ---------- Helper functions ----------
static string[] FindWavFiles(string pattern)
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

static string GetDefaultOutputFileName(string pattern)
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

static void MergeWavFiles(string[] inputFiles, string outputFile)
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

static string Capitalize(string voice) =>
    char.ToUpper(voice[0], CultureInfo.InvariantCulture) + voice[1..].ToLowerInvariant();

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
