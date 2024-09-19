import { LightningElement, track, wire} from 'lwc';
import getAgentContactDetail from '@salesforce/apex/RequestContactUpdateController.getAgentContactDetail';
import updateAgentContact from '@salesforce/apex/RequestContactUpdateController.updateAgentContact';
import getContactDetails from '@salesforce/apex/RequestContactUpdateController.getContactDetails';
import { CurrentPageReference } from 'lightning/navigation'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import N2G_Logo from '@salesforce/resourceUrl/N2GLogo';
import N2GFooter_Logo from '@salesforce/resourceUrl/N2GFooterLogo';



export default class EmailUi extends LightningElement {
    
    N2GLogo = N2G_Logo ;
    N2GFooterLogo=N2GFooter_Logo;
    Website_HelpText = 'Please ensure to include http//:when capturing your website.';
    NoOfEmployee_HelpText='No of Employees with a title of Broker and Account Executives in your office / department';
    AnnualPremium_HelpText='Annual Premium Value placed by your office / department accross all carriers not only N2G';

    EventSection_HelpText='Please add the events your office plans to attend and or sponsor in the next 12 months';
    TopCarrierSection_HelpText='Please add your top carriers';
    SpecialityInfoSection_HelpText='Please add any specialty lines and industry verticals your office targets, e.g. Multinational Programs, Technology,...';
    lineOfBusinessSection_HelpText='Please add any line of business your office places Ex. Foreign Casualty, Global Property';

    parameters = {};
    @track data;
    @track objectData = {};
    @track saveDraftValues = [];
    @track spinnerStatus = false;
    @track HeadOfficeOptions=[];
    @track createNewHeadOffice=false;
    @track createNewManager=false;
    @track createNewLOBManager=false;
    @track showCreateContact=false;
    @track newContact={};
    @track salutationOptions=[];
    @track isLinkExpired=false;
    @track showRecordForm=false;
    @track showRecordFormClass='slds-hide';
    @track isSuccess=false;
    @track validateRequired;

    @track Competitor1Option=[];
    @track Competitor2Option=[];
    @track Competitor3Option=[];
    @track CompetitorNameOption=[];
    @track LOBCompetitor1Option=[];
    @track LOBCompetitor2Option=[];
    @track LOBCompetitor3Option=[];
    @track LOBProductOptions = [];

    @track events=[];
    @track eventDeleteEnable=false;
    @track topCarriers=[];
    @track topCarrierDeleteEnable=false;
    @track specialtyInfos=[];
    @track specialtyDeleteEnable=false;
    @track lineOfBusinessData=[];
    @track lineOfBusinessDeleteEnable=false;

    @track refreshChild=false;
    @track refreshManagerChild={};

    @track additionalContactRecords=[];
    @track additionalLOBContactRecords=[];
    @track headOfficeAdditionalContact=[];
    @track emailWiseContact={};

    @track defaultManagerId;
   
    get options() {
        return [
            { label: 'N2G', value: 'N2G' },
            { label: 'In Progress', value: 'inProgress' },
            { label: 'Finished', value: 'finished' },
        ];
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference){
       
        if(currentPageReference){
            this.parameters=currentPageReference.state;
        }
    }

    

    connectedCallback() {
        this.data={};
        debugger;
        console.log('EmailUI');
        this.agentContactInformation();
        this.getContactInfo('');
    }

