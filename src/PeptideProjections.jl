module PeptideProjections

using Colors
using CairoMakie

export
    # Theme types
    AbstractTheme, Hydropathy, Colorful, ColorfulHydropathy,

    # Plot functions
    plotwheel, plotwheel!, plotnet, plotnet!

include("util.jl")
include("aa.jl")
include("themes/themes.jl")

# Import the theme types and functions
using .Themes
using .Themes: AbstractTheme, Hydropathy, Colorful, ColorfulHydropathy

include("plot.jl")

end # module PeptideProjections
