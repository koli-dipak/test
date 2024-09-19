import { api, track } from 'lwc';
import omniscriptStepChartItems from 'vlocity_ins/omniscriptStepChartItems';
import tmpl from './overrideStepChartItems.html';
export default class OverrideStepChartItems extends omniscriptStepChartItems {
		@track currIndex
		@api stepNum
		@api
		get stepNumber(){
			return this.currIndex;
		}
		set stepNumber(value){
			this.currIndex = value;
		}
		render(){
		var jsondef = JSON.parse(JSON.stringify(this.jsonDef));
		//console.log('@@stepNumber:::',this.stepNum)
		//console.log('@@jsondef:::',jsondef)

			this.currIndex = Number(this.stepNum);
				
			super.render();
			return tmpl;
		}
}