# PeptideProjections

PeptideProjections is a Julia package for visualizing peptide sequences using different projection methods and color themes. It provides an intuitive way to analyze and present protein sequences with various visualization styles.

## Installation
This package is not registered in the Julia general registry at the moment. You can install it using the following command:

```julia-repl
] add https://github.com/jowch/PeptideProjections.jl
```

## Quick Start

```julia
using PeptideProjections
using CairoMakie  # For plotting

# Create a wheel plot with default theme
plotwheel("LLGDFFRKSKEKIGKEFKRIVQRIKDFLRNLVPRTES")

# Create a net plot with a specific theme
plotnet("LLGDFFRKSKEKIGKEFKRIVQRIKDFLRNLVPRTES", theme=ColorfulHydropathy)
```

## Available Themes

### 1. Colorful Theme

Highlights different amino acid properties with distinct colors:

- Positive (H, K, R): Blue
- Negative (D, E): Orange
- Polar (S, T, N, Q): Green
- Hydrophobic (A, F, I, L, M, V, Y, W): Gold
- Special (C, G, P): Gray

<!-- ![Colorful Theme](docs/src/assets/colorful_theme.png) -->

### 2. ColorfulHydropathy Theme

Emphasizes hydropathy while maintaining charge information:

- Hydrophobic: Black
- Positive: Blue
- Negative: Orange
- Others: Green

<!-- ![ColorfulHydropathy Theme](docs/src/assets/colorful_hydropathy_theme.png) -->

### 3. Hydropathy Theme

Emphasizes hydropathy with hydrophobic residues in black and polar residues in red

<!-- ![Hydropathy Theme](docs/src/assets/hydropathy_theme.png) -->

## API Reference

### Main Functions

- `plotwheel(sequence; theme=Colorful, scale=150)` - Create a wheel projection
- `plotwheel!(ax, sequence; theme=Colorful, scale=150)` - Add wheel projection to existing axis
- `plotnet(sequence; theme=Colorful, scale=150)` - Create a net projection
- `plotnet!(ax, sequence; theme=Colorful, scale=150)` - Add net projection to existing axis

## Contributing

Contributions are welcome! Please feel free to submit a pull request or open an issue.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
