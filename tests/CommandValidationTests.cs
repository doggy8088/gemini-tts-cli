namespace GeminiTtsCli.Tests;

public class CommandValidationTests
{
    [Fact]
    public void NormalizeShortcutArgs_ShouldMapBareTextToTextOption()
    {
        var result = GeminiTtsHelpers.NormalizeShortcutArgs(["Hello world"]);

        Assert.Equal(["--text", "Hello world"], result);
    }

    [Fact]
    public void NormalizeShortcutArgs_ShouldMapFileReferenceToTextOption()
    {
        var result = GeminiTtsHelpers.NormalizeShortcutArgs(["@input.txt"]);

        Assert.Equal(["--text", "\"@input.txt\""], result);
    }

    [Fact]
    public void NormalizeShortcutArgs_ShouldPreserveTrailingOptions()
    {
        var result = GeminiTtsHelpers.NormalizeShortcutArgs(["Hello world", "--sayit"]);

        Assert.Equal(["--text", "Hello world", "--sayit"], result);
    }

    [Fact]
    public void NormalizeShortcutArgs_ShouldQuoteFileReferenceAfterTextOption()
    {
        var result = GeminiTtsHelpers.NormalizeShortcutArgs(["-t", "@input.txt"]);

        Assert.Equal(["-t", "\"@input.txt\""], result);
    }

    [Theory]
    [InlineData("--text")]
    [InlineData("list-voices")]
    [InlineData("merge")]
    [InlineData("help")]
    public void NormalizeShortcutArgs_ShouldLeaveOptionsAndCommandsUnchanged(string firstArg)
    {
        var result = GeminiTtsHelpers.NormalizeShortcutArgs([firstArg]);

        Assert.Equal([firstArg], result);
    }

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
