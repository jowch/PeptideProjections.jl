module PeptideProjections

using BioSequences
using CairoMakie

export
isspecial, ishydrophobic, ispositive, isnegative, ischarged, ispolar,
molecularweight, volume, plotwheel!, plotprofile!

include("util.jl")
include("aa.jl")
include("plot.jl")

end # module PeptideProjections
