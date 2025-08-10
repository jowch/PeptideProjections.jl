using CairoMakie
using PeptideProjections

let f = Figure(size = 50 .* (5, 15))
    axs = Axis[]

    for (i, theme) in enumerate([Colorful, ColorfulHydropathy, Hydropathy])
		ax = Axis(f[i, 1], yticks = ([-π/2, 0, π/2], ["-π/2", "0", "π/2"]))
        plotwheel!(ax, "LLGDFFRKSKEKIGKEFKRIVQRIKDFLRNLVPRTES", theme = theme)
        push!(axs, ax)
    end

    hidedecorations!.(axs)

    f
end

let f = Figure(size = 50 .* (8, 5))
    axs = Axis[]

    for (i, theme) in enumerate([Colorful, ColorfulHydropathy, Hydropathy])
		ax = Axis(f[i, 1], yticks = ([-π/2, 0, π/2], ["-π/2", "0", "π/2"]))
        plotnet!(ax, "LLGDFFRKSKEKIGKEFKRIVQRIKDFLRNLVPRTES", theme = theme)
        push!(axs, ax)
    end

    hidedecorations!.(axs)

    f
end
    
