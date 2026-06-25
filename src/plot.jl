
abstract type Wheel end
abstract type Net end

"""
    netcoords(seq::AbstractString, rot = 0) -> Vector{Point2f}

Idealized net placement. Residue `i` is placed at `Point2f(i, θ)`, where the
angular coordinate `θ = mod((i - 1) * RADIANS_PER_TURN - rot, 2π)` has period
`2π`. Used as the default `coords` for [`plotnet!`](@ref); supply a custom
vector to plot measured positions instead.
"""
function netcoords(seq::AbstractString, rot = 0)
	[Point2f(i, mod((i - 1) * RADIANS_PER_TURN - rot, 2π)) for (i, _) in enumerate(seq)]
end

"""
    wheelcoords(seq::AbstractString, rot = 0) -> Vector{Point2f}

Idealized helical-wheel placement, reproducing `plotwheel`'s existing spiral
layout verbatim (the radius steps out by `0.5` for each completed full turn).
Used as the default `coords` for [`plotwheel!`](@ref); supply a custom vector to
plot measured positions instead.
"""
function wheelcoords(seq::AbstractString, rot = 0)
	coords = Point2f[]
	num_full_cycles = 0
	for (i, _) in enumerate(seq)
		angle = (i - 1) * RADIANS_PER_TURN - rot
		# a new turn begins each time the angle returns to a multiple of 2π
		if angle % (2π) == 0
			num_full_cycles += 1
		end
		radius = 1 + num_full_cycles * 0.5
		push!(coords, Point2f(radius * sin(angle), radius * cos(angle)))
	end
	coords
end

"""
    turn(i, rot)

Calculate the vertical position of the i-th residue on the wheel.
"""
turn(::Type{Wheel}, i, rot) = sin.((i .- 1) * RADIANS_PER_TURN .- rot)

"""
    sizefn(i, rot; s = 10)

Calculate the size of the i-th residue on the wheel.
"""
sizefn(::Type{Wheel}, i, rot; s = 10) = s * (cos.((i .- 1) * RADIANS_PER_TURN .- rot) / 4 .+ 0.75)

const _NET_MARKERSIZE_FRAC = 0.6
const _WHEEL_MARKERSIZE_FRAC = 0.75
const _LETTER_MARKERSIZE_FRAC = 0.45   # fraction of disk diameter (data units)
const _INDEX_MARKERSIZE_FRAC = 0.28    # subscript, relative to disk diameter
const _WHEEL_LIMIT_PAD_FRAC = 0.65
const _NET_LIMIT_PAD_FRAC = 1.0
const _NET_Y_COMPACT_FRAC = 0.25   # retain 25% of angular (vertical) span
const _MIN_MARKERSIZE = 0.06

function _min_pairwise_spacing(coords)
	n = length(coords)
	n <= 1 && return 1.0
	dmin = Inf
	for i in 1:n, j in (i + 1):n
		a, b = coords[i], coords[j]
		dmin = min(dmin, hypot(a[1] - b[1], a[2] - b[2]))
	end
	dmin
end

# Compress net x (sequence index) to ~2π span and squeeze y (angle) for a tighter panel.
function _net_display_coords(coords)
	xs = getindex.(coords, 1)
	ys = getindex.(coords, 2)
	xmin, xmax = extrema(xs)
	ymin, ymax = extrema(ys)
	xspan = max(xmax - xmin, 1)
	xscale = 2π / xspan
	yc = (ymin + ymax) / 2
	[Point2f((c[1] - xmin) * xscale, yc + (c[2] - yc) * _NET_Y_COMPACT_FRAC) for c in coords]
end

"""
    default_markersize(coords, projection) -> Float64

Default residue disk **diameter** in data units. Disks are sized from the
minimum center-to-center distance among all residue pairs so they do not overlap.
For [`Net`](@ref), `coords` are raw placement coordinates; the same display
compression applied by [`plotnet!`](@ref) is used internally. Pass the second
argument as `Wheel` or `Net` (both exported).
"""
function default_markersize(coords, ::Type{Net})
	display = _net_display_coords(coords)
	max(_MIN_MARKERSIZE, _NET_MARKERSIZE_FRAC * _min_pairwise_spacing(display))
end

function default_markersize(coords, ::Type{Wheel})
	max(_MIN_MARKERSIZE, _WHEEL_MARKERSIZE_FRAC * _min_pairwise_spacing(coords))
end

function _content_limits(coords, markersize; square = false, pad_frac = _NET_LIMIT_PAD_FRAC)
	xs = getindex.(coords, 1)
	ys = getindex.(coords, 2)
	pad = pad_frac * markersize
	xlo, xhi = extrema(xs) .+ (-pad, pad)
	ylo, yhi = extrema(ys) .+ (-pad, pad)
	if square
		side = max(xhi - xlo, yhi - ylo)
		cx = (xlo + xhi) / 2
		cy = (ylo + yhi) / 2
		half = side / 2
		return cx - half, cx + half, cy - half, cy + half
	end
	return xlo, xhi, ylo, yhi
