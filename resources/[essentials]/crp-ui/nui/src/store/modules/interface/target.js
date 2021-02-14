const state = () => ({
	hideState: false, activeState: false, options: []
})

const getters = {
	getData: state => {
		return state;
	}
}

const actions = {
	setData(state, data) {
        state.commit('setData', data);
    }
}

const mutations = {
    setData(state, data) {
		for (var name in data) {
			state[name] = data[name];
		}
    }
}

export default { namespaced: true, getters, state, actions, mutations }