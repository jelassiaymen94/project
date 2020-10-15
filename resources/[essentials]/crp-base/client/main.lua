Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

        if NetworkIsPlayerActive(PlayerId()) then
			TriggerEvent('crp-base:onPlayerJoined')
			break
		end
	end
end)

AddEventHandler('crp-base:onPlayerJoined', function()
    CRP.Spawn:InitializeMenu()
end)

RegisterUICallback('disconnectUser', function(data, cb)
	TriggerServerEvent('crp-base:disconnectUser')

	cb({ status = true })
end)

RegisterUICallback('selectCharacter', function(data, cb)
	local success, characterData = RPC:execute('selectCharacter', data)

	cb({ status = success })
end)

RegisterUICallback('deleteCharacter', function(data, cb)
	local success = RPC:execute('deleteCharacter', data)

	cb({ status = success })
end)

RegisterUICallback('createCharacter', function(data, cb)
	local success, characterData = RPC:execute('createCharacter', data)

	cb({ status = success, characterData = characterData })
end)