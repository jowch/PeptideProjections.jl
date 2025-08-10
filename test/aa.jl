using Test
using PeptideProjections
using PeptideProjections: RESIDUES_PER_TURN, RADIANS_PER_TURN, DEGREES_PER_TURN
using PeptideProjections: ispositive, isnegative, ischarged, ispolar, ishydrophobic, isspecial, molecularweight, volume

@testset "Amino Acid Properties" begin
    @testset "Classification Functions" begin
        # Test special amino acids
        @test isspecial('P')
        @test isspecial('G')
        @test isspecial('C')
        @test !isspecial('A')
        
        # Test hydrophobic amino acids
        @test ishydrophobic('A')
        @test ishydrophobic('F')
        @test !ishydrophobic('D')
        
        # Test charged amino acids
        @test ispositive('R')
        @test isnegative('E')
        @test ischarged('K')
        @test !ischarged('A')
        
        # Test polar amino acids
        @test ispolar('S')
        @test ispolar('T')
        @test !ispolar('V')
    end
    
    @testset "Molecular Weight Calculations" begin
        # Test individual amino acids
        @test molecularweight('A') == 89
        @test molecularweight('G') == 75  # Smallest amino acid
        @test molecularweight('W') == 204  # Largest amino acid
        
        # Test scaling
        @test 0.0 <= molecularweight('A', scaled=true) <= 1.0
        @test molecularweight('G', scaled=true) == 0.0  # Should be smallest
        @test molecularweight('W', scaled=true) == 1.0  # Should be largest
    end
    
    @testset "Volume Calculations" begin
        # Test individual amino acids
        @test volume('G') ≈ 60.1  # Smallest volume
        @test volume('W') ≈ 227.8  # Largest volume
        
        # Test scaling
        @test 0.0 <= volume('A', scaled=true) <= 1.0
        @test volume('G', scaled=true) == 0.0  # Should be smallest
        @test volume('W', scaled=true) == 1.0  # Should be largest
    end
    
    @testset "Constants" begin
        @test RESIDUES_PER_TURN ≈ 3.6
        @test RADIANS_PER_TURN ≈ 2π / 3.6
        @test DEGREES_PER_TURN ≈ 360 / 3.6
    end
    
    @testset "Edge Cases" begin
        # Test with unknown amino acid (should use default values)
        @test volume('X') == 88.6  # Default volume
        @test molecularweight('X') == 89  # Default weight
    end
end