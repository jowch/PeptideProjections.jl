
COLOR_POSITIVE = :dodgerblue
COLOR_NEGATIVE = :tomato
COLOR_POLAR = :lightgreen
COLOR_HYDROPHOBIC = :gold

function color(aa::AminoAcid)
    if ispositive(aa)
        return COLOR_POSITIVE
    elseif isnegative(aa)
        return COLOR_NEGATIVE
    elseif ispolar(aa)
        return COLOR_POLAR
    elseif ishydrophobic(aa)
        return COLOR_HYDROPHOBIC
    else
        return :darkgray
    end
end

function plotwheel!(
    ax, seq::LongAA;
    rot = 0, label = true, sizefn = volume,
    minsize = 0.15, maxsize = 0.5
)
    is = length(seq):-1:1
    xs = sin.((is .- 1) ./ RESIDUES_PER_TURN .* 2π .- rot)
    ys = cos.((is .- 1) ./ RESIDUES_PER_TURN .* 2π .- rot)
    ss = sizefn.(seq[is]; scaled = true) |> rescale(; lo = minsize, hi = maxsize)
    cs = color.(seq[is])

    lines!(xs, ys, linewidth = 2, color = xs, colormap = :Greys_3)

    for (i, x, y, s, c) ∈ zip(is, xs, ys, ss, cs)
        poly!(
            ax, Circle(Point2f(x, y), s);
            color = c, strokewidth = 2, strokecolor = :black
        )

        if label
            text!(
                ax, string(seq[i]), position = (x, y), align = (:center, :center),
                justification = :center, textsize = 7 * (1 + s)
            )
        end
    end
end

# TODO: Use Makie plot recipes
function plotprofile!(
    ax, seq::LongAA;
    rot = 0, label = true, sizefn = volume,
    minsize = 0.15, maxsize = 0.5
)
    ax.xticks = 1:length(seq)
    xs = 1:0.01:length(seq)

    lines!(
        ax, xs, cos.((xs .- 1) ./ RESIDUES_PER_TURN .* 2π .- rot),
        color = sin.((xs .- 1) ./ RESIDUES_PER_TURN .* 2π .- rot),
        linewidth = 5, colormap = :Greys_3
    )

    colors = color.(seq)
    sizes = sizefn.(seq; scaled = true) |> rescale(; lo = minsize, hi = maxsize)

    for (x, (c, s)) in enumerate(zip(colors, sizes))
        y = cos((x - 1) / RESIDUES_PER_TURN * 2π - rot)
        poly!(
            ax, Circle(Point2f(x, y), s);
            color = c, strokewidth = 2, strokecolor = :black
        )

        if label
            text!(
                ax, string(seq[x]), position = (x, y), align = (:center, :center),
                justification = :center, textsize = 8 * (1 + s)
            )
        end
    end

    ax
end
