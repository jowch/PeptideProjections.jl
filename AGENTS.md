## Learned User Preferences

- Prioritize user ergonomics and maintainability over introducing Makie `@recipe`s for projection plots unless composability clearly requires it.
- Residue labels belong inside the disks: bold letter with a smaller subscripted sequence index; both must stay legible.
- Validate plotting changes by inspecting rendered figures (e.g. under `examples/`), not only tests — check clipping, overlap, and font consistency across panels.
- When implementing from an attached plan file, do not edit the plan file itself.

## Learned Workspace Facts

- Projection rendering in `src/plot.jl` uses data-space `Circle` scatter markers plus data-space text; axis limits are set explicitly from disk extent, not center-point autolimits.
- `markersize` is disk diameter in data units; defaults come from minimum pairwise spacing among placement coords to avoid overlap.
- Net plots apply display-only x compression (`_net_display_coords`) so the index axis matches one helical turn (~2π) and panels stay compact with `DataAspect`.
- Regenerate example figures from the package root with `julia --project examples/example.jl` (PNG and SVG).
- Architecture and conventions are documented in `CLAUDE.md`; themes are type tags (e.g. `Colorful`), not instances.
