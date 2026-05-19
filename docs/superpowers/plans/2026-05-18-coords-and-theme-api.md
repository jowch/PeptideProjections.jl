# Coordinate & Theme API Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make PeptideProjections' themed net/wheel renderer reusable by PeptideGraphs.jl — expose placement as data, accept a placement override, and publish the theme color API and helix geometry constants.

**Architecture:** Four additive, backward-compatible changes to PeptideProjections.jl. Placement math is factored into pure functions `netcoords`/`wheelcoords` returning `Vector{Point2f}`; `plotnet!`/`plotwheel!` call them by default but accept a `coords` keyword override; a shared private `_drawresidues!` helper does the drawing. The theme color functions are renamed and exported. The idealized net's angular coordinate is in radians (period `2π`) so it shares a coordinate system with PeptideGraphs' measured `θ`.

**Tech Stack:** Julia, CairoMakie (hard dependency), Colors, Test.

---

## Background for the implementer

This is a Julia package. Source lives in `src/`, tests in `test/`. The module
`src/PeptideProjections.jl` `include`s, in order: `util.jl`, `aa.jl`,
`themes/themes.jl`, `plot.jl`. The `Themes` submodule (`src/themes/`) holds a
generic `color`/`textcolor` function with a fallback method plus one method per
theme; each theme is an abstract type used purely as a dispatch tag.

Run the whole test suite from the package root:

    julia --project -e 'using Pkg; Pkg.test()'

`test/runtests.jl` `include`s one file per entry in its `tests` vector inside a
top-level `@testset`. `Point2f` and `Figure` come from CairoMakie, which is a
dependency of the package and so resolvable in the test environment once added
to `test/Project.toml`.

---

## File Structure

- `src/themes/themes.jl` — modify: rename the fallback `color`/`textcolor`.
- `src/themes/hydropathy.jl`, `colorful.jl`, `colorfulhydropathy.jl` — modify: rename the per-theme methods.
- `src/plot.jl` — modify: add `netcoords`/`wheelcoords`/`_drawresidues!`; refactor `plotnet!`/`plotwheel!`.
- `src/PeptideProjections.jl` — modify: imports and `export` list.
- `src/aa.jl` — unchanged (constants already `const`; only exported from the module file).
- `test/Project.toml` — modify: add CairoMakie.
- `test/runtests.jl` — modify: add `"coords"` to the `tests` list.
- `test/themes.jl` — modify: rename call sites.
- `test/coords.jl` — create: tests for `netcoords`/`wheelcoords` and the render/override behaviour.
- `Project.toml` — modify: version bump.
- `README.md` — modify: API reference.

---

## Task 1: Rename and export the theme color API

Renames `Themes.color → themecolor` and `Themes.textcolor → themetextcolor`,
then exports the new names plus the helix geometry constants.

**Files:**
- Modify: `test/themes.jl`
- Modify: `src/themes/themes.jl`
- Modify: `src/themes/hydropathy.jl`
- Modify: `src/themes/colorful.jl`
- Modify: `src/themes/colorfulhydropathy.jl`
- Modify: `src/plot.jl`
- Modify: `src/PeptideProjections.jl`

- [ ] **Step 1: Update the theme tests to the new names**

In `test/themes.jl`, replace every occurrence of `Themes.color(` with
`Themes.themecolor(` and every occurrence of `Themes.textcolor(` with
`Themes.themetextcolor(`. (Use an editor replace-all; there are ~10 of the
first and ~5 of the second. The color-constant tests like
`Themes.COLOR_POSITIVE` are unaffected.)

- [ ] **Step 2: Run the theme tests to verify they fail**

Run: `julia --project -e 'using Pkg; Pkg.test()'`
Expected: FAIL — `UndefVarError: themecolor not defined` (or similar) from the
`Themes` testset.

- [ ] **Step 3: Rename the fallback methods**

In `src/themes/themes.jl`, change the two generic definitions:

```julia
    """
        themecolor(::Type{<:AbstractTheme}, aa::AbstractChar)

    Return the marker color for the given amino acid for the provided theme.
    """
    themecolor(::Type{<:AbstractTheme}, aa::AbstractChar) = colorant"darkgray"

    """
        themetextcolor(::Type{<:AbstractTheme}, aa::AbstractChar)

    Return the label text color for the given amino acid for the provided theme.
    """
    themetextcolor(::Type{<:AbstractTheme}, aa::AbstractChar) = colorant"black"
```

- [ ] **Step 4: Rename the per-theme methods**

