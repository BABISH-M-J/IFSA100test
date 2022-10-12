import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin }                    from 'lightning/navigation';
import { refreshApex }                        from '@salesforce/apex';
import { ShowToastEvent }                     from 'lightning/platformShowToastEvent'
import initWrapper                            from '@salesforce/apex/programAuthComponentController.initWrapper';
import singleCheckboxUpdate                   from '@salesforce/apex/programAuthComponentController.singleCheckboxUpdate';
import updateFullColumn                       from '@salesforce/apex/programAuthComponentController.fullColumnUpdate';
import updateProgs                            from '@salesforce/apex/programAuthComponentController.updateProgAuths';
import sort                                   from '@salesforce/apex/programAuthComponentController.sortWrapper';
import approveAllTerm                         from '@salesforce/apex/programAuthComponentController.approveAll';
import checkUpdatingProgAuths                 from '@salesforce/apex/programAuthComponentController.checkUpdatingProgAuths';
import approveAllSemesterColumn                       from '@salesforce/apex/programAuthComponentController.approveAllSemesterColumn';
import approveAllSummerColumn                       from '@salesforce/apex/programAuthComponentController.approveAllSummerColumn';
import approveAllWinterColumn                       from '@salesforce/apex/programAuthComponentController.approveAllWinterColumn';
import approveAllColumn                       from '@salesforce/apex/programAuthComponentController.approveAllColumn';

export default class programAuthWebComponent extends NavigationMixin(LightningElement) {
    // Essentially Global variables    
    @api recordId;
    @track loading;
    @track progWrap;
    @track error;
    @track successfulUpdate;
    @track submitted;
    @track pageView = [];
    @track currentPage = 1;
    @track pageArray = [];
    @track recordsPerPage = 50;
    @track numOfPages;
    @track searchTerm = null;
    @track programChevron = 'utility:down';
    @track countryChevron = 'utility:right';
    @track openChevron = 'utility:right';
    @track appClosed = false;
    @track saving = false;
    @track recordPerPageLabel = 'Records per page (' + this.recordsPerPage + ')';

    @track semesterSelected = false;
    @track summerSelected = false;
    @track winterSelected = false;

    @track isUpdatingAll = false;
    @track traceflag = false;
    @track parentCheckboxes = false;
    //@track ApprovesAllPrograms = true ;
    
    @track approvesSelected = false ;    

    isReadOnly = true;


    //Init method
    @wire(initWrapper, {accId: '$recordId',
                        searchTerm: null}) 
    progWrapper(value){
        
        this.wiredProgData = 3000;
        const { data, error } = value;
        if(data){
            //ProgWrap set to returned value from initWrapper method

            this.progWrap = data;
            this.semesterSelected = this.progWrap.approveAllSemester;
            this.summerSelected = this.progWrap.approveAllSummer;
            this.winterSelected = this.progWrap.approveAllWinter;
            this.approvesSelected = this.semesterSelected && this.summerSelected && this.winterSelected;
            this.isUpdatingAll = this.updatingProgAuth;
            this.isReadOnly = this.progWrap.readOnly;

            // Num of pages = Proglist length / records per page
            this.numOfPages = Math.ceil(this.progWrap.progList.length / this.recordsPerPage);
            this.pageArray = [];
           
            for(let i = 0; i < this.numOfPages; i++){

                // Push number value to page array
                this.pageArray.push(i + 1);
            }

            let endIndex = 0;
            // Set the page View based on page size
            if(this.recordsPerPage > this.progWrap.progList.length){
                endIndex = this.progWrap.progList.length;
            }
            else{
                endIndex = this.recordsPerPage;
            }

            for(let i = this.currentPage - 1; i < endIndex; i++){
                this.pageView.push(data.progList[i]);
            }
            this.selectPage({target: {value: 1}});
        }
        else{
            this.error = error;
        }
    }

