module Themes
    using Colors

    import ..PeptideProjections: ispositive, isnegative, ischarged, ispolar, ishydrophobic, isspecial,
                                 text_on

    export AbstractTheme, Hydropathy, Colorful, ColorfulHydropathy

    abstract type AbstractTheme end

    # colors
    COLOR_POSITIVE = colorant"#00a8ff"
    COLOR_NEGATIVE = colorant"#ff5700"
    COLOR_POLAR = colorant"#a8ff00"
    COLOR_HYDROPHOBIC = colorant"#ffd700"
    COLOR_RED = colorant"#ff0028"

    """
        themecolor(::Type{<:AbstractTheme}, aa::AbstractChar)

    Return the marker color for the given amino acid for the provided theme.
    """
    themecolor(::Type{<:AbstractTheme}, aa::AbstractChar) = colorant"darkgray"

    """
        themetextcolor(::Type{<:AbstractTheme}, aa::AbstractChar)

    Return the label text color for the given amino acid for the provided theme.
    """
    themetextcolor(theme::Type{<:AbstractTheme}, aa::AbstractChar) =
        text_on(themecolor(theme, aa))

    include("hydropathy.jl")
    include("colorful.jl")
    include("colorfulhydropathy.jl")
end