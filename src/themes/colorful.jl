
abstract type Colorful <: AbstractTheme end


function themecolor(::Type{Colorful}, aa::AbstractChar)
    if ispositive(aa)
        return COLOR_POSITIVE
    elseif isnegative(aa)
        return COLOR_NEGATIVE
    elseif ispolar(aa)
        return COLOR_POLAR
    elseif ishydrophobic(aa)
        return COLOR_HYDROPHOBIC
    elseif isspecial(aa)
        # return darken(COLOR_HYDROPHOBIC, 0.1)
        return colorant"gray70"
    else
        return colorant"darkgray"
    end
end

