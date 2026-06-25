# Changelog

All notable changes to PeptideProjections.jl are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Default disk diameter is constant across sequence lengths, derived from fixed
  layout cell pitch rather than per-sequence pairwise spacing. Wheels are scaled
  to a fixed outer radius; nets use fixed index pitch.

## [0.4.0] - 2026-06-24

### Added

- Data-space residue disks with geometry-driven `default_markersize` and explicit
  axis limits; net display compression for compact panels.
- `text_on` for automatic label contrast; SVG example exports.
- Exported `Wheel` and `Net` dispatch tags.

### Changed

- **Breaking:** `plotwheel!` / `plotnet!` no longer accept `scale`; use `markersize`
  (data-unit diameter) instead. `scale` on non-mutating forms sets figure pixel size
  only.
- **Breaking:** `themetextcolor` is now derived from marker fill via WCAG luminance.
- Net default standalone figure size is `scale .* (4, 1.2)` (was sequence-length
  dependent).

## [0.3.0] - 2026-05-18

First release registered in the Julia General registry.

### Added

- `netcoords` and `wheelcoords`: pure functions returning the net and
  helical-wheel placement of a sequence as a `Vector{Point2f}`.
- A `coords` keyword on `plotnet!`/`plotwheel!` (and `plotnet`/`plotwheel`),
  letting callers plot supplied positions instead of the idealized placement.
- Exported the theme color API (`themecolor`, `themetextcolor`) and the helix
  geometry constants (`RESIDUES_PER_TURN`, `RADIANS_PER_TURN`).
- `examples/example.jl`, a runnable script that regenerates the LL-37 example
  images.
- A `[compat]` entry for `julia` (1.10).

### Changed

- The net projection's angular coordinate is now in radians with period `2π`
  (previously in units of residues-per-turn). The `rot` argument to
  `plotnet`/`plotnet!` is correspondingly now in radians.
- Renamed the theme color functions `color`/`textcolor` to
  `themecolor`/`themetextcolor`.

[Unreleased]: https://github.com/jowch/PeptideProjections.jl/compare/v0.4.0...HEAD
[0.4.0]: https://github.com/jowch/PeptideProjections.jl/releases/tag/v0.4.0
[0.3.0]: https://github.com/jowch/PeptideProjections.jl/releases/tag/v0.3.0
