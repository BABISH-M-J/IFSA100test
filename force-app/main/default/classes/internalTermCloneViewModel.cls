/**
 * Viewmodel for <<internalTermCloneController>>
 * @author Brock Barlow
 */
// ApexDoc updated 2/16/2021 Brock Barlow
public without sharing class internalTermCloneViewModel extends internalBaseViewModel
{
    /** Terms for future years */
    public List<Term__c> futureTerms {get;set;}
    /** Term section names */
    public List<String> termSections {get;set;}
    /** The selected term to clone to */
    public Term__c selectedTerm {get;set;}
    /** An instance of programTermViewModel representing the program term being cloned */
    public programTermViewModel programTerm {get;set;}
    
    
    // Constructors
    /**
     * Get all terms with a year that is greater than the current year
     */
    public internalTermCloneViewModel()
    {
        this.futureTerms = [SELECT Id, Name, Section__c, Year__c FROM Term__c WHERE Year__c >=: Date.today().year()];
        this.termSections = apexConversionUtility.getPicklistStringValues(Term__c.Section__c);
    }
    /**
     *  Get all terms with a year that is greater than the current year and gets program term details for the provided Program_Term__c Id
     */
    public internalTermCloneViewModel(Id ptId)
    {
        
        this();
        // Get the selected program term's record
        this.programTerm = new programTermViewModel(ptId);
        getrelatedObjects();
    }
    /**
     *  Get all terms with a year that is greater than the current year. Gets program term details for the provided Program_Term__c Id, Selects a Term__c
     */
    public internalTermCloneViewModel(Id ptId, Id termId)
    {
        // Also load with the future term selected
        this();
        this.selectedTerm = [SELECT Id, Name, Section__c, Year__c FROM Term__c WHERE Id =: termId].get(0);
        this.programTerm = new programTermViewModel(ptId, this.selectedTerm.Id);
        getrelatedObjects();
    }
    // Methods
    /**
     * Serializes this object
     */
    public String getSerializedViewModel()
	{
		return JSON.serialize(this);
	}

    /**
     * Get records related to the program term
    */
    private void getrelatedObjects()
    {
        // Test to ensure that the program term being cloned is a Standard or Parent Program Term
        if(this.programTerm.programTerm.RecordType.Name.contains('Program Option'))
            throw new internalTermCloneViewModelException('Cannot Start with a Program Option record type');
        // Get the related records
        List<Application_Requirement__c> reqs = apexQueryUtility.selectAllFrom('Application_Requirement__c', 'Program_Term__r.Parent_Program_Term__c, Dynamic_Form__r.Name', 'Program_Term__c = \'' + this.programTerm.programTerm.Id + '\' OR Program_Term__r.Parent_Program_Term__c = \'' + this.programTerm.programTerm.Id + '\'');
        List<Program_Fee__c> fees = apexQueryUtility.selectAllFrom('Program_Fee__c', 'Program_Term__r.Parent_Program_Term__c', 'Program_Term__c = \'' + this.programTerm.programTerm.Id + '\' OR Program_Term__r.Parent_Program_Term__c = \'' + this.programTerm.programTerm.Id + '\'');
        List<Program_Term_Housing_Option__c> housingOptions = apexQueryUtility.selectAllFrom('Program_Term_Housing_Option__c', 'Housing_Option__r.Name, Program_Term__r.Parent_Program_Term__c', 'Program_Term__c = \'' + this.programTerm.programTerm.Id + '\' OR Program_Term__r.Parent_Program_Term__c = \'' + this.programTerm.programTerm.Id + '\'');
        List<Program_Term__c> pTerms = apexQueryUtility.selectAllFrom('Program_Term__c', 'Program__r.Name', 'Parent_Program_Term__c = \'' + this.programTerm.programTerm.Id + '\'');
        // If there are program options create instances of programTermViewModel
        system.debug(pTerms.size());
        for(Program_Term__c pt: pTerms)
        {
            this.programTerm.programOptionsMap.put(pt.Id, this.selectedTerm == null ? new programTermViewModel(pt) : new programTermViewModel(pt, this.selectedTerm.Id));
        }
        // Place the Application_Requirement__c records with the correct program term
        for(Application_Requirement__c req: reqs)
        {
            if(req.Program_Term__r.Parent_Program_Term__c != null)
            {
                this.programTerm.programOptionsMap.get(req.Program_Term__c).add(req);
                if(req.Dynamic_Form__c != null){
                    Dynamic_Form__c tempForm = new Dynamic_Form__c(Id = req.Dynamic_Form__c,
                                                                   Name = req.Dynamic_Form__r.Name);
                    this.programTerm.programOptionsMap.get(req.Program_Term__c).add(tempForm);
                }
            }
            else
            {
                this.programTerm.add(req);
                if(req.Dynamic_Form__c != null){
                    Dynamic_Form__c tempForm = new Dynamic_Form__c(Id = req.Dynamic_Form__c,
                                                                   Name = req.Dynamic_Form__r.Name);
                    this.programTerm.add(tempForm);
                }
            }
        }
        // Place the Program_Fee__c records with the correct program term
        for(Program_Fee__c fee: fees)
        {
            if(fee.Program_Term__r.Parent_Program_Term__c != null)
            {
                this.programTerm.programOptionsMap.get(fee.Program_Term__c).add(fee);
            }
            else
            {
                this.programTerm.add(fee);
            }
        }
        // Place the Resource_Item__c records with the correct program term
        for(Program_Term_Housing_Option__c house: housingOptions)
        {
            if(house.Program_Term__r.Parent_Program_Term__c != null)
            {
                this.programTerm.programOptionsMap.get(house.Program_Term__c).add(house);
            }
            else
            {
                this.programTerm.add(house);
            }
        }
        // Place the Dynamic_Form__c records with the correct program term
        /*for(Dynamic_Form__c form: dForms)
        {
            if(form.Program_Term__r.Parent_Program_Term__c != null)
            {
                this.programTerm.programOptionsMap.get(house.Program_Term__c).add(house);
            }
            else
            {
                this.programTerm.add(house);
            }
        }*/
        this.programTerm.programOptions.addAll(this.programTerm.programOptionsMap.values());
    }

    // Sub Classes
    /** Exception class for internalTermCloneViewModel */
    public without sharing class internalTermCloneViewModelException extends Exception {}
    /** Apex wrapper for Program Term object - This object needs to be better documented */
    public without sharing class programTermViewModel
    {
        public Program_Term__c programTerm {get;set;}
        public Program__c program {get;set;}
        public Term__c term {get;set;}
        public List<Application_Requirement__c> requirements {get;set;}
        public List<Program_Fee__c> fees {get;set;}
        public List<Program_Term_Housing_Option__c> housingOptions {get;set;}
        public Map<Id, programTermViewModel> programOptionsMap {get;set;}
        public List<programTermViewModel> programOptions {get;set;}
        public List<Dynamic_Form__c> dynamicForms {get;set;}
        public Boolean ownerActive {get;set;}

        public programTermViewModel(Id ptId)
        {
            this((Program_Term__c) apexQueryUtility.selectAllFrom('Program_Term__c', 'RecordType.Name, Owner.IsActive, Program__r.Name', 'Id = \'' + ptId + '\'').get(0));
            this.ownerActive = this.programTerm.Owner.IsActive;
        }
        public programTermViewModel(Id ptId, Id tId)
        {
            this(ptId);
            this.program = (Program__c) apexQueryUtility.selectAllFrom('Program__c', 'Id = \'' + this.programTerm.Program__c + '\'').get(0);
            this.term = (Term__c) apexQueryUtility.selectAllFrom('Term__c', 'Id = \'' + tId + '\'').get(0);
        }

        public programTermViewModel(Program_Term__c pt)
        {
            this.programTerm = pt;
            this.requirements = new List<Application_Requirement__c>();
            this.fees = new List<Program_Fee__c>();
            this.housingOptions = new List<Program_Term_Housing_Option__c>();
            this.programOptionsMap = new Map<Id, programTermViewModel>();
            this.programOptions = new List<programTermViewModel>();
            this.dynamicForms = new List<Dynamic_Form__c>();
        }
        public programTermViewModel(Program_Term__c pt, Id tId)
        {
            this(pt);
            this.program = (Program__c) apexQueryUtility.selectAllFrom('Program__c', 'Id = \'' + this.programTerm.Program__c + '\'').get(0);
            this.term = (Term__c) apexQueryUtility.selectAllFrom('Term__c', 'Id = \'' + tId + '\'').get(0);
        }
        public void add(Application_Requirement__c req)
        {
            this.requirements.add(req);
        }
        public void add(Program_Fee__c fee)
        {
            this.fees.add(fee);
        }
        public void add(Program_Term_Housing_Option__c house)
        {
            this.housingOptions.add(house);
        }
        public void add(Dynamic_Form__c dForm){
            this.dynamicForms.add(dForm);
        }
        public void add(Program_Term__c programTerm)
        {
            this.programOptionsMap.put(programTerm.Id, this.term == null ? new programTermViewModel(programTerm) :  new programTermViewModel(programTerm, term.Id));
        }

        /**
        * Clones Program Term and specified related records
        */
        public List<String> cloneRecords(String newTermId, String parentProgramTermId)
        {
            List<String> jobIds = new List<String>();
            Map<Id, Application_Requirement__c> appReqMap = new Map<Id, Application_Requirement__c>();
            cleanProgramTerm(parentProgramTermId);

            Database.SaveResult ptSave = Database.insert(this.programTerm);
            
            if(ptSave.isSuccess())
            {
                List<Application_Requirement__c> reqs = new List<Application_Requirement__c>();
                List<Program_Fee__c> fees = new List<Program_Fee__c>(); 
                List<Program_Term_Housing_Option__c> housingOptions = new List<Program_Term_Housing_Option__c> ();
                List<Program_Term__c> programOptions = new List<Program_Term__c>();
                List<SObject> relatedToInsert = new List<SObject>();

                for(Application_Requirement__c item: this.requirements)
                {
                    Id oldId = item.Id;
                    item.Id = null;
                    item.Program_Term__c = ptSave.getId();
                    appReqMap.put(oldId, item);
                    relatedToInsert.add(item);
                }
                for(Program_Term_Housing_Option__c item: this.housingOptions)
                {
                    item.Id = null;
                    item.Program_Term__c = ptSave.getId();
                    relatedToInsert.add(item);
                }            
                for(Program_Fee__c item: this.fees)
                {
                    item.Id = null;
                    item.Program_Term__c = ptSave.getId();
                    item.Amount__c = 0;
                    relatedToInsert.add(item);
                }

                for(programTermViewModel programOption: this.programOptions)
                {
                    jobIds.addAll(programOption.cloneRecords(newTermId, ptSave.getId()));
                }                        
                if(configurationManager.isTestMode())
                    system.enqueueJob(new sObjectQueueableUpdater(relatedToInsert, sObjectQueueableUpdater.dmlOperation.isInsert));
                else
                    jobIds.add(Id.valueOf(system.enqueueJob(new sObjectQueueableUpdater(relatedToInsert, sObjectQueueableUpdater.dmlOperation.isInsert, appReqMap))));
                return jobIds;
            }
            return null;
        }
        public List<String> cloneRecords(String newTermId, String parentProgramTermId, String opportunityId)
        {
            List<String> jobIds = cloneRecords(newTermId, parentProgramTermId);
            Opportunity o = new Opportunity(Id = opportunityId, Program_Term__c = this.programTerm.Id);
            Database.update(o);
            return jobIds;
        }
        /**
        * Resets a Program Term record
        */
        private void cleanProgramTerm(Id parentProgramTermId)
        {
            this.programTerm.Id = null;
            this.programTerm.Term__c = this.term.Id;
            this.programTerm.Parent_Program_Term__c = parentProgramTermId;
            String ptName = this.program.Name + ' ' + this.term.name;
            this.programTerm.Ready_for_Billing__c = false;
            this.programTerm.Ready_for_Billing_Checked__c = false;
            this.programTerm.Name = parentProgramTermId == null ? ptName : ptName + ' ' + this.programTerm.Program_Option_Name__c;
            if(this.programTerm.Name.length() > 80 && this.Program.Abbreviated_Program_Name__c != null)
            {
                this.programTerm.Name = this.Program.Abbreviated_Program_Name__c + ' ' + this.term.name + ' ' + this.programTerm.Program_Option_Name__c;
            }
            if(this.programTerm.Name.length() > 80 && this.Program.Abbreviated_Program_Name__c == null)
            {
                ifsaDataException e = new ifsaDataException();
                e.setMessage('Program Term Name is too long and does not have an Abbreviated Name set on the Program.');
                throw e;
            }
            this.programTerm.Date_Approval_Status__c = 'Draft';
            // Add One Year to these dates
            this.programTerm.Application_Deadline__c = this.programTerm.Application_Deadline__c != null ? this.programTerm.Application_Deadline__c.addYears(1) : null;
            this.programTerm.Program_Due_Date__c = this.programTerm.Program_Due_Date__c != null ? this.programTerm.Program_Due_Date__c.addYears(1) : null;
            // Null these dates
            this.programTerm.Assessments_Begin__c = null;
            this.programTerm.Assessments_End__c = null;
            this.programTerm.Classes_Begin__c = null;
            this.programTerm.Classes_End__c = null;
            this.programTerm.End_Date__c = null;
            this.programTerm.Exam_End_Date__c = null;
            this.programTerm.Exam_Start_Date__c = null;
            this.programTerm.Group_Transfer_to_Host_City__c = null;
            this.programTerm.IFSA_Orientation_End_Date__c = null;
            this.programTerm.IFSA_Orientation_Start_Date__c = null;
            this.programTerm.Move_into_Term_Housing__c = null;
            this.programTerm.Start_Date__c = null;
            this.programTerm.Start_Of_Second_Term__c = null;
            this.programTerm.Suggested_Departure_from_U_S__c = null;
            this.programTerm.University_Orientation_Ends__c = null;
            this.programTerm.University_Orientation_Starts__c = null;
            this.programTerm.Arrival_Window_End_Time__c = null;
            this.programTerm.Arrival_Window_Start_Time__c = null;
            // Null Orientation Group
            this.programTerm.Orientation_Group__c = null;
            // Null Program Operation Status
            this.programTerm.Program_Operation_Status__c = null;
            this.programTerm.Program_Operation_Status_Reason__c = null;
        }
    }

}