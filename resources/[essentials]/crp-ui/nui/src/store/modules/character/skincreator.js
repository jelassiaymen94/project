import { accessories, bodyFeatures, camera, clothing, faceFeatures, getMenuCategories, headBlend, headOverlays, ped } from './../../../utils/data.js';

const state = () => ({
	categories: [], camera: [], pedInfo: {}, ped: [], headBlend: [],
	faceFeatures: [], headOverlays: [], bodyFeatures: [],clothing: [], accessories: []
})

const getters = {
	getCategories: state => {
		return state.categories;
	},
	getCameraData: state => {
		return state.camera;
	},
	getPedInfo: state => {
		return state.pedInfo
	},
	getPed: state => {
		return state.ped;
	},
	getHeadBlend: state => {
		return state.headBlend;
	},
	getFaceFeatures: state => {
		return state.faceFeatures;
	},
	getHeadOverlays: state => {
		return state.headOverlays;
	},
	getBodyFeatures: state => {
		return state.bodyFeatures;
	},
	getClothing: state => {
		return state.clothing;
	},
	getAccessories: state => {
		return state.accessories;
	}
}

const actions = {
    setData(state, data) {
        state.commit('setData', data);
    }
}

const mutations = {
	setData(state, data) {
		const categories = getMenuCategories(data.type);

		state.categories = categories, state.camera = camera;

		switch (data.type) {
			case 2:
				setClothingData(state, data.variations, data.totals);
				setAccessoriesData(state, data.variations, data.totals);
				setPedData(state, data.currentModel, data.totals);
				break;
			case 3:
				setHeadOverlayData(state, data.headOverlays);
				setBodyFeatures(state, data.colors, data.variations, data.totals, data.headOverlays);
				break;
			default:
				state.headBlend = headBlend, state.faceFeatures = faceFeatures;

				if (data.headBlend) {
					for (let i = 0; i < state.headBlend.length; i++) {
						state.headBlend[i].value = data.headBlend[i];
					}
				}

				for (let i = 0; i < state.faceFeatures.length; i++) {
					state.faceFeatures[i].value = data.faceFeatures[i];
				}

				setPedData(state, data.currentModel, data.totals);
				setHeadOverlayData(state, data.headOverlays);
				setBodyFeatures(state, data.colors, data.variations, data.totals, data.headOverlays);
				setClothingData(state, data.variations, data.totals);
				setAccessoriesData(state, data.variations, data.totals);
				break;
        }
    }
}

function setPedData(state, currentModel, totals) {
	state.pedInfo = { type: false, sex: false }, state.ped = ped;
	state.pedInfo.type = isNaN(currentModel[0]) ? currentModel[0] : false, state.pedInfo.sex = currentModel[1];

	if (!state.pedInfo.type) {
		state.pedInfo.sex ? state.ped[0].value : state.ped[1].value = currentModel[0];
	}

	state.ped[0].maxValue = totals.skins[0], state.ped[1].maxValue = totals.skins[1];
}

function setHeadOverlayData(state, headOverlay) {
	state.headOverlays = headOverlays;

	for (let i = 0; i < state.headOverlays.length; i+=2) {
		const id = state.headOverlays[i].id;

		if (headOverlay[id]) {
			let value = headOverlay[id].overlayValue == 255 ? 0 : headOverlay[id].overlayValue;

			state.headOverlays[i].value = value, state.headOverlays[i + 1].value = headOverlay[id].opacity;
		}
	}
}

function setBodyFeatures(state, colors, variations, totals, headOverlays) {
	state.bodyFeatures = bodyFeatures;

	for (let i = 0; i < state.bodyFeatures.length; i++) {
		let option = state.bodyFeatures[i]

		if (i >= 3 && i <= 5) {
			option.subOptions[1].items = colors.makeupColors;
		} else {
			option.subOptions[1].items = colors.hairColors;
		}

		if (i == 0) {
			option.value = variations.drawables[2], option.maxValue = totals.drawables[2];
			option.subOptions[0].value = variations.drawablesTextures[2], option.subOptions[0].maxValue = totals.drawablesTextures[2];
			option.subOptions[1].value = colors.hairColor, option.subOptions[2].value = colors.hairHightlightColor, option.subOptions[2].items = colors.hairColors;
		} else {
			const headOverlay = headOverlays[option.id];

			if (headOverlay) {
				option.value = (headOverlay.overlayValue == 255) ? -1 : headOverlay.overlayValue, option.subOptions[0].value = headOverlay.opacity;

				if (option.value != -1) {
					option.subOptions[1].value = headOverlay.firstColour;

					if (option.subOptions[2]) {
						option.subOptions[2].value = headOverlay.secondColour;
					}
				}

				if (option.subOptions[2]) {
					option.subOptions[2].items = colors.makeupColors;
				}

				if (option.maxValue == 0) {
					option.maxValue = totals.drawables[option.id];
				}
			}
		}
	}
}

function setClothingData(state, variations, totals) {
	state.accessories = accessories;

	for (let i = 0; i < state.clothing.length; i++) {
		let clothesOption = state.clothing[i];

		if (i == 0) {
			clothesOption.value = variations.props[0], clothesOption.maxValue = totals.props[0];
			clothesOption.subOptions[0].value = variations.propsTextures[0], clothesOption.subOptions[0].maxValue = totals.propsTextures[0];
		} else {
			clothesOption.value = variations.drawables[clothesOption.id], clothesOption.maxValue = totals.drawables[clothesOption.id];
			clothesOption.subOptions[0].value = variations.drawablesTextures[clothesOption.id], clothesOption.subOptions[0].maxValue = totals.drawablesTextures[clothesOption.id];
		}
	}
}

function setAccessoriesData(state, variations, totals) {
	state.clothing = clothing;

	for (let i = 0; i < state.accessories.length; i++) {
		let accessoryOption = state.accessories[i];

		switch (i) {
			case 1: case 2: case 4: case 5:
				accessoryOption.value = variations.props[accessoryOption.id], accessoryOption.maxValue = totals.props[accessoryOption.id];
				accessoryOption.subOptions[0].value = variations.propsTextures[accessoryOption.id], accessoryOption.subOptions[0].maxValue = totals.propsTextures[accessoryOption.id];
				break;
			default:
				accessoryOption.value = variations.drawables[accessoryOption.id], accessoryOption.maxValue = totals.drawables[accessoryOption.id];
				accessoryOption.subOptions[0].value = variations.drawablesTextures[accessoryOption.id], accessoryOption.subOptions[0].maxValue = totals.drawablesTextures[accessoryOption.id];
				break;
		}
	}
}

export default { namespaced: true, getters, state, actions, mutations }