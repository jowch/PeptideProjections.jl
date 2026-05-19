using Test
using CairoMakie
using PeptideProjections
using PeptideProjections: RADIANS_PER_TURN

@testset "Placement coordinates" begin
    seq = "LLGDFFRK"

    @testset "netcoords" begin
        coords = netcoords(seq)
        @test coords isa Vector{Point2f}
        @test length(coords) == length(seq)
        # x is the 1-based sequence index
        @test first.(coords) == 1:length(seq)
        # angular coordinate has period 2π
        @test all(0 .<= last.(coords) .< 2π)
        # residue 1 at rot 0 sits at angle 0
        @test last(netcoords("A")[1]) == 0
        # rot shifts the angular coordinate
        @test last(netcoords("A", 1.0)[1]) ≈ mod(-1.0, 2π)
        # consecutive residues step by RADIANS_PER_TURN before wrapping
        @test last(coords[2]) ≈ mod(RADIANS_PER_TURN, 2π)
    end

    @testset "wheelcoords" begin
        coords = wheelcoords(seq)
        @test coords isa Vector{Point2f}
        @test length(coords) == length(seq)
        # residue 1 at rot 0: angle 0, radius 1.5 → (0, 1.5)
        @test wheelcoords("A")[1] ≈ Point2f(0, 1.5)
    end
end
