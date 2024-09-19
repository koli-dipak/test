import omniscriptEditBlock from 'vlocity_ins/omniscriptEditBlock';
import tmpl from './overrideSelectProductBlockSwitch.html';
export default class overrideSelectProductBlockSwitch extends omniscriptEditBlock {

		render(){
				console.log('inside override edit block')
				super.render();
				return tmpl;
		}
}