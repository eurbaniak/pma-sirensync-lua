local isNuiVisible = false

local function toggleNuiFrame()
  isNuiVisible = not isNuiVisible
  SendReactMessage('setVisible', isNuiVisible)
end

RegisterCommand('+toggleNui', toggleNuiFrame)
RegisterNUICallback('hideFrame', function(_, cb)
  toggleNuiFrame()
  cb({})
end)

RegisterKeyMapping('+toggleNui', 'Toggle NUI frame', 'keyboard', '/')

--

local sirenSync <const> = exports['pma-sirensync']
local Wait <const> = Wait
local PlayerPedId <const> = PlayerPedId
local GetVehiclePedIsIn <const> = GetVehiclePedIsIn
local TriggerServerEvent <const> = TriggerServerEvent
local SetVehRadioStation <const> = SetVehRadioStation
local SetVehicleRadioEnabled <const> = SetVehicleRadioEnabled
local DisableControlAction <const> = DisableControlAction
local GetPedInVehicleSeat <const> = GetPedInVehicleSeat
local GetVehicleClass <const> = GetVehicleClass
local IsPedInAnyHeli <const> = IsPedInAnyHeli
local IsPedInAnyPlane <const> = IsPedInAnyPlane
local debug

local function isAllowedSirens(veh, ped)
  return GetPedInVehicleSeat(veh, -1) == ped and GetVehicleClass(veh) == 18 and not IsPedInAnyHeli(ped) and
      not IsPedInAnyPlane(ped)
end

CreateThread(function()
  debug = sirenSync.getDebug()
  local audioBanks = sirenSync.getAddonAudioBanks()
  for _, v in pairs(audioBanks) do
    RequestScriptAudioBank(v.bankName, false)
  end
  while true do
    local curSirenSound = sirenSync.getCurSirenSound()
    local curSiren2Sound = sirenSync.getCurSiren2Sound()
    local curHornSound = sirenSync.getCurHornSound()

    for veh, soundId in pairs(curSirenSound) do
      sirenSync.releaseSirenSound(veh, soundId, true)
    end

    for veh, soundId in pairs(curSiren2Sound) do
      sirenSync.releaseSiren2Sound(veh, soundId, true)
    end

    for veh, soundId in pairs(curHornSound) do
      sirenSync.releaseHornSound(veh, soundId, true)
    end

    Wait(1000)
  end
end)

CreateThread(function()
  local ped = PlayerPedId()
  local curState
  local curVeh = 0
  local lastVeh = 0
  local ensuringState = false
  local changedVehicle = false
  local allowedSirens = false
  local sleep = 0

  while true do
    ped = PlayerPedId()
    curVeh = GetVehiclePedIsIn(ped, false)
    allowedSirens = isAllowedSirens(curVeh, ped)

    if curVeh ~= lastVeh then
      if curVeh ~= 0 then
        curState = Entity(curVeh).state

        if allowedSirens then
          SetVehRadioStation(curVeh, "OFF")
          SetVehicleRadioEnabled(curVeh, false)
        end
      end

      changedVehicle = true
    end

    -- Update the state whilst it's ensuring
    curState = ensuringState and Entity(curVeh).state or curState

    sleep = 0

    if changedVehicle and curVeh == 0 then
      if lastVeh ~= 0 then
        curState:set("sirenMode", 0, true)
        curState:set("siren2Mode", 0, true)
        curState:set("sirenOn", false, true)
        curState:set("siren2On", false, true)
        curState:set("horn", false, true)
      end

      sleep = 250
      goto skipLoop
    end

    if curVeh == 0 or not allowedSirens then
      sleep = 250
      goto skipLoop
    end

    if changedVehicle and not ensuringState and not curState.stateEnsured then
      if debug then
        print(("State bag doesn't exist for vehicle %s, ensuring"):format(curVeh))
      end

      ensuringState = true
      TriggerServerEvent("pma-sirensync:ensureStateBag", VehToNet(curVeh))
      sleep = 500

      goto skipLoop
    else
      ensuringState = false
    end

    -- These are disabled to prevent game mechanics from interfering with the keymapping
    DisableControlAction(0, 80, true)  -- R
    DisableControlAction(0, 81, true)  -- .
    DisableControlAction(0, 82, true)  -- ,
    DisableControlAction(0, 83, true)  -- =
    DisableControlAction(0, 84, true)  -- -
    DisableControlAction(0, 85, true)  -- Q
    DisableControlAction(0, 86, true)  -- E
    DisableControlAction(0, 172, true) -- Up arrow

    :: skipLoop ::

    lastVeh = curVeh
    changedVehicle = false

    Wait(sleep)
  end
end)

-- main --

local curSirenSound = {}
local curSiren2Sound = {}
local curHornSound = {}