    searchProgs(){
        this.loading = true;
        //Recalls the init method but with a searchTerm
        initWrapper({accId: this.recordId,
                     searchTerm: this.searchTerm})
            .then(result => {
               
                if(result.progList){
                    this.loading = false;
                    this.progWrap = result;
                    this.updatePageView();
                    this.numOfPages = Math.ceil(this.progWrap.progList.length / this.recordsPerPage);
                    this.pageArray = [];
                    for(let i = 1; i < this.numOfPages; i++){
                        this.pageArray.push(i);
                    } 
                }
                else{
                    this.loading = false;
                    this.progWrap = null;
                }
            })
             .catch(error => {
                this.error = error;
            });
    }

    refreshProgs(){
        refreshApex(this.wiredProgData);
    }

    //setter to update searchTerm
    updateSearchTerm(event){
        this.searchTerm = event.target.value;
    }

    // Boolean to check if first page
    @api
    get firstPage(){
        let first = false;
        if(this.currentPage === 1){
            first = true;
        }
        else{
            first = false;
        }

        return first;
    }

    // Boolean to check if last page
    @api
    get lastPage(){
        let last = false;
        if(this.currentPage === this.numOfPages){
            last = true;
        }
        else{
            last = false;
        }

        return last;
    }

    @api
    get areChecksDisabled(){
        return this.loading || this.isReadOnly;
    }

    //update currentpage and pageview
    nextPage(){
        this.currentPage++;
        this.updatePageView();
    }

    //update currentpage and pageview
    previousPage(){
        this.currentPage--;
        this.updatePageView();
    }

    //update currentpage and pageview
    selectPage(event){
        this.currentPage = event.target.value;
        this.updatePageView();
    }

    updatePaginatorClass(){
        for(let i = 0; i < this.template.querySelectorAll('lightning-button').length; i++){
            if(this.template.querySelectorAll('lightning-button')[i].value === this.currentPage && this.template.querySelectorAll('lightning-button')[i].name === "pageButton"){
                this.template.querySelectorAll('lightning-button')[i].variant = 'inverse';
            }
            else if(this.template.querySelectorAll('lightning-button')[i].name === "pageButton"){
                this.template.querySelectorAll('lightning-button')[i].variant = 'neutral';
            }
        }
    }

    // calls the Single checkbox change method
    handleCheckboxChange(event){
        this.loading = true;
        let checkValue = event.target.value;
        let jsonWrap = JSON.stringify(this.progWrap);
        singleCheckboxUpdate({jsonWrapper : jsonWrap,
                              progName : event.target.dataset.progName,
                              section : checkValue,
                              checked : event.target.checked
                            }).then(result => {
                this.loading = false;
                this.progWrap = result;
                this.updatePageView();
            })
            .catch(error => {
                this.error = error;
            });
    
}

    // Calls the Update column method
    updateColumn(event){ 
    this.loading = true;
        let jsonWrap = JSON.stringify(this.progWrap);
        updateFullColumn({jsonWrapper : jsonWrap,
                          section : event.target.value,
                          checked : event.target.checked
                        }).then(result => {
                this.loading = false;
                this.progWrap = result;
                this.updatePageView();
            })
            .catch(error => {
                this.error = error;
            });
    }

    // Actual submit, calls to the updateProgAuths method
    updateProgAuths(){
        this.loading = true;
        this.saving = true;
        let jsonWrap = JSON.stringify(this.progWrap);
        console.log('SemesterSelected'+this.semesterSelected);
        // modified by powerfluence - req no.1 - 005 - starts
        this.finishApproveAll('Approves_All_Calendar_Programs__c', this.semesterSelected); 
        this.finishApproveAll('Approves_All_Summer_Programs__c', this.summerSelected);  
        this.finishApproveAll('Approves_All_Winter_Programs__c', this.winterSelected);
        // modified by powerfluence - req no.1 - 005 - ends
        
        updateProgs({jsonWrapper : jsonWrap})
        .then(result => {
            this.saving = false;
            //this.loading = false;
            this.progWrap = result;
            this.showToast('SUCCESS', 'Changes have been saved');
            this.loading = true;
        this.refreshProgs();
        this.loading = false;
            console.log('two five two');
        })
        .catch(error => {
            this.saving = false;
            this.loading = false;
            this.error = error;
            console.log('Error',this.error);
            this.showToast('ERROR', 'Failed to save Program Authorizations.');
        });
}

