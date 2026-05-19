using Test
using PeptideProjections

const testdir = dirname(@__FILE__)

tests = [
    "aa",
    "themes",
    "coords",
]

@testset "PeptideProjections" begin
    for t in tests
        @info "Testing $t"
        tp = joinpath(testdir, "$(t).jl")
        include(tp)
    end
end
