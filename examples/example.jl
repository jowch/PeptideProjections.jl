# Reproduces the example images in this directory:
#
#   ll37-wheels.{png,svg}       — LL-37 helical wheels, one panel per theme
#   ll37-nets.{png,svg}         — LL-37 nets, one panel per theme
#   comparison-wheels.{png,svg} — LL-37 vs magainin-2 wheels (rows) × themes (cols)
#   comparison-nets.{png,svg}   — LL-37 vs magainin-2 nets (rows) × themes (cols)
#
# Run from the package root:  julia --project examples/example.jl

using CairoMakie
using PeptideProjections

const LL37 = "LLGDFFRKSKEKIGKEFKRIVQRIKDFLRNLVPRTES"
const MAGAININ2 = "GIGKFLHSAKKFGKAFVGEIMNS"

const THEMES = [Colorful, ColorfulHydropathy, Hydropathy]
const PANEL_WIDTH = 540

function net_row_height(seq; panel_width = PANEL_WIDTH)
	f = Figure(size = (panel_width, panel_width))
	ax = Axis(f[1, 1])
	plotnet!(ax, seq)
	lim = ax.finallimits[]
	round(Int, panel_width * height(lim) / width(lim))
end

function theme_row_figure(seq; projection = plotwheel!)
	row_h = projection === plotnet! ? net_row_height(seq) : round(Int, PANEL_WIDTH / length(THEMES))
	f = Figure(size = (PANEL_WIDTH, row_h))
	axs = Axis[]
	for (i, theme) in enumerate(THEMES)
		ax = Axis(f[1, i]; title = string(theme))
		projection(ax, seq; theme = theme)
		push!(axs, ax)
	end
	hidedecorations!.(axs)
	f
end

function comparison_figure(seqs, labels; projection = plotwheel!)
	row_h = if projection === plotnet!
		maximum(net_row_height(s) for s in seqs)
	else
		round(Int, PANEL_WIDTH / length(THEMES))
	end
	f = Figure(size = (PANEL_WIDTH, row_h * length(seqs)))
	axs = Axis[]
	for (row, (seq, label)) in enumerate(zip(seqs, labels))
		for (col, theme) in enumerate(THEMES)
			title = col == 1 ? "$label — $(theme)" : string(theme)
			ax = Axis(f[row, col]; title = title)
			projection(ax, seq; theme = theme)
			push!(axs, ax)
		end
	end
	hidedecorations!.(axs)
	f
end

ll37_wheels = theme_row_figure(LL37; projection = plotwheel!)
ll37_nets = let
	row_h = net_row_height(LL37)
	f = Figure(size = (PANEL_WIDTH, row_h * length(THEMES)))
	axs = Axis[]
	for (i, theme) in enumerate(THEMES)
		ax = Axis(f[i, 1]; title = string(theme))
		plotnet!(ax, LL37; theme = theme)
		push!(axs, ax)
	end
	hidedecorations!.(axs)
	f
end

comparison_wheels = comparison_figure(
	[LL37, MAGAININ2], ["LL-37", "Magainin 2"]; projection = plotwheel!)
comparison_nets = comparison_figure(
	[LL37, MAGAININ2], ["LL-37", "Magainin 2"]; projection = plotnet!)

for (name, fig) in (
	("ll37-wheels", ll37_wheels),
	("ll37-nets", ll37_nets),
	("comparison-wheels", comparison_wheels),
	("comparison-nets", comparison_nets),
)
	for ext in ("png", "svg")
		save(joinpath(@__DIR__, "$name.$ext"), fig)
	end
end
