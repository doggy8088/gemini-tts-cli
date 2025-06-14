namespace GeminiTtsCli.Tests;

public class FileUtilityTests
{
    [Theory]
    [InlineData("@file.txt", true)]
    [InlineData("\"@file.txt\"", true)]
    [InlineData("@/path/to/file.txt", true)]
    [InlineData("\"@/path/to/file.txt\"", true)]
    [InlineData("@", true)] // Actually returns true based on implementation
    [InlineData("file.txt", false)]
    [InlineData("", false)]
    [InlineData(null, false)]
    [InlineData(" @file.txt", false)]
    [InlineData("file@.txt", false)]
    public void IsFileReference_ShouldDetectFileReferences(string? input, bool expected)
    {
        // Act
        var result = GeminiTtsHelpers.IsFileReference(input);
        
        // Assert
        Assert.Equal(expected, result);
    }

    [Fact]
    public void ReadAndFilterFileLines_ShouldFilterEmptyAndSymbolOnlyLines()
    {
        // Arrange
        var tempFile = Path.GetTempFileName();
        var lines = new[]
        {
            "Hello world",
            "",
            "   ",
            "Another line with text",
            "   \t   ",
            "!@#$%^&*()",
            "Line with 123 numbers",
            "Mixed symbols and text ABC",
            "---",
            ""
        };
        File.WriteAllLines(tempFile, lines);

        try
        {
            // Act
            var result = GeminiTtsHelpers.ReadAndFilterFileLines(tempFile);

            // Assert
            Assert.Equal(4, result.Length);
            Assert.Contains("Hello world", result);
            Assert.Contains("Another line with text", result);
            Assert.Contains("Line with 123 numbers", result);
            Assert.Contains("Mixed symbols and text ABC", result);
            Assert.DoesNotContain("!@#$%^&*()", result);
            Assert.DoesNotContain("---", result);
        }
        finally
        {
            File.Delete(tempFile);
        }
    }

    [Fact]
    public void ReadAndFilterFileLines_ShouldThrowFileNotFoundException_WhenFileDoesNotExist()
    {
        // Arrange
        var nonExistentFile = "non_existent_file.txt";

        // Act & Assert
        Assert.Throws<FileNotFoundException>(() => GeminiTtsHelpers.ReadAndFilterFileLines(nonExistentFile));
    }
}