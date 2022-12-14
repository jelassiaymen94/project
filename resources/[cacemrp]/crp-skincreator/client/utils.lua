function getHeadBlend()
	return exports['crp-lib']:getHeadBlend(playerPed)
end

function getFaceFeatures()
	local data = {}

	for i = 1, 20, 1 do
		data[i] = GetPedFaceFeature(playerPed, i - 1)
	end

	return data
end

function getHeadOverlays()
	local data = {}

	for i = 1, 12, 1 do
		local success, overlayValue, colourType, firstColour, secondColour, overlayOpacity = GetPedHeadOverlayData(playerPed, i - 1)

		if success then
			data[i] = { overlayValue = overlayValue, colourType = colourType, firstColour = firstColour, secondColour = secondColour, opacity = overlayOpacity }
		end
	end

	return data
end

function getColors()
	local hairColors, makeupColors = {}, {}

	for i = 1, GetNumHairColors() do
		local r, g, b = GetPedHairRgbColor(i - 1)

		hairColors[i] = { r, g, b }
	end

	for i = 1, GetNumMakeupColors() do
		local r, g, b = GetPedMakeupRgbColor(i - 1)

		makeupColors[i] = { r, g, b }
	end

	return {
		hairColors = hairColors, hairColor = GetPedHairColor(playerPed), eyeColor = GetPedEyeColor(playerPed),
		hairHightlightColor = GetPedHairHighlightColor(playerPed), makeupColors = makeupColors
	}
end

function getVariations()
	local drawables, drawablesTextures = {}, {}

	for i = 1, 12 do
		drawables[i], drawablesTextures[i] = GetPedDrawableVariation(playerPed, i - 1), GetPedTextureVariation(playerPed, i - 1)
	end

	local props, propsTextures = {}, {}

	for i = 1, 8 do
		props[i], propsTextures[i] = GetPedPropIndex(playerPed, i - 1), GetPedPropTextureIndex(playerPed, i - 1)
	end

	return {
		drawables = drawables, drawablesTextures = drawablesTextures, props = props, propsTextures = propsTextures
	}
end

