import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLocCountryCode from '@salesforce/apex/LocationDetailController.getLocationCountryCode';
import getLocStateCode from '@salesforce/apex/LocationDetailController.getLocationStateCode';
import insertLocationRecord from '@salesforce/apex/LocationDetailController.insertLocationRecord';
import proccesRecordBefore from '@salesforce/apex/LocationDetailController.proccesRecordBefore';
import insertLocationRecordIntoCaseAndLocationObject from '@salesforce/apex/LocationDetailController.insertLocationRecordIntoCaseAndLocationObject';
// import { createRecord  } from 'lightning/uiRecordApi';
// import { NavigationMixin } from 'lightning/navigation';
// import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
// export default class NewLocationRecordPage extends NavigationMixin( LightningElement ){
export default class NewLocationRecordPage extends LightningElement {
    @api recordId;
    @track strStreet;
    @track strCity;
    @track strState;
    @track strCountry;
    @track strPostalCode;

    objectAPIName = "Location";
    @track isModalOpen = false;
    @api createLocationClick;
    @track countryCodeRecord = {};
    @track stateCodeRecord = {}; //m
    @track addressfields;
    @track isSpinnerLoad = false;
    @track isDuplicateRecordFound = false;
    imgsrc = 'data:@file/png;base64,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';
    @track addressRecords = [];
    @track anyExtisingDuplicateOptionSelected = false;
    @track selectdDulpicateLocationId = '';
    @track optionIndex;


    connectedCallback() {
        console.log('recordID', this.recordId);
        console.log("this.createLocationClick", this.createLocationClick);
        this.isModalOpen = this.createLocationClick;
        getLocCountryCode({})
            .then(result => {
                console.log('Record', result);
                this.countryCodeRecord = JSON.parse(JSON.stringify(result));

                // add 16-aug-2023
                // let countryArr = [];
                // let options = [];
                // countryArr = Object.keys(this.countryCodeRecord);
                // console.log('countryArr', countryArr);
                // for(let x in countryArr){
                //     options.push({value: countryArr[x], label: countryArr[x]})
                // }
                // this.data1 = options;
                // console.log('this.data1', this.data1);
            })
            .catch(error => {
                console.error(error);
            });

        // 09/aug/2023
        getLocStateCode({})
            .then(result => {
                console.log('Record', result);
                this.stateCodeRecord = JSON.parse(JSON.stringify(result));

                // add 16-aug-2023
                // let stateArr = [];
                // let options = [];
                // stateArr = Object.keys(this.stateCodeRecord);
                // console.log('countryArr', stateArr);
                // for(let x in stateArr){
                //     options.push({value: stateArr[x], label: stateArr[x]})
                // }
                // this.data2 = options;
                // console.log('this.data2', this.data2);
            })
            .catch(error => {
                console.error(error);
            });
    }

