
abstract type Wheel end
abstract type Net end

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

"""
    plotwheel!(ax, seq::AbstractString, rot = 0; theme = Colorful)

Plot the wheel on the given axis.
"""
function plotwheel!(ax, seq::AbstractString, rot = 0; theme = Colorful, scale = 150)
	num_full_cycles = 0

	for (i, aa) in enumerate(seq)
		angle = (i - 1) * RADIANS_PER_TURN - rot

		# increment num_full_cycles when we fill all of the possible positions
		# in the first loop
		if angle % (2π) == 0
			num_full_cycles += 1
		end

		radius = 1 + num_full_cycles * 0.5

		x = radius * sin(angle)
		y = radius * cos(angle)

		c = Themes.themecolor(theme, aa)
		scatter!(
			ax, x, y;
			color = c, strokecolor = darken(c, 0.1), strokewidth = 1,
			markersize = 0.2 * scale
		)
		text!(
			ax, x, y; text = string(aa), align = (:center, :center),
			offset = (0, 2),
			color = Themes.themetextcolor(theme, aa), fontsize = 10, font = :bold
		)
		text!(
			ax, x, y; text = string(i), align = (:center, :top),
			offset = (0, -2),
			color = Themes.themetextcolor(theme, aa), fontsize = 5, font = :bold
		)
	end

	nothing
end

"""
	plotwheel(seq::AbstractString, rot = 0; scale = 150, kwargs...)

Plot the wheel on a new figure. See `plotwheel!` for more details.
"""
function plotwheel(seq::AbstractString, rot = 0; scale = 150, kwargs...)
	f = Figure(size = scale .* (15, 4))
	ax = Axis(f[1, 1], yticks = ([-π/2, 0, π/2], ["-π/2", "0", "π/2"]))

	plotwheel!(ax, seq, rot; kwargs...)

	f
end


turn(::Type{Net}, i, rot) = mod.(i .- rot, 2π / RADIANS_PER_TURN)

"""
	plotnet!(ax, seq::AbstractString, rot = 0; theme = Colorful, scale = 150)

Plot the net on the given axis.
"""
function plotnet!(ax, seq::AbstractString, rot = 0; theme = Colorful, scale = 150)
	for (i, aa) in enumerate(seq)
		c = Themes.themecolor(theme, aa)
		scatter!(
			ax, i, turn(Net, i, rot);
			color = c, strokecolor = darken(c, 0.1), strokewidth = 1,
			markersize = 0.2 * scale
		)
		text!(
			ax, i, turn(Net, i, rot); text = string(aa), align = (:center, :center),
			offset = (0, 2),
			color = Themes.themetextcolor(theme, aa), fontsize = 10, font = :bold
		)
		text!(
			ax, i, turn(Net, i, rot); text = string(i), align = (:center, :top),
			offset = (0, -2),
			color = Themes.themetextcolor(theme, aa), fontsize = 5, font = :bold
		)
	end

	nothing
end

"""
	plotnet(seq::AbstractString, rot = 0; scale = 150, kwargs...)

Plot the net on a new figure. See `plotnet!` for more details.
"""
function plotnet(seq::AbstractString, rot = 0; scale = 150, kwargs...)
	f = Figure(size = scale .* (length(seq) / 15, 1))
	ax = Axis(f[1, 1])

	plotnet!(ax, seq, rot; scale, kwargs...)

	hidedecorations!(ax)
	
	f
end
