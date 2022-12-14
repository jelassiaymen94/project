import { send } from './../../../utils/lib';

const state = () => ({
	itemsList: [],
	firstName: '',
	firstWeight: 0,
	firstMaxWeight: 325,
	firstItems: [],
	secondName: '',
	secondWeight: 0,
	secondMaxWeight: 0,
	secondItems: [],
	type: 0,
	shopType: 0,
	maxSlots: [],
	coords: {},
	queue: [],
	isCrafting: false,
	craftProgress: 0,
});

const getters = {
	getData: (state) => {
		return state;
	},
	getItemsList: (state) => {
		return state.itemsList;
	},
	getQueueData: (state) => {
		return state.queue;
	},
};

const actions = {
	setData(state, data) {
		state.commit('setData', data);
	},
	setItems(state, data) {
		state.commit('setItems', data);
	},
	moveItem(state, data) {
		state.commit('moveItem', data);
	},
	addQueue(state, data) {
		state.commit('addQueue', data);
	},
};

const mutations = {
	setData(state, data) {
		(state.firstItems = []), (state.secondItems = []);

		for (var name in data) {
			if (!name.includes('Items')) {
				state[name] = data[name];
			}
		}

		for (let i = 0; i < 40; i++) {
			let itemData = data.firstItems.find((element) => element.slot - 1 == i),
				slotData = {};

			if (itemData) {
				slotData = {
					itemId: itemData.item,
					quantity: itemData.count,
					meta: itemData.meta,
					durability: itemData.creation_time,
				};
			}

			state.firstItems[i] = slotData;
		}

		for (let i = 0; i < state.maxSlots; i++) {
			let itemData = data.secondItems.find((element) => element.slot - 1 == i),
				slotData = {};

			if (itemData) {
				slotData = {
					itemId: itemData.item,
					quantity: itemData.count,
					meta: itemData.meta,
					durability: itemData.creation_time,
				};

				if (state.type == 5) slotData.price = itemData.price;
			}

			state.secondItems[i] = slotData;
		}

		this.commit('inventory/calculateWeight');
	},
	setItems(state, data) {
		state.itemsList = data;
	},
	moveItem(state, data) {
		var current = getItemsArray(state, data.current),
			future = getItemsArray(state, data.future);

		if (
			Number(data.index) != Number(data.futureIndex) ||
			data.current != data.future
		) {
			if (state.type == 5 && data.future == state.secondName) {
				return;
			}

			let moveInfo = {
					current: data.current,
					future: data.future,
					currentIndex: Number(data.index) + 1,
					futureIndex: Number(data.futureIndex) + 1,
					count: Number(data.quantity),
					data: { type: state.type, coords: state.coords },
				},
				nuiType = 'moveItem';

			if (state.type == 5 && data.current == state.secondName) {
				(moveInfo.data.shopType = state.shopType), (nuiType = 'buyItem');
			}

			send(nuiType, moveInfo).then((data) => {
				if (data.success) {
					console.log(data);
					const currentSlot = data.current
						? {
								itemId: data.current.item,
								quantity: data.current.count,
								durability: data.current.creation_time,
						  }
						: {};

					current.splice(moveInfo.currentIndex - 1, 1, currentSlot);

					if (nuiType == 'buyItem') {
						for (let i = 0; i < 40; i++) {
							let itemData = data.future.find(
									(element) => element.slot - 1 == i
								),
								slotData = {};

							if (itemData) {
								slotData = {
									itemId: itemData.item,
									quantity: itemData.count,
									meta: itemData.meta,
									durability: itemData.creation_time,
								};
							}

							future.splice(i, 1, slotData);
						}
					} else {
						const futureSlot = data.future
							? {
									itemId: data.future.item,
									quantity: data.future.count,
									durability: data.future.creation_time,
							  }
							: {};

						future.splice(moveInfo.futureIndex - 1, 1, futureSlot);
					}

					if (state.type == 7) {
						(state.isCrafting = data.canCraft), (state.craftProgress = 0);

						if (state.isCrafting) {
							let interval = setInterval(() => {
								state.craftProgress++;

								if (state.craftProgress == 100) {
									clearInterval(interval);

									// state.isCrafting = false, state.craftProgress = 0;
									console.log('finished crafting');
									// send('finishedCraft');
								}
							}, (data.craftTimer * 60000) / 100);
						}
					}

					this.commit('inventory/calculateWeight');
				}
			});
		}
	},
	calculateWeight(state) {
		let firstWeight = 0,
			secondWeight = 0;

		for (let i = 0; i < state.firstItems.length; i++) {
			if (state.firstItems[i].itemId) {
				let item = state.itemsList.find(
					(element) => element.identifier == state.firstItems[i].itemId
				);

				firstWeight += item.weight * state.firstItems[i].quantity;
			}
		}

		for (let i = 0; i < state.secondItems.length; i++) {
			if (state.secondItems[i].itemId) {
				let item = state.itemsList.find(
					(element) => element.identifier == state.secondItems[i].itemId
				);

				secondWeight += item.weight * state.secondItems[i].quantity;
			}
		}

		(state.firstWeight = firstWeight), (state.secondWeight = secondWeight);
	},
	addQueue(state, data) {
		const item = state.itemsList.find(
			(element) => element.identifier == data.itemId
		);

		if (item) {
			const message = item.hash
				? data.state
					? 'EQUIPADO'
					: 'DESEQUIPADO'
				: (data.state ? 'USOU ' : 'REMOVIDO ') + data.quantity + 'X';

			state.queue.push({
				message: message,
				image: item.image,
				name: item.name,
			});

			setTimeout(() => {
				state.queue.splice(0, 1);
			}, 2500);
		}
	},
};

function getItemsArray(state, inventory) {
	return inventory == state.firstName ? state.firstItems : state.secondItems;
}

export default { namespaced: true, getters, state, actions, mutations };
