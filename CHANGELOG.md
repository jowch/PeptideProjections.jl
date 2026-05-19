# Changelog

All notable changes to PeptideProjections.jl are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

[0.3.0]: https://github.com/jowch/PeptideProjections.jl/releases/tag/v0.3.0
