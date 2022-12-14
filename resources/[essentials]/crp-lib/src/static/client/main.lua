local registeredEvents = {}

function SendUIMessage(data)
	exports['crp-ui']:SendUIMessage(data)
end

function RegisterUICallback(name, cb)
	AddEventHandler(('crp-ui:%s'):format(name), cb)

	registeredEvents[#registeredEvents + 1] = name
end

AddEventHandler('crp-ui:isReady', function()
	for k, name in ipairs(registeredEvents) do
		exports['crp-ui']:RegisterUIEvent(name)
	end
end)

function LoadDictionary(dictionary)
	RequestAnimDict(dictionary)

    while not HasAnimDictLoaded(dictionary) do
        Citizen.Wait(0)
	end
end

function LoadAnimationSet(setName)
	RequestAnimSet(setName)

	while not HasAnimSetLoaded(setName) do
		Citizen.Wait(0)
	end
end

function TaskPlayAnimation(entity, dictionary, animation, blendInSpeed, blendOutSpeed, duration, flag, playbackRate)
	if dictionary and not IsEntityPlayingAnim(entity, dictionary, animation, 3) then
		LoadDictionary(dictionary)

		TaskPlayAnim(entity, dictionary, animation, blendInSpeed, blendOutSpeed, duration, flag, playbackRate, false, false, false)

		RemoveAnimDict(dictionary)
	else
		if not IsPedUsingScenario(entity, animation) then
			TaskStartScenarioInPlace(entity, animation, 0, true)
		end
	end
end

function LoadModel(modelHash)
	RequestModel(modelHash)

	while not HasModelLoaded(modelHash) do
		Citizen.Wait(0)
	end
end

function CreateEntity(pedType, modelHash, coords, isNetwork, netMissionEntity)
	if not HasModelLoaded(modelHash) then
		LoadModel(modelHash)
	end

	local entity = CreatePed(pedType, modelHash, coords, isNetwork, netMissionEntity)

	SetModelAsNoLongerNeeded(modelHash)

	return entity
end

function DoesPedExistInCoords(coords, distance)
    local handle, ped = FindFirstPed()
    local isFound, foundPed, success = false, 0

    repeat
        local pedCoords = GetEntityCoords(ped)

        if #(coords - pedCoords) < distance then
            isFound, foundPed = true, ped
        end

        success, ped = FindNextPed(handle)
    until not success

    EndFindPed(handle)

    return isFound, foundPed
end

function GetVehicleInDirection(fromEntity, fromCoords, toCoords)
	local rayHandle = StartShapeTestCapsule(fromEntity.x, fromEntity.y, fromEntity.z, toCoords.x, toCoords.y, toCoords.z, 5.0, 10, fromEntity, 7)
	local retval, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)

	return entityHit
end

function GetClosestPlayer()
    local players, closestDistance, closestPlayer, playerPed = GetPlayers(), -1, -1, PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    for i = 1, #players do
        local targetPed = GetPlayerPed(players[i])

        if targetPed ~= playerPed then
            local _coords = GetEntityCoords(targetPed)
            local distance = #(_coords - coords)

            if closestDistance == -1 or closestDistance > distance then
                closestPlayer, closestDistance = players[i], distance
            end
        end
    end

    return closestPlayer, closestDistance
end

RegisterNetEvent('crp-lib:playSound')
AddEventHandler('crp-lib:playSound', function(soundName, volume)
    exports['crp-ui']:triggerSound(soundName, volume)
end)