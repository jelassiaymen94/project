<script>
	import Vue from 'vue';

	export default {
		name: 'inputOption',
		props: {
			data: Object,
			click: Function,
		},
		methods: {
			canChange: function(newValue) {
				const data = this.data;

				if (newValue >= data.minValue && newValue <= data.maxValue) {
					return true;
				}

				return false;
			},
			changeValue: function(boolean) {
				let value = this.data.value;

				boolean ? value++ : value--;

				if (this.canChange(value)) {
					Vue.set(this.data, 'value', value);
				}
			},
			updateValue: function(event) {
				if (event.target.value === '') {
					Vue.set(this.data, 'value', 0);
				}
			},
		},
		watch: {
			'data.value': function(newValue, oldValue) {
				if (!this.canChange(newValue)) {
					Vue.set(this.data, 'value', oldValue);
				} else {
					this.click(this.data.id, this.data.isMain, this.data.isProp);
				}
			},
		},
		render() {
			const data = this.data;

			return (
				<div class='option input'>
					<div class='label-container'>
						<span>{data.title}</span>
						<span class='counter'>{data.value + ' | ' + data.maxValue}</span>
					</div>
					<div class='controls'>
						<button class='arrowLeft' onClick={() => this.changeValue(false)}>
							&#8249;
						</button>
						<input
							type='number'
							v-model={data.value}
							onChange={this.updateValue}
						/>
						<button class='arrowRight' onClick={() => this.changeValue(true)}>
							&#8250;
						</button>
					</div>
				</div>
			);
		},
	};
</script>