    agentContactInformation(){
        this.spinnerStatus=true;
        getAgentContactDetail({"recordId": this.parameters.id})
        .then(result => {
            //desierlized
            console.log('@@@@', JSON.parse(result));
            this.spinnerStatus=false;
            var resultData=JSON.parse(result);
            console.log("@@@resultData@@@",resultData);
            this.data = resultData.Data;
            //this.defaultManagerId = this.data.Manager__c;
            for(var key in resultData.Competitor1){
                this.Competitor1Option.push({"label":resultData.Competitor1[key], "value":key})
            }
            for(var key in resultData.Competitor2){
                this.Competitor2Option.push({"label":resultData.Competitor2[key], "value":key})
            }
            for(var key in resultData.Competitor3){
                this.Competitor3Option.push({"label":resultData.Competitor3[key], "value":key})
            }
            for(var key in resultData.CompetitorName){
                this.CompetitorNameOption.push({"label":resultData.CompetitorName[key], "value":key})
            }
            for(var key in resultData.LOBCompetitor1){
                this.LOBCompetitor1Option.push({"label":resultData.Competitor1[key], "value":key})
            }
            for(var key in resultData.LOBCompetitor2){
                this.LOBCompetitor2Option.push({"label":resultData.Competitor2[key], "value":key})
            }
            for(var key in resultData.LOBCompetitor3){
                this.LOBCompetitor3Option.push({"label":resultData.Competitor3[key], "value":key})
            }
            for(var key in resultData.LOBProduct){
                this.LOBProductOptions.push({"label":resultData.LOBProduct[key], "value":key})
            }
            for(var key in resultData.Salutation){
                this.salutationOptions.push({"label":resultData.Salutation[key], "value":key})
            }

            this.Competitor1Option.reverse();
            this.Competitor2Option.reverse();
            this.Competitor3Option.reverse();
            this.CompetitorNameOption.reverse();
            this.LOBCompetitor1Option.reverse();
            this.LOBCompetitor2Option.reverse();
            this.LOBCompetitor3Option.reverse();
            this.LOBProductOptions.reverse();
            this.salutationOptions.reverse();

            this.Competitor1Option=JSON.parse(JSON.stringify(this.Competitor1Option))
            this.Competitor2Option=JSON.parse(JSON.stringify(this.Competitor2Option))
            this.Competitor3Option=JSON.parse(JSON.stringify(this.Competitor3Option))
            this.CompetitorNameOption=JSON.parse(JSON.stringify(this.CompetitorNameOption))
            this.LOBCompetitor1Option=JSON.parse(JSON.stringify(this.LOBCompetitor1Option))
            this.LOBCompetitor2Option=JSON.parse(JSON.stringify(this.LOBCompetitor2Option))
            this.LOBCompetitor3Option=JSON.parse(JSON.stringify(this.LOBCompetitor3Option))
            this.salutationOptions=JSON.parse(JSON.stringify(this.salutationOptions))

            this.isLinkExpired=this.data.Is_Link_Expired__c;
            this.showRecordForm=!this.isLinkExpired;
            this.showRecordFormClass=this.showRecordForm?'slds-show':'slds-hide';
            

            
            /*this.events=[{Event_Name__c : resultData.Events[0].Event_Name__c}, {Location__c : resultData.Events[0].Location__c},{Event_Start_Date__c:resultData.Events[0].Event_Start_Date__c},{Event_End_Date__c:resultData.Events[0].Event_End_Date__c}];
            console.log('below 12',resultData);

            this.topCarriers=[{Comment__c:resultData.TopCarrier[0].Comment__c},{Competitor_Name__c:resultData.TopCarrier[0].Competitor_Name__c},{Premium__c:resultData.TopCarrier[0].Premium__c}];

           
            this.specialtyInfos=[{Competitor_1__c:resultData.SpecialityInfo[0].Competitor_1__c},{Competitor_2__c:resultData.SpecialityInfo[0].Competitor_2__c},{Competitor_3__c:resultData.SpecialityInfo[0].Competitor_3__c},{Premium__c:resultData.SpecialityInfo[0].Premium__c},{Product__c:resultData.SpecialityInfo[0].Product__c},{Wholesale__c:resultData.SpecialityInfo[0].Wholesale__c}];
           
            for(let i = 0; i < this.events.length; i++){
                console.log('Success OKK',i,this.events[i].Event_Name__c);


                // console.log(this.events=[{Event_Name__c : resultData.Events[i].Event_Name__c, Location__c : resultData.Events[i].Location__c,Event_Start_Date__c:resultData.Events[i].Event_Start_Date__c,Event_End_Date__c:resultData.Events[i].Event_End_Date__c}]);
                }*/
                
                // this.events=[{Event : resultData.Events[0].Event_Name__c}, {Location : resultData.Events[0].Location__c},{Eventg:resultData.Events[0].Event_Start_Date__c},{Eventy:resultData.Events[0].Event_End_Date__c}];
                // console.log('below 12',this.events);
    
                this.events=[];
    
                // this.topCarriers=[{Comment__c:resultData.TopCarrier[0].Comment__c},{Competitor_Name__c:resultData.TopCarrier[0].Competitor_Name__c},{Premium__c:resultData.TopCarrier[0].Premium__c}];
    
                this.topCarriers=[];
               
                // this.specialtyInfos=[{Competitor_1__c:resultData.SpecialityInfo[0].Competitor_1__c},{Competitor_2__c:resultData.SpecialityInfo[0].Competitor_2__c},{Competitor_3__c:resultData.SpecialityInfo[0].Competitor_3__c},{Premium__c:resultData.SpecialityInfo[0].Premium__c},{Product__c:resultData.SpecialityInfo[0].Product__c},{Wholesale__c:resultData.SpecialityInfo[0].Wholesale__c}];
    
                this.specialtyInfos=[];
                
                this.lineOfBusinessData=[];
               
                for(let i = 0; i < resultData.Events.length; i++){
                    var e = resultData.Events[i];
                    this.events.push(e);
                }
                for(let i = 0; i < resultData.SpecialityInfo.length; i++){
                    var e = resultData.SpecialityInfo[i];
                    if(e.Broker_Contact__c!=null){
                        e["Manager__c"]={
                            isSaved:true,
                            existing:false,
                            index:i,
                            FirstName:e.Broker_Contact__r.FirstName__c,
                            LastName:e. Broker_Contact__r.LastName__c,
                            Email:e.Broker_Contact__r.Email__c,
                            Salutation:e.Broker_Contact__r.Salutation__c,
                            Phone:e.Broker_Contact__r.Phone__c,
                            displayText:e.Broker_Contact__r.FirstName__c+' '+e.Broker_Contact__r.LastName__c+ '('+e.Broker_Contact__r.Email__c+')'
                        }   
                        this.additionalContactRecords.push(e["Manager__c"]);  
                        this.emailWiseContact[e.Broker_Contact__r.Email__c]=  e["Manager__c"]; 
                    }else if(e.Manager__c!=undefined){
                        e["Manager__c"]={
                            existing:true,
                            Id:e.Manager__c,
                            index:i,
                            FirstName:e.Manager__r.FirstName,
                            LastName:e.Manager__r.LastName,
                            Email:e.Manager__r.Email,
                            Salutation:e.Manager__r.Salutation,
                            Phone:e.Manager__r.Phone,
                            displayText:e.Manager__r.FirstName+' '+e.Manager__r.LastName+ '('+e.Manager__r.Email+')'
                        }   
                         
                    }
                    this.specialtyInfos.push(e);
                }
                for(let i = 0; i < resultData.TopCarrier.length; i++){
                    var e = resultData.TopCarrier[i];
                    this.topCarriers.push(e);
                }
                for(let i = 0; i < resultData.LineOfBusiness.length; i++){
                    var e = resultData.LineOfBusiness[i];
                    if(e.Broker_Contact__c!=null){
                        e["Manager__c"]={
                            isSaved:true,
                            existing:false,
                            index:i,
                            FirstName:e.Broker_Contact__r.FirstName__c,
                            LastName:e. Broker_Contact__r.LastName__c,
                            Email:e.Broker_Contact__r.Email__c,
                            Salutation:e.Broker_Contact__r.Salutation__c,
                            Phone:e.Broker_Contact__r.Phone__c,
                            displayText:e.Broker_Contact__r.FirstName__c+' '+e.Broker_Contact__r.LastName__c+ '('+e.Broker_Contact__r.Email__c+')'
                        }   
                        this.additionalLOBContactRecords.push(e["Manager__c"]);  
                        this.emailWiseContact[e.Broker_Contact__r.Email__c]=  e["Manager__c"]; 
                    }else if(e.Manager__c!=undefined){
                        e["Manager__c"]={
                            existing:true,
                            Id:e.Manager__c,
                            index:i,
                            FirstName:e.Manager__r.FirstName,
                            LastName:e.Manager__r.LastName,
                            Email:e.Manager__r.Email,
                            Salutation:e.Manager__r.Salutation,
                            Phone:e.Manager__r.Phone,
                            displayText:e.Manager__r.FirstName+' '+e.Manager__r.LastName+ '('+e.Manager__r.Email+')'
                        }
                    }
                    this.lineOfBusinessData.push(e);
                }

                this.topCarrierDeleteEnable=this.topCarriers.length>1;
                this.eventDeleteEnable=this.events.length>1;
                this.specialtyDeleteEnable=this.specialtyInfos.length>1;
                this.lineOfBusinessDeleteEnable=this.lineOfBusinessData.length>1;
                        
                if(this.topCarriers.length==0){
                    this.topCarriers=[{}];
                }
                if(this.events.length==0){
                    this.events=[{}];
                }
                if(this.specialtyInfos.length==0){
                    this.specialtyInfos=[{}];
                }
                if(this.lineOfBusinessData.length==0){
                    this.lineOfBusinessData=[{}];
                }

                if(resultData.BrokerContact!=undefined){
                    for(let i = 0; i < resultData.BrokerContact.length; i++){
                        var e = resultData.BrokerContact[i];
                        this.data["Head_of_Office__c"]={
                            isSaved:true,
                            FirstName:e.FirstName__c,
                            LastName:e.LastName__c,
                            Email:e.Email__c,
                            Salutation:e.Salutation,
                            Phone:e.Phone__c,
                            displayText:e.FirstName__c+' '+e.LastName__c+ '('+e.Email__c+')'
                        }    
                        this.headOfficeAdditionalContact=[this.data["Head_of_Office__c"]]; 
                        this.HeadofOfficeNewRec=JSON.stringify(this.data["Head_of_Office__c"]); 
                    }
                     
                }
            })
        
        .catch(error => {
            this.spinnerStatus=false;
            console.log('failed',error);
        });

    }

