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
