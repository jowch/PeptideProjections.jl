
abstract type ColorfulHydropathy <: AbstractTheme end

function color(::Type{ColorfulHydropathy}, aa::AbstractChar)
    if ishydrophobic(aa)
        return colorant"gray15"
    elseif ispositive(aa)
        return COLOR_POSITIVE
    elseif isnegative(aa)
        return COLOR_NEGATIVE
    else
        return COLOR_POLAR
    end
end

function textcolor(::Type{ColorfulHydropathy}, aa::AbstractChar)
    if ishydrophobic(aa)
        return colorant"white"
    else
        return colorant"black"
    end
end
