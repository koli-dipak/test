import { LightningElement, api } from 'lwc';

export default class CounterOfSelectReqForm extends LightningElement {
    qty = 1;
    @api qtyval = '1';//
    
    connectedCallback(){
        /* if(this.qty == 1){
            this.setDecrementCounter();
        }*/
    }

    setDecrementCounter(event) {
        if(this.qtyval > 1){
            this.qtyval = this.qtyval-1; 
        const decrementEvent = new CustomEvent(
                                 'decrement', 
                                 { detail: this.qtyval }
                               );
        this.dispatchEvent(decrementEvent);
        }
        
    }

    setIncrementCounter(event) {
        this.qtyval = this.qtyval+1;
        const incrementEvent = new CustomEvent(
                                  'increment', 
                                  { detail: this.qtyval }
                               );
        this.dispatchEvent(incrementEvent);
    }

    selectedValue(event){
       /* this.qtyval = parseInt(event.currentTarget.value);
        const incrementEvent = new CustomEvent(
                                  'increment', 
                                  { detail: this.qtyval }
                               );
        this.dispatchEvent(incrementEvent);*/
    }

}