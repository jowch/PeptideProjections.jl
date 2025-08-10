using DataStructures

const RESIDUES_PER_TURN = 3.6
const RADIANS_PER_TURN = 2π / RESIDUES_PER_TURN
const DEGREES_PER_TURN = rad2deg(RADIANS_PER_TURN)

SPECIAL = Set(('C', 'G', 'P'))
HYDROPHOBIC = Set(('A', 'F', 'I', 'L', 'M', 'V', 'Y', 'W'))
POSITIVE = Set(('H', 'K', 'R'))
NEGATIVE = Set(('D', 'E'))
CHARGED = union(POSITIVE, NEGATIVE)
POLAR = union(CHARGED, ('S', 'T', 'N', 'Q'))

isspecial(aa::AbstractChar) = aa ∈ SPECIAL
ishydrophobic(aa::AbstractChar) = aa ∈ HYDROPHOBIC
ispositive(aa::AbstractChar) = aa ∈ POSITIVE
isnegative(aa::AbstractChar) = aa ∈ NEGATIVE
ischarged(aa::AbstractChar) = aa ∈ CHARGED
ispolar(aa::AbstractChar) = aa ∈ POLAR

# TODO: use AAindex for these
MOLECULAR_WEIGHTS = DefaultDict(89,
    'A' => 89,
    'R' => 174,
    'N' => 132,
    'D' => 133,
    'C' => 121,
    'Q' => 146,
    'E' => 147,
    'G' => 75,
    'H' => 155,
    'I' => 131,
    'L' => 131,
    'K' => 146,
    'M' => 149,
    'F' => 165,
    'P' => 115,
    'S' => 105,
    'T' => 119,
    'W' => 204,
    'Y' => 181,
    'V' => 117
)

MIN_MW = minimum(values(MOLECULAR_WEIGHTS))
MAX_MW = maximum(values(MOLECULAR_WEIGHTS))

function molecularweight(aa::AbstractChar; scaled = false)
    scaled ? rescale(MOLECULAR_WEIGHTS[aa], MIN_MW, MAX_MW) : MOLECULAR_WEIGHTS[aa]
end

function molecularweight(seq::AbstractString; scaled = false)
    scaled ? rescale(sum(molecularweight, seq), MIN_MW, MAX_MW) : sum(molecularweight, seq)
end

VOLUMES = DefaultDict(88.6, 
    'A' => 88.6,
    'R' => 173.4,
    'N' => 114.1,
    'D' => 111.1,
    'C' => 108.0,
    'Q' => 143.8,
    'E' => 138.4,
    'G' => 60.1,
    'H' => 153.2,
    'I' => 166.0,
    'L' => 166.0,
    'K' => 168.6,
    'M' => 162.0,
    'F' => 189.0,
    'P' => 112.7,
    'S' => 89.0,
    'T' => 116.1,
    'W' => 227.8,
    'Y' => 193.6,
    'V' => 140.0
)

MIN_VOLUME = minimum(values(VOLUMES))
MAX_VOLUME = maximum(values(VOLUMES))

function volume(aa::AbstractChar; scaled = false)
    scaled ? rescale(VOLUMES[aa], MIN_VOLUME, MAX_VOLUME) : VOLUMES[aa]
end
