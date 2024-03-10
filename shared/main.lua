function joaat(key)
    local keyLowered = string.lower(key)
    local hash = 0

    for i = 1, #keyLowered do
        hash = hash + string.byte(keyLowered, i)
        hash = hash + (hash << 10)
        hash = hash ~ (hash >> 6)
    end

    hash = hash + (hash << 3)
    hash = hash ~ (hash >> 11)
    hash = hash + (hash << 15)

    return hash & 0xFFFFFFFF
end

HornOverride = {}
HornOverride[joaat("firetruk")] = "VEHICLES_HORNS_FIRETRUCK_WARNING"

PrimarySirenOverride = {}
PrimarySirenOverride[joaat("police")] = { "SIREN_ALPHA", "SIREN_BRAVO", "SIREN_CHARLIE" }

AddonAudioBanks = {}
AddonAudioBanks["DLC_WMSIRENS_SOUNDSET"] = { bankName = "DLC_WMSIRENS\\SIRENPACK_ONE", sounds = { "SIREN_ALPHA", "SIREN_BRAVO", "SIREN_CHARLIE" } }

Debug = false
