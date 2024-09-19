import omniscriptStepChart from 'vlocity_ins/omniscriptStepChart';
import {api, track} from 'lwc'
import tmpl from './overrideStepChart.html'
export default class OverrideStepChart extends omniscriptStepChart {
		
	@track isvisible;
	@track recordData;
	@track ApplicationNumber='';
	@api steps
		render(){
				this.isvisible = true
					//this.isvisible = super.inProgress || super.isCompleted ? true : false;

				var childerns = JSON.parse(JSON.stringify(this._jsonDef.children))
				var steps = childerns.filter(step => {
					if(step.isStep && step.propSetMap.chartLabel!='' && (step.bShow==undefined || step.bShow)){
						return step
					}
				})
				var finalsteps = []
				for(var i=0; i<steps.length;i++){
							steps[i]['stepNumber'] = i+1;
				}
				this.steps = steps
				if(this.jsonDef!=undefined && this.jsonDef.response!=undefined &&  this.jsonDef.response.ReferenceNumber!=undefined &&  this.jsonDef.response.ReferenceNumber!="" &&  this.jsonDef.response.VersionNumberforDR!=undefined){
					this.ApplicationNumber=this.jsonDef.response.ReferenceNumber +' - v'+this.jsonDef.response.VersionNumberforDR;
				}
				if(this.jsonDef!=undefined && this.jsonDef.response!=undefined &&  this.jsonDef.response.NewData!=undefined &&  this.jsonDef.response.NewData.length>0){
					if(this.jsonDef.response.NewData[0].vlocity_ins__ApplicationReferenceNumber__c!=undefined){
						this.ApplicationNumber=this.jsonDef.response.NewData[0].vlocity_ins__ApplicationReferenceNumber__c +' - v'+this.jsonDef.response.NewData[0].Version__c;
					}
				}
				//console.log('steps:::',this.steps)

				//console.log('index:::')
				// console.log('super.currentIndex::'+super.currentIndex);
				// console.log('this.isvisible::'+this.isvisible);
				super.render();
				return tmpl;
		}
		
		// isvisible(){
		// 		console.log('super.currentIndex::'+super.currentIndex);
		// 		//return super.currentIndex <= super._lastExecutedStepIndex;
		// 		return false;
		// }
}