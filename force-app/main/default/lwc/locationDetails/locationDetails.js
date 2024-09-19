import { LightningElement, wire,api,track } from 'lwc';
import getLocationCase from '@salesforce/apex/LocationDetailController.getLocationCase';
import deleteLocationCase from '@salesforce/apex/LocationDetailController.deleteLocationCase';
import getCjrValue from '@salesforce/apex/LocationDetailController.getCjrValue';

export default class CaseLocationDatatable extends LightningElement {


    @api recordId;
    @api cjr;
    @track junctionData;
    @api ids = [];
    @track isSpinner = true;
    
    @track columns = [
        // { label: 'Case Number', fieldName: 'Location__r.' },
        // { label: 'Location ID', fieldName: ' ' },
        // { label: 'Location: Created By', fieldName: 'CreatedBy' },//m
        // { label: 'Location: Created Date', fieldName: 'CreatedDate' },//m
        { label: 'Location ID', fieldName: 'Name' },
        // { label: 'Location: Address(City)', fieldName: 'Address__City__s' },
        // { label: 'Location: Address', fieldName: 'Location_Full_Address__c' },
        { label: 'Location Address', fieldName: 'Location_Adress__c' },
         { label: '', type: 'button', initialWidth: 135, typeAttributes: { label: 'Remove', name: 'remove', title: 'Click to remove' } }

        // { label: 'Status', fieldName: 'Status__c' }
    ];


    connectedCallback(){
        this.getData();
        getCjrValue({ recordId: this.recordId})
            .then(result => {
                this.isSpinner = false
                console.log('this.result', result);
                this.cjr = result;
                if(this.cjr != undefined){
                    JSON.parse(JSON.stringify(this.cjr)).forEach(e => {
                        this.ids.push(e.Id);
                    });
                    console.log('==test===',this.ids);
                }
                this.getData();
            })
            .catch(error => {
                console.error(error);
            });
        // console.log('==cjr==',this.cjr);

        
    }
    
    getData(){
        getLocationCase({ caseId: this.recordId, ids : this.ids})
            .then(result => {
                this.junctionData = result.map(record => ({
                    ...record,
                    Name: record.Location__r.Name,
                    // CreatedBy: record.Location__r.CreatedBy.Name,//m
                    // CreatedDate: record.Location__r.CreatedDate,//m
                    // Address__City__s: record.Location__r.Address__City__s,
                    // Location_Adress__c: record.Location__r.Location_Adress__c
                    // Location_Full_Address__c: record.Location__r.Location_Full_Address__c
                    Location_Adress__c: record.Location__r.Location_Adress__c
                }));
                console.log('this.result', result);
                console.log('this.junctionData', this.junctionData);
                console.log('this.recordId', this.recordId);
            })
            .catch(error => {
                console.error(error);
            });
    }
    handleRefreshDatatable(){
        this.getData();
    }

 handleRowAction(event) {
    const action = event.detail.action;
    console.log("@@action",action);
    console.log("@@event.detail.action",event.detail.action);
    const row = event.detail.row;
    if (action.name === 'remove') {
        this.removeRecord(row);
    }
}

removeRecord(row) {
    const recordId = row.Id;
    const filteredData = this.junctionData.filter(record => record.Id !== recordId);
    this.junctionData = filteredData;
    console.log("junctionData",this.junctionData);
    // Make a server call to delete the record
    deleteLocationCase({ recordId: recordId })
    .then(result => {
        // Handle the success response if needed
        console.log('Record deleted successfully.');
    })
    .catch(error => {
        // Handle the error response if needed
        console.error(error);
    });
}
}