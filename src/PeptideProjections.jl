module PeptideProjections

using Colors
using CairoMakie

export
    # Theme types
    AbstractTheme, Hydropathy, Colorful, ColorfulHydropathy,

    # Theme color API
    themecolor, themetextcolor,

    # Helix geometry constants
    RESIDUES_PER_TURN, RADIANS_PER_TURN,

    # Placement
    netcoords, wheelcoords,

    # Plot functions
    plotwheel, plotwheel!, plotnet, plotnet!

include("util.jl")
include("aa.jl")
include("themes/themes.jl")

# Import the theme types and functions
using .Themes
using .Themes: AbstractTheme, Hydropathy, Colorful, ColorfulHydropathy,
               themecolor, themetextcolor

include("plot.jl")

end # module PeptideProjections
