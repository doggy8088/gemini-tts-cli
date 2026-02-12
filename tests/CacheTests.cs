using Xunit;
using GeminiTtsCli;

namespace GeminiTtsCli.Tests;

public class CacheTests
{
    [Fact]
    public void GenerateCacheKey_ShouldReturnDeterministicHash()
    {
        // Arrange
        var instructions = "Read this";
        var speaker = "zephyr";
        var text = "Hello world";

        // Act
        var key1 = GeminiTtsHelpers.GenerateCacheKey(instructions, speaker, text);
        var key2 = GeminiTtsHelpers.GenerateCacheKey(instructions, speaker, text);

        // Assert
        Assert.Equal(key1, key2);
    }

    [Fact]
    public void GenerateCacheKey_ShouldReturnDifferentHashes_ForDifferentInputs()
    {
        // Arrange
        var instructions = "Read this";
        var speaker = "zephyr";
        var text = "Hello world";
        var baseKey = GeminiTtsHelpers.GenerateCacheKey(instructions, speaker, text);

        // Act
        var diffInstructions = GeminiTtsHelpers.GenerateCacheKey("Read that", speaker, text);
        var diffSpeaker = GeminiTtsHelpers.GenerateCacheKey(instructions, "aoede", text);
        var diffText = GeminiTtsHelpers.GenerateCacheKey(instructions, speaker, "Hello there");

        // Assert
        Assert.NotEqual(baseKey, diffInstructions);
        Assert.NotEqual(baseKey, diffSpeaker);
        Assert.NotEqual(baseKey, diffText);
    }

    [Theory]
    [InlineData("", "", "")]
    [InlineData("instructions", "", "text")]
    [InlineData("", "speaker", "text")]
    [InlineData("instructions", "speaker", "")]
    public void GenerateCacheKey_ShouldHandleEmptyInputs(string instructions, string speaker, string text)
    {
        // Act
        var key = GeminiTtsHelpers.GenerateCacheKey(instructions, speaker, text);

        // Assert
        Assert.StartsWith("GeminiTtsCli_", key);
        // "GeminiTtsCli_" (13 chars) + SHA256 hex string (64 chars) = 77 chars
        Assert.Equal(77, key.Length);
    }

    [Fact]
    public void GenerateCacheKey_ShouldGenerateValidHexString()
    {
        // Arrange
        var key = GeminiTtsHelpers.GenerateCacheKey("i", "s", "t");
        var hashPart = key.Substring("GeminiTtsCli_".Length);

        // Act & Assert
        // Hex string should be valid characters 0-9, A-F
        Assert.Matches("^[0-9A-F]+$", hashPart);
        // SHA256 hash is 32 bytes = 64 hex chars
        Assert.Equal(64, hashPart.Length);
    }
}