In `src/themes/hydropathy.jl`, rename the two function definitions:
`function color(::Type{Hydropathy}, ...)` → `function themecolor(::Type{Hydropathy}, ...)`
and `function textcolor(::Type{Hydropathy}, ...)` → `function themetextcolor(::Type{Hydropathy}, ...)`.

In `src/themes/colorful.jl`, rename `function color(::Type{Colorful}, ...)` →
`function themecolor(::Type{Colorful}, ...)` and
`function textcolor(::Type{Colorful}, ...)` →
`function themetextcolor(::Type{Colorful}, ...)`.

In `src/themes/colorfulhydropathy.jl`, rename
`function color(::Type{ColorfulHydropathy}, ...)` →
`function themecolor(::Type{ColorfulHydropathy}, ...)` and
`function textcolor(::Type{ColorfulHydropathy}, ...)` →
`function themetextcolor(::Type{ColorfulHydropathy}, ...)`.

(Only the function names on the `function` lines change; the bodies are
untouched.)

- [ ] **Step 5: Update the renderer call sites**

In `src/plot.jl`, replace `Themes.color(theme, aa)` with
`Themes.themecolor(theme, aa)` (one occurrence in `plotwheel!`, one in
`plotnet!`) and `Themes.textcolor(theme, aa)` with
`Themes.themetextcolor(theme, aa)` (two occurrences in `plotwheel!`, two in
`plotnet!`).

- [ ] **Step 6: Import and export the new names**

In `src/PeptideProjections.jl`, change the `using .Themes:` line to also import
the renamed functions:

```julia
using .Themes: AbstractTheme, Hydropathy, Colorful, ColorfulHydropathy,
               themecolor, themetextcolor
```

Then replace the `export` block with:

```julia
export
    # Theme types
    AbstractTheme, Hydropathy, Colorful, ColorfulHydropathy,

    # Theme color API
    themecolor, themetextcolor,

    # Helix geometry constants
    RESIDUES_PER_TURN, RADIANS_PER_TURN,

    # Plot functions
    plotwheel, plotwheel!, plotnet, plotnet!
```

- [ ] **Step 7: Run the test suite to verify it passes**

Run: `julia --project -e 'using Pkg; Pkg.test()'`
Expected: PASS — all `PeptideProjections` testsets green.

- [ ] **Step 8: Commit**

```bash
git add src/themes src/plot.jl src/PeptideProjections.jl test/themes.jl
git commit -m "Rename and export the theme color API

color/textcolor in the Themes submodule become themecolor/themetextcolor
and are exported from the top-level module, along with the helix geometry
constants RESIDUES_PER_TURN and RADIANS_PER_TURN.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 2: Add `netcoords` and `wheelcoords`

Pure placement functions returning `Vector{Point2f}`. The net coordinate is in
radians (period `2π`); the wheel reproduces the existing growing-radius spiral.

**Files:**
- Modify: `test/Project.toml`
- Modify: `test/runtests.jl`
- Create: `test/coords.jl`
- Modify: `src/plot.jl`
- Modify: `src/PeptideProjections.jl`

- [ ] **Step 1: Add CairoMakie to the test environment**

Replace the contents of `test/Project.toml` with:

```toml
[deps]
CairoMakie = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
Colors = "5ae59095-9a9b-59fe-a467-6f913c188581"
Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
```

- [ ] **Step 2: Register the new test file**

In `test/runtests.jl`, change the `tests` vector to:

```julia
tests = [
    "aa",
    "themes",
    "coords",
]
```

- [ ] **Step 3: Write the failing tests**

Create `test/coords.jl`:

```julia
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
```

- [ ] **Step 4: Run the tests to verify they fail**

Run: `julia --project -e 'using Pkg; Pkg.test()'`
Expected: FAIL — `UndefVarError: netcoords not defined`.

- [ ] **Step 5: Implement the placement functions**

In `src/plot.jl`, immediately after the `abstract type Wheel end` /
`abstract type Net end` lines (before the `turn` definitions), insert:

```julia
"""
    netcoords(seq::AbstractString, rot = 0) -> Vector{Point2f}

Idealized net placement. Residue `i` is placed at `Point2f(i, θ)`, where the
angular coordinate `θ = mod((i - 1) * RADIANS_PER_TURN - rot, 2π)` has period
`2π`. Used as the default `coords` for [`plotnet!`](@ref); supply a custom
vector to plot measured positions instead.
"""
function netcoords(seq::AbstractString, rot = 0)
    [Point2f(i, mod((i - 1) * RADIANS_PER_TURN - rot, 2π)) for (i, _) in enumerate(seq)]
end

