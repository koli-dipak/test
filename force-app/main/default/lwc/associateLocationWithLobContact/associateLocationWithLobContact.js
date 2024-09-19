import { LightningElement, api, track } from 'lwc';
import getLocation from '@salesforce/apex/LocationDetailController.getLocation';
import associateLocationLobRecords from '@salesforce/apex/LocationDetailController.associateLocationRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { FlowNavigationBackEvent, FlowNavigationNextEvent } from "lightning/flowSupport";

export default class AssociateLocationWithLobContact extends LightningElement {
    @api cjr;
    @api contact;
    @api lob;
    @api CaseId;
    @api availableActions = [];
    //
    @api locaRecordTemp;
    @api contactRecordTemp; //m
    @api AccountId; //m
    @api ContactRecordTypeId; //m

    @api PreviousActionButtonHide;

    @track locIds = [];
    @track locRecords;
    @track columns = [
        { label: 'FirstName', fieldName: 'FirstName' },
        { label: 'LastName', fieldName: 'LastName' }];

    @track lobcolumns = [
        { label: 'Line of Business', fieldName: 'Line_of_Business__c' },
        { label: 'Stage', fieldName: 'LOB_Stage__c' },
        { label: 'Policy', fieldName: 'LOB_Stage__c' },
        { label: 'Effective Date', fieldName: 'LOB_Effective_Date__c', type: "date" },
        { label: 'Estimated Premium', fieldName: 'Estimated_LOB_Premium__c', type: 'currency', typeAttributes: { minimumFractionDigits: '2', currencyCode: { fieldName: 'CurrencyIsoCode' } } }
    ];
    @track selectedRows = [];
    @track allLobSelectedRecord = {};
    @track allContactSelectedRecord = {};
    @track allContactSelectedRecordTempData = {};
    clickedButtonLabel;
    currentIndex = -1;
    contactIds = [];
    @track mainHelpTextTitle;
    imgsrc = 'data:@file/png;base64,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';
    @api removeListOfLocationAndContact = [];
    noContactAssociateWithLocationError = {};
    alreadyContactsAvailable = false;



    handleAccordionToggle(event) {
        // Logic to handle accordion toggle if needed
    }
    connectedCallback() {
        console.log('cjr', this.cjr);
        console.log('lobTable', this.lob);
        for(let x in this.lob){
            // this.mainHelpTextTitle ='For the following locations, you have selected '+this.lob[x].Line_of_Business__c+' for a Risk Engineering Survey Request. Please select the contacts associated to each survey location.'; // Change this for N2G-618
            this.mainHelpTextTitle ='You have selected '+this.lob[x].Line_of_Business__c+' for a risk engineering request. Please select the contacts associated to each location. If you have chosen no location, also select a contact to associate to the request.';
        }
        //
        console.log('locaRecordTemp', this.locaRecordTemp);
        console.log('contactRecordTemp', this.contactRecordTemp);
        console.log('removeListOfLocationAndContact ', this.removeListOfLocationAndContact);
        this.getLocation();

    }

