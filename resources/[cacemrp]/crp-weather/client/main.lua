local currentWeather, lastWeather, desyncState = 'CLEAR', 'CLEAR', false
local baseTime, timeOffset, timer, hour, minute = 8, 0, 0, 0, 0

SetScenarioTypeEnabled('WORLD_VEHICLE_STREETRACE', false)
SetScenarioTypeEnabled('WORLD_VEHICLE_SALTON', false)
SetScenarioTypeEnabled('WORLD_VEHICLE_SALTON_DIRT_BIKE', false)
SetScenarioTypeEnabled('WORLD_VEHICLE_POLICE_BIKE', false)
SetScenarioTypeEnabled('WORLD_VEHICLE_POLICE_CAR', false)
SetScenarioTypeEnabled('WORLD_VEHICLE_POLICE_NEXT_TO_CAR', false)
SetScenarioTypeEnabled('WORLD_VEHICLE_STREETRACE', false)
SetScenarioTypeEnabled('WORLD_VEHICLE_MILITARY_PLANES_BIG', false)
SetScenarioTypeEnabled('WORLD_VEHICLE_MILITARY_PLANES_SMALL', false)
SetScenarioTypeEnabled('WORLD_VEHICLE_MECHANIC', false)
SetScenarioTypeEnabled('WORLD_VEHICLE_BUSINESSMEN', false)
SetScenarioTypeEnabled('WORLD_VEHICLE_BIKE_OFF_ROAD_RACE', false)

function startSync()
	Citizen.CreateThread(function()
		while not desyncState do
			Citizen.Wait(100)

			if lastWeather ~= currentWeather then
                lastWeather = currentWeather

                SetWeatherTypeOverTime(currentWeather, 15.0)

                Citizen.Wait(15000)
			end

			ClearOverrideWeather()
			ClearWeatherTypePersist()

			SetWeatherTypePersist(lastWeather)
			SetWeatherTypeNow(lastWeather)
			SetWeatherTypeNowPersist(lastWeather)

			local state = false

			if lastWeather == 'XMAS' then
				state = true
			end

			SetForceVehicleTrails(state)
			SetForcePedFootstepsTracks(state)
		end
	end)

	Citizen.CreateThread(function()
		while not desyncState do
			Citizen.Wait(0)

			local newBaseTime = baseTime

			if GetGameTimer() - 500 > timer then
				newBaseTime = newBaseTime + 0.25

				timer = GetGameTimer()
			end

			baseTime = newBaseTime

			hour = math.floor(((baseTime + timeOffset) / 60) % 24)
			minute = math.floor((baseTime + timeOffset) % 60)

			NetworkOverrideClockTime(hour, minute, 0)
		end
	end)
end

startSync()

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

		SetPedDensityMultiplierThisFrame(0.4)
		SetParkedVehicleDensityMultiplierThisFrame(1.0)

        SetVehicleDensityMultiplierThisFrame(0.4)
        SetRandomVehicleDensityMultiplierThisFrame(0.4)
    end
end)

function toggleDesync(state, type, hour, minute)
	desyncState = state

	PauseClock(state)

	if not desyncState then
		startSync()
		return
	end

	Citizen.CreateThread(function()
		while desyncState do
			Citizen.Wait(100)

			ClearOverrideWeather()
			ClearWeatherTypePersist()

			SetWeatherTypePersist(type)
			SetWeatherTypeNow(type)
			SetWeatherTypeNowPersist(type)

			SetForceVehicleTrails(false)
			SetForcePedFootstepsTracks(false)
		end
	end)

	NetworkOverrideClockTime(hour, minute, 0)
end

exports('toggleDesync', toggleDesync)

Citizen.CreateThread(function()
	local data = RPC:execute('requestSync')

	if data then
		currentWeather, baseTime, timeOffset = data.weather, data.baseTime, data.timeOffset
	end
end)

RegisterNetEvent('crp-weather:updateWeather')
AddEventHandler('crp-weather:updateWeather', function(newWeather)
    currentWeather = newWeather
end)

RegisterNetEvent('crp-weather:updateTime')
AddEventHandler('crp-weather:updateTime', function(base, offset)
    baseTime, timeOffset = base, offset
end)