end

# Draw one themed disk plus stacked letter/index labels per residue.
function _drawresidues!(ax, seq::AbstractString, coords, projection;
                        theme = Colorful, markersize)
	stroke_w = max(0.02 * markersize, 0.01)
	letter_fs = _LETTER_MARKERSIZE_FRAC * markersize
	index_fs = _INDEX_MARKERSIZE_FRAC * markersize

	for (i, aa) in enumerate(seq)
		x, y = coords[i][1], coords[i][2]
		c = Themes.themecolor(theme, aa)
		tc = Themes.themetextcolor(theme, aa)
		scatter!(
			ax, x, y;
			color = c, strokecolor = darken(c, 0.1), strokewidth = stroke_w,
			marker = Circle, markerspace = :data, markersize = markersize
		)
		label = rich(string(aa), subscript(string(i); fontsize = index_fs))
		text!(
			ax, x, y;
			text = label, align = (:center, :center),
			color = tc, fontsize = letter_fs, font = :bold,
			markerspace = :data
		)
	end

	nothing
end

"""
    plotwheel!(ax, seq::AbstractString, rot = 0; theme = Colorful, markersize = nothing,
               coords = wheelcoords(seq, rot))

Plot the helical wheel on the given axis. Placement defaults to
[`wheelcoords`](@ref); pass `coords` (a `Vector{Point2f}`, one per residue) to
plot measured positions instead, in which case `rot` is ignored.

Disk **diameter** defaults from [`default_markersize`](@ref); pass `markersize`
(data units) to override. Sets [`DataAspect`](@ref) and axis limits from disk
extent (overwriting any prior `aspect` and `limits` on `ax`).
"""
function plotwheel!(ax, seq::AbstractString, rot = 0; theme = Colorful, markersize = nothing,
                    coords = wheelcoords(seq, rot))
	length(coords) == length(seq) || throw(ArgumentError(
		"coords has $(length(coords)) points but seq has $(length(seq)) residues"))

	ms = something(markersize, default_markersize(coords, Wheel))
	ax.aspect[] = DataAspect()
	limits!(ax, _content_limits(coords, ms; square = true, pad_frac = _WHEEL_LIMIT_PAD_FRAC)...)
	_drawresidues!(ax, seq, coords, Wheel; theme, markersize = ms)

	nothing
end

"""
	plotwheel(seq::AbstractString, rot = 0; scale = 150, kwargs...)

Plot the wheel on a new figure. See `plotwheel!` for drawing options. `scale`
sets export pixel size only (`scale .* (15, 4)`); disk size is controlled by
`markersize` in data units.
"""
function plotwheel(seq::AbstractString, rot = 0; scale = 150, kwargs...)
	f = Figure(size = scale .* (15, 4))
	ax = Axis(f[1, 1], yticks = ([-π/2, 0, π/2], ["-π/2", "0", "π/2"]))

	plotwheel!(ax, seq, rot; kwargs...)

	f
end


"""
    plotnet!(ax, seq::AbstractString, rot = 0; theme = Colorful, markersize = nothing,
             coords = netcoords(seq, rot))

Plot the net on the given axis. Placement defaults to [`netcoords`](@ref); pass
`coords` (a `Vector{Point2f}`, one per residue) to plot measured positions
instead, in which case `rot` is ignored.

Disk **diameter** defaults from [`default_markersize`](@ref); pass `markersize`
(data units) to override. The index and angular axes are compressed for a compact
panel with [`DataAspect`](@ref). Sets axis limits from disk extent (overwriting
any prior `aspect` and `limits` on `ax`).
"""
function plotnet!(ax, seq::AbstractString, rot = 0; theme = Colorful, markersize = nothing,
                  coords = netcoords(seq, rot))
	length(coords) == length(seq) || throw(ArgumentError(
		"coords has $(length(coords)) points but seq has $(length(seq)) residues"))

	display = _net_display_coords(coords)
	ms = something(markersize, default_markersize(coords, Net))
	ax.aspect[] = DataAspect()
	limits!(ax, _content_limits(display, ms; pad_frac = _NET_LIMIT_PAD_FRAC)...)
	_drawresidues!(ax, seq, display, Net; theme, markersize = ms)

	nothing
end

"""
	plotnet(seq::AbstractString, rot = 0; scale = 150, kwargs...)

Plot the net on a new figure. See `plotnet!` for drawing options. `scale` sets
export pixel size only (`scale .* (4, 1.2)`); disk size is controlled by
`markersize` in data units.
"""
function plotnet(seq::AbstractString, rot = 0; scale = 150, kwargs...)
	f = Figure(size = scale .* (4, 1.2))
	ax = Axis(f[1, 1])

	plotnet!(ax, seq, rot; kwargs...)

	hidedecorations!(ax)

	f
end
