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