local function getSoundBankForSound(sound)
  for key, value in pairs(AddonAudioBanks) do
    if type(value.sounds) == "string" then
      if value.sounds == sound then
        return key
      end
    else
      for i = 1, #value.sounds do
        if value.sounds[i] == sound then
          return key
        end
      end
    end
  end
  return ""
end

local function isAllowedSirens(veh, ped)
  return GetPedInVehicleSeat(veh, -1) == ped and GetVehicleClass(veh) == 18 and not IsPedInAnyHeli(ped) and
      not IsPedInAnyPlane(ped)
end

local function releaseSirenSound(veh, soundId, isCleanup)
  if isCleanup and (DoesEntityExist(veh) and not IsEntityDead(veh)) then return end
  StopSound(soundId)
  ReleaseSoundId(soundId)
  curSirenSound[veh] = nil
end

local function releaseSiren2Sound(veh, soundId, isCleanup)
  if isCleanup and (DoesEntityExist(veh) and not IsEntityDead(veh)) then return end
  StopSound(soundId)
  ReleaseSoundId(soundId)
  curSiren2Sound[veh] = nil
end

local function releaseHornSound(veh, soundId, isCleanup)
  if isCleanup and (DoesEntityExist(veh) and not IsEntityDead(veh)) then return end
  StopSound(soundId)
  ReleaseSoundId(soundId)
  curHornSound[veh] = nil
end

local restoreSiren = 0

RegisterCommand("+sirenModeHold", function()
  local ped = PlayerPedId()
  local veh = GetVehiclePedIsIn(ped, false)

  if not isAllowedSirens(veh, ped) then return end

  local ent = Entity(veh).state

  if (ent.sirenOn or ent.siren2On) and ent.lightsOn then return end

  ent:set("sirenMode", 1, true)
end, false)

RegisterCommand("-sirenModeHold", function()
  local ped = PlayerPedId()
  local veh = GetVehiclePedIsIn(ped, false)

  if not isAllowedSirens(veh, ped) then return end

  local ent = Entity(veh).state

  ent:set("sirenMode", 0, true)
end, false)

RegisterKeyMapping("+sirenModeHold", "Hold this button to sound your emergency vehicle's siren", "keyboard", "R")

RegisterCommand("sirenSoundCycle", function()
  local ped = PlayerPedId()
  local veh = GetVehiclePedIsIn(ped, false)

  if not isAllowedSirens(veh, ped) then return end

  local ent = Entity(veh).state

  if not ent.lightsOn then return end

  local newSirenMode = (ent.sirenMode or 0) + 1

  if newSirenMode > 3 then
    newSirenMode = 1
  end

  PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)

  ent:set("sirenOn", true, true)
  ent:set("sirenMode", newSirenMode, true)
end, false)

RegisterKeyMapping("sirenSoundCycle",
  "Cycle through your emergency vehicle's siren sounds whilst your emergency lights are on", "keyboard", "COMMA")

RegisterCommand("sirenSoundOff", function()
  local ped = PlayerPedId()
  local veh = GetVehiclePedIsIn(ped, false)

  if not isAllowedSirens(veh, ped) then return end

  local ent = Entity(veh).state

  ent:set("sirenOn", false, true)
  ent:set("siren2On", false, true)
  ent:set("sirenMode", 0, true)
  ent:set("siren2Mode", 0, true)
end, false)

RegisterKeyMapping("sirenSoundOff", "Turn off your sirens after being toggled", "keyboard", "PERIOD")

RegisterCommand("+hornHold", function()
  local ped = PlayerPedId()
  local veh = GetVehiclePedIsIn(ped, false)

  if not isAllowedSirens(veh, ped) then return end

  local ent = Entity(veh).state

  if ent.horn then return end

  ent:set("horn", true, true)
  restoreSiren = ent.sirenMode
  ent:set("sirenMode", 0, true)
end, false)

RegisterCommand("-hornHold", function()
  local ped = PlayerPedId()
  local veh = GetVehiclePedIsIn(ped, false)

  if not isAllowedSirens(veh, ped) then return end

  local ent = Entity(veh).state

  if not ent.horn then return end

  ent:set("horn", false, true)
  ent:set("sirenMode", ent.lightsOn and restoreSiren or 0, true)
  restoreSiren = 0
end, false)

RegisterKeyMapping("+hornHold", "Hold this button to sound your vehicle's horn", "keyboard", "E")

RegisterCommand("sirenSound2Cycle", function()
  local ped = PlayerPedId()
  local veh = GetVehiclePedIsIn(ped, false)

  if not isAllowedSirens(veh, ped) then return end

  local ent = Entity(veh).state

  local newSirenMode = (ent.siren2Mode or 0) + 1
  local sounds = PrimarySirenOverride[GetEntityModel(veh)] or ""

  if type(sounds) == "string" then
    newSirenMode = 1
  else
    if newSirenMode > #sounds then
      newSirenMode = 1
    end
  end

  PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)

  ent:set("siren2On", true, true)
  ent:set("siren2Mode", newSirenMode, true)
