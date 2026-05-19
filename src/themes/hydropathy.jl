
abstract type Hydropathy <: AbstractTheme end

function themecolor(::Type{Hydropathy}, aa::AbstractChar)
    if ishydrophobic(aa)
        return colorant"gray15"
    else
        return COLOR_RED
    end
end

function themetextcolor(::Type{Hydropathy}, aa::AbstractChar)
    if ishydrophobic(aa)
        return colorant"white"
    else
        return colorant"black"
    end
end
