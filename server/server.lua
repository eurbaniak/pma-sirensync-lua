RegisterNetEvent("pma-sirensync:ensureStateBag")
AddEventHandler("pma-sirensync:ensureStateBag", function(vehNet)
    local veh = NetworkGetEntityFromNetworkId(vehNet)

    if veh == 0 then
        return
    end

    local ent = Entity(veh).state

    if ent.stateEnsured then
        return
    end

    ent.stateEnsured = true
    ent.sirenMode = 0
    ent.siren2Mode = 0
    ent.horn = false
    ent.lightsOn = false
    ent.siren2On = false
    ent.sirenOn = false
end)