    handleSubmit(event) {
        this.isSpinnerLoad = true;
        console.log('this.strStreet', this.strStreet);
        console.log('this.strCity', this.strCity);
        console.log('this.strState', this.strState);
        console.log('this.strCountry', this.strCountry);
        console.log('this.strPostalCode', this.strPostalCode);

        let fields = event.detail.fields;
        // this.addressfields = fields;
        // event.preventDefault(); // Prevent default form submission

        if (this.objectAPIName === 'Location') {

            fields.Address__Street__s = this.strStreet;
            fields.Address__City__s = this.strCity;
            fields.Address__StateCode__s = this.strState;
            fields.Address__CountryCode__s = this.strCountry;
            fields.Address__PostalCode__s = this.strPostalCode;

        }
        // if ( this.objectAPIName === 'Location' ) {

        //     fields.Address__c.street = this.strStreet;
        //     fields.Address__c.city = this.strCity;
        //     fields.Address__c.stateCode = this.strState;
        //     fields.Address__c.country = this.strCountry;
        //     fields.Address__c.postalCode = this.strPostalCode;

        // } 
        // if ( this.objectAPIName === 'Location' ) {
        //     fields.Address__c = {
        //         Address__Street__s : this.strStreet,
        //         Address__City__s : this.strCity,
        //         Address__StateCode__s : this.strState,
        //         Address__CountryCode__s : this.strCountry,
        //         Address__PostalCode__s : this.strPostalCode
        //     }

        // } 

        // if (this.objectAPIName === 'Location') {
        //     fields.Address__c = {
        //         Street__c: this.strStreet,
        //         City__c: this.strCity,
        //         State__c: this.strState,
        //         Country__c: this.strCountry,
        //         PostalCode__c: this.strPostalCode
        //     };
        // }

        console.log("fields", JSON.parse(JSON.stringify(fields)));
        this.addressfields = JSON.parse(JSON.stringify(fields))

        // event.preventDefault(); // Prevent default form submission
        this.isSpinnerLoad = true;
        /*insertLocationRecord ({LocationRecord: fields})
        .then(result => {
            console.log('outputresult : ', result );
          //   for(let x in result){
          //     this.searchKey = result[x].LastName;
          //   }
          //   this.isSpinnerLoad = false;
          //   this.isModalOpen = false;
            this.handleSuccess();
          //   this.toggleResult();
        })
        .catch(error => {
          console.error('@@Error',error);
          // this.isSpinnerLoad = false;
          this.handleError();

        });*/
        if ((this.addressfields.Address__PostalCode__s == undefined || this.addressfields.Address__PostalCode__s == '') && (this.addressfields.Address__Street__s == undefined || this.addressfields.Address__Street__s == '') && (this.addressfields.Address__City__s == undefined || this.addressfields.Address__City__s == '') && (this.addressfields.Address__StateCode__s == undefined || this.addressfields.Address__StateCode__s == '') && (this.addressfields.Address__CountryCode__s == undefined || this.addressfields.Address__CountryCode__s == '')) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'No Record',
                    message: 'There is no location record selected',
                    variant: 'error'
                })
            );
            this.isSpinnerLoad = false;
        }
        proccesRecordBefore({ LocationRecord: fields })
            .then(result => {
                console.log('proccesRecordBefore outputresult : ', result);
                if (result.length > 0) {
                    this.isDuplicateRecordFound = true;
                    this.isSpinnerLoad = false;
                    for (let x in result) {
                        let index = parseInt(x)+1;
                        console.log(index)
                        let constructedString =
                            (result[x].Currency_Code__c !== undefined ? result[x].Currency_Code__c : '') +
                            ' ' +
                            (result[x].Building_Property_Name__c !== undefined ? result[x].Building_Property_Name__c : '') +
                            ' ' +
                            (result[x].Address__CountryCode__s !== undefined ? result[x].Address__CountryCode__s : '') +
                            ' ' +
                            (result[x].Address__Street__s !== undefined ? result[x].Address__Street__s : '') +
                            ' ' +
                            (result[x].Address__City__s !== undefined ? result[x].Address__City__s : '') +
                            ' ' +
                            (result[x].Address__PostalCode__s !== undefined ? result[x].Address__PostalCode__s : '') +
                            ' ' +
                            (result[x].Address__StateCode__s !== undefined ? result[x].Address__StateCode__s : '');
                        // this.addressRecords.push({'optionValue': 'Option '+ x+1, 'value': result[x].Id, 'label': result[x].Currency_Code__c +' '+ result[x].Building_Property_Name__c +' '+ result[x].Address__CountryCode__s +' '+ result[x].Address__Street__s +' '+ result[x].Address__City__s +' '+ result[x].Address__PostalCode__s +' '+ result[x].Address__StateCode__s, 'class': 'radio-button-label'});
                        this.addressRecords.push({ 'optionValue': 'Location ' + index, 'value': result[x].Id, 'label': constructedString, 'class': 'radio-button-label' });

                    }
                }else {
                    // event.preventDefault();
                    this.template.querySelector('lightning-record-edit-form').submit(fields); // Call the submit method
                }
            })
            .catch(error => {
                console.log('error ', error);
                this.isSpinnerLoad = false;
            });
        event.preventDefault();
        //this.template.querySelector('lightning-record-edit-form').submit(fields); // Call the submit method

    }

    handleSuccess(event) {

        // console.log( 'Updated Record Id is ', event.detail.id );
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Successful',
                // message: 'Your new survey location has been added successfully to your risk engineering request, you may proceed to the next screen.', //This success message is change due to N2G-644
                message: 'Success! Your new survey location has been added.',
                variant: 'success'
            })
        );
        // Wait for a short time before refreshing the page
        // setTimeout(() => {
        //     location.reload();
        // }, 1000); // 1000 milliseconds (1 second) delay
        this.isSpinnerLoad = false;
        this.isModalOpen = false;
        this.dispatchEvent(new CustomEvent('close'))
    }
    handleError(error) {
        console.log("error");
        // this.error = true;
        if ((this.addressfields.Address__PostalCode__s == undefined || this.addressfields.Address__PostalCode__s == '') && (this.addressfields.Address__Street__s == undefined || this.addressfields.Address__Street__s == '') && (this.addressfields.Address__City__s == undefined || this.addressfields.Address__City__s == '') && (this.addressfields.Address__StateCode__s == undefined || this.addressfields.Address__StateCode__s == '') && (this.addressfields.Address__CountryCode__s == undefined || this.addressfields.Address__CountryCode__s == '')) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'No Record',
                    message: 'There is no location record selected',
                    variant: 'error'
                })
            );
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Duplicate Record',
                    message: 'The record you are about to create looks like a duplicate. Open an existing record instead',
                    variant: 'error'
                })
            );
        }
        this.isSpinnerLoad = false;
    }
    addressInputChange(event) {
        // this.addressData.country = this.getKeyByValue(this.countryCodeRecord, event.detail.country);
        // this.addressData.province = this.getKeyByValue(this.stateCodeRecord, event.detail.province);

        this.strStreet = event.target.street;
        this.strCity = event.target.city;
        // this.strState = event.target.province;
        // this.strState = this.stateCodeRecord[event.target.province];
        this.strState = this.stateCodeRecord[this.toTitleCase(event.target.province)];
        // this.strCountry = this.countryCodeRecord[event.target.country];
        this.strCountry = this.countryCodeRecord[this.toTitleCase(event.target.country)];
        this.strPostalCode = event.target.postalCode;
    }
    toTitleCase(str) {
        return str.toLowerCase().split(' ').map(function (word) {
            return (word.charAt(0).toUpperCase() + word.slice(1));
        }).join(' ');
    }
    // getKeyByValue(object, value) {
    //     return Object.keys(object).find(key => object[key] === value);
    // }

    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
        this.dispatchEvent(new CustomEvent('close'))
        // console.log('countrycode',this.CountryCodePicklist);
    }
    
    optionSelect(event){
        console.log('OUTPUT option select : ', event.target.value);
        console.log('OUTPUT option select index: ', event.target.dataset.index);
        this.optionIndex = event.target.dataset.index;
        this.selectdDulpicateLocationId = event.target.value;
        this.anyExtisingDuplicateOptionSelected = true;
       
    }

    addLocationsOption(event){
        this.isSpinnerLoad = true;
        insertLocationRecordIntoCaseAndLocationObject ({LocationId: this.selectdDulpicateLocationId, CaseId: this.recordId})
        .then(result => {
            console.log('outputresult : ', result );
            this.isSpinnerLoad = false;
            this.isModalOpen = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Successful',
                    // message: 'Your new survey location has been added successfully to your risk engineering request, you may proceed to the next screen.', //This success message is change due to N2G-644
                    message: 'Success! Your new survey location has been added.',
                    variant: 'success'
                })
            );
        })
        .catch(error => {
          console.error('@@Error',error);
          this.isSpinnerLoad = false;
          this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Duplicate Record',
                    message: 'Duplicate Record Found : '+this.addressRecords[this.optionIndex].label,
                    variant: 'error'
                })
            );
        });
    }

    createNewLocationRecord(){
        this.isSpinnerLoad = true;
        console.log('OUTPUT addressfields: ',this.addressfields);
        insertLocationRecord ({LocationRecord: this.addressfields})
        .then(result => {
            console.log('outputresult : ', result );
            this.handleSuccess();
        })
        .catch(error => {
          console.error('@@Error',error);
          this.handleError();
        });
    }

    // _recordId;

    // @api set recordId(value) {

    //      this._recordId = value;
    //     //this._recordId = '500Ea000003zLKLIA2';

    //     console.log('recordId', this._recordId);
    //         const defaultValues = encodeDefaultFieldValues({
    //             Case__c: this._recordId
    //             });
    //             this[NavigationMixin.Navigate]({
    //                 type: 'standard__objectPage',
    //                 attributes: {
    //                     objectApiName:'Location',
    //                     actionName: 'new'
    //                 },
    //                 state: {
    //                     navigationLocation: 'RELATED_LIST',
    //                     defaultFieldValues: defaultValues
    //                 }
    //              });
    // }

    // get recordId() {
    // return this._recordId;
    // }

}