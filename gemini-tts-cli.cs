
// dotnet run -- GeminiTtsCli.cs --instructions @script.txt --speaker1 zephyr --speaker2 puck

using System.CommandLine;
using System.CommandLine.Invocation;
using System.Globalization;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using NAudio.Wave;

// ---------- 參數與常數 ----------
const string ModelId = "gemini-2.5-flash-preview-tts";
const string ApiPath = "streamGenerateContent";
const int SampleHz = 24_000; // 24 kHz
const int Bits = 16;
const int Channels = 1;

var allowedVoices = new HashSet<string>(StringComparer.OrdinalIgnoreCase)
{
   // 女性
    "achernar","aoede","autonoe","callirrhoe","despina","erinome","gacrux","kore",
    "laomedeia","leda","sulafat","zephyr",
    "pulcherrima","vindemiatrix",
    // 男性
    "achird","algenib","algieba","alnilam","charon","enceladus","fenrir","iapetus",
    "orus","puck","rasalgethi","sadachbia","sadaltager","schedar","umbriel","zubenelgenubi",
};

// ---------- CLI 介面 ----------
var instructionsOpt = new Option<string>("--instructions", "輸入指引文字(必填)") { IsRequired = true };
var speaker1Opt = new Option<string>("--speaker1", "Speaker 1 的 voice name(必填)") { IsRequired = true };
var textOpt = new Option<string>("--text", "要 TTS 的文字(必填)") { IsRequired = true };
var outputOpt = new Option<string>("--outputfile", () => "output.wav", "輸出 WAV 檔名(預設 output.wav)");

var root = new RootCommand("Gemini TTS CLI");
root.AddOption(instructionsOpt);
root.AddOption(speaker1Opt);
root.AddOption(textOpt);
root.AddOption(outputOpt);

root.SetHandler(async (string instructions, string speaker1, string text, string output) =>
{
    // 組成傳給 Gemini TTS 的指令
    instructions = instructions + "\n\nSpeaker 1: " + text;

    System.Console.WriteLine($"📜 指令: {instructions}");

    // ---------- 檢查環境變數 ----------
    var apiKey = Environment.GetEnvironmentVariable("GEMINI_API_KEY");
    if (string.IsNullOrWhiteSpace(apiKey))
        throw new InvalidOperationException("請先在環境變數 GEMINI_API_KEY 儲存 API 金鑰");

    // ---------- 驗證聲音 ----------
    if (!allowedVoices.Contains(speaker1))
        throw new ArgumentException($"Speaker1 不合法: {speaker1}");

    // ---------- 組 JSON ----------
    var payload = new
    {
        contents = new[]
        {
            new
            {
                role  = "user",
                parts = new[] { new { text = instructions } }
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

    // ---------- 呼叫 API ----------
    const int maxRetries = 3;
    int attempt = 0;
    Exception? lastException = null;
    string? base64 = null;
    byte[]? pcmBytes = null;

    while (attempt < maxRetries)
    {
        try
        {
            using var res = await http.SendAsync(req, HttpCompletionOption.ResponseHeadersRead);
            res.EnsureSuccessStatusCode();

            var json = await res.Content.ReadAsStringAsync();
            using var doc = JsonDocument.Parse(json);
            base64 = doc.RootElement[0]
                          .GetProperty("candidates")[0]
                          .GetProperty("content")
                          .GetProperty("parts")[0]
                          .GetProperty("inlineData")
                          .GetProperty("data")
                          .GetString();

            if (string.IsNullOrWhiteSpace(base64))
                throw new InvalidOperationException("API 回傳空白音訊資料");

            pcmBytes = Convert.FromBase64String(base64);
            break; // 成功則跳出 retry 迴圈
        }
        catch (Exception ex)
        {
            lastException = ex;
            attempt++;
            if (attempt < maxRetries)
            {
                Console.WriteLine($"⚠️ 發生例外，重試第 {attempt} 次: {ex.Message}");
                await Task.Delay(1000);
            }
        }
    }

    if (pcmBytes == null)
        throw new InvalidOperationException($"API 失敗超過 {maxRetries} 次", lastException);

    // ---------- RAW 轉 WAV ----------
    using var ms = new MemoryStream(pcmBytes);
    using var raw = new RawSourceWaveStream(ms, new WaveFormat(SampleHz, Bits, Channels));
    WaveFileWriter.CreateWaveFile(output, raw);

    Console.WriteLine($"✅ 已產生 {output}");
}, instructionsOpt, speaker1Opt, textOpt, outputOpt);

// ---------- 執行 ----------
return await root.InvokeAsync(args);

// ---------- 協助函式 ----------
static string Capitalize(string voice) =>
    char.ToUpper(voice[0], CultureInfo.InvariantCulture) + voice[1..].ToLowerInvariant();