    getLocation() {
        for (let x in this.cjr) {
            this.locIds.push(this.cjr[x].Location__c);
        }
        // getLocation({ locId: this.locIds })
        getLocation({ locId: this.locIds, caseId : this.CaseId })
            .then(result => {
                // Handle the success response if needed
                console.log(result);
                // this.locRecords = JSON.parse(JSON.stringify(result));
                this.locRecords = JSON.parse(result);
                console.log('## this.locRecords ##', this.locRecords);
                //let alreadyContactsAvailable = false;
                for (let x in this.locRecords) {
                    // this.locRecords[x].LocationAddressAndName = this.locRecords[x].Name + ' ' + this.locRecords[x].Location_Adress__c; // change due to N2G-618
                    this.locRecords[x].LocationAddressAndName = this.locRecords[x].Name + ' ' + this.locRecords[x].Location_Adress__c != undefined || this.locRecords[x].Location_Adress__c != '' ? this.locRecords[x].Location_Adress__c: '';
                    this.locRecords[x].defaultselected = [];
                    // this.locRecords[x].defaultContactSelected = [];
                    const defaultCont = [];
                    if(this.locRecords[x].Location_And_Contacts__r != undefined){
                        for(let y in this.locRecords[x].Location_And_Contacts__r.records){
                            defaultCont.push(this.locRecords[x].Location_And_Contacts__r.records[y].Contact__r);
                            // this.allContactSelectedRecordTempData[this.locRecords[x].Location_And_Contacts__r.records[y].Location__c] = []; comment due to not able to set for every record
                            // this.allContactSelectedRecordTempData[this.locRecords[x].Location_And_Contacts__r.records[y].Location__c] = [];
                            // alreadyContactsAvailable = true;
                            this.alreadyContactsAvailable = true;

                            const contactRecords = this.locRecords[x].Location_And_Contacts__r.records;
                            const contactIds = contactRecords.map(record => record.Contact__c);
                            this.noContactAssociateWithLocationError[this.locRecords[x].Location_And_Contacts__r.records[y].Location__c] = contactIds;
                        }
                    }
                    this.locRecords[x].defaultContactSelected = defaultCont;
                    this.allLobSelectedRecord[this.locRecords[x].Id] = this.locRecords[x].defaultselected;
                    this.allContactSelectedRecord[this.locRecords[x].Id] = this.locRecords[x].defaultContactSelected;
                    if (this.locaRecordTemp != undefined) {
                        var locationTempList = JSON.parse(this.locaRecordTemp);
                        for (var j = 0; j < locationTempList.length; j++) {
                            if (locationTempList[j].Id == this.locRecords[x].Id) {
                                this.locRecords[x].defaultselected = locationTempList[j].defaultselected;
                                this.locRecords[x].defaultContactSelected = locationTempList[j].defaultContactSelected;
                                this.allLobSelectedRecord[locationTempList[j].Id] = locationTempList[j].defaultselected;
                                this.allContactSelectedRecord[locationTempList[j].Id] = locationTempList[j].defaultContactSelected;
                            }
                        }
                    }else{
                        
                    }
                    // this.locRecords[x].defaultselected = (this.locaRecordTemp == undefined)?[]:JSON.parse(this.locaRecordTemp)[x].defaultselected;
                    // this.locRecords[x].defaultContactSelected =  this.locaRecordTemp == undefined?[]:JSON.parse(this.locaRecordTemp)[x].defaultContactSelected; //m
                    // this.allLobSelectedRecord[this.locRecords[x].Id] = this.locRecords[x].defaultselected;
                    // this.allContactSelectedRecord[this.locRecords[x].Id] = this.locRecords[x].defaultContactSelected;
                }
                if(this.locaRecordTemp != undefined){
                    for (const key in this.allContactSelectedRecord) {
                        console.log('key',key)
                        if (this.allContactSelectedRecord.hasOwnProperty(key)) {
                            var contactList = [];
                            for (const keyId in this.allContactSelectedRecord[key]) {
                                contactList.push(this.allContactSelectedRecord[key][keyId].Id)
                            }
                            this.allContactSelectedRecord[key] = contactList;
    
                    }
                }
                }
                
                // if(alreadyContactsAvailable){
                if(this.alreadyContactsAvailable){
                    for(let x in this.locRecords){
                        this.allContactSelectedRecord[this.locRecords[x].Id] = [];

                        // for set location into below object with empty array [] if no location key is available
                        if(!(this.noContactAssociateWithLocationError.hasOwnProperty(this.locRecords[x].Id))){
                            this.noContactAssociateWithLocationError[this.locRecords[x].Id] = [];
                        }
                    }
                //    this.allContactSelectedRecord = this.allContactSelectedRecordTempData;
                }
                console.log('==this.allContactSelectedRecor====>',this.allContactSelectedRecord);

                console.log("this.locRecords", this.locRecords)

                for(let x in this.locRecords){
                    this.lobRowSelection(JSON.parse(JSON.stringify(this.lob)), x, this.locRecords[x].Id)
                }
            })
            .catch(error => {
                // Handle the error response if needed
                console.error(error);
            });


    }

    // lobRowSelection(event) {
    //     // console.log("selectedRows", JSON.parse(JSON.stringify(this.selectedRows)));
    //     this.selectedRows = event.detail.selectedRows;
    //     console.log('Selected Rows:', this.selectedRows);

    //     console.log('@index', event.target.dataset.index);
    //     console.log('@record', JSON.parse(JSON.stringify(event.target.dataset.location)));
    //     const locationName = JSON.parse(JSON.stringify(event.target.dataset.location));

    //     var lobIds = [];
    //     JSON.parse(JSON.stringify(this.selectedRows)).forEach(element => {
    //         lobIds.push(element.Id);
    //     });

    //     const searchIndex = this.locRecords.findIndex((e) => e.Id == locationName);
    //     this.locRecords[searchIndex].defaultselected = lobIds;
    //     this.locaRecordTemp = JSON.stringify(this.locRecords);


