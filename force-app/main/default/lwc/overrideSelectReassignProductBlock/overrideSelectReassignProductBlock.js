import omniscriptEditBlock from 'vlocity_ins/omniscriptEditBlock';
import tmpl from './overrideSelectReassignProductBlock.html';
export default class OverrideSelectReassignProductBlock extends omniscriptEditBlock {

		render(){
				console.log('inside override edit block')
				super.render();
				return tmpl;
		}
}