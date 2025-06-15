namespace GeminiTtsCli.Tests;

public class StringUtilityTests
{
    [Theory]
    [InlineData("zephyr", "Zephyr")]
    [InlineData("algieba", "Algieba")]
    [InlineData("AUTONOE", "Autonoe")]
    [InlineData("callirrhoe", "Callirrhoe")]
    [InlineData("a", "A")]
    [InlineData("ABC", "Abc")]
    [InlineData("test", "Test")]
    public void Capitalize_ShouldCapitalizeFirstLetterAndLowercaseRest(string input, string expected)
    {
        // Act
        var result = GeminiTtsHelpers.Capitalize(input);
        
        // Assert
        Assert.Equal(expected, result);
    }

    [Fact]
    public void Capitalize_ShouldThrow_WhenInputIsEmpty()
    {
        // Arrange
        var input = "";

        // Act & Assert
        Assert.Throws<IndexOutOfRangeException>(() => GeminiTtsHelpers.Capitalize(input));
    }

    [Fact]
    public void Capitalize_ShouldThrow_WhenInputIsNull()
    {
        // Arrange
        string? input = null;

        // Act & Assert
        Assert.Throws<NullReferenceException>(() => GeminiTtsHelpers.Capitalize(input!));
    }
}