    addEvents(event){
        this.events.push({});
        this.eventDeleteEnable=this.events.length>1;
    }
    deleteEvent(event){
        console.log('@@event',event.target.dataset.index)
        var indx=parseInt(event.target.dataset.index);
        var eventData=JSON.parse(JSON.stringify(this.events));
        eventData.splice(indx, 1);
        this.events=eventData;
        this.eventDeleteEnable=eventData.length>1;
    }
    handleEventChange(event){
        console.log('@@event',event.target.dataset.index)
        var indx=parseInt(event.target.dataset.index);
        var eventData=JSON.parse(JSON.stringify(this.events));
        eventData[indx][event.target.name]= event.target.value;
        this.events=eventData;
    }

    handleEventAddressChange(event){
        console.log('@@event',event.target.dataset.index)
        var indx=parseInt(event.target.dataset.index);
        var eventData=JSON.parse(JSON.stringify(this.events));
        eventData[indx]['Event_Street__c']= event.target.street;
        eventData[indx]['Event_City__c']= event.target.city;
        eventData[indx]['Event_State__c']= event.target.province;
        eventData[indx]['Event_Country__c']= event.target.country;
        eventData[indx]['Event_PostalCode__c']= event.target.postalCode;
        console.log('@@eventData::'+eventData);
        console.log('@@indx::'+indx);
        this.events=eventData;
    }

