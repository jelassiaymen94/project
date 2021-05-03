zones, eventList = {}, {
	['mrpd_service'] = {
		type = 2,
		label = 'Entrar/Sair de serviço',
		eventName = 'crp-inventory:openShop',
		data = { 3 }
	},
    [`prop_vend_coffe_01`] = {
        eventName = 'crp-inventory:openShop', type = 1, label = 'Máquina de vendas', data = { 3 }
    }
}

function createTarget(zoneName, coords, length, width, minZ, maxZ, data)
	zones[#zones + 1] = BoxZone:Create(coords.xyz, length, width, { name = zoneName, heading = coords.w, minZ = minZ, maxZ = maxZ, data = data })

	Debug('Created target zone (' .. zoneName .. ') successfully.')
end

exports('createTarget', createTarget)

function RotationToDirection(rotation)
	local adjustedRotation = {
		x = (math.pi / 180) * rotation.x, y = (math.pi / 180) * rotation.y, z = (math.pi / 180) * rotation.z
	}

	return {
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), z = math.sin(adjustedRotation.x)
	}
end

function isPointInsideZone(point)
	for k, v in ipairs(zones) do
		if v:isPointInside(point) then
			return true, v.name
		end
	end

	return false
end