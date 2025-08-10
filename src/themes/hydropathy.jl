
abstract type Hydropathy <: AbstractTheme end

function color(::Type{Hydropathy}, aa::AbstractChar)
    if ishydrophobic(aa)
        return colorant"gray15"
    else
        return COLOR_RED
    end
end

function textcolor(::Type{Hydropathy}, aa::AbstractChar)
    if ishydrophobic(aa)
        return colorant"white"
    else
        return colorant"black"
    end
end
