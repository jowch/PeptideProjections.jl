# Coordinate & theme API for PeptideGraphs reuse — design

**Date:** 2026-05-18
**Status:** Approved
**Target version:** PeptideProjections 0.2.1 → 0.3.0

## Background

PeptideGraphs.jl (Wong-Lab/PeptideGraphs.jl) wants to reuse PeptideProjections'
themed net/wheel renderer to draw contact-graph nodes, then overlay its own
edges. The current API blocks this:

- `plotnet!` / `plotwheel!` compute each residue's `(x, y)` *inside* the
  rendering loop. The coordinates never escape, so a caller cannot attach edges
  to them.
- Placement is derived purely from sequence index. There is no way to feed in
  measured side-chain positions.
- The theme color functions (`color`, `textcolor`) live unexported inside the
  `Themes` submodule, so they cannot be reused for graph-node styling.

This spec covers four additive, backward-compatible changes to
**PeptideProjections.jl only**. The PeptideGraphs side — a weak dependency on
PeptideProjections plus a `PeptideGraphsPeptideProjectionsExt` extension
carrying the edge-overlay recipe — is separate work in that repository.
PeptideProjections stays graph-agnostic: it never learns what an edge is.

## Coordinate model decision

The idealized **net**'s angular coordinate moves from units of
residues-per-turn to **radians**. Residue *i* is placed at

    y = mod((i - 1) * RADIANS_PER_TURN - rot, 2π)

instead of the previous `(i - rot) mod 3.6`. This makes the idealized net and
PeptideGraphs' measured `θ` (radians, from cylindrical side-chain positions)
share one coordinate system, so supplying measured coords is a true drop-in
rather than a rescaled approximation.

The standalone net's appearance is essentially unchanged: `plotnet` hides axis
decorations, so only the y-scale changes (`[0, 3.6)` → `[0, 2π)`); relative
marker spacing within a column is preserved up to scale.

## Change 1 — Expose placement as data

Two new pure, exported functions in `src/plot.jl`:

- `wheelcoords(seq::AbstractString, rot = 0) -> Vector{Point2f}`
  The existing growing-radius spiral: residue *i* at radius
  `1 + num_full_cycles * 0.5`, angle `(i-1) * RADIANS_PER_TURN - rot`.
- `netcoords(seq::AbstractString, rot = 0) -> Vector{Point2f}`
  `Point2f(i, mod((i-1) * RADIANS_PER_TURN - rot, 2π))` for each residue.

`Point2f` is provided by CairoMakie, already a hard dependency.

`plotwheel!` / `plotnet!` are refactored to obtain placement from these
functions, then delegate drawing to a shared private helper:

    _drawresidues!(ax, seq, coords; theme, scale)

`_drawresidues!` does the per-residue `scatter!` (marker, stroke) plus the two
`text!` overlays (residue letter, sequence index) — the block currently
duplicated verbatim between the wheel and net loops. Extracting it removes the
duplication and is the single place placement and drawing meet.

## Change 2 — Accept a placement override

`plotnet!` / `plotwheel!` gain a `coords` keyword defaulting to the computed
placement:

    plotnet!(ax, seq, rot = 0; theme = Colorful, scale = 150,
             coords = netcoords(seq, rot))
    plotwheel!(ax, seq, rot = 0; theme = Colorful, scale = 150,
               coords = wheelcoords(seq, rot))

When `coords` is supplied explicitly, `rot` is ignored for placement (it only
feeds the default). A `length(coords) == length(seq)` mismatch raises
`ArgumentError`. The non-mutating `plotnet` / `plotwheel` forward `coords`
through their `kwargs`.

This collapses "idealized figure vs. measured figure" into "default coords vs.
supplied coords" — one code path. PeptideGraphs feeds measured `(z, θ)` through
the same themed renderer.

The `coords` override is provided for **both** net and wheel, for API
symmetry, even though PeptideGraphs' immediate need is the net.

## Change 3 — Publicize the theme color API

The `Themes` submodule's generic functions are renamed:

- `color` → `themecolor`
- `textcolor` → `themetextcolor`

This touches the three theme files (`hydropathy.jl`, `colorful.jl`,
`colorfulhydropathy.jl`), the fallback definitions in `themes/themes.jl`,
the call sites in `plot.jl`, and `test/themes.jl`. No external callers exist —
the functions were never exported.

`themecolor` and `themetextcolor` are then **exported** from the top-level
`PeptideProjections` module. The bare names `color` / `textcolor` are
deliberately not exported: `color` collides with names from `Colors.jl` and
Makie in a `using` context.

## Change 4 — Expose the net's angular period

With the radians coordinate model, the net's angular period is exactly `2π`,
which PeptideGraphs' existing `±2π` seam-wrapping logic uses directly — no
dedicated period constant is needed.

The underlying helix geometry constants `RESIDUES_PER_TURN` (3.6) and
`RADIANS_PER_TURN` (`2π / 3.6`), already `const` in `src/aa.jl`, are added to
the top-level `export` list. The `netcoords` docstring documents that the
angular coordinate has period `2π`.

## Testing

- New `test/coords.jl`, added to the `tests` list in `runtests.jl`:
  - `netcoords` / `wheelcoords` return a `Vector{Point2f}` whose length equals
    the sequence length.
  - Net y-values all lie in `[0, 2π)`.
  - `rot` shifts net coordinates as expected.
  - Passing `coords` of the wrong length to `plotnet!` / `plotwheel!` raises
    `ArgumentError`.
- Render smoke test: `plotnet` / `plotwheel` return a `Figure`, both with
  default placement and with an explicit `coords` argument.
- `test/themes.jl` updated for the renamed `themecolor` / `themetextcolor`.

## Out of scope

- The PeptideGraphs weakdep, `PeptideGraphsPeptideProjectionsExt`, and the
  edge-overlay recipe — separate work in PeptideGraphs.jl.
- Reworking the wheel's spiral geometry or the unused `turn`/`sizefn` helpers
  beyond what change 1's refactor requires.