    showToast(title, message) {
        let variant;
        switch (title) {
            case 'SUCCESS':
            case 'ERROR':
                variant = title.toLowerCase();
                break;
            default:
                variant = 'info';
                break;
        }
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    //Updates the page view, called by many other methods
    updatePageView(){
        //this.updatePaginatorClass();
        let startIndex = (this.currentPage - 1) * this.recordsPerPage;
        let endIndex = 0;
        if((startIndex + this.recordsPerPage) > this.progWrap.progList.length){
            endIndex = this.progWrap.progList.length;
        }
        else{
            endIndex = (startIndex + this.recordsPerPage);
        }
        let tempPageView = [];
        for(let i = startIndex; i < endIndex; i++){
            tempPageView.push(this.progWrap.progList[i]);
        }
        this.pageView = tempPageView;
    }

    // Calls the sort method
    sortList(sortParam){
        this.loading = true;
        let jsonWrap = JSON.stringify(this.progWrap);
        sort({jsonWrapper : jsonWrap,
              sortParamater : sortParam})
        .then(result => {
            this.currentPage = 1;
            this.loading = false;
            this.progWrap = result;
            this.updatePageView();
        })
        .catch(error => {
            this.error = error;
        });
    }

    //Sets the sort param and updates the cheverons
    sortByProgram(){
        if(this.programChevron === 'utility:right'){
            this.programChevron = 'utility:down';
            this.countryChevron = 'utility:right';
            this.sortList('program');
        }
        
    }

    //Sets the sort param and updates the cheverons
    sortByCountry(){
        if(this.countryChevron === 'utility:right'){
            this.countryChevron = 'utility:down';
            this.programChevron = 'utility:right';
            this.sortList('country');
        }
    }

    //Updates the paginator 
    handleOnSelect(event){
        switch (event.detail.value) {
            case 'OpenProgAuth':
                // Handles Open Program Authorization Menu Item
                //console.log(event.detail);
                /* this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.modalRecordId,
                        objectApiName: 'Program_Authorization__c',
                        actionName: 'view'
                    }
                }); */
                break;        
            default:
                // Handles Records Per Page Menu Items
                if(event.detail.value && !(event.detail.value < 1)){
                    this.loading = true;
                    this.recordsPerPage = Number(event.detail.value);
                    this.recordPerPageLabel = 'Records per page (' + this.recordsPerPage + ')';
                    this.pageArray = [];
                    
                    this.numOfPages = Math.ceil(this.progWrap.progList.length / this.recordsPerPage);
                    for(let i = 1; i < this.numOfPages; i++){
                        this.pageArray.push(i);
                    }
                    if(this.currentPage > this.pageArray.length - 1){
                        this.currentPage = this.pageArray.length - 1;
                    }
                    this.updatePageView();
                    this.loading = false;
                }
                break;
        }
    }

    handleApproveAllSemesterClick(){
        this.semesterSelected = !this.semesterSelected;
        // modified by powerfluence - req no.1 - 001 - starts
        // this.finishApproveAll('Approves_All_Calendar_Programs__c', this.semesterSelected); 
        this.loading = true;
        this.approvesSelected = this.semesterSelected && this.summerSelected && this.winterSelected;
        let jsonWrap = JSON.stringify(this.progWrap);
        if (this.semesterSelected) {
            approveAllSemesterColumn({jsonWrapper : jsonWrap}).then(result => {
                this.progWrap = result;
                this.updatePageView();
                this.loading = false;
            }).catch(error => {
                this.error = error;
                this.loading = false;
            }); 
        } else {
            this.loading = false;
        }
        // modified by powerfluence - req no.1 - 001 - ends
        console.log('semester-->',this.semesterSelected); 
        // added by powerfluence - req no. 9 
        this.loading = true;
        this.refreshProgs();
        this.loading = false;
      
    }

    handleApproveAllSummerClick(){
        this.summerSelected = !this.summerSelected;
        // modified by powerfluence - req no.1 - 002 - starts
         //this.finishApproveAll('Approves_All_Summer_Programs__c', this.summerSelected);  
        this.loading = true;
        this.approvesSelected = this.semesterSelected && this.summerSelected && this.winterSelected;
        let jsonWrap = JSON.stringify(this.progWrap);
        if (this.summerSelected) {
            approveAllSummerColumn({jsonWrapper : jsonWrap}).then(result => {
                console.log('result came for approveAllSummerColumn');
                this.progWrap = result;
                this.updatePageView();
                this.loading = false;
            }).catch(error => {
                this.error = error;
                this.loading = false;
            }); 
        } else {
            this.loading = false;
        }
        // modified by powerfluence - req no.1 - 002 - ends
        console.log('summer-->', this.summerSelected); 
        // added by powerfluence - req no. 9 
        this.loading = true;
        this.refreshProgs();
        this.loading = false;
    }

    handleApproveAllWinterClick(){
        this.winterSelected = !this.winterSelected;
        // modified by powerfluence - req no.1 - 003 - starts
       //  this.finishApproveAll('Approves_All_Winter_Programs__c', this.winterSelected);
        this.loading = true;
        this.approvesSelected = this.semesterSelected && this.summerSelected && this.winterSelected;
        let jsonWrap = JSON.stringify(this.progWrap);
        if (this.winterSelected) {
            approveAllWinterColumn({jsonWrapper : jsonWrap}).then(result => {
                console.log('result came for approveAllWinterColumn');
                this.progWrap = result;
                this.updatePageView();
                this.loading = false;
            }).catch(error => {
                this.error = error;
                this.loading = false;
            }); 
        } else {
            this.loading = false;
        }
        // modified by powerfluence - req no.1 - 003 - ends
        console.log('winter-->', this.winterSelected); 
        // added by powerfluence - req no. 9 
        this.loading = true;
        this.refreshProgs();
        this.loading = false;
    }

    // changed by powerfluence - req no. 10b -- 001 - starts here
        handleApproveAllProgramsClick(){
            this.loading = true;
            // modified by powerfluence - req no.1 - 004 - starts
             this.semesterSelected = true; 
             this.summerSelected = true;
             this.winterSelected = true;
            this.approvesSelected = this.semesterSelected && this.summerSelected && this.winterSelected;
            // this.finishApproveAll('Approves_All_Calendar_Programs__c', true);
            // this.finishApproveAll('Approves_All_Summer_Programs__c', true);     
            // this.finishApproveAll('Approves_All_Winter_Programs__c', true);
           // modified by powerfluence - req no.1 - 004 - ends
            let jsonWrap = JSON.stringify(this.progWrap);
            approveAllColumn({jsonWrapper : jsonWrap}).then(result => {
                this.progWrap = result;
                this.updatePageView();
                this.loading = false;
            }).catch(error => {
                this.error = error;
                this.loading = false;
            }); 
            // added by powerfluence - req no. 9  
            // this.refreshProgs();  
            this.loading = true;
        this.refreshProgs();
        this.loading = false;
        }
    // changed by powerfluence - req no. 10b -- 001 - ends here
    


        finishApproveAll(field, value){
        approveAllTerm({
            accountId: this.recordId,
            field: field,
            value: value
        }).then(result => {
                this.isUpdatingAll = true;
                this.checkUpdatingProgramAuths();
            })
            .catch(error => {
                this.error = error;
            });
    }

    checkUpdatingProgramAuths(){
        checkUpdatingProgAuths({
            accountId: this.recordId
        }).then(result => {
            if(result){
                this.isUpdatingAll = true;
                setTimeout(this.checkUpdatingProgramAuths(), 2000);
            }
            else{
                this.isUpdatingAll = false;
            // commented by powerfluence - req no. 9  
            // this.searchProgs();
            }
        })
        .catch(error => {
            this.error = error;
        });
    }

}