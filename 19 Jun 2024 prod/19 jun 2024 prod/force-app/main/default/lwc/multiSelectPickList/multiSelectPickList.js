import { LightningElement, track, api } from 'lwc';

export default class MultiSelectPickList extends LightningElement {

    @api options;
    @api selectedValue;
    @api iconNameOfSearchResult;
    @api selectedValues = [];
    @api label;
    @api disabled = false;
    @api multiSelect = false;
    @track value;
    @track values = [];
    @track objectValues = [];
    @track optionData;
    @api searchString;
    @track noResultMessage;
    @api showDropdown = false;

    @api refreshOptions(options) {
        if (options && options.length > 0){
            this.optionData = JSON.parse(JSON.stringify(options));
        }
        else{
            this.optionData = [];
            this.noResultMessage = "No results found for '" + this.searchString + "'";
        }
    }

    /*connectedCallback() {
        this.showDropdown = false;
        var optionData = this.options ? (JSON.parse(JSON.stringify(this.options))) : null;
        var value = this.selectedValue ? (JSON.parse(JSON.stringify(this.selectedValue))) : null;
        var values = this.selectedValues ? (JSON.parse(JSON.stringify(this.selectedValues))) : null;
        if (value || values) {
            var searchString;
            var count = 0;
            for (var i = 0; i < optionData.length; i++) {
                if (this.multiSelect) {
                    if (values.includes(optionData[i].value)) {
                        optionData[i].selected = true;
                        count++;
                    }
                } else {
                    if (optionData[i].value == value) {
                        searchString = optionData[i].label;
                    }
                }
            }
            if (this.multiSelect)
                this.searchString = count + ' Option(s) Selected';
            else
                this.searchString = searchString;
        }
        this.value = value;
        this.values = values;
        this.optionData = optionData;
    }*/

    /*filterOptions(event) {
        this.searchString = event.target.value;
        if (this.searchString && this.searchString.length > 0) {
            this.noResultMessage = '';
            if (this.searchString.length >= 2) {
                var flag = true;
                for (var i = 0; i < this.optionData.length; i++) {
                    if (this.optionData[i].label.toLowerCase().trim().startsWith(this.searchString.toLowerCase().trim())) {
                        this.optionData[i].isVisible = true;
                        flag = false;
                    } else {
                        this.optionData[i].isVisible = false;
                    }
                }
                if (flag) {
                    this.noResultMessage = "No results found for '" + this.searchString + "'";
                }
            }
            this.showDropdown = true;
        } else {
            this.showDropdown = false;
        }
    }*/

    selectItem(event) {
        var selectedVal = event.currentTarget.dataset.id;
        console.log('@@selectedVal:::',selectedVal);
        if (selectedVal) {
            if(selectedVal === "SearchInAll"){


                // added for searchInAll Bug start

                /*this.objectValues.forEach(element => {
                    if(element.value === selectedVal){
                        this.objectValues.splice(this.objectValues.indexOf(element), 1);
                    }
                });
                var options = JSON.parse(JSON.stringify(this.optionData));
                for (var i = 0; i < options.length; i++) {
                    if (options[i].value === selectedVal) {
                        options[i].selected = false;
                        this.values.splice(this.values.indexOf(options[i].value), 1);
                    }
        
                    if (options[i].selected) {
                        count++;
                    }
                }

                let ev2 = new CustomEvent('selectoption', { detail: {
                    values : this.values,
                    objectValues: this.objectValues
                } });
                this.dispatchEvent(ev2);*/

                // added for searchInAll Bug end

                let ev = new CustomEvent('opendatatable', { detail: this.searchString });
                this.dispatchEvent(ev);
                return;
            }
            var count = 0;
            var options = JSON.parse(JSON.stringify(this.optionData));
            console.log('@@this.objectValues::Before',this.objectValues);
            for (var i = 0; i < options.length; i++) {
                if (options[i].value === selectedVal) {
                    if (this.multiSelect) {
                        if (this.values.includes(options[i].value)) {
                            this.values.splice(this.values.indexOf(options[i].value), 1);
                        } else {
                            this.values.push(options[i].value);
                        }

                        options[i].selected = options[i].selected ? false : true;
                        // added by surag
                        if(options[i].selected){
                            this.objectValues.push({label: options[i].label, value: options[i].value, selected: true});
                        }
                        else{
                            this.objectValues.forEach(element => {
                                if(element.value === options[i].value){
                                    this.objectValues.splice(this.objectValues.indexOf(element), 1);
                                }
                            });
                        }
                    }
                }
                if (options[i].selected) {
                    count++;
                }
            }
            
            console.log('@@this.objectValues::After',this.objectValues);
            this.optionData = options;
            if (this.multiSelect) {

                let ev = new CustomEvent('selectoption', { detail: {
                    values : this.values,
                    objectValues: this.objectValues
                } });
                this.dispatchEvent(ev);
            }

            if (this.multiSelect)
                event.preventDefault();
            else
                this.showDropdown = false;
        }
    }

