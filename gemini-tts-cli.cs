
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

root.SetHandler(async (string instructions, string speaker1, string text, string output) =>
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
        throw new InvalidOperationException("Please set the API key in the GEMINI_API_KEY environment variable");

    // ---------- Validate voice ----------
    if (!allowedVoices.Contains(speaker1))
        throw new ArgumentException($"Invalid Speaker1: {speaker1}");

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
    var req = new HttpRequestMessage(HttpMethod.Post,
        $"v1beta/models/{ModelId}:{ApiPath}?key={apiKey}")
    {
        Content = new StringContent(JsonSerializer.Serialize(payload), Encoding.UTF8, "application/json")
    };

    // ---------- Dump req ----------
    // Console.WriteLine("=== HTTP Request ===");
    // Console.WriteLine($"{req.Method} {req.RequestUri}");
    // foreach (var header in req.Headers)
    //     Console.WriteLine($"{header.Key}: {string.Join(", ", header.Value)}");
    // if (req.Content != null)
    // {
    //     foreach (var header in req.Content.Headers)
    //         Console.WriteLine($"{header.Key}: {string.Join(", ", header.Value)}");
    //     var content = await req.Content.ReadAsStringAsync();
    //     Console.WriteLine(content);
    // }
    // Console.WriteLine("====================");

    // ---------- Call API ----------
    const int maxRetries = 3;
    int attempt = 0;
    Exception? lastException = null;
    string? base64 = null;
    byte[]? pcmBytes = null;

    while (attempt < maxRetries)
    {
        string json = string.Empty;
        try
        {
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
                Console.WriteLine($"⚠️ Exception occurred, retry attempt {attempt}: Gemini refused to generate audio\n{json}");
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
                throw new InvalidOperationException("API returned empty audio data");

            pcmBytes = Convert.FromBase64String(base64);
            break; // 成功則跳出 retry 迴圈
        }
        catch (Exception ex)
        {
            lastException = ex;
            if (attempt < maxRetries)
            {
                Console.WriteLine($"⚠️ Exception occurred, retry attempt {attempt+1}: {json}");
                await Task.Delay(1000);
            }
            attempt++;
        }
    }

    if (pcmBytes == null)
    {
        // throw new InvalidOperationException($"API failed more than {maxRetries} times", lastException);
        Console.WriteLine($"⚠️ API failed more than {maxRetries} times");
    }
    else
    {
        // ---------- Convert RAW to WAV ----------
        using var ms = new MemoryStream(pcmBytes);
        using var raw = new RawSourceWaveStream(ms, new WaveFormat(SampleHz, Bits, Channels));
        WaveFileWriter.CreateWaveFile(output, raw);

        Console.WriteLine($"✅ Generated {output}");
    }

}, instructionsOpt, speaker1Opt, textOpt, outputOpt);

// ---------- Execute ----------
return await root.InvokeAsync(args);

// ---------- Helper functions ----------
static string Capitalize(string voice) =>
    char.ToUpper(voice[0], CultureInfo.InvariantCulture) + voice[1..].ToLowerInvariant();
