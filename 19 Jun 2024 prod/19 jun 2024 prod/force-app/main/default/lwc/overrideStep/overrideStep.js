import omniscriptStep from 'vlocity_ins/omniscriptStep';
import tmpl from './overrideStep.html';
export default class overrideSelectProductBlock extends omniscriptStep {

		render(){
			//	console.log('inside override Step')
				super.render();
				return tmpl;
		}
		// renderedCallback(){
		// 	console.log('renderedCallback')
		// }
}