    addTopCarrier(event){
        this.topCarriers.push({});
        this.topCarrierDeleteEnable=this.topCarriers.length>1;
    }
    deleteTopCarrier(event){
        console.log('@@event',event.target.dataset.index)
        var indx=parseInt(event.target.dataset.index);
        var data=JSON.parse(JSON.stringify(this.topCarriers));
        data.splice(indx, 1);
        this.topCarriers=data;
        this.topCarrierDeleteEnable=data.length>1;
    }
    handleTopCarrierChange(event){
        console.log('@@event',event.target.dataset.index)
        var indx=parseInt(event.target.dataset.index);
        var data=JSON.parse(JSON.stringify(this.topCarriers));
        data[indx][event.target.name]= event.target.value;
        this.topCarriers=data;
    }
    
    addSpecialtyInfo(event){
        this.specialtyInfos.push({});
        this.specialtyDeleteEnable=this.specialtyInfos.length>1;
        console.log("specialtyInfos@@",this.specialtyInfos);
        console.log("specialtyDeleteEnable@@",this.specialtyDeleteEnable);

    }
    deleteSpecialtyInfo(event){
        console.log('@@event',event.target.dataset.index)
        var indx=parseInt(event.target.dataset.index);
        var data=JSON.parse(JSON.stringify(this.specialtyInfos));
        data.splice(indx, 1);
        this.specialtyInfos=data;
        this.specialtyDeleteEnable=data.length>1;
    }
    handleSpecialtyInfoChange(event){
        console.log('@@event',event.target.dataset.index)
        var indx=parseInt(event.target.dataset.index);
        var data=JSON.parse(JSON.stringify(this.specialtyInfos));
        data[indx][event.target.name]= event.target.value;
        this.specialtyInfos=data;
    }
    addLineOfBusiness(event){
        this.lineOfBusinessData.push({});
        this.lineOfBusinessDeleteEnable=this.lineOfBusinessData.length>1;
        console.log("lineOfBusinessData@@",this.lineOfBusinessData);
        console.log("lineOfBusinessDeleteEnable@@",this.lineOfBusinessDeleteEnable);

    }
    deleteLineOfBusiness(event){
        console.log('@@event',event.target.dataset.index)
        var indx=parseInt(event.target.dataset.index);
        var data=JSON.parse(JSON.stringify(this.lineOfBusinessData));
        data.splice(indx, 1);
        this.lineOfBusinessData=data;
        this.lineOfBusinessDeleteEnable=data.length>1;
    }
    handleLOBChange(event){
        console.log('@@event',event.target.dataset.index)
        var indx=parseInt(event.target.dataset.index);
        var data=JSON.parse(JSON.stringify(this.lineOfBusinessData));
        data[indx][event.target.name]= event.target.value;
        this.lineOfBusinessData=data;
    }