end, false)

RegisterKeyMapping("sirenSound2Cycle",
  "Cycle through your emergency vehicle's secondary siren sounds, this doesn't require your emergency lights to be on",
  "keyboard", "UP")

RegisterCommand("sirenLightsToggle", function()
  local ped = PlayerPedId()
  local veh = GetVehiclePedIsIn(ped, false)

  if not isAllowedSirens(veh, ped) then return end

  local ent = Entity(veh).state

  PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
  local curMode = ent.lightsOn
  ent:set("lightsOn", not curMode, true)

  if not curMode then return end

  ent:set("siren2On", false, true)
  ent:set("sirenOn", false, true)
  ent:set("sirenMode", 0, true)
end, false)

RegisterKeyMapping("sirenLightsToggle", "Toggle your emergency vehicle's siren lights", "keyboard", "Q")

stateBagWrapper("horn", function(ent, value)
  local relHornId = curHornSound[ent]
  if relHornId then
    releaseHornSound(ent, relHornId)
    debugLog("[horn] " .. ent .. " has sound, releasing sound id " .. relHornId)
  end
  if not value then return end
  local soundId = GetSoundId()
  debugLog("[horn] Setting sound id " .. soundId .. " for " .. ent)
  curHornSound[ent] = soundId
  local soundName = HornOverride[GetEntityModel(ent)] or "SIRENS_AIRHORN"
  PlaySoundFromEntity(soundId, soundName, ent, 0, false, 0)
end)

stateBagWrapper("lightsOn", function(ent, value)
  SetVehicleHasMutedSirens(ent, true)
  SetVehicleSiren(ent, value)
  debugLog("[lights] " .. ent .. " has sirens " .. (value and "on" or "off"))
end)

stateBagWrapper("sirenMode", function(ent, soundMode)
  local relSoundId = curSirenSound[ent]
  if relSoundId then
    releaseSirenSound(ent, relSoundId)
    debugLog("[sirenMode] " .. ent .. " has sound, releasing sound id " .. relSoundId)
  end
  if soundMode == 0 then return end
  local soundId = GetSoundId()
  curSirenSound[ent] = soundId
  debugLog("[sirenMode] Setting sound id " .. soundId .. " for " .. ent)
  if soundMode == 1 then
    PlaySoundFromEntity(soundId, "VEHICLES_HORNS_SIREN_1", ent, 0, false, 0)
    debugLog("[sirenMode] playing sound 1 for " .. ent .. " with sound id " .. soundId)
  elseif soundMode == 2 then
    PlaySoundFromEntity(soundId, "VEHICLES_HORNS_SIREN_2", ent, 0, false, 0)
    debugLog("[sirenMode] playing sound 2 for " .. ent .. " with sound id " .. soundId)
  elseif soundMode == 3 then
    PlaySoundFromEntity(soundId, "VEHICLES_HORNS_POLICE_WARNING", ent, 0, false, 0)
    debugLog("[sirenMode] playing sound 3 for " .. ent .. " with sound id " .. soundId)
  else
    releaseSirenSound(ent, soundId)
    debugLog("[sirenMode] invalid soundMode sent to " .. ent .. " with sound id " .. soundId .. ", releasing sound")
  end
end)

stateBagWrapper("siren2Mode", function(ent, soundMode)
  local relSoundId = curSiren2Sound[ent]
  if relSoundId then
    releaseSiren2Sound(ent, relSoundId)
    debugLog("[siren2Mode] " .. ent .. " has sound, releasing sound id " .. relSoundId)
  end
  if soundMode == 0 then return end
  local soundId = GetSoundId()
  curSiren2Sound[ent] = soundId
  debugLog("[siren2Mode] Setting sound id " .. soundId .. " for " .. ent)
  local sounds = PrimarySirenOverride[GetEntityModel(ent)] or "VEHICLES_HORNS_SIREN_1"
  if type(sounds) == "string" then
    local soundBank = getSoundBankForSound(sounds)
    PlaySoundFromEntity(soundId, sounds, ent, soundBank ~= "" and soundBank or 0, false, 0)
    debugLog("[siren2Mode] playing sound 1 for " .. ent .. " with sound id " .. soundId)
  else
    for i, sound in ipairs(sounds) do
      if (soundMode - 1) == (i - 1) then
        local soundBank = getSoundBankForSound(sound)
        PlaySoundFromEntity(soundId, sound, ent, soundBank ~= "" and soundBank or 0, false, 0)
        debugLog("[siren2Mode] playing sound " .. i .. " for " .. ent .. " with sound id " .. soundId)
        return
      end
    end
    releaseSirenSound(ent, soundId)
    debugLog("[siren2Mode] invalid soundMode sent to " .. ent .. " with sound id " .. soundId .. ", releasing sound")
  end
end)
