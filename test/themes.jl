using Test
using Colors
using PeptideProjections
using PeptideProjections.Themes

@testset "Themes" begin
    # Test amino acids for each category
    test_aas = (
        positive = 'R',  # Arginine
        negative = 'D',  # Aspartic acid
        polar = 'S',     # Serine
        hydrophobic = 'A', # Alanine
        special = 'P',   # Proline
        other = 'X'      # Unknown
    )

    @testset "AbstractTheme" begin
        @test Themes.themecolor(AbstractTheme, 'A') == colorant"darkgray"
        @test Themes.themetextcolor(AbstractTheme, 'A') == colorant"black"
    end

    @testset "Hydropathy" begin
        @test Themes.themecolor(Hydropathy, test_aas.hydrophobic) == colorant"gray15"
        @test Themes.themecolor(Hydropathy, test_aas.positive) == Themes.COLOR_RED
        @test Themes.themecolor(Hydropathy, test_aas.negative) == Themes.COLOR_RED
        @test Themes.themecolor(Hydropathy, test_aas.polar) == Themes.COLOR_RED
        @test Themes.themecolor(Hydropathy, test_aas.special) == Themes.COLOR_RED
        @test Themes.themecolor(Hydropathy, test_aas.other) == Themes.COLOR_RED
        @test Themes.themetextcolor(Hydropathy, test_aas.positive) == colorant"black"  # Non-hydrophobic AA returns black
    end

    @testset "Colorful" begin
        @test Themes.themecolor(Colorful, test_aas.positive) == Themes.COLOR_POSITIVE
        @test Themes.themecolor(Colorful, test_aas.negative) == Themes.COLOR_NEGATIVE
        @test Themes.themecolor(Colorful, test_aas.polar) == Themes.COLOR_POLAR
        @test Themes.themecolor(Colorful, test_aas.hydrophobic) == Themes.COLOR_HYDROPHOBIC
        @test Themes.themecolor(Colorful, test_aas.special) == colorant"gray70"
        @test Themes.themecolor(Colorful, test_aas.other) == colorant"darkgray"

        # Test text colors
        @test Themes.themetextcolor(Colorful, test_aas.positive) == colorant"white"
        @test Themes.themetextcolor(Colorful, test_aas.negative) == colorant"white"
        @test Themes.themetextcolor(Colorful, test_aas.polar) == colorant"black"
    end

    @testset "ColorfulHydropathy" begin
        @test Themes.themecolor(ColorfulHydropathy, test_aas.hydrophobic) == colorant"gray15"
        @test Themes.themecolor(ColorfulHydropathy, test_aas.positive) == Themes.COLOR_POSITIVE
        @test Themes.themecolor(ColorfulHydropathy, test_aas.negative) == Themes.COLOR_NEGATIVE
        @test Themes.themecolor(ColorfulHydropathy, test_aas.polar) == Themes.COLOR_POLAR
        @test Themes.themecolor(ColorfulHydropathy, test_aas.special) == Themes.COLOR_POLAR  # Falls to else case
        @test Themes.themetextcolor(ColorfulHydropathy, test_aas.positive) == colorant"black"  # Non-hydrophobic AA returns black
    end

    @testset "Color Constants" begin
        @test Themes.COLOR_POSITIVE == colorant"#00a8ff"
        @test Themes.COLOR_NEGATIVE == colorant"#ff5700"
        @test Themes.COLOR_POLAR == colorant"#a8ff00"
        @test Themes.COLOR_HYDROPHOBIC == colorant"#ffd700"
        @test Themes.COLOR_RED == colorant"#ff0028"
    end
end