    getContactInfo(filterName){
        this.spinnerStatus=true;
        getContactDetails({"filter": filterName})
        .then(result => {
            var data= JSON.parse(result);
            this.HeadOfficeOptions=[];
            this.HeadOfficeOptions.push({"label":"Create New Contact", "value":"New"})
            for(var i in data){
                this.HeadOfficeOptions.push({"label":data[i].Name,"value":data[i].Id})
            }

            this.ManagerOptions=[];
            this.ManagerOptions.push({"label":"Create New Contact", "value":"New"})
            for(var i in data){
                this.ManagerOptions.push({"label":data[i].Name,"value":data[i].Id})
            }
        })
        .catch(error => {
            this.spinnerStatus=false;
            console.log('failed',error);
        });

    }

   /* @wire(getAgentContactData, {recordId: 'a8c7i000000JXG0AAO'})
    agentContactData({data, error}){
        if(data){
            this.data = data;
            console.log('data', data);
        }
        if(error){
            console.log('Error', error);
        }
    }*/

    handlechange(event){
        this.objectData[event.target.name] = event.target.value;
    }

    handleHeadOfficeChange(event){
        this.headOfOffice = event.detail.selectedRecord;
        if(this.headOfOffice==undefined){
            this.objectData['Head_of_Office__c'] =null;
            this.newContact={isCancelled:this.newContact.isCancelled};
            this.newContact.index='headOffice';
            return;
            
        }
       /* if(this.headOfOffice!=null && this.headOfOffice!="New"){
            this.objectData['Head_of_Office__c'] = this.headOfOffice;
        }else if(this.headOfOffice=="New"){
            this.createNewHeadOffice=true;
            this.showCreateContact=true;
            this.objectData['Head_of_Office__c'] =null;
        }*/
        if((this.headOfOffice.Id!=undefined && this.headOfOffice.Id!='') || (this.headOfOffice.Email!=undefined && this.headOfOffice.Email!='')){
            this.createNewHeadOffice=true;
            this.showCreateContact=true;
            this.objectData['Head_of_Office__c'] =this.headOfOffice.Id;
            this.newContact={};
            this.newContact.existing=true;
            this.newContact.Id=this.headOfOffice.Id;
            this.newContact.FirstName=this.headOfOffice.FirstName;
            this.newContact.LastName=this.headOfOffice.LastName;
            this.newContact.Email=this.headOfOffice.Email;
            this.newContact.Salutation=this.headOfOffice.Salutation;
            this.newContact.Phone=this.headOfOffice.Phone;
            this.newContact.index='headOffice';
        }
        else if(this.headOfOffice.Id==''){
            this.createNewHeadOffice=true;
            this.showCreateContact=true;
            this.objectData['Head_of_Office__c'] =null;
            this.newContact={};
            this.newContact.index='headOffice';
            
        }
        
    }
    handleManagerChange(event){
        
        this.Manager = event.detail.selectedRecord;
        /*if(this.Manager!=null && this.Manager!="New"){
            this.objectData['Manager__c'] = this.Manager;
        }else if(this.Manager=="New"){
            this.createNewManager=true;
            this.showCreateContact=true;
            this.objectData['Manager__c'] = null;
        }*/
        if(this.Manager==undefined){
            this.objectData['Manager__c'] =null;
            
            this.newContact={existing:false,isCancelled:this.newContact.isCancelled};
            var t = parseInt(event.target.dataset.index);
            this.newContact.index=t;
            var a = JSON.parse(JSON.stringify(this.specialtyInfos));
            a[t][event.target.name] = this.newContact,
            this.specialtyInfos = a
            return;
        }
        
        if((this.Manager.Id!=undefined && this.Manager.Id!='') || (this.Manager.Email!=undefined && this.Manager.Email!='')){
            this.createNewManager=true;
            this.showCreateContact=true;
            this.objectData['Manager__c'] =this.Manager.Id;
            this.newContact={};
            this.newContact.existing=true;
            this.newContact.Id=this.Manager.Id;
            this.newContact.FirstName=this.Manager.FirstName;
            this.newContact.LastName=this.Manager.LastName;
            this.newContact.Email=this.Manager.Email;
            this.newContact.Salutation=this.Manager.Salutation;
            this.newContact.Phone=this.Manager.Phone;
            
            var t = parseInt(event.target.dataset.index);
            this.newContact.index=t;
            var a = JSON.parse(JSON.stringify(this.specialtyInfos));
            a[t][event.target.name] = this.newContact;
            this.specialtyInfos = a
        }
        else if(this.Manager.Id==''){
            this.createNewManager=true;
            this.showCreateContact=true;
            this.objectData['Manager__c'] =null;
            this.newContact={existing:false};
            var t = parseInt(event.target.dataset.index);
            this.newContact.index=t;
            var a = JSON.parse(JSON.stringify(this.specialtyInfos));
            a[t][event.target.name] = this.newContact,
            this.specialtyInfos = a
            
        }
    }

