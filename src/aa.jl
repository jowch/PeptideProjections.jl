using DataStructures

RESIDUES_PER_TURN = 3.6

SPECIAL = Set((AA_C, AA_G, AA_P))
HYDROPHOBIC = Set((AA_A, AA_F, AA_I, AA_L, AA_M, AA_V, AA_Y, AA_W))
POSITIVE = Set((AA_H, AA_K, AA_R))
NEGATIVE = Set((AA_D, AA_E))
CHARGED = union(POSITIVE, NEGATIVE)
POLAR = union(CHARGED, (AA_S, AA_T, AA_N, AA_Q))

isspecial(aa::AminoAcid) = aa ∈ SPECIAL
ishydrophobic(aa::AminoAcid) = aa ∈ HYDROPHOBIC
ispositive(aa::AminoAcid) = aa ∈ POSITIVE
isnegative(aa::AminoAcid) = aa ∈ NEGATIVE
ischarged(aa::AminoAcid) = aa ∈ CHARGED
ispolar(aa::AminoAcid) = aa ∈ POLAR

MOLECULAR_WEIGHTS = DefaultDict(89,
    AA_A => 89,
    AA_R => 174,
    AA_N => 132,
    AA_D => 133,
    AA_C => 121,
    AA_Q => 146,
    AA_E => 147,
    AA_G => 75,
    AA_H => 155,
    AA_I => 131,
    AA_L => 131,
    AA_K => 146,
    AA_M => 149,
    AA_F => 165,
    AA_P => 115,
    AA_S => 105,
    AA_T => 119,
    AA_W => 204,
    AA_Y => 181,
    AA_V => 117
)

MIN_MW = minimum(values(MOLECULAR_WEIGHTS))
MAX_MW = maximum(values(MOLECULAR_WEIGHTS))

function molecularweight(aa::AminoAcid; scaled = false)
    scaled ? rescale(MOLECULAR_WEIGHTS[aa], MIN_MW, MAX_MW) : MOLECULAR_WEIGHTS[aa]
end

VOLUMES = DefaultDict(88.6, 
    AA_A => 88.6,
    AA_R => 173.4,
    AA_N => 114.1,
    AA_D => 111.1,
    AA_C => 108.0,
    AA_Q => 143.8,
    AA_E => 138.4,
    AA_G => 60.1,
    AA_H => 153.2,
    AA_I => 166.0,
    AA_L => 166.0,
    AA_K => 168.6,
    AA_M => 162.0,
    AA_F => 189.0,
    AA_P => 112.7,
    AA_S => 89.0,
    AA_T => 116.1,
    AA_W => 227.8,
    AA_Y => 193.6,
    AA_V => 140.0
)

MIN_VOLUME = minimum(values(VOLUMES))
MAX_VOLUME = maximum(values(VOLUMES))

function volume(aa::AminoAcid; scaled = false)
    scaled ? rescale(VOLUMES[aa], MIN_VOLUME, MAX_VOLUME) : VOLUMES[aa]
end