    //     this.allLobSelectedRecord = {
    //         ...this.allLobSelectedRecord,
    //         [locationName]: lobIds
    //     };

    //     console.log('allrec', JSON.parse(JSON.stringify(this.allLobSelectedRecord)));
    // }

    lobRowSelection(lobRecord, index, locId) {
        // console.log("selectedRows", JSON.parse(JSON.stringify(this.selectedRows)));
        this.selectedRows = lobRecord;
        console.log('Selected Rows:', this.selectedRows);

        console.log('@index', index);
        console.log('@record', locId);
        const locationName = locId;

        var lobIds = [];
        JSON.parse(JSON.stringify(this.selectedRows)).forEach(element => {
            lobIds.push(element.Id);
        });

        const searchIndex = this.locRecords.findIndex((e) => e.Id == locationName);
        this.locRecords[searchIndex].defaultselected = lobIds;
        this.locaRecordTemp = JSON.stringify(this.locRecords);


        this.allLobSelectedRecord = {
            ...this.allLobSelectedRecord,
            [locationName]: lobIds
        };

        console.log('allrec', JSON.parse(JSON.stringify(this.allLobSelectedRecord)));
    }

    // contactRowSelection(event){
    //     this.selectedRows = event.detail.selectedRows;
    //     console.log('this.selectedRows',this.selectedRows);
    //     const locationName = JSON.parse(JSON.stringify(event.target.dataset.location));
    //     var contactIds = [];
    //     JSON.parse(JSON.stringify(this.selectedRows)).forEach(element => {
    //         contactIds.push(element.Id);
    //     });

    //     //m
    //     const searchIndex = this.locRecords.findIndex((e) => e.Id==locationName);
    //     this.locRecords[searchIndex].defaultContactSelected = contactIds;
    //     this.contactRecordTemp = JSON.stringify(this.locRecords);

    //     this.allContactSelectedRecord = {
    //         ...this.allContactSelectedRecord,
    //         [locationName]: contactIds
    //     };
    //     console.log('allContactrec',JSON.parse(JSON.stringify(this.allContactSelectedRecord)));
    //     console.log('locRecords',JSON.parse(JSON.stringify(this.locRecords)));
    // }

    contactRowSelection(event) {
        // 1: e.detail.selectedRows is array of object
        console.log('@@event.detail@@', event.detail.contactRecords); //m
        console.log('@@event.detail@@', event.detail.locationRecordId); //m
        console.log('@@event.detail.loctionIndex@@', event.detail.loctionIndex); //m
        console.log('@@event.detail.selectedContacts@@', event.detail.selectedContacts); //m
        this.currentIndex = event.detail.loctionIndex;



        // this.selectedRows = event.detail.selectedRows;
        // this.selectedRows = [JSON.parse(JSON.stringify(event.detail.contactRecords))]; //m
        // this.selectedRows = Array.isArray(event.detail.contactRecords) ? event.detail.contactRecords : [event.detail.contactRecords]; //m

        // if(this.prevIndex == this.currentIndex){
        //     this.selectedRows.push(event.detail.contactRecords); //m
        //     console.log("pushing into the selected row");
        //     this.contactIds = [];
        // }
        // else {
        //     this.selectedRows = [];
        //     this.contactIds = [];
        //     this.prevIndex = this.currentIndex;
        //     this.selectedRows.push(event.detail.contactRecords);
        //     console.log("clearing selected row");
        // } comment today


        console.log('this.selectedRows', this.selectedRows);
        // const locationName = JSON.parse(JSON.stringify(event.target.dataset.location));
        const locationName = event.detail.locationRecordId;
        var contactId = [];
        //var locationName = event.detail.locationRecordId;
        contactId = JSON.parse(JSON.stringify(event.detail.selectedContacts));
        const searchIndex = this.locRecords.findIndex((e) => e.Id == locationName);
        this.locRecords[searchIndex].defaultContactSelected = contactId;
        this.locaRecordTemp = JSON.stringify(this.locRecords);
        console.log('==locaRecordTemp==>', this.locaRecordTemp);


        // JSON.parse(JSON.stringify(this.selectedRows)).forEach(element => {
        //     this.contactIds.push(element.Id);

        // }); comment today

        //m
        // const searchIndex = this.locRecords.findIndex((e) => e.Id==locationName);
        // this.locRecords[searchIndex].defaultContactSelected = contactIds;
        // this.contactRecordTemp = JSON.stringify(this.locRecords);

        // this.allContactSelectedRecord = {
        //     ...this.allContactSelectedRecord,
        //     [locationName]: this.contactIds
        // };

        // Assuming event.detail.contactRecords is an array, extract the contactIds into a new array.
        const newContactIds = event.detail.contactRecords.Id;

        // If the location already has selected contactIds, merge the new contactId with the existing ones.
        if (this.allContactSelectedRecord.hasOwnProperty(locationName)) {
            this.allContactSelectedRecord[locationName] = [
                ...this.allContactSelectedRecord[locationName],
                newContactIds
            ];
        } else {
            // If it's the first time selecting contacts for this location, simply assign the new contactId.
            this.allContactSelectedRecord[locationName] = [newContactIds];
        }

        console.log('allContactrec', JSON.parse(JSON.stringify(this.allContactSelectedRecord)));
        console.log('locRecords', JSON.parse(JSON.stringify(this.locRecords)));
    }

