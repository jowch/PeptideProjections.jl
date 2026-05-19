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

@testset "Rendering and coords override" begin
    seq = "LLGDFFRK"

    @testset "default placement" begin
        @test plotnet(seq) isa Figure
        @test plotwheel(seq) isa Figure
    end

    @testset "coords override" begin
        @test plotnet(seq; coords = netcoords(seq)) isa Figure
        @test plotwheel(seq; coords = wheelcoords(seq)) isa Figure

        f = Figure()
        ax = Axis(f[1, 1])
        @test plotnet!(ax, seq; coords = netcoords(seq)) === nothing
        @test plotwheel!(ax, seq; coords = wheelcoords(seq)) === nothing

        # a synthetic placement, distinct from the computed defaults, is
        # accepted and rendered through the same themed renderer
        custom = [Point2f(i, 0.0) for i in 1:length(seq)]
        @test plotnet(seq; coords = custom) isa Figure
        @test plotwheel(seq; coords = custom) isa Figure
        @test plotnet!(ax, seq; coords = custom) === nothing
        @test plotwheel!(ax, seq; coords = custom) === nothing
    end

    @testset "coords length mismatch" begin
        f = Figure()
        ax = Axis(f[1, 1])
        @test_throws ArgumentError plotnet!(ax, seq; coords = netcoords("AC"))
        @test_throws ArgumentError plotwheel!(ax, seq; coords = wheelcoords("AC"))
    end
end