function getTotals()
	local variations = getVariations()
	local drawables, drawablesTextures = {}, {}

	for i = 1, 12 do
		drawables[i] = GetNumberOfPedDrawableVariations(playerPed, i - 1)
	end

	for i = 1, #variations.drawables do
		drawablesTextures[i] = GetNumberOfPedTextureVariations(playerPed, i - 1, variations.drawables[i])
	end

	local props, propsTextures = {}, {}

	for i = 1, 8 do
		props[i] = GetNumberOfPedPropDrawableVariations(playerPed, i - 1)
	end

	for i = 1, #variations.props do
		propsTextures[i] = GetNumberOfPedPropTextureVariations(playerPed, i - 1, variations.props[i])
	end

	return {
		drawables = drawables, drawablesTextures = drawablesTextures, props = props, propsTextures = propsTextures, skins = { #maleSkins, #femaleSkins }
	}
end

function getCurrentModel()
	local model = GetEntityModel(playerPed)
	local success, modelSex = isMpModel(model)

	if success then
		return { true, modelSex }
	end

	for i = 1, #maleSkins do
		if maleSkins[i] == model then
			return { i, true }
		end
	end

	for i = 1, #femaleSkins do
		if femaleSkins[i] == model then
			return { i, false }
		end
	end

	return false
end

function isMpModel(model)
	if `mp_m_freemode_01` == model then
		return true, true
	end

	if `mp_f_freemode_01` == model then
		return true, false
	end

	return false
end

function getCurrentSkin()
	return {
		model = GetEntityModel(playerPed), headBlend = getHeadBlend(), faceFeatures = getFaceFeatures(),
		headOverlays = getHeadOverlays(), colors = getColors(), variations = getVariations(), totals = getTotals()
	}
end

function setCharacterSkin(data)
	local headBlend = data.headBlend

	setSkin(data.model)

	if headBlend then
		SetPedHeadBlendData(playerPed, headBlend[1], headBlend[2], headBlend[3], headBlend[4], headBlend[5], headBlend[6], headBlend[7], headBlend[8], headBlend[9], false)
	end

	setFaceFeatures(data.faceFeatures)

	SetPedHairColor(playerPed, data.hairColor, data.hairHightlightColor)

	setHeadOverlays(data.headOverlays)
	setClothing(data.variations.drawables, data.variations.props, data.variations.drawablesTextures, data.variations.propsTextures)
end

exports('setCharacterSkin', setCharacterSkin)

function setSkin(model)
	SetEntityInvincible(playerPed, true)

	if IsModelInCdimage(model) and IsModelValid(model) then
		LoadModel(model)

		SetPlayerModel(PlayerId(), model)
		SetModelAsNoLongerNeeded(model)

		playerPed = PlayerPedId()

		ClearPedDecorations(playerPed)
		ClearPedFacialDecorations(playerPed)
		SetPedDefaultComponentVariation(playerPed)

		if isMpModel(model) then
			SetPedHairColor(playerPed, 0, 0)
			SetPedEyeColor(playerPed, 0)
		end

		ClearAllPedProps(playerPed)
	end

	SetEntityInvincible(playerPed, false)
end

exports('setSkin', setSkin)

function setClothing(drawables, props, drawablesTextures, propsTextures)
	for i = 1, 12 do
		SetPedComponentVariation(playerPed, i - 1, drawables[i], drawablesTextures[i], 2)
	end

	for i = 1, 8 do
		ClearPedProp(playerPed, i - 1)

		SetPedPropIndex(playerPed, i - 1, props[i], propsTextures[i], true)
	end
end

function setFaceFeatures(data)
	for i = 1, #data do
		SetPedFaceFeature(playerPed, i - 1, data[i])
	end
end

function setHeadOverlays(data)
	for i = 1, #data do
		SetPedHeadOverlay(playerPed, i - 1, data[i].overlayValue, data[i].opacity)

		if data[i].firstColour then
			SetPedHeadOverlayColor(playerPed, i - 1, data[i].colourType, data[i].firstColour, data[i].secondColour)
		end
	end
end

function triggerCustomCamera()
	startPosition = GetEntityCoords(playerPed)

	if not camera then
		FreezeEntityPosition(playerPed, true)

		local forwardVector = GetEntityForwardVector(playerPed)
		local forwardCameraPosition = vector3(startPosition.x + forwardVector.x * 1.2, startPosition.y + forwardVector.y * 1.2, startPosition.z + zPos)

		fov, startCamPosition = 90.0, forwardCameraPosition

		camera = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', forwardCameraPosition, 0, 0, 0, fov, true, 0)

		PointCamAtCoord(camera, startPosition)
		SetCamActive(camera, true)
		RenderScriptCams(true, false, 0, true, false)
	end
end

function changeCameraHeight(value)
	if camera then
		zPos = value

		if zPos > 0.8 then
			zPos = 0.8
		end

		if zPos < -0.8 then
			zPos = -0.8
		end

		SetCamCoord(camera, startCamPosition.x, startCamPosition.y, startCamPosition.z + zPos)
		PointCamAtCoord(camera, startCamPosition.x, startCamPosition.y, startCamPosition.z + zPos)

		SetCamActive(camera, true)
		RenderScriptCams(true, false, 0, true, false)
	end
end

function changeCameraZoom(value)
	if camera then
		fov = value

		if fov > 100 then
			fov = 100.0
		end

		if fov < 10 then
			fov = 10.0
		end

		SetCamFov(camera, RoundNumber(fov, 1))
		SetCamActive(camera, true)
		RenderScriptCams(true, false, 0, true, false)
	end
end

function updateData()
	local data = {
		type = menuType, variations = getVariations(), totals = getTotals()
	}

	if menuType == 1 then
		data.headOverlays, data.colors = getHeadOverlays(), getColors()
	end

	exports['crp-ui']:updateData(data)
end