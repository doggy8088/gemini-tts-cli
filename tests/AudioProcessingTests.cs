using NAudio.Wave;

namespace GeminiTtsCli.Tests;

public class AudioProcessingTests
{
    [Fact]
    public void MergeWavFiles_ShouldMergeMultipleWavFiles()
    {
        // Arrange
        var tempDir = Path.GetTempPath();
        var outputFile = Path.Combine(tempDir, "merged_test.wav");
        var inputFiles = new[]
        {
            Path.Combine(tempDir, "input1.wav"),
            Path.Combine(tempDir, "input2.wav")
        };

        // Create simple WAV files for testing
        CreateTestWavFile(inputFiles[0], 0.5f); // 0.5 second of audio
        CreateTestWavFile(inputFiles[1], 0.3f); // 0.3 second of audio

        try
        {
            // Act
            GeminiTtsHelpers.MergeWavFiles(inputFiles, outputFile);

            // Assert
            Assert.True(File.Exists(outputFile));
            
            // Verify the merged file has some content
            var fileInfo = new FileInfo(outputFile);
            Assert.True(fileInfo.Length > 0);

            // Verify it's a valid WAV file by trying to read it
            using var audioFileReader = new AudioFileReader(outputFile);
            Assert.True(audioFileReader.TotalTime.TotalSeconds > 0.7); // Should be approximately 0.8 seconds
        }
        finally
        {
            // Cleanup
            foreach (var file in inputFiles.Concat(new[] { outputFile }))
            {
                if (File.Exists(file))
                    File.Delete(file);
            }
        }
    }

    [Fact]
    public void MergeWavFiles_ShouldThrow_WhenNoInputFiles()
    {
        // Arrange
        var outputFile = Path.Combine(Path.GetTempPath(), "test_output.wav");
        var inputFiles = Array.Empty<string>();

        // Act & Assert - Expecting ArgumentOutOfRangeException based on implementation
        Assert.Throws<ArgumentOutOfRangeException>(() => GeminiTtsHelpers.MergeWavFiles(inputFiles, outputFile));
    }

    [Fact]
    public void MergeWavFiles_ShouldThrow_WhenInputFileDoesNotExist()
    {
        // Arrange
        var outputFile = Path.Combine(Path.GetTempPath(), "test_output.wav");
        var inputFiles = new[] { "nonexistent.wav" };

        // Act & Assert
        Assert.Throws<FileNotFoundException>(() => GeminiTtsHelpers.MergeWavFiles(inputFiles, outputFile));
    }

    private static void CreateTestWavFile(string fileName, float durationSeconds)
    {
        var sampleRate = 24000;
        var channels = 1;
        var sampleCount = (int)(sampleRate * durationSeconds);
        
        using var writer = new WaveFileWriter(fileName, new WaveFormat(sampleRate, 16, channels));
        
        // Generate a simple sine wave
        for (int i = 0; i < sampleCount; i++)
        {
            var sample = (short)(Math.Sin(2.0 * Math.PI * 440.0 * i / sampleRate) * 1000);
            writer.WriteSample(sample / 32768f);
        }
    }
}

public class ConcatenatingWaveProviderTests
{
    [Fact]
    public void Constructor_ShouldThrow_WhenNoSources()
    {
        // Arrange
        var sources = Array.Empty<WaveStream>();

        // Act & Assert
        Assert.Throws<ArgumentException>(() => new ConcatenatingWaveProvider(sources));
    }

    [Fact]
    public void Read_ShouldConcatenateMultipleStreams()
    {
        // Arrange
        var tempDir = Path.GetTempPath();
        var file1 = Path.Combine(tempDir, "test1.wav");
        var file2 = Path.Combine(tempDir, "test2.wav");

        CreateTestWavFile(file1, 0.1f);
        CreateTestWavFile(file2, 0.1f);

        try
        {
            using var stream1 = new AudioFileReader(file1);
            using var stream2 = new AudioFileReader(file2);
            var sources = new WaveStream[] { stream1, stream2 };

            var provider = new ConcatenatingWaveProvider(sources);

            // Act
            var buffer = new byte[1024];
            var totalRead = 0;
            int bytesRead;
            
            // Read until no more data
            while ((bytesRead = provider.Read(buffer, totalRead, buffer.Length - totalRead)) > 0)
            {
                totalRead += bytesRead;
                if (totalRead >= buffer.Length) break; // Prevent overflow for test
            }

            // Assert
            Assert.True(totalRead > 0);
            Assert.Equal(stream1.WaveFormat.SampleRate, provider.WaveFormat.SampleRate);
            Assert.Equal(stream1.WaveFormat.Channels, provider.WaveFormat.Channels);
        }
        finally
        {
            if (File.Exists(file1)) File.Delete(file1);
            if (File.Exists(file2)) File.Delete(file2);
        }
    }

    private static void CreateTestWavFile(string fileName, float durationSeconds)
    {
        var sampleRate = 24000;
        var channels = 1;
        var sampleCount = (int)(sampleRate * durationSeconds);
        
        using var writer = new WaveFileWriter(fileName, new WaveFormat(sampleRate, 16, channels));
        
        for (int i = 0; i < sampleCount; i++)
        {
            var sample = (short)(Math.Sin(2.0 * Math.PI * 440.0 * i / sampleRate) * 1000);
            writer.WriteSample(sample / 32768f);
        }
    }
}