    handleLOBManagerChange(event){
        this.LOBManager = event.detail.selectedRecord;
        /*if(this.LOBManager!=null && this.LOBManager!="New"){
            this.objectData['Manager__c'] = this.LOBManager;
        }else if(this.LOBManager=="New"){
            this.createNewLOBManager=true;
            this.showCreateContact=true;
            this.objectData['Manager__c'] = null;
        }*/
        if(this.LOBManager==undefined){
            this.objectData['Manager__c'] =null;
            
            this.newContact={existing:false,isCancelled:this.newContact.isCancelled};
            var t = parseInt(event.target.dataset.index);
            this.newContact.index=t;
            var a = JSON.parse(JSON.stringify(this.lineOfBusinessData));
            a[t][event.target.name] = this.newContact,
            this.lineOfBusinessData = a
            return;
        }
        
        if((this.LOBManager.Id!=undefined && this.LOBManager.Id!='') || (this.LOBManager.Email!=undefined && this.LOBManager.Email!='')){
            this.createNewLOBManager=true;
            this.showCreateContact=true;
            this.objectData['Manager__c'] =this.LOBManager.Id;
            this.newContact={};
            this.newContact.existing=true;
            this.newContact.Id=this.LOBManager.Id;
            this.newContact.FirstName=this.LOBManager.FirstName;
            this.newContact.LastName=this.LOBManager.LastName;
            this.newContact.Email=this.LOBManager.Email;
            this.newContact.Salutation=this.LOBManager.Salutation;
            this.newContact.Phone=this.LOBManager.Phone;
            
            var t = parseInt(event.target.dataset.index);
            this.newContact.index=t;
            var a = JSON.parse(JSON.stringify(this.lineOfBusinessData));
            a[t][event.target.name] = this.newContact;
            this.lineOfBusinessData = a
        }
        else if(this.LOBManager.Id==''){
            this.createNewLOBManager=true;
            this.showCreateContact=true;
            this.objectData['Manager__c'] =null;
            this.newContact={existing:false};
            var t = parseInt(event.target.dataset.index);
            this.newContact.index=t;
            var a = JSON.parse(JSON.stringify(this.lineOfBusinessData));
            a[t][event.target.name] = this.newContact,
            this.lineOfBusinessData = a
            
        }
    }

