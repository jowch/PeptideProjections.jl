
"""
    rescale(A, [minvalue], [maxvalue]; lo = 0, hi = 1)

Rescale values in array A to range from `lo` to `hi`.
"""
function rescale(A, minvalue = nothing, maxvalue = nothing; lo = 0, hi = 1)
    if isnothing(minvalue)
        minvalue = minimum(A)
    end

    if isnothing(maxvalue)
        maxvalue = maximum(A)
    end

    if minvalue < maxvalue
        (A .- minvalue) ./ (maxvalue - minvalue) .* (hi - lo) .+ lo
    else
        A
    end
end

function rescale(args...; kwargs...)
    A -> rescale(A, args...; kwargs...)
end

"""
    darken(color, p)

Darken a color by a factor of `p`.
"""
darken((; r, g, b)::T, p::Real) where {T <: AbstractRGB} =
    T(clamp01(r * (1 - p)), clamp01(g * (1 - p)), clamp01(b * (1 - p)))

darken((; r, g, b, alpha)::T, p::Real) where {T <: AbstractRGBA} =
    T(clamp01(r * (1 - p)), clamp01(g * (1 - p)), clamp01(b * (1 - p)), alpha)

"""
    lighten(color, p)

Lighten a color by a factor of `p`.
"""
lighten(color::AbstractRGB, p::Real) = darken(color, -p)

"""
    clamp(x, lo = 0, hi = 1)

Clamp a value `x` to be between `lo` and `hi`.
"""
clamp(x, lo = 0, hi = 1) = x < lo ? lo : x > hi ? hi : x

"""
    clamp01(x)

Clamp a value `x` to be between 0 and 1.
"""
clamp01(x) = clamp(x)

function _linear_srgb(c)
	c <= 0.03928 ? c / 12.92 : ((c + 0.055) / 1.055)^2.4
end

"""
    relative_luminance(color) -> Float64

WCAG 2.x relative luminance of an sRGB color (0 = black, 1 = white).
"""
function relative_luminance((; r, g, b)::Colorant)
	0.2126 * _linear_srgb(r) + 0.7152 * _linear_srgb(g) + 0.0722 * _linear_srgb(b)
end

"""
    text_on(bg) -> Colorant

Pick black or white label text for readable contrast on solid fill color `bg`.
"""
text_on(bg::Colorant) = relative_luminance(bg) < 0.5 ? colorant"white" : colorant"black"
