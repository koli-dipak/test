import { LightningElement } from 'lwc';
import { OmniscriptBaseMixin } from "vlocity_ins/omniscriptBaseMixin"; 
//import tmpl from './overrideSelectProductBlock.html';

export default class OverrideButton extends OmniscriptBaseMixin(LightningElement) {
		
		nextStep(){
				this.omniNextStep(); 
		}
		
}