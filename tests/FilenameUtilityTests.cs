namespace GeminiTtsCli.Tests;

public class FilenameUtilityTests
{
    [Theory]
    [InlineData("output.wav", 1, "output-01.wav")]
    [InlineData("output.wav", 10, "output-10.wav")]
    [InlineData("output.wav", 100, "output-100.wav")]
    [InlineData("output", 3, "output-03.wav")]
    [InlineData("test.mp3", 7, "test-07.mp3")]
    public void GenerateNumberedFilename_ShouldGenerateCorrectFilenames(string baseOutput, int index, string expected)
    {
        // Act
        var result = GeminiTtsHelpers.GenerateNumberedFilename(baseOutput, index);
        
        // Assert
        Assert.Equal(expected, result);
    }

    [Fact]
    public void GenerateNumberedFilename_ShouldHandlePathsCorrectly()
    {
        // Arrange
        var baseOutput = Path.Combine("path", "to", "output.wav");
        var index = 5;
        
        // Build expected result using the same path operations
        var directory = Path.GetDirectoryName(baseOutput) ?? "";
        var nameWithoutExt = Path.GetFileNameWithoutExtension(baseOutput);
        var extension = Path.GetExtension(baseOutput);
        var expected = Path.Combine(directory, $"{nameWithoutExt}-{index:D2}{extension}");
        
        // Act
        var result = GeminiTtsHelpers.GenerateNumberedFilename(baseOutput, index);
        
        // Assert
        Assert.Equal(expected, result);
    }

    [Theory]
    [InlineData("*.wav", "merged.wav")]
    [InlineData("test*.wav", "test-merged.wav")]
    [InlineData("output-*.wav", "output-merged.wav")]
    [InlineData("**/*.wav", "all-merged.wav")]
    [InlineData("file*.mp3", "file-merged.wav")] // Extension becomes .wav regardless
    public void GetDefaultOutputFileName_ShouldGenerateCorrectDefaults(string pattern, string expected)
    {
        // Act
        var result = GeminiTtsHelpers.GetDefaultOutputFileName(pattern);
        
        // Assert
        Assert.Equal(expected, result);
    }

    [Fact]
    public void FindWavFiles_ShouldFindMatchingFiles()
    {
        // Arrange - Create files in current directory
        var currentDir = Directory.GetCurrentDirectory();
        var testFiles = new[]
        {
            Path.Combine(currentDir, "test1.wav"),
            Path.Combine(currentDir, "test2.wav"),
            Path.Combine(currentDir, "test3.txt"),
            Path.Combine(currentDir, "other.wav")
        };

        // Create test files
        foreach (var file in testFiles)
        {
            File.WriteAllText(file, "test");
        }

        try
        {
            // Act - Use pattern relative to current directory
            var result = GeminiTtsHelpers.FindWavFiles("test*.wav");

            // Assert
            Assert.Equal(2, result.Length);
            Assert.Contains(testFiles[0], result);
            Assert.Contains(testFiles[1], result);
            Assert.DoesNotContain(testFiles[2], result); // .txt file
            Assert.DoesNotContain(testFiles[3], result); // different name pattern
        }
        finally
        {
            // Cleanup
            foreach (var file in testFiles)
            {
                if (File.Exists(file))
                    File.Delete(file);
            }
        }
    }

    [Fact]
    public void FindWavFiles_ShouldReturnEmptyArray_WhenNoFilesMatch()
    {
        // Act - Use a pattern that won't match anything
        var result = GeminiTtsHelpers.FindWavFiles("nonexistent*.wav");

        // Assert
        Assert.Empty(result);
    }
}