    showOptions() {
        if (this.disabled == false && this.options && this.optionData.length > 0) {
            this.noResultMessage = '';
            var options = JSON.parse(JSON.stringify(this.optionData));
            for (var i = 0; i < options.length; i++) {
                options[i].isVisible = true;
            }
            if (options.length > 0) {
                this.showDropdown = true;
            }
            this.optionData = options;
        }
    }

    closePill(event) {
        console.log('@@event.currentTarget::',event.currentTarget);
        var value = event.currentTarget.name;
        console.log('@@value:::',value);
        var count = 0;
        var options = JSON.parse(JSON.stringify(this.optionData));
        for (var i = 0; i < options.length; i++) {
            if (options[i].value === value) {
                options[i].selected = false;
                this.values.splice(this.values.indexOf(options[i].value), 1);
            }

            if (options[i].selected) {
                count++;
            }
        }

        // added by surag
         this.objectValues.forEach(element => {
            if(element.value === value){
                this.objectValues.splice(this.objectValues.indexOf(element), 1);
            }
        });

        this.optionData = options;
        if (this.multiSelect) {
            let ev = new CustomEvent('selectoption', { detail: {
                    values : this.values,
                    objectValues: this.objectValues
                } });
                this.dispatchEvent(ev);
        }
    }

    handleBlur() {
        var previousLabel;
        var count = 0;

        for (var i = 0; i < this.optionData.length; i++) {
            if (this.optionData[i].value === this.value) {
                previousLabel = this.optionData[i].label;
            }
            if (this.optionData[i].selected) {
                count++;
            }
        }

        this.showDropdown = false;
    }

    handleMouseOut() {
        this.showDropdown = false;
    }

    handleMouseIn() {
        //  this.showDropdown();
        // console.log('@@ handle mouse INNNNNN:: ',this.showDropdown);
        // this.showDropdown = true;
    }

    @api
    handleMouseInFromParent(){
        this.showDropdown = true;
    }

    @api clearSelectedRecords(){
        this.values = [];
        this.objectValues = [];
        this.selectedValue = [];
        this.selectedValues = [];
        this.searchString = '';
    }


    //////////////////////// Added by surag /////////////////////////////////
    handleSearchKeyChange(event) {
        this.searchString = event.target.value;
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        this.delayTimeout = setTimeout(() => {
            let ev = new CustomEvent('searchkeychange', { detail: searchKey });
            this.dispatchEvent(ev);
        }, 200);
    }

    @api 
    clear(options){
        this.objectValues = [];
        this.searchString = '';
        this.values = [];
        var options = JSON.parse(JSON.stringify(this.optionData));
        for (var i = 0; i < options.length; i++) {
                options[i].selected = false;
        }
        this.optionData = options;

    }
}