    handleAddressChange(event){
        this.objectData['Street__c'] = event.target.street;
        this.objectData['State__c'] = event.target.province;
        this.objectData['City__c'] = event.target.city;
        this.objectData['Country__c'] = event.target.country;
        this.objectData['PostalCode__c'] = event.target.postalCode;
    }
    hideModalBox(){
        //
        if( this.headOfOffice!=undefined && this.headOfOffice.Id=='' &&  this.createNewHeadOffice){
            // use to remove selected value in lookup field 
            this.refreshChild=JSON.parse(JSON.stringify({"index":this.newContact.index}))//this.newContact.index;//!this.refreshChild;
        }
        //
        if( this.Manager!=undefined && this.Manager.Id=='' && this.createNewManager){

            if(this.emailWiseContact[this.newContact.Email]!=undefined){
                var a = JSON.parse(JSON.stringify(this.specialtyInfos));
                a[this.newContact.index]['Manager__c'] = this.emailWiseContact[this.newContact.Email];
                this.specialtyInfos = a
            }

            // use to remove selected value in lookup field
            this.refreshManagerChild=JSON.parse(JSON.stringify({"index":this.newContact.index}));
        }
        //
        if( this.LOBManager!=undefined && this.LOBManager.Id=='' && this.createNewLOBManager){

            if(this.emailWiseContact[this.newContact.Email]!=undefined){
                var a = JSON.parse(JSON.stringify(this.lineOfBusinessData));
                a[this.newContact.index]['Manager__c'] = this.emailWiseContact[this.newContact.Email];
                this.lineOfBusinessData = a
            }

            // use to remove selected value in lookup field
            this.refreshManagerChild=JSON.parse(JSON.stringify({"index":this.newContact.index}));
        }
        this.newContact.isCancelled=true;
        this.newContact.isSaved=false;
        this.createNewManager=false;
        this.createNewLOBManager=false;
        this.createNewHeadOffice=false;
        this.showCreateContact=false;
        this.newContact={};
        
    }

    handlecontactchange(event){
        this.newContact[event.target.name] = event.target.value;
        this.newContact.isUpdated=true;
    }
    saveContact(){
        if((this.newContact.FirstName==undefined || this.newContact.FirstName == "")
            ||(this.newContact.LastName==undefined || this.newContact.LastName == "")
            || (this.newContact.Email==undefined || this.newContact.Email == "")
            || (this.newContact.Phone==undefined || this.newContact.Phone == "")
            || (this.newContact.Salutation==undefined || this.newContact.Salutation == "") ){
            this.showToast('Warning','Please Fill All Information',"Warning")
            return ;   
        }
        // Allow A-Z, a-z, 0-9 and underscore. Min 1 char.
        /*var re = /^[0-9]{10}$/;

        if(!re.test(this.newContact.Phone)){
            this.showToast('Warning','Please enter valid 10 digit Contact Number',"Warning")
            return ;   
        }*/
        if(this.createNewManager){
            console.log('JSON.stringify(this.newContact):: ',JSON.stringify(this.newContact));
            this.ManagerNewRec=JSON.stringify(this.newContact);
            console.log("ManagerNewRec@@@@",this.ManagerNewRec);
            this.newContact.displayText=this.newContact.FirstName +' '+this.newContact.LastName+'('+this.newContact.Email+')';

            var additionalCnt=JSON.parse(JSON.stringify(this.additionalContactRecords));
            if(this.newContact.isUpdated){
                additionalCnt.push(JSON.parse(JSON.stringify(this.newContact)));
            }

            var alreadyExistEmail=[];
            var additionalConRecords=[];
            for(var i=additionalCnt.length-1;i>=0;i--){
                if(!alreadyExistEmail.includes(additionalCnt[i].Email)){
                    alreadyExistEmail.push(additionalCnt[i].Email);
                    additionalConRecords.push(JSON.parse(JSON.stringify(additionalCnt[i])));
                }
            }
            this.additionalContactRecords=[];
            for(var i=additionalConRecords.length-1;i>=0;i--){
                this.additionalContactRecords.push(JSON.parse(JSON.stringify(additionalConRecords[i])));
            }
            /* if(this.newContact.isUpdated){
                this.additionalContactRecords.push(JSON.parse(JSON.stringify(this.newContact)));
            }*/
            this.additionalContactRecords=JSON.parse(JSON.stringify(this.additionalContactRecords));
            console.log(" this.additionalContactRecords", this.additionalContactRecords);
        }
        if(this.createNewLOBManager){
            console.log('JSON.stringify(this.newContact):: ',JSON.stringify(this.newContact));
            this.ManagerNewRec=JSON.stringify(this.newContact);
            console.log("ManagerNewRec@@@@",this.ManagerNewRec);
            this.newContact.displayText=this.newContact.FirstName +' '+this.newContact.LastName+'('+this.newContact.Email+')';

            var additionalCnt=JSON.parse(JSON.stringify(this.additionalLOBContactRecords));
            if(this.newContact.isUpdated){
                additionalCnt.push(JSON.parse(JSON.stringify(this.newContact)));
            }

            var alreadyExistEmail=[];
            var additionalConRecords=[];
            for(var i=additionalCnt.length-1;i>=0;i--){
                if(!alreadyExistEmail.includes(additionalCnt[i].Email)){
                    alreadyExistEmail.push(additionalCnt[i].Email);
                    additionalConRecords.push(JSON.parse(JSON.stringify(additionalCnt[i])));
                }
            }
            this.additionalLOBContactRecords=[];
            for(var i=additionalConRecords.length-1;i>=0;i--){
                this.additionalLOBContactRecords.push(JSON.parse(JSON.stringify(additionalConRecords[i])));
            }
            /* if(this.newContact.isUpdated){
                this.additionalLOBContactRecords.push(JSON.parse(JSON.stringify(this.newContact)));
            }*/
            this.additionalLOBContactRecords=JSON.parse(JSON.stringify(this.additionalLOBContactRecords));
            console.log(" this.additionalLOBContactRecords", this.additionalLOBContactRecords);
        }
        if(this.createNewHeadOffice){
            this.newContact.isCancelled=false;
            this.newContact.isSaved=true;
            this.newContact.displayText=this.newContact.FirstName +' '+this.newContact.LastName+'('+this.newContact.Email+')';

            this.data['Head_of_Office__c']=JSON.parse(JSON.stringify(this.newContact));
            this.headOfficeAdditionalContact=JSON.parse(JSON.stringify([this.data["Head_of_Office__c"]]));
            this.HeadofOfficeNewRec=JSON.stringify(this.newContact);
        }

        this.newContact.isCancelled=false;
        this.newContact.isSaved=true;

        this.createNewManager=false;
        this.createNewLOBManager=false;
        this.createNewHeadOffice=false;
        this.showCreateContact=false;
        this.newContact={};
    }