    removeContactIdFromRecord(event) {
        console.log('@@event.detail@@', event.detail.contactRecords); //m
        console.log('@@event.detail@@', event.detail.locationRecordId); //m
        const locationName = JSON.parse(JSON.stringify(event.detail.locationRecordId));
        const removeContactIds = event.detail.contactRecords;
        if (this.allContactSelectedRecord.hasOwnProperty(locationName)) {
            // Filter out the contactId from the array of contactIds for the specified locationName
            this.allContactSelectedRecord[locationName] = this.allContactSelectedRecord[locationName].filter(id => id !== removeContactIds);
            // let tempArray = this.allContactSelectedRecord[locationName];
            // this.allContactSelectedRecord[locationName] = this.allContactSelectedRecord[locationName].forEach((id, index) => {
            //     if(id != removeContactIds){
            //         tempArray[index] = [];
            //     }
            // });
            //this.allContactSelectedRecord[locationName] = tempArray;
            if (this.noContactAssociateWithLocationError !== null && Object.keys(this.noContactAssociateWithLocationError).length !== 0) {
                if (this.noContactAssociateWithLocationError.hasOwnProperty(locationName)) {
                    this.noContactAssociateWithLocationError[locationName] = this.noContactAssociateWithLocationError[locationName].filter(id => id !== removeContactIds);
                }
            }
        }
        var lt = JSON.parse(this.locaRecordTemp);
        console.log('locaRecordTemp', lt);
        console.log('locaRecordTemsdsdp', this.locaRecordTemp);
        for (var i = 0; i < lt.length; i++) {

            if (lt[i].Id == locationName) {
                var defaultCon = [];
                for (var j = 0; j < lt[i].defaultContactSelected.length; j++) {
                    if (lt[i].defaultContactSelected[j].Id == removeContactIds) {
                        continue;
                    } else {
                        defaultCon.push(lt[i].defaultContactSelected[j]);
                    }
                }
                lt[i].defaultContactSelected = defaultCon;
            }

            // to parmanet delete of location contact junction object record
            if(lt[i].Id == locationName && lt[i].Location_And_Contacts__r && lt[i].Location_And_Contacts__r.records){
                for (var j = 0; j < lt[i].Location_And_Contacts__r.records.length; j++) {
                    if (lt[i].Location_And_Contacts__r.records[j].Contact__c == removeContactIds && lt[i].Location_And_Contacts__r.records[j].Location__c == locationName) {
                        this.removeListOfLocationAndContact.push(lt[i].Location_And_Contacts__r.records[j].Id)
                    }
                }
            }

        }
        console.log('locaRecordTemp', lt);
        this.locaRecordTemp = JSON.stringify(lt);
        console.log('allContactrec', JSON.parse(JSON.stringify(this.allContactSelectedRecord)));
        console.log('locRecords', JSON.parse(JSON.stringify(this.locRecords)));
        console.log('locaRecordTemp', JSON.parse(JSON.stringify(this.locaRecordTemp)));
        console.log('removeListOfLocationAndContact', this.removeListOfLocationAndContact);

    }


