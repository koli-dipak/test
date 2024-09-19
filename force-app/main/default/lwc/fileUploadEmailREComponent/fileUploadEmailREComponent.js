import { api, LightningElement, track, wire } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
//import { OmniscriptBaseMixin } from "vlocity_ins/omniscriptBaseMixin";
//import { OmniscriptActionCommonUtil } from "vlocity_ins/omniscriptActionUtils";

export default class FileUploadEmailREComponent extends LightningElement {
    //send data to flow
    @api fileData
    @api uniqueId;


    imgsrc = 'data:@file/png;base64,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';

    //collect All Data from Submit Form
    @track inputData = {}

    //All Prime section object to store Prime Data
    @track primeInsureData = {};
    @track brokerInformationData = {};
    @track primeContractData = {};
    @track primeREInformationData = {};
    @track ACInformationData = {};
    @track requestedDocuments = [];
    @track spinner = false;
    @track errorMessage;

    //RecordType
    @track additionalMemberId;
    @track contractId;
    @track locationId;

    //addtional Insure 
    @track insuredTableVisible = false;
    @track addInsuredModal = false;
    @track addInsuredEnable = true;
    @track updateInsuredEnable = false;
    @track insuredDeleteModal = false;
    @track additionalInsuredData = [];
    @track updateadditionalInsuredData = [];
    @track currentInsured = [];
    @track allAdditionalInsuredData;
    @track selectedInsuredIndex;
    @track organizeName = '';
    @track yearInBusiness = '';
    @track address = '';
    @track addressLine1 = '';
    @track city = '';
    @track state = '';
    @track country = '';
    //@track defaultCountry; 
    @track typeofOrganization = '';
    @track otherTypeofOrganization = '';

    //addtional Contract
    @track contractTableVisible = false;
    @track addContractModal = false;
    @track addContractEnable = true;
    @track updateContractEnable = true;
    @track contractDeleteModal = false;
    @track additionalContractData = [];
    @track currentContract = [];
    @track allAdditionalContractData;
    @track selectedContractIndex;
    @track proposedEffectiveDate = '';
    @track requestedQuoteDate = '';
    @track contractValue = '';
    @track contractNumber = '';
    @track contractLength = '';
    @track typeofContract = '';
    @track otherTypeofContract = '';
    @track contractCountry = '';
    @track specific_Contracts_as_Listed = true;
    @track All_Contracts = false;

    //additional Countries 
    @track countriesTableVisible = false;
    @track addCountriesModal = false;
    @track addCountriesEnable = true;
    @track updateCountriesEnable = true;
    @track countriesDeleteModal = false;
    @track additionalCountriesData = [];
    @track currentCountry = [];
    @track allAdditionalCountriesData;
    @track selectedCountryIndex;
    @track countryOfOperation = '';
    @track jobDescription = '';
    @track USNationalIsChecked = false;
    @track numberOfUSN = '';
    @track totalRemunerationUSN = '';
    @track ThirdCountryNationalIsChecked = false;
    @track numberOfTCN = '';
    @track totalRemunerationTCN = '';
    @track LocalNationalIsChecked = false;
    @track numberLN = '';
    @track totalRemunerationLN = '';

    //Requested Documents
    @track selectedRDTypeOfOrganization = '';
    @track fileErrorMessage;
    @track copyoftheUSGovernmentFile;
    @track yearLosshistoryforDBAFile;
    @track contractListingFile;
    @track remunerationListingFile;

    @track USGovernmentValid = false;
    @track YLHforDBAValid = false;
    @track CLValid = false;
    @track RLValid = false;

    //Show and Hide Compoents
    @track showHideDetails = {};

    //progress bar track variables
    @track InsuredColorChange = false;
    @track brokerColorChange = false;
    @track ContractColorChange = false;
    @track RemunerationColorChange = false;
    @track AdditionalColorChange = false;
    @track RequestedColorChange = false;

    //form submit
    @track formSubmitSuccess = false;

    //Set Date and radom number for File
    @track fileEncryptedToken;


    @track countriesList = [
        { label: "None", value: "" },
    ];

    @track allStateList = [];
    @track stateList = [
        { label: "None", value: "" }
    ]
    @track addtionalStateList = [
        { label: "None", value: "" }
    ]

    @track organizationList = [];
    @track contractList = [];
    @track SecurityLocationList = [];
    @track translatorList = [];

