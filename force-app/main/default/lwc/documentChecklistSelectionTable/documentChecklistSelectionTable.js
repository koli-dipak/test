import { LightningElement, api, track } from 'lwc';
import { OmniscriptBaseMixin } from "vlocity_ins/omniscriptBaseMixin";

export default class DocumentChecklistSelectionTable extends OmniscriptBaseMixin(LightningElement){
    @api checkListItemSelectionList;
    @track data= [];
    @track restorePopup=false;
    @track editpopup=false;
    @track isAllSelected = false;
    @api instruction;
    @track currentEditId;
		inputData;
    
    sendtoOmniscript() {
        var Final = {}
        Final['updatedChecklistData'] = JSON.parse(JSON.stringify(this.data));
        this.omniApplyCallResp(Final);
    }

    handleInstructionChange(event) {
        
        this.instruction = event.target.value;
    }
    handleEditInstruction(event)
    {
        let itemId=event.currentTarget.dataset.itemId;
        this.currentEditId=itemId;
        this.editpopup=true;
          // Update the isSelected property of the item
        for(let i in this.data){
            if(this.data[i].id == itemId){
                this.instruction = this.data[i].name;
                break;
            }
        }

        
        console.log('-->Instrcutions'+this.instruction);
        console.log('-->event.target'+event.target);
    }

    handleSave() {
         // Update the isSelected property of the item
        this.data = this.data.map(item => {
            if (item.id === this.currentEditId) {
                return { ...item, name:  this.instruction };
            }
            return item;
        });

        // Dispatch a custom event to notify the parent component to save the edited instruction
        this.dispatchEvent(new CustomEvent('save', { detail: this.instruction }));
        //this.sendtoOmniscript();
        this.editpopup=false;
    }

    handleCancel() {
        this.editpopup=false;
        // Dispatch a custom event to notify the parent component to close the modal
        this.dispatchEvent(new CustomEvent('cancel'));
    }

    connectedCallback() {
        let eventData = JSON.parse(JSON.stringify(this.checkListItemSelectionList));
				this.inputData=[];
        let uniqueKey={};
        for(let x in eventData){
            let checkListJson = {
                id: eventData[x].Id,
                name: eventData[x].Instruction,
                ratingID:eventData[x].RatingId,
                icon: 'utility:edit', 
                isSelected: eventData[x].isSelected,
                type:eventData[x].Type,
                concatFormula:eventData[x].ConcatFormula,
            }
            this.inputData.push(checkListJson);
            console.log('--->'+checkListJson);      
						if(uniqueKey[checkListJson.concatFormula]==undefined){
								this.data.push(checkListJson);
								uniqueKey[checkListJson.concatFormula]=checkListJson;
						}
             // Check if concatFormula already exists
					 // let isDuplicate = this.data.some(item => item.concatFormula === checkListJson.concatFormula);

						// If it's not a duplicate, push the item
					 // if (!isDuplicate) {
									//this.data.push(checkListJson);
					 // }
           
        }
       
    }

    handleToggleChange(event) {
        const itemId = event.target.name;
        const checked = event.target.checked;

        // Update the isSelected property of the item
        this.data = this.data.map(item => {
            if (item.id === itemId) {
                return { ...item, isSelected: checked };
            }
            return item;
        });
       // this.sendtoOmniscript();

        this.updateIsAllSelected(); // Update isAllSelected after each toggle change
    }

    updateIsAllSelected() {
       // this.isAllSelected = this.data.every(item => item.isSelected);
    }

    handleRestoreClick(){
        this.restorePopup=true;
    }


    closeModal() {
         this.restorePopup=false;
    }
		
		updateData(){
				let finalData=[];
				let keyWiseData={};
				
				for(var i in this.data){
						keyWiseData[this.data[i].concatFormula]=this.data[i];
				}
				for(var i in this.inputData){
						let updateInfo=keyWiseData[this.inputData[i].concatFormula];
						this.inputData[i].isSelected=updateInfo.isSelected;
						this.inputData[i].name=updateInfo.name;
				}
				this.data=this.inputData;
		}

    handleNextClick(){
				this.updateData();
        this.sendtoOmniscript();
        this.omniNextStep();
        // Handle next click action
    }
   previousPage()
    {
        this.omniPrevStep(); 

    }
}