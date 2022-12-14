playerPed, dropsList, zones, dropsZone, isInsideZone = PlayerPedId(), {}, {}, nil, false
isDoingAnimation, isUsing, isWeaponEquiped, weaponSlot = false, false, false, nil

Citizen.CreateThread(function()
	dropsList = RPC:execute('fetchDropsData')

	for dropId, drop in ipairs(dropsList) do
		if drop then
			drop.zone = createZone(drop.coords, drop.name)
		end
	end

	dropsZone = ComboZone:Create(zones, { name = 'dropsZone', debugPoly = false })

	dropsZone:onPlayerInOut(function(isPointInside, point, zone)
		if zone then
			if isPointInside then
				createMarkers()
			end

			isInsideZone = isPointInside
		end
	end)

	exports['crp-ui']:setItems(itemsList)
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5000)

		playerPed = PlayerPedId()
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		DisableControlAction(0, 14, true)
		DisableControlAction(0, 15, true)
		DisableControlAction(0, 16, true)
		DisableControlAction(0, 17, true)
		DisableControlAction(0, 99, true)
		DisableControlAction(0, 100, true)
		DisableControlAction(0, 115, true)
		DisableControlAction(0, 116, true)
	end
end)

function openInventory()
	playerPed = PlayerPedId()

	if IsPedInAnyVehicle(playerPed, false) then
		local vehicle = GetVehiclePedIsIn(playerPed, false)

		if vehicle ~= 0 then
			Debug('Opened glovebox inventory.')

			TriggerEvent('crp-inventory:openInventory', 3, 'glovebox-' .. GetVehicleNumberPlateText(vehicle))
		end
	else
		local coords = GetEntityCoords(playerPed)
		local found, container = searchContainers(coords)

		if found then
			Debug('Opened container inventory.')

			TriggerEvent('crp-inventory:openInventory', 4, 'container (' .. RoundNumber(container.x) .. ' | ' .. RoundNumber(container.y) .. ')')
		else
			local vehicle = GetVehicleInFront(coords)

			if vehicle ~= 0 and not IsThisModelABicycle(GetEntityModel(vehicle)) then
				local minimum, maximum = GetModelDimensions(vehicle)
				local position = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, minimum - 0.5, 0.0)

				if #(position - coords) < 3.5 then
					local vehicleStatus = GetVehicleDoorLockStatus(vehicle)

					if vehicleStatus == 0 or vehicleStatus == 1 then
						SetVehicleDoorOpen(vehicle, 5, 0, 0)
						TaskTurnPedToFaceEntity(playerPed, vehicle, 1.0)

						Citizen.Wait(1000)

						Debug('Checking vehicle trunk.')

						TriggerEvent('crp-inventory:openInventory', 2, 'trunk-' .. GetVehicleNumberPlateText(vehicle))
					else
						Debug('The vehicle trunk is closed.')

						exports['crp-ui']:setAlert('O ve??culo est?? trancado', 'inform')
					end
				end
			else
				local name, coords = searchDropInventories(coords)

				Debug('Opened drop inventory.')

				TriggerEvent('crp-inventory:openInventory', 1, name, coords)
			end
		end
	end
end

function toggleActionBar(state)
	if state then
		exports['crp-ui']:openApp('actionbar', RPC:execute('getActionBarItems'), false, false)
	else
		exports['crp-ui']:closeApp('actionbar')
	end
end

function useItem(slot)
	if isUsingItem then
		return
	end

	local success, data = RPC:execute('getItem', slot)

	if not success then
		if data then
			exports['crp-ui']:setAlert(data)
		end

		return
	end

	local itemData = getItemData(data.item)

	if IsWeaponValid(itemData.hash) then
		if isWeaponEquiped then
			holsterWeapon(itemData.identifier)
			return
		end

		Citizen.Wait(200)

		isWeaponEquiped, weaponSlot = true, slot

		equipWeapon(itemData, data.meta.ammo)
		return
	end

	if itemData.eventName then
		isUsingItem = true

		exports['crp-ui']:addQueue(itemData.identifier, 1, true)

		TriggerEvent(itemData.eventName, data)
	end
end

function hasItem(name, quantity)
	return RPC:execute('hasItem', name, quantity)
end

function createMarkers()
	Citizen.CreateThread(function()
		while isInsideZone do
			Citizen.Wait(0)

			for i = 1, #dropsList do
				if zone.name == dropsList[i].zone.name then
					DrawMarker(20, dropsList[i].coords.x, dropsList[i].coords.y, dropsList[i].coords.z - 0.8, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.25, 0.25, 0.25, 255, 255, 255, 100, false, true, 2, false, false, false, false)
				end
			end
		end
	end)
end

exports('hasItem', hasItem)

RegisterUICallback('moveItem', function(data, cb)
	local success, current, future, canCraft, craftTimer = RPC:execute('moveItem', data.current, data.future, data.currentIndex, data.futureIndex, data.count, data.data)

    cb({ success = success, current = current, future = future, canCraft = canCraft, craftTimer = craftTimer })
end)

RegisterUICallback('buyItem', function(data, cb)
	local success, current, future = RPC:execute('buyItem', data.current, data.future, data.currentIndex, data.futureIndex, data.count, data.data)

    cb({ success = success, current = current, future = future })
end)

AddEventHandler('crp-inventory:openInventory', function(type, name, data)
	local success, data = RPC:execute('openInventory', type, name, data)

	if success then
		if type == 2 or type == 4 then
			TaskPlayAnimation(playerPed, nil, 'PROP_HUMAN_BUM_BIN')
		else
			TaskPlayAnimation(playerPed, 'pickup_object', 'putdown_low', 5.0, 1.5, 1.0, 48, 0.0)
		end

		exports['crp-ui']:openApp('inventory', data)
	end
end)

AddEventHandler('crp-inventory:openShop', function(type)
	local success, data = RPC:execute('openShop', type)

	if success then
		exports['crp-ui']:openApp('inventory', data)
	end
end)

AddEventHandler('crp-ui:closedMenu', function(name, data)
	if name ~= 'inventory' then
		return
	end

	Debug('Inventory closed.')

	TriggerServerEvent('crp-inventory:closedInventory', data.first, data.second)

	ClearPedTasks(playerPed)
end)

AddEventHandler('crp-inventory:usedItem', function(success, itemName)
	if success then
		local usedItem = RPC:execute('useItem', itemName, 1)

		if usedItem then
			exports['crp-ui']:addQueue(itemName, 1, false)
		end
	end

	isUsingItem = false
end)

exports['crp-binds']:RegisterKeybind('inventory', '[Invent??rio] Abrir', 'i', openInventory)
exports['crp-binds']:RegisterHoldKeybind('actionbar', '[Actionbar] Mostrar/Ocultar', 'Tab', toggleActionBar, 200)

exports['crp-binds']:RegisterKeybind('useItem1', '[Invent??rio] Usar item - 1', '1', useItem, 1)
exports['crp-binds']:RegisterKeybind('useItem2', '[Invent??rio] Usar item - 2', '2', useItem, 2)
exports['crp-binds']:RegisterKeybind('useItem3', '[Invent??rio] Usar item - 3', '3', useItem, 3)
exports['crp-binds']:RegisterKeybind('useItem4', '[Invent??rio] Usar item - 4', '4', useItem, 4)