using System.Diagnostics;
using System.Text;
using System.Text.Json;
using Xunit;
using Xunit.Abstractions;

namespace GeminiTtsCli.Tests;

public class PerformanceTests : IDisposable
{
    private readonly ITestOutputHelper _output;
    private readonly string _tempFile;

    public PerformanceTests(ITestOutputHelper output)
    {
        _output = output;
        _tempFile = Path.GetTempFileName();
    }

    public void Dispose()
    {
        if (File.Exists(_tempFile))
        {
            try { File.Delete(_tempFile); } catch {}
        }
    }

    [Fact]
    public async Task Measure_GenerateSingleTts_Performance()
    {
        // 1. Setup Mock HttpClient
        var mockHandler = new MockHttpMessageHandler();
        var httpClient = new HttpClient(mockHandler)
        {
            BaseAddress = new Uri("https://generativelanguage.googleapis.com/")
        };

        // Redirect Console to suppress output during benchmark
        var originalOut = Console.Out;
        Console.SetOut(TextWriter.Null);

        try
        {
            // 2. Prepare parameters
            var instructions = "Test instructions";
            var speaker1 = "zephyr";
            var text = "This is a test text for performance measurement.";
            var apiKey = "dummy_key";

            // Warmup
            await GeminiTtsHelpers.GenerateSingleTtsWithClient(httpClient, instructions, speaker1, text, _tempFile, apiKey, noCache: true);

            // 3. Measure
            int iterations = 100;
            long startAllocated = GC.GetTotalAllocatedBytes(true);
            var sw = Stopwatch.StartNew();

            for (int i = 0; i < iterations; i++)
            {
                await GeminiTtsHelpers.GenerateSingleTtsWithClient(httpClient, instructions, speaker1, text, _tempFile, apiKey, noCache: true);
            }

            sw.Stop();
            long endAllocated = GC.GetTotalAllocatedBytes(true);

            long allocated = endAllocated - startAllocated;

            // Restore Console for output
            Console.SetOut(originalOut);

            _output.WriteLine($"Iterations: {iterations}");
            _output.WriteLine($"Total Time: {sw.ElapsedMilliseconds} ms");
            _output.WriteLine($"Avg Time: {sw.ElapsedMilliseconds / (double)iterations} ms");
            _output.WriteLine($"Total Allocated: {allocated / 1024.0 / 1024.0:F2} MB");
            _output.WriteLine($"Avg Allocated: {allocated / iterations} bytes");
        }
        finally
        {
            Console.SetOut(originalOut);
        }
    }

    class MockHttpMessageHandler : HttpMessageHandler
    {
        private readonly string _jsonResponse;

        public MockHttpMessageHandler()
        {
            // Create a dummy base64 audio (50KB) to make allocation noticeable
            var dummyAudio = new byte[50 * 1024];
            new Random(42).NextBytes(dummyAudio);
            var base64Audio = Convert.ToBase64String(dummyAudio);

            var payload = new[]
            {
                new
                {
                    candidates = new[]
                    {
                        new
                        {
                            finishReason = "STOP",
                            content = new
                            {
                                parts = new[]
                                {
                                    new
                                    {
                                        inlineData = new
                                        {
                                            data = base64Audio
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            };

            _jsonResponse = JsonSerializer.Serialize(payload);
        }

        protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
        {
            var response = new HttpResponseMessage(System.Net.HttpStatusCode.OK)
            {
                Content = new StringContent(_jsonResponse, Encoding.UTF8, "application/json")
            };
            return Task.FromResult(response);
        }
    }
}
