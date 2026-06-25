# Reproduces the example images in this directory:
#
#   ll37-wheels.{png,svg} — helical-wheel projections of LL-37, one per theme
#   ll37-nets.{png,svg}   — net projections of LL-37, one per theme
#
# Run from the package root:  julia --project examples/example.jl

using CairoMakie
using PeptideProjections

# LL-37, the human cathelicidin antimicrobial peptide.
const LL37 = "LLGDFFRKSKEKIGKEFKRIVQRIKDFLRNLVPRTES"

const THEMES = [Colorful, ColorfulHydropathy, Hydropathy]

# Match figure cell aspect to data limits so DataAspect panels fill their cells.
const PANEL_WIDTH = 540

net_row_h = let
	f = Figure(size = (PANEL_WIDTH, PANEL_WIDTH))
	ax = Axis(f[1, 1])
	plotnet!(ax, LL37)
	lim = ax.finallimits[]
	round(Int, PANEL_WIDTH * height(lim) / width(lim))
end

wheel_side = round(Int, PANEL_WIDTH / length(THEMES))

# Wheels: one column per theme. plotwheel! sets DataAspect automatically.
wheels = let f = Figure(size = (PANEL_WIDTH, wheel_side))
	axs = Axis[]
	for (i, theme) in enumerate(THEMES)
		ax = Axis(f[1, i]; title = string(theme))
		plotwheel!(ax, LL37; theme = theme)
		push!(axs, ax)
	end
	hidedecorations!.(axs)
	f
end

# Nets: one row per theme; row height follows compressed net data aspect.
nets = let f = Figure(size = (PANEL_WIDTH, net_row_h * length(THEMES)))
	axs = Axis[]
	for (i, theme) in enumerate(THEMES)
		ax = Axis(f[i, 1]; title = string(theme))
		plotnet!(ax, LL37; theme = theme)
		push!(axs, ax)
	end
	hidedecorations!.(axs)
	f
end

for ext in ("png", "svg")
	save(joinpath(@__DIR__, "ll37-wheels.$ext"), wheels)
	save(joinpath(@__DIR__, "ll37-nets.$ext"), nets)
end
