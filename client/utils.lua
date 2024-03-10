--- A simple wrapper around SendNUIMessage that you can use to
--- dispatch actions to the React frame.
---
---@param action string The action you wish to target
---@param data any The data you wish to send along with this action
function SendReactMessage(action, data)
  SendNUIMessage({
    action = action,
    data = data
  })
end

local currentResourceName = GetCurrentResourceName()

local debugIsEnabled = GetConvarInt(('%s-debugMode'):format(currentResourceName), 0) == 1

--- A simple debug print function that is dependent on a convar
--- will output a nice prettfied message if debugMode is on
function debugPrint(...)
  if not debugIsEnabled then return end
  local args <const> = { ... }

  local appendStr = ''
  for _, v in ipairs(args) do
    appendStr = appendStr .. ' ' .. tostring(v)
  end
  local msgTemplate = '^3[%s]^0%s'
  local finalMsg = msgTemplate:format(currentResourceName, appendStr)
  print(finalMsg)
end

local playerId = PlayerId()

function debugLog(msg)
  if not Debug then return end
  print(msg)
end

function stateBagWrapper(bagKey, handler)
  local handle = AddStateBagChangeHandler(bagKey, null, function(bagName, _key, value, _, replicated)
    local entNet = tonumber(string.match(bagName, "entity:(%d+)"))
    local timeout = GetGameTimer() + 1500

    while not NetworkDoesEntityExistWithNetworkId(entNet) do
      Wait(0)
      if timeout < GetGameTimer() then return end
    end

    local veh = NetToVeh(entNet)
    local amOwner = NetworkGetEntityOwner(veh) == playerId
    if (not amOwner and replicated) or (amOwner and not replicated) then return end
    handler(veh, value)
  end)
  return handle
end