"""
    wheelcoords(seq::AbstractString, rot = 0) -> Vector{Point2f}

Idealized helical-wheel placement. Residue `i` is placed on a spiral whose
radius grows by `0.5` each full turn. Used as the default `coords` for
[`plotwheel!`](@ref); supply a custom vector to plot measured positions instead.
"""
function wheelcoords(seq::AbstractString, rot = 0)
    coords = Point2f[]
    num_full_cycles = 0
    for (i, _) in enumerate(seq)
        angle = (i - 1) * RADIANS_PER_TURN - rot
        # a new turn begins each time the angle returns to a multiple of 2π
        if angle % (2π) == 0
            num_full_cycles += 1
        end
        radius = 1 + num_full_cycles * 0.5
        push!(coords, Point2f(radius * sin(angle), radius * cos(angle)))
    end
    coords
end
```

- [ ] **Step 6: Export the placement functions**

In `src/PeptideProjections.jl`, insert into the `export` block, immediately
before the `# Plot functions` comment:

```julia
    # Placement
    netcoords, wheelcoords,

```

- [ ] **Step 7: Run the tests to verify they pass**

Run: `julia --project -e 'using Pkg; Pkg.test()'`
Expected: PASS — including the new `Placement coordinates` testset.

- [ ] **Step 8: Commit**

```bash
git add test/Project.toml test/runtests.jl test/coords.jl src/plot.jl src/PeptideProjections.jl
git commit -m "Expose net and wheel placement as pure functions

netcoords/wheelcoords return Vector{Point2f}. The net angular coordinate
is now in radians with period 2π so it shares a coordinate system with
measured side-chain angles.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 3: Refactor the renderers and add the `coords` override

`plotnet!`/`plotwheel!` compute placement via `netcoords`/`wheelcoords` by
default, accept a `coords` keyword override, and share one drawing helper.

**Files:**
- Modify: `test/coords.jl`
- Modify: `src/plot.jl`

- [ ] **Step 1: Write the failing render/override tests**

Append to `test/coords.jl`, inside the file but after the existing
`@testset "Placement coordinates"` block (at top level):

```julia
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
    end

    @testset "coords length mismatch" begin
        f = Figure()
        ax = Axis(f[1, 1])
        @test_throws ArgumentError plotnet!(ax, seq; coords = netcoords("AC"))
        @test_throws ArgumentError plotwheel!(ax, seq; coords = wheelcoords("AC"))
    end
end
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `julia --project -e 'using Pkg; Pkg.test()'`
Expected: FAIL — `plotnet!` does not accept a `coords` keyword
(`MethodError` / unsupported keyword argument).

- [ ] **Step 3: Add the shared drawing helper**

In `src/plot.jl`, immediately before the `plotwheel!` definition, insert:

```julia
# Draw one themed marker plus residue-letter and index labels per residue at
# the supplied coordinates. Shared by plotwheel! and plotnet!.
function _drawresidues!(ax, seq::AbstractString, coords; theme = Colorful, scale = 150)
    for (i, aa) in enumerate(seq)
        x, y = coords[i]
        c = Themes.themecolor(theme, aa)
        scatter!(
            ax, x, y;
            color = c, strokecolor = darken(c, 0.1), strokewidth = 1,
            markersize = 0.2 * scale
        )
        text!(
            ax, x, y; text = string(aa), align = (:center, :center),
            offset = (0, 2),
            color = Themes.themetextcolor(theme, aa), fontsize = 10, font = :bold
        )
        text!(
            ax, x, y; text = string(i), align = (:center, :top),
            offset = (0, -2),
            color = Themes.themetextcolor(theme, aa), fontsize = 5, font = :bold
        )
    end

    nothing
end
```

- [ ] **Step 4: Replace the `plotwheel!` body**

In `src/plot.jl`, replace the entire `plotwheel!` function (the docstring and
`function plotwheel!(...) ... end` block) with:

```julia
"""
    plotwheel!(ax, seq::AbstractString, rot = 0; theme = Colorful, scale = 150,
               coords = wheelcoords(seq, rot))

Plot the helical wheel on the given axis. Placement defaults to
[`wheelcoords`](@ref); pass `coords` (a `Vector{Point2f}`, one per residue) to
plot measured positions instead, in which case `rot` is ignored.
"""
function plotwheel!(ax, seq::AbstractString, rot = 0; theme = Colorful, scale = 150,
                    coords = wheelcoords(seq, rot))
    length(coords) == length(seq) || throw(ArgumentError(
        "coords has $(length(coords)) points but seq has $(length(seq)) residues"))

    _drawresidues!(ax, seq, coords; theme, scale)
end
```

