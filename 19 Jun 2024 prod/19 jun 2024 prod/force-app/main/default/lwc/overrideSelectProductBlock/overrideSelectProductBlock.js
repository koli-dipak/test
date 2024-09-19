import omniscriptEditBlock from 'vlocity_ins/omniscriptEditBlock';
import tmpl from './overrideSelectProductBlock.html';
export default class overrideSelectProductBlock extends omniscriptEditBlock {

		render(){
				console.log('inside override edit block')
				super.render();
				return tmpl;
		}
}