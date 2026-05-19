# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

PeptideProjections is a Julia package for visualizing peptide sequences as helical
wheel and net projections with selectable color themes. Plotting is built on
CairoMakie.

## Commands

Run from the package root:

- Run the full test suite: `julia --project -e 'using Pkg; Pkg.test()'`
- Run a single test file directly (e.g. just the theme tests):
  `julia --project -e 'using PeptideProjections; include("test/themes.jl")'`
  (test files use `@testset` and `include` siblings via `test/runtests.jl`)
- Instantiate dependencies: `julia --project -e 'using Pkg; Pkg.instantiate()'`
- Regenerate the example figures: `julia --project example.jl` (produces the wheel
  and net comparison figures saved under `examples/`)

Note `test/` has its own `Project.toml` — `Pkg.test()` resolves test-only deps
(notably `Test`) from there.

## Architecture

Load order is fixed by `src/PeptideProjections.jl`: `util.jl` → `aa.jl` →
`themes/themes.jl` → `plot.jl`. Later files depend on names from earlier ones.

- **`src/aa.jl`** — amino acid domain model. Defines residue classification sets
  (`HYDROPHOBIC`, `POSITIVE`, `NEGATIVE`, `POLAR`, `SPECIAL`) and their predicates
  (`ishydrophobic`, `ispositive`, etc.), plus `molecularweight`/`volume` lookups.
  Lookups use `DefaultDict` so unknown residues fall back to a default value
  rather than erroring. Also defines the geometry constant `RESIDUES_PER_TURN = 3.6`
  and derived `RADIANS_PER_TURN` used by all projections.

- **`src/themes/`** — the `Themes` submodule. `themes.jl` declares the
  `AbstractTheme` type and the `color` / `textcolor` generic functions with
  darkgray/black fallbacks, then includes one file per concrete theme. Each theme
  (`Colorful`, `ColorfulHydropathy`, `Hydropathy`) is an `abstract type <: AbstractTheme`
  used purely as a dispatch tag — themes are *types passed as values*, never
  instances. A theme is implemented by adding `color`/`textcolor` methods that
  dispatch on `::Type{ThemeName}` and branch on the `aa.jl` predicates. To add a
  theme: create `src/themes/<name>.jl`, `include` it in `themes.jl`, and export it
  from both `Themes` and the top-level module.

- **`src/plot.jl`** — projection rendering. `Wheel` and `Net` are abstract dispatch
  tags for the `turn`/`sizefn` geometry helpers. Public API: `plotwheel`/`plotnet`
  create a new `Figure`; `plotwheel!`/`plotnet!` draw onto an existing Makie `Axis`.
  The mutating `!` forms hold the actual drawing logic; the non-mutating forms just
  set up the figure and delegate. Each residue is rendered as a scatter marker plus
  two `text!` overlays (residue letter and sequence index).

- **`src/util.jl`** — small color/number helpers (`rescale`, `darken`, `lighten`,
  `clamp01`).

## Conventions

- Source files are indented with tabs.
- Themes are referenced by type (e.g. `theme = Colorful`), not constructed.
- CairoMakie is a hard dependency; loading the package is enough to plot.
