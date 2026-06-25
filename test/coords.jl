using Test
using CairoMakie
using PeptideProjections
using PeptideProjections: RADIANS_PER_TURN, Wheel, Net, _net_display_coords, _WHEEL_MARKERSIZE_FRAC,
                            _MIN_MARKERSIZE

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

    @testset "net display coords" begin
        raw = netcoords(seq)
        display = _net_display_coords(raw)
        @test first(extrema(first.(display))) ≈ 0.0
        @test last(extrema(first.(display))) ≈ 2π
        @test length(display) == length(raw)
    end

    @testset "default_markersize" begin
        net_coords = netcoords(seq)
        wheel_coords = wheelcoords(seq)
        net_display = _net_display_coords(net_coords)
        @test default_markersize(net_coords, Net) > 0
        @test default_markersize(wheel_coords, Wheel) > 0
        pair_min(coords) = minimum(
            hypot(coords[i][1] - coords[j][1], coords[i][2] - coords[j][2])
            for i in 1:length(coords) for j in (i + 1):length(coords))
        @test default_markersize(net_coords, Net) <= pair_min(net_display)
        @test default_markersize(wheel_coords, Wheel) <= pair_min(wheel_coords)
        @test default_markersize([Point2f(0, 0)], Wheel) ==
              max(_MIN_MARKERSIZE, _WHEEL_MARKERSIZE_FRAC)
    end
end

@testset "Rendering and coords override" begin
    seq = "LLGDFFRK"

    @testset "default placement" begin
        @test plotnet(seq) isa Figure
        @test plotwheel(seq) isa Figure
    end

    @testset "figure sizes" begin
        f_small = Figure(size = (400, 200))
        ax = Axis(f_small[1, 1])
        plotwheel!(ax, seq)
        @test ax.aspect[] isa DataAspect

        f_large = Figure(size = (1200, 600))
        ax2 = Axis(f_large[1, 1])
        plotnet!(ax2, seq)
        @test width(ax2.finallimits[]) > 0
        @test ax2.aspect[] isa DataAspect

        # data limits and disk sizing are geometry-driven, not pixel-driven
        f_a = Figure(size = (240, 240))
        ax_a = Axis(f_a[1, 1])
        plotwheel!(ax_a, seq)
        f_b = Figure(size = (960, 960))
        ax_b = Axis(f_b[1, 1])
        plotwheel!(ax_b, seq)
        @test ax_a.finallimits[] ≈ ax_b.finallimits[]

        f_c = Figure(size = (300, 300))
        ax_c = Axis(f_c[1, 1])
        plotnet!(ax_c, seq)
        f_d = Figure(size = (900, 900))
        ax_d = Axis(f_d[1, 1])
        plotnet!(ax_d, seq)
        @test ax_c.finallimits[] ≈ ax_d.finallimits[]
    end

    @testset "markersize override" begin
        f = Figure()
        ax = Axis(f[1, 1])
        plotnet!(ax, seq; markersize = 0.08)
        @test width(ax.finallimits[]) > 0
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