    @track contentVersionIds = [];
    @track deleteContentVersionIds = [];




    @track uniqueRandomNumber;
    connectedCallback() {
        let x = Math.floor((Math.random() * 10000000) + 1);

        this.uniqueRandomNumber = new Date().getTime() + '' + x;
        console.log('@@this.uniqueRandomNumber :: ', this.uniqueRandomNumber)
    }


    // get acceptedFormats() {
    //     return ['.xlsx','.xls','.csv', '.doc', '.docx','.pdf'];
    // }
    get acceptedFormats() {
        const excludedExtensions = ['.exe', '.bat', '.msi', '.com', '.vbs', '.ps1', '.sh','.js'];
        const allExtensions = [
            '.123', '.3dm', '.3ds', '.3g2', '.3gp', '.7z', '.aac', '.aaf', '.accdb', '.aep', '.ai', '.aif', '.aiff', '.amr', '.apk',
            '.app', '.asf', '.asp', '.aspx', '.avi', '.bak', '.bmp', '.bup', '.c', '.cfg', '.cgi', '.class', '.conf', '.cpp', '.cr2',
            '.css', '.csv', '.cue', '.dat', '.db', '.dbf', '.deb', '.dll', '.dmg', '.doc', '.docx', '.dot', '.dotx', '.dwg', '.dxf',
            '.eml', '.eps', '.flac', '.flv', '.fnt', '.fon', '.gadget', '.gz', '.h', '.html', '.htm', '.ics', '.iff', '.indd', '.iso',
            '.jar', '.java', '.jpeg', '.jpg', '.key', '.kml', '.kmz', '.log', '.m4a', '.m4v', '.max', '.mdb', '.mobi',
            '.mov', '.mp3', '.mp4', '.mpeg', '.mpg', '.msi', '.nb', '.numbers', '.obj', '.odp', '.ods', '.odt', '.ogg', '.otf', '.pages',
            '.pdf', '.php', '.pkg', '.pl', '.ppt', '.pptx', '.prproj', '.ps', '.psd', '.pst', '.pub', '.py', '.rar', '.rm', '.rtf',
            '.rw2', '.sav', '.scss', '.sh', '.srt', '.svg', '.swf', '.tar', '.tex', '.tga', '.tgz', '.thm', '.tif', '.tiff', '.tmp',
            '.txt', '.vob', '.vsd', '.wav', '.webm', '.wma', '.wmv', '.wpd', '.wps', '.xcf', '.xls', '.xlsx', '.xml', '.xps', '.zip','.png'
        ];

        return allExtensions.filter(extension => !excludedExtensions.includes(extension));
    }



    //File Upload 
    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        uploadedFiles.forEach(file => {
            this.contentVersionIds.push(file.contentVersionId);
            this.collectFiels = {
                'filename': file.name,
                'versionId': file.contentVersionId
            };
            console.log(this.collectFiels);
            this.requestedDocuments = [...this.requestedDocuments, this.collectFiels];
        });
        console.log('All requested Documents', JSON.parse(JSON.stringify(this.requestedDocuments)));


        var finalContentVersion = '';
        for (var i in this.requestedDocuments) {
            finalContentVersion += this.requestedDocuments.versionId + ',';
        }
        //send data from lwc to flow
        this.fileData = JSON.stringify(this.requestedDocuments)

        this.dispatchEvent(new FlowAttributeChangeEvent('fileData', this.fileData));
        this.dispatchEvent(new FlowAttributeChangeEvent('uniqueId', this.uniqueRandomNumber));

    }

    @track collectRemoveFiles = [];

    //Remove File
    removeFile(event) {
        this.contentVersionIds.splice(parseInt(event.target.dataset.index), 1);
        //this.requestedDocuments[];
        // this.collectRemoveFiles = [event.target.dataset.filename];
        this.requestedDocuments.splice(parseInt(event.target.dataset.index), 1);
        this.requestedDocuments = JSON.parse(JSON.stringify(this.requestedDocuments));
        console.log('Remainig requested Documents', JSON.parse(JSON.stringify(this.requestedDocuments)));


        //send data from lwc to flow
        this.fileData = JSON.stringify(this.requestedDocuments)
       // this.fileData = this.requestedDocuments;
        console.log('File Data', JSON.parse(JSON.stringify( this.fileData)));

        this.dispatchEvent(new FlowAttributeChangeEvent('fileData', this.fileData));
    }
}