    handleSaveClick(){
        var hasError=false;
        this.template.querySelectorAll('lightning-input').forEach(element => {
            if(!element.reportValidity()){
                //element.checkValidity()
                hasError=true;
            }
        });
        this.template.querySelectorAll('lightning-textarea').forEach(element => {
            if(!element.reportValidity()){
                //element.checkValidity()
                hasError=true;
            }
        });
        this.template.querySelectorAll('lightning-combobox').forEach(element => {
            if(!element.reportValidity()){
                //element.checkValidity()
                hasError=true;
            }
        });
        
        /*for(var i=0;i<this.specialtyInfos.length;i++){
            if(this.specialtyInfos[i].Manager__c==null ||  (typeof this.specialtyInfos[i].Manager__c ==='object' && this.specialtyInfos[i].Manager__c.Email ==null)){
                this.validateRequired=JSON.parse(JSON.stringify({"index":i}))
                hasError=true;
            }
        }*/

        if(hasError){
            this.showToast('Warning','Please Fill All Information',"Warning")
            return;
        }



        this.spinnerStatus=true;
        this.objectData['Id'] = this.data.Id;
        let recorData = (JSON.stringify(this.objectData));
        console.log('dlghdsljfghdxlkjgh', JSON.parse(JSON.stringify(this.specialtyInfos)));
        

        updateAgentContact({recordData:recorData ,headOfOfficeRec : (this.HeadofOfficeNewRec),events : JSON.stringify(this.events),specInfo : JSON.stringify(this.specialtyInfos),topCarrier : JSON.stringify(this.topCarriers),LOBInfo : JSON.stringify(this.lineOfBusinessData)})
            .then(result => {
                console.log('$$$$$$$', result);
                this.spinnerStatus=false;
                console.log('Success');
                this.isSuccess=true;
                this.showRecordForm=false;
                this.showRecordFormClass='slds-hide';
            })
            .catch(error => {
                this.spinnerStatus=false;
                console.log('Failed',error);
            });
    }

    showToast(title,message,type) {
        const event = new ShowToastEvent({
            "title": title,
            "message":message,
            "variant":type
        });
        this.dispatchEvent(event);
    }
}