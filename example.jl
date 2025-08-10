using CairoMakie
using PeptideProjections

let f = Figure(size = 50 .* (12, 5))
    axs = Axis[]

    for (i, theme) in enumerate([Colorful, ColorfulHydropathy, Hydropathy])
		ax = Axis(f[1, i], yticks = ([-π/2, 0, π/2], ["-π/2", "0", "π/2"]), title = string(theme), aspect = DataAspect())
        plotwheel!(ax, "LLGDFFRKSKEKIGKEFKRIVQRIKDFLRNLVPRTES", theme = theme)
        push!(axs, ax)
    end

    hidedecorations!.(axs)

    f
end

let f = Figure(size = 50 .* (5, 8))
    axs = Axis[]

    for (i, theme) in enumerate([Colorful, ColorfulHydropathy, Hydropathy])
		ax = Axis(f[i, 1], yticks = ([-π/2, 0, π/2], ["-π/2", "0", "π/2"]), title = string(theme))
        plotnet!(ax, "LLGDFFRKSKEKIGKEFKRIVQRIKDFLRNLVPRTES", theme = theme)
        push!(axs, ax)
    end

    hidedecorations!.(axs)

    f
end
    
