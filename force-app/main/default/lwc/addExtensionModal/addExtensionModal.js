import { LightningElement, api, track } from 'lwc';

export default class AddExtensionModal extends LightningElement {
    @api country;
    options = [];
    lstOption = [];
    showAddExtoModal = false;
  
    @api showTheExtension() {
      this.showAddExtoModal = true;
      this.HeaderTitle = "Add Extension";
      this.FooterBtnTitle = "Add In Country";
    //   const country = this.template.querySelector("c-f-c-first-page");
    //   country.countryVal();
    //   console.log("mycountry", this.country);
    // console.log("mycountryval", (JSON.parse(JSON.stringify(this.country[0]["Country"]))));
    // console.log("mycountryval2", (JSON.parse(JSON.stringify(this.country.length))));
    // console.log("mycountryval4", (JSON.parse(JSON.stringify(this.country))));
    for (var i = 0;i < this.country.length;i++) {
        this.lstOption.push({label: (JSON.parse(JSON.stringify(this.country[i]["Country"]))), value: (JSON.parse(JSON.stringify(this.country[i]["Country"])))},);
    }
    // console.log("val6", (JSON.stringify(this.lstOption)).slice(1, -1))
    // this.lstOption = (JSON.stringify(this.lstOption)).slice(1, -1);
    // console.log("val7", this.lstOption)
    }
    

    

    handleDialogClose() {
        this.showAddExtoModal = false;
        console.log(this.options)
        this.lstOption = [];
    }
    MdlClose(){
        this.showAddExtoModal = false;
        console.log(this.options)
        this.lstOption = [];
    }

    @track recordApi;
    @track value1 = '';
    @track value2 = '';
    @track value3 = '';
    @track value4 = '';
    @track value5 = '';
    @track value6 = '';

    get Extensions() {
        return [
                { label: 'Extension 1', value: 'exten1' },
                { label: 'Extension 2', value: 'exten2' },
                { label: 'Extension 3', value: 'exten3' },
                { label: 'Extension 4', value: 'exten4' },
                { label: 'Extension 5', value: 'exten5' },
                { label: 'Extension 6', value: 'exten6' },
            ];  
    }  
    // valdata = (JSON.parse(JSON.stringify(this.country[1]["Country"])));

    @track Country = this.lstOption
    //     [
    //     {"label":"Ireland","value":"Ireland"},{"label":"France","value":"France"},{"label":"Brazil","value":"Brazil"},
     
            
    // ];

    // get Country() {
        
    //         return[
    //         //    (JSON.stringify(this.lstOption)).slice(1, -1)
    //             {"label":"Ireland","value":"Ireland"},{"label":"France","value":"France"},{"label":"Brazil","value":"Brazil"}
                
    //         ]     
    // }

    get OccurrenceLmt() {
        return[
            {label: "Per Schedule", value: "Per Schedule"},
            {label: "Post Schedule", value: "Post Schedule"},
        ]
    }

    get AggregateLmt() {
        return[
            {label: "Per Schedule", value: "Per Schedule"},
            {label: "Post Schedule", value: "Post Schedule"},
        ]
    } 
        
     

    connectedCallback(){
        this.recordApi = {
            value5: "$500",
            value6: "$1500"
        }
    }


    // console.log( ‘Data received from Picklist Field ‘ + JSON.stringify( data.values ) );
    // renderedCallback(){
    //     this.options = this.country.map( Country => {
    //         return {
    //             label: `${Country.label}`,
    //             value: `${Country.value}`
    //         };
    //     });
    //     console.log( 'Options are ' + JSON.stringify( this.options ) );
    // }
  

   

    handleChange1(event) {
        this.value1 = event.detail.value;
        this.options.splice(0, 0, (event.detail.value));
    }

    handleChange2(event) {
        this.value2 = event.detail.value;
        this.options.splice(1, 0, (event.detail.value));
    }

    handleChange3(event) {
        this.value3 = event.detail.value;
        this.options.splice(2, 0, (event.detail.value));
    }

    handleChange4(event) {
        this.value4 = event.detail.value;
        this.options.splice(3, 0, (event.detail.value));
    }

    handleChange5(event) {
        this.value5 = event.detail.value;
        this.options.splice(4, 0, (event.detail.value));
    }

    handleChange6(event) {
        this.value6 = event.detail.value;
        this.options.splice(5, 0, (event.detail.value));
    }

    addFormInCov(){
        console.log( 'Input is ' + this.value1 );
        console.log( 'Input is ' + this.value2 );
        console.log( 'Input is ' + this.value3 );
        console.log( 'Input is ' + this.value4 );
        console.log( 'Input is ' + this.value5 );
        console.log( 'Input is ' + this.value6 );
        this.dispatchEvent( new CustomEvent( 'pass', {
            detail: this.options
        } ) );
        this.options = [];
        this.showAddExtoModal = false;
        this.lstOption = [];
    }

}