    handleClick(event) {
        // this.clickedButtonLabel = event.target.label;
        this.clickedButtonLabel = event.target.title;
        if (event.target.title == 'Next') {
            // let isError = false;
            // for (const key in  this.allContactSelectedRecord) {
            //     if (Array.isArray( this.allContactSelectedRecord[key]) &&  this.allContactSelectedRecord[key].length === 0) {
            //         isError = true;
            //         break;
            //     }
            // }
            // if(isError == true){
            //     this.dispatchEvent(
            //     new ShowToastEvent({
            //             title: 'Error',
            //             // message: 'One or more contacts are required per location. You may look up an existing contact or create a new one.',
            //             message: 'One or more contacts is required for your Risk Engineering Request.',
            //             variant: 'error'
            //         })
            //     );
            //     return;
            // }

// anand logic
        //     let isError = false;
        //     let defaultSelectionIsNull = false;
        //    let noContactAssociateWithLocationError = this.noContactAssociateWithLocationError;
        //     let allContactSelectedRecord = JSON.parse(JSON.stringify(this.allContactSelectedRecord));

        //     let DefaultDeleted = false;
        //     let DefaultDeletedArrObj = [];

        //     //when default selection is null
        //    if(noContactAssociateWithLocationError == null){
        //         console.log('Default Selection object is null...');
        //         defaultSelectionIsNull = true;
        //    }

        //     for(let x in noContactAssociateWithLocationError){
        //         if( noContactAssociateWithLocationError[x].length === 0 ){
        //             DefaultDeleted = true;
                    
        //             DefaultDeletedArrObj.push(x)
        //             console.log('OUTPUT x : ',DefaultDeletedArrObj);
        //         }
               
        //     }

        //     for(let y in allContactSelectedRecord){
        //         let skipOther = false;
                                
        //           if( DefaultDeletedArrObj.includes(y)){
        //              if(allContactSelectedRecord[y].length === 0){
        //                  isError = true;
        //                  skipOther = true;
        //              } else {
        //                  isError = false;
        //              }
        //          } else if (DefaultDeletedArrObj.length == 0 || defaultSelectionIsNull){
        //              if(allContactSelectedRecord[y].length == 0){
        //                  isError = true;
        //                  skipOther = true;
        //              } else {
        //                  isError = false;
        //              }
        //          }

        //          if(noContactAssociateWithLocationError.hasOwnProperty(y) && !isError){
        //              if(noContactAssociateWithLocationError[y].length != 0 && allContactSelectedRecord[y].length == 0)
        //                 isError = false;
        //          } 
        //     }
            // andand logic end

            let isError = false;
            let noContactAssociateWithLocationError = this.noContactAssociateWithLocationError;
            let allContactSelectedRecord = JSON.parse(JSON.stringify(this.allContactSelectedRecord));

            // Check if no keys in noContactAssociateWithLocationError
            if (Object.keys(noContactAssociateWithLocationError).length === 0) {
               for(let x in allContactSelectedRecord){
                    if(allContactSelectedRecord[x].length == 0){
                        isError = true;
                        break;
                    }
               }
            } else {
                // Iterate through the keys in noContactAssociateWithLocationError
                for (let key in noContactAssociateWithLocationError) {
                    // Check if the key exists in allContactSelectedRecord
                    if (key in allContactSelectedRecord) {
                        const noContactArray = noContactAssociateWithLocationError[key];
                        const allContactArray = allContactSelectedRecord[key];

                        // Check if both arrays are empty
                        if (noContactArray.length === 0 && allContactArray.length === 0) {
                            // Set isError to true and break the loop
                            isError = true;
                            break;
                        }
                    }
                }
            }

            console.log("isError:", isError);

            if(isError){
                this.dispatchEvent(
                new ShowToastEvent({
                        title: 'Error',
                        // message: 'One or more contacts are required per location. You may look up an existing contact or create a new one.',
                        message: 'One or more contacts is required for your Risk Engineering Request.',
                        variant: 'error'
                    })
                );
                return;
            }



            associateLocationLobRecords({ selectedLobRecords: this.allLobSelectedRecord, selectedContactRecords: this.allContactSelectedRecord, CaseId: this.CaseId, removeListOfLocationAndContact: this.removeListOfLocationAndContact })
                .then(result => {
                    console.log('result on next', result);
                })
                .catch(error => {
                    console.error('error on next', error);
                });

            if (this.availableActions.find((action) => action === "NEXT")) {
                const navigateNextEvent = new FlowNavigationNextEvent();
                this.dispatchEvent(navigateNextEvent);
            }
        } else {
            if (this.availableActions.find((action) => action === "BACK")) {
                const navigateBackEvent = new FlowNavigationBackEvent();
                this.dispatchEvent(navigateBackEvent);
            }
            // this.dispatchEvent(new FlowNavigationBackEvent());
            console.log('Available Actions:', this.availableActions);
        }
    }
}