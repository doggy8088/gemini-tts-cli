namespace GeminiTtsCli.Tests;

public class CommandValidationTests
{
    [Fact]
    public void ValidateRootCommandOptions_ShouldAllowSayItWithFile()
    {
        var error = GeminiTtsHelpers.ValidateRootCommandOptions(null, "input.txt", sayIt: true, singleOutput: false, merge: false);

        Assert.Null(error);
    }

    [Fact]
    public void ValidateRootCommandOptions_ShouldAllowSayItWithFileReference()
    {
        var error = GeminiTtsHelpers.ValidateRootCommandOptions("@input.txt", null, sayIt: true, singleOutput: false, merge: false);

        Assert.Null(error);
    }

    [Fact]
    public void ValidateRootCommandOptions_ShouldRejectSayItWithMerge()
    {
        var error = GeminiTtsHelpers.ValidateRootCommandOptions(null, "input.txt", sayIt: true, singleOutput: false, merge: true);

        Assert.Equal("Cannot use --sayit with --merge. Playback mode does not write batch outputs.", error);
    }
}