- [ ] **Step 5: Replace the `plotnet!` body**

In `src/plot.jl`, replace the entire `plotnet!` function (the docstring and
`function plotnet!(...) ... end` block) with:

```julia
"""
    plotnet!(ax, seq::AbstractString, rot = 0; theme = Colorful, scale = 150,
             coords = netcoords(seq, rot))

Plot the net on the given axis. Placement defaults to [`netcoords`](@ref); pass
`coords` (a `Vector{Point2f}`, one per residue) to plot measured positions
instead, in which case `rot` is ignored.
"""
function plotnet!(ax, seq::AbstractString, rot = 0; theme = Colorful, scale = 150,
                  coords = netcoords(seq, rot))
    length(coords) == length(seq) || throw(ArgumentError(
        "coords has $(length(coords)) points but seq has $(length(seq)) residues"))

    _drawresidues!(ax, seq, coords; theme, scale)
end
```

(The non-mutating `plotwheel`/`plotnet` need no change: they already forward
`kwargs...` to the mutating form, so a caller-supplied `coords` passes straight
through.)

- [ ] **Step 6: Run the tests to verify they pass**

Run: `julia --project -e 'using Pkg; Pkg.test()'`
Expected: PASS — including the `Rendering and coords override` testset.

- [ ] **Step 7: Commit**

```bash
git add src/plot.jl test/coords.jl
git commit -m "Accept a coords override in plotnet!/plotwheel!

Both renderers compute placement via netcoords/wheelcoords by default and
accept a coords keyword to plot measured positions through the same themed
renderer. Drawing is factored into a shared _drawresidues! helper.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 4: Version bump and documentation

**Files:**
- Modify: `Project.toml`
- Modify: `README.md`

- [ ] **Step 1: Bump the version**

In `Project.toml`, change `version = "0.2.1"` to `version = "0.3.0"`.

- [ ] **Step 2: Update the README API reference**

In `README.md`, replace the `### Main Functions` section (the four
`plotwheel`/`plotnet` bullet lines) with:

```markdown
### Main Functions

- `plotwheel(sequence; theme=Colorful, scale=150, coords=wheelcoords(sequence))` - Create a wheel projection
- `plotwheel!(ax, sequence; theme=Colorful, scale=150, coords=wheelcoords(sequence))` - Add wheel projection to existing axis
- `plotnet(sequence; theme=Colorful, scale=150, coords=netcoords(sequence))` - Create a net projection
- `plotnet!(ax, sequence; theme=Colorful, scale=150, coords=netcoords(sequence))` - Add net projection to existing axis

Pass `coords` (a `Vector{Point2f}`, one point per residue) to plot measured
positions instead of the idealized helical placement.

### Placement

- `netcoords(sequence, rot=0)` - Idealized net placement; the angular coordinate is in radians with period `2π`
- `wheelcoords(sequence, rot=0)` - Idealized helical-wheel placement

### Theme Colors

- `themecolor(theme, aa)` - Marker color for an amino acid under a theme
- `themetextcolor(theme, aa)` - Label text color for an amino acid under a theme
```

- [ ] **Step 3: Run the full test suite**

Run: `julia --project -e 'using Pkg; Pkg.test()'`
Expected: PASS — all testsets green.

- [ ] **Step 4: Commit**

```bash
git add Project.toml README.md
git commit -m "Bump to v0.3.0 and document the new API

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Self-review notes

- **Spec coverage:** Change 1 → Task 2 (`netcoords`/`wheelcoords`) + Task 3
  (`_drawresidues!` refactor). Change 2 → Task 3 (`coords` keyword + length
  check). Change 3 → Task 1 (rename + export `themecolor`/`themetextcolor`).
  Change 4 → Task 1 (export `RESIDUES_PER_TURN`/`RADIANS_PER_TURN`); the radians
  model making the period `2π` is realized in Task 2's `netcoords`. Radians
  coordinate model → Task 2. Tests → Tasks 1–3. Version bump → Task 4.
- **Type consistency:** `netcoords`/`wheelcoords` return `Vector{Point2f}`
  throughout; `_drawresidues!(ax, seq, coords; theme, scale)` is called with the
  same argument shape in both `plotwheel!` and `plotnet!`; `themecolor`/
  `themetextcolor` names are used identically in the theme files, `plot.jl`,
  and tests.
- **Out of scope (per spec):** the PeptideGraphs weakdep/extension; reworking
  the unused `turn`/`sizefn` helpers and the wheel spiral geometry.
