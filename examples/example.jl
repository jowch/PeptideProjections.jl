# Reproduces the example images in this directory:
#
#   ll37-wheels.png — helical-wheel projections of LL-37, one per theme
#   ll37-nets.png   — net projections of LL-37, one per theme
#
# Run from the package root:  julia --project examples/example.jl

using CairoMakie
using PeptideProjections

# LL-37, the human cathelicidin antimicrobial peptide.
const LL37 = "LLGDFFRKSKEKIGKEFKRIVQRIKDFLRNLVPRTES"

const THEMES = [Colorful, ColorfulHydropathy, Hydropathy]

# Wheels: one column per theme. DataAspect keeps each wheel circular.
wheels = let f = Figure(size = 50 .* (12, 5))
    axs = Axis[]
    for (i, theme) in enumerate(THEMES)
        ax = Axis(f[1, i]; title = string(theme), aspect = DataAspect())
        plotwheel!(ax, LL37; theme = theme)
        push!(axs, ax)
    end
    hidedecorations!.(axs)
    f
end

# Nets: one row per theme.
nets = let f = Figure(size = 50 .* (5, 8))
    axs = Axis[]
    for (i, theme) in enumerate(THEMES)
        ax = Axis(f[i, 1]; title = string(theme))
        plotnet!(ax, LL37; theme = theme)
        push!(axs, ax)
    end
    hidedecorations!.(axs)
    f
end

save(joinpath(@__DIR__, "ll37-wheels.png"), wheels)
save(joinpath(@__DIR__, "ll37-nets.png"), nets)
