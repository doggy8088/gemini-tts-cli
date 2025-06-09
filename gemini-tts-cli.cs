
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
static string Capitalize(string voice) =>
    char.ToUpper(voice[0], CultureInfo.InvariantCulture) + voice[1..].ToLowerInvariant();
