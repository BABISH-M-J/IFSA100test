public without sharing class formBuilderComponentController {

    /* Wrappers */
    // Multiple Wrappers allows for getting around SF deserialize failures on subqueries

    /**
     * Represents a Dynamic_Form__c record    
    */
    public class Form{
        /** Id of the form if editing, null if new */
        @AuraEnabled public Id formId {get;set;}
        /** Name of the Form */
        @AuraEnabled public String formName {get;set;}
        /** Name of form record type being created or edited */
        @AuraEnabled public String recordType {get;set;}
        /** Maps to the Number of Required Elements field on Form */
        @AuraEnabled public Integer numReqElements {get;set;}
        /** Maps to the min number of required elements field on Form */
        @AuraEnabled public Integer minNumReqElements {get;set;}
        /** Required for CIF, holds the related Program Term Name */
        @AuraEnabled public String progTermName {get;set;}
        /** Required for CIF, holds the related Program Term Id */
        @AuraEnabled public String progTermId {get;set;}
        /** Holds the Application Requirements that are related to the progTermId */
        @AuraEnabled public List<Application_Requirement__c> avaliableAppReqs {get;set;}
        /** All Content Rules Avaliable for current form */
        @AuraEnabled public List<Rule__mdt> contentRules {get;set;}
        /** All Form Item Rules Avaliable for current form */
        @AuraEnabled public List<Rule__mdt> formItemRules {get;set;}
        /** A List of all avaliable Form Item Types, pulled from Form_Item_Type__mdt custom metadata */
        @AuraEnabled public List<Form_Item_Type__mdt> formItemTypes {get; set;}
        /** Application Requirement Phases currently avaliable in the schema */
        @AuraEnabled public List<String> appPhaseOptions {get;set;}
        /** Activated */
        @AuraEnabled public Boolean activated {get;set;}
        /** Form Status */
        @AuraEnabled public String formStatus {get;set;}
        /** List of all Items on form */
        @AuraEnabled public List<Item> items {get;set;}
        /** List of all Form Rules on form */
        @AuraEnabled public List<Rule> formRules {get;set;}
        /** List of all Item Rules on form */
        @AuraEnabled public List<Rule> itemRules {get;set;}
        /** Holds the curent value of the incrementing data number assigned to Rules and Items */
        @AuraEnabled public Integer newDataNum {get; set;}
    }

    // Base class for items used in form
    /*
     * @noResText:      No Response Text, this will be used to store text displayed to a user that requires no input from them
     * @dataNum:        Assigned to each Item, essentially an Id field
    */
    public virtual class FormItem {
        @AuraEnabled String noResText {get; set;}
        @AuraEnabled Integer dataNum {get; set;}
    }

    // Wrapper for an Individual Item on a form
    /*
     * @desField:       Field on the destination object that this item will relate to
     * @desobject:      Destination object that this Item will relaste to
     * @fieldType:      Type of field that this item is. Options are pulled from Form_Item_Types__mdt custom metadata
     * @label:          Label displayed to the user for this item
     * @pos:            Position this item will appear on the form
     * @response:       Holds the value entered by the user for the item
     * @showLabel:      Determines whether to show the label or not, defaults to true
     * @desPickVals:    If a fieldType of picklist is choosen, selecting this will say to use the destination fields picklist values
     * @values:         If a fieldType of picklist is choosen, picklist values can be entered manually rather than using the destinations
     * @showInfo:       Field used to know to display edit info or not - NEEDS TO BE REVAMPED
    */
    public class Item extends FormItem {
        @AuraEnabled public String desField {get;set;}
        /** Destination object that this Item will relaste to */
        @AuraEnabled public String desObj {get;set;}
        /** Type of field that this item is. Options are pulled from Form_Item_Types__mdt custom metadata */
        @AuraEnabled public String fieldType {get;set;}
        /** Label displayed to the user for this item */
        @AuraEnabled public String label {get;set;}
        /** No Response Text, this will be used to store text displayed to a user that requires no input from them */
        @AuraEnabled public String noResText {get;set;}
        /** Position this item will appear on the form */
        @AuraEnabled public Integer pos {get;set;}
        /** Holds the value entered by the user for the item */
        @AuraEnabled public String response {get;set;}
        /** Determines whether to show the label or not, defaults to true */
        @AuraEnabled public Boolean showLabel {get;set;}
        /** If a fieldType of picklist is choosen, selecting this will say to use the destination fields picklist values */
        @AuraEnabled public Boolean desPickVals {get;set;}
        /** If a fieldType of picklist is choosen, picklist values can be entered manually rather than using the destinations */
        @AuraEnabled public String values {get;set;}
        /** Field used to know to display edit info or not - NEEDS TO BE REVAMPED */
        @AuraEnabled public Boolean showInfo {get;set;}
        /** Assigned to each Item, essentially an Id field */
        @AuraEnabled public Integer dataNum {get;set;}
        /** Hide of PDF */
        @AuraEnabled public Boolean hideOnPDF {get;set;}
        /** Is ready only */
        @AuraEnabled public Boolean isReadOnly {get;set;}
    }

    // Wrapper for an Individual Rule on a Form
    /*
     * @appReqId:       Id of the Application Requirement being affected by the Rule
     * @appReqName:     Name of the Application Requirement being affected by the Rule, used for displaying infomation to the user
     * @changeToPhase:  The phase the affected Application Requirement will change to if the rule criteria is fufilled
     * @contItemNum:    Controlling Item's Data Number, only used for Rules on Items
     * @conItemLabel    Lable of the controlling Item
     * @contRule:       The condition type that must be fufilled fo the dependent Item to be affected
     * @contData:       The data that the condition type must fufill to affect the dependednt item.
     * @depAffect:      Currently just show or Hide, what happens to the dependent item
     * @depItemNum:     Dependent Item's Data Number, on used for Rules on Items
     * @depItemLabel    Label of the Dependent Item
     * @reqRuleItems:   Number of required Rule Items to be related to the Rule
     * @ruleName:       Used as a lookup field to hold the name of the Rule, avaliable rules pulled from the Rule__mdt custom metadata
     * @ruleItems:      List of Rule Items related to this Rule
     * @minDepts:       The minimum number of departments to be selected
     * @maxDepts:       The maximum number of departments to be selected
    */
    public class Rule extends FormItem{
        @AuraEnabled public String appReqId {get;set;}
        /** Name of the Application Requirement being affected by the Rule, used for displaying infomation to the user */
        @AuraEnabled public String appReqName {get;set;}
        /** The phase the affected Application Requirement will change to if the rule criteria is fufilled */
        @AuraEnabled public String changeToPhase {get;set;}
        /** Controlling Item's Data Number, only used for Rules on Items */
        @AuraEnabled public Integer contItemNum {get;set;}
        /** Lable of the controlling Item */
        @AuraEnabled public String contItemLabel {get;set;}
        /** The condition type that must be fufilled fo the dependent Item to be affected */
        @AuraEnabled public String contRule {get;set;}
        /** The data that the condition type must fufill to affect the dependednt item. */
        @AuraEnabled public String contData {get;set;}
        /** Currently just show or Hide, what happens to the dependent item */
        @AuraEnabled public String depAffect {get;set;}
        /** Dependent Item's Data Number, on used for Rules on Items */
        @AuraEnabled public Integer depItemNum {get;set;}
        /** Label of the Dependent Item */
        @AuraEnabled public String depItemLabel {get;set;}
        /** Alternate for each */
        @AuraEnabled public Boolean altForEach {get;set;}
        /** Number of required Rule Items to be related to the Rule */
        @AuraEnabled public Integer reqRuleItems {get;set;}
        /** Used as a lookup field to hold the name of the Rule, avaliable rules pulled from the Rule__mdt custom metadata */
        @AuraEnabled public String ruleName {get;set;}
        /** List of Rule Items related to this Rule */
        @AuraEnabled public List<RuleItem> ruleItems {get;set;}
        /** Assigned to each Rule, essentially an Id field */
        @AuraEnabled public Integer dataNum {get;set;}
        @AuraEnabled public Integer minDepts {get;set;}
        @AuraEnabled public Integer maxDepts {get;set;}
        @AuraEnabled public List<DesignationItem> designations {get;set;}
        @AuraEnabled public Boolean selectDesignations {get;set;}
        @AuraEnabled public Boolean linkClassesDept {get;set;}
        @AuraEnabled public Integer minClassesPerDept {get;set;}
        @AuraEnabled public Integer maxClassesPerDept {get;set;}

    }

    // 
    /**
     * Wrapper for an Individule Rule Item on a Rule
    */
    public class RuleItem{
        /** Id of the record related to this Rule Item */
        @AuraEnabled public String relId {get;set;}
        /** Object Name of the record related to the Rule Item */
        @AuraEnabled public String relObj {get;set;}
        /** Name of the reocrd related to the Rule Item */
        @AuraEnabled public String relObjName {get;set;}
    }

    // Wrapper for an Individule Rule Item on a Rule
    /*
     * @relId:      Id of the record related to this Rule Item
     * @relObj:     Object Name of the record related to the Rule Item
     * @relObjName: Name of the reocrd related to the Rule Item
    */
    public class DesignationItem{
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public Boolean designationRequired {get;set;}
    }
    
    /* Init / Submit Methods */
    /**
     * Initializes a Form wrapper to edit or create a dynamic form, Supply either a form id or a record type id, NOT BOTH
     * @param formId The Id of the form to edit
     * @param recordTypeId The record type Id of the form to create
     * @return an instance of Form 
     */
    @auraEnabled (cacheable=true)
    public static Form initForm(string formId, string recordTypeId){
        Form formWrap = new Form();
        formWrap.newDataNum = 0;
        // Edit Form - Just need to deserialize the JSON
        if(formId != null){
            Dynamic_Form__c f = [SELECT Id, JSON__c, RecordTypeId FROM Dynamic_Form__c WHERE Id = :formId LIMIT 1];
            try{
                formWrap = (Form)JSON.deserialize(f.JSON__c, Form.class);
                formWrap.formId = formId;
                Map<String, List<Rule__mdt>> allAvaliableRules = findAvaliableRules(formWrap.recordType);
                formWrap.contentRules = allAvaliableRules.get('Content');
                formWrap.formItemRules = allAvaliableRules.get('Form Item');
                
                formWrap.appPhaseOptions = returnPhaseOptions();
                formWrap.formItemTypes = returnFormItemTypes();
                formWrap.avaliableAppReqs = returnAppReqs(formWrap.progTermId);
            }
            catch(NullPointerException e){
                System.debug(LoggingLevel.INFO, 'JSON__c is null');
                formWrap = createNewForm(f);
            }
        }
        // Create Form
        else{
            Dynamic_Form__c f = new Dynamic_Form__c(RecordTypeId = recordTypeId);
            formWrap = createNewForm(f);
        }
        return formWrap;
    }

    private static Form createNewForm(Dynamic_Form__c f)
    {
            Form formWrap = new Form();
            formWrap.formId = f.Id;
            formWrap.newDataNum = 0;
            formWrap.recordType = [SELECT Name FROM RecordType WHERE Id = :f.RecordTypeId LIMIT 1].Name;
            
            formWrap.items = null;
            formWrap.formRules = null;
            formWrap.itemRules = null;
            Map<String, List<Rule__mdt>> allAvaliableRules = findAvaliableRules(formWrap.recordType);
            formWrap.contentRules = allAvaliableRules.get('Content');
            formWrap.formItemRules = allAvaliableRules.get('Form Item');
            
            formWrap.appPhaseOptions = returnPhaseOptions();
            formWrap.formItemTypes = returnFormItemTypes();
            formWrap.avaliableAppReqs = returnAppReqs(formWrap.progTermId);
            return formWrap;
    }

    /**
     * Returns all Phase picklist values from Application_Requirement__c
     * @return List<String> Phase options
     */
    public static List<String> returnPhaseOptions(){
        List<String> pickListValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = Application_Requirement__c.Phase__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : ple){
			pickListValuesList.add(pickListVal.getLabel());
		}     
		return pickListValuesList;
    }

    /**
     * Returms Form Item Types from the Form_Item_Type__mdt metadata table
     * @return List<Form_Item_Type__mdt> Form Item Types
     */
    public static List<Form_Item_Type__mdt> returnFormItemTypes(){
        List<Form_Item_Type__mdt> allFormItemTypes = [SELECT Description__c, MasterLabel, DeveloperName FROM Form_Item_Type__mdt ORDER BY MasterLabel];

        return allFormItemTypes;
    }

    /** Splits all Content and Form Item Rules into a map mapped to their types (Content, Form Item)
     * @param formType Param relates to the record type of the form, this also relates to the Form_Type__mdt metadata table
     * @return Map<String, List<Rule__mdt>> Rule types
    */
    public static Map<String, List<Rule__mdt>> findAvaliableRules(String formType){
        List<Rule__mdt> allRules = [SELECT Type__c, Description__c, MasterLabel, DeveloperName FROM Rule__mdt ORDER BY MasterLabel];
        List<Form_Type_Rule__mdt> ftrs = [SELECT Id, Rule__c, Form_Type__r.DeveloperName FROM Form_Type_Rule__mdt];

        Map<String, List<Rule__mdt>> avaliableRules = new Map<String, List<Rule__mdt>>();
        avaliableRules.put('Content', new List<Rule__mdt>());
        avaliableRules.put('Form Item', new List<Rule__mdt>());

        // sort through rules to split into mapping
        for(Rule__mdt rule : allRules){
            for(Form_Type_Rule__mdt ftr : ftrs){
                if(ftr.Form_Type__r.DeveloperName == formType && ftr.Rule__c == rule.Id){
                    if(rule.Type__c == 'Content'){
                        List<Rule__mdt> tempList = avaliableRules.get('Content');
                        templist.add(rule);
                        avaliableRules.put('Content', tempList);
                    }
                    else if(rule.Type__c == 'Form Item'){
                        List<Rule__mdt> tempList = avaliableRules.get('Form Item');
                        templist.add(rule);
                        avaliableRules.put('Form Item', tempList);
                    }
                }
            }
        }
        return avaliableRules;
    }

    /**
     * Method to submit the form, will return the Id of the inserted or updated form record
     * @param jsonWrapper a JSON serialized Form
     * @param numReqElements the number of elements that are required by the form (For CIF, this would be number of required courses)
     * @param formName the name of the form
     * @return String, the Id of the inserted or updated form
     */
    @auraEnabled
    public static String submitForm(String jsonWrapper, Integer numReqElements, Integer minNumReqElements, string formName, Boolean isActive){
        Form formWrap = (Form)JSON.deserialize(jsonWrapper, Form.class);
        string returnFormId;
        //Create New Form
        if(formWrap.formId == null){
            Dynamic_Form__c newForm = new Dynamic_Form__c();

            //Many fields are set to null before saving so the JSON filed will not be too large, these are reinstantiated in the init method
            formWrap.contentRules = null;
            formWrap.formItemRules = null;
            formWrap.appPhaseOptions = null;
            formWrap.formItemTypes = null;
            formWrap.avaliableAppReqs = null;
            formWrap.activated = false;
            
            if(formWrap.items != null){
                for(Item i : formWrap.items){
                    i.showInfo = null;
                }
            }

            formWrap.numReqElements = numReqElements;
            formWrap.minNumReqElements = minNumReqElements;
            formWrap.formName = formName;
            formWrap.formStatus = 'Draft'; // New Forms are always in draft

            //This is the string that will be saved into the JSON__c field on the form
            //Any manipulation of the Wrapper needs to be completed before this call
            String savedJSONString = JSON.serialize(formWrap, true);

            // Below are manipulations of the actual Form__c fields not just the JSON data
            newForm.JSON__C = savedJSONString;
            newForm.recordTypeId = Schema.SObjectType.Dynamic_Form__c.getRecordTypeInfosByName().get(formWrap.recordType).getRecordTypeId();
            newForm.Number_of_Required_Elements__c = numReqElements;
            newForm.Status__c = 'Draft';
            newForm.Name = formName;
            newForm.Program_Term__c = formWrap.progTermName;

            insert newForm;

            //Id to be returned
            returnFormId = newForm.Id;
        }
        //Edit the existing form -- all above comments apply to below as well
        else{
            Dynamic_Form__c newForm = [SELECT Id, JSON__c, Number_of_Required_Elements__c, Program_Term__c FROM Dynamic_Form__c WHERE Id = :formWrap.formId LIMIT 1];
            formWrap.contentRules = null;
            formWrap.formItemRules = null;
            
            formWrap.appPhaseOptions = null;
            formWrap.formItemTypes = null;
            formWrap.avaliableAppReqs = null;
            if(formWrap.items != null){
                for(Item i : formWrap.items){
                    i.showInfo = null;
                }
            }
            

            formWrap.numReqElements = numReqElements;
            formWrap.minNumReqElements = minNumReqElements;
            formWrap.formName = formName;
            formWrap.activated = isActive;
            //if active set to published
            if(isActive){
                formWrap.formStatus =  'Published';
            }
            else{
                formWrap.formStatus = 'Draft';
            }
            
            String savedJSONString = JSON.serialize(formWrap, true);

            newForm.JSON__C = savedJSONString;
            newForm.Number_of_Required_Elements__c = numReqElements;
            newForm.Name = formName;
            newForm.Program_Term__c = formWrap.progTermName;
            if(isActive){
                newForm.Status__c = 'Published';
            }
            else{
                newForm.Status__c = 'Draft';
            }

            update newForm;

            returnFormId = newForm.Id;
        }

        if(formWrap.progTermId != null){
            Id cifId = Schema.SObjectType.Application_Requirement__c.getRecordTypeInfosByName().get('Class Interest Form').getRecordTypeId();
            List<Application_Requirement__c> appReqList = new List<Application_Requirement__c>();
            Program_Term__c progTerm = [SELECT Id, (SELECT Id, Dynamic_Form__c FROM Application_Requirements__r WHERE recordTypeId = :cifId) FROM Program_Term__c WHERE Id = :formWrap.progTermId];
            if(progTerm.Application_Requirements__r.isEmpty()){
                Application_Requirement__c appReq = new Application_Requirement__c();
                appReq.Name = 'Class Interest Form';
                appReq.Phase__c = 'Not Visible';
                appReq.Program_Term__c = formWrap.progTermId;
                appReq.RecordTypeId = cifId;
                appReq.Directions__c = 'N/A';
                appReq.Dynamic_Form__c = returnFormId;
                
                insert appReq;
            }
            else{
                for(Application_Requirement__c appReq : progTerm.Application_Requirements__r){
                    if(appReq.Dynamic_Form__c == null){
                        appReq.Dynamic_Form__c = returnFormId;
                        appReqList.add(appReq);
                    }
                }
                if(!appReqList.isEmpty()){
                    update appReqList;
                }
            }

        }

        return returnFormId;
    }

    /* Other */
    /** Search for Courses based on a search term and the Program Term Id 
     * @param searchTerm A string to search courses by
     * @param progTermId A program term Id
     * @param reqIdList A list of course Ids that are currently required by the Form, this ensurse that these courses cannot be searched for 
     * @return List<Course__c> List of courses that match the parameters
     */
    @AuraEnabled (cacheable=true)
    public static List<Course__c> courseSearch(string searchTerm, String progTermId, List<String> reqIdList){
        // format the search term to fit the standard LIKE format
        String formattedSearchTerm = '%' + searchTerm + '%';
        //Need to Program Id related to the Program Term
        Program_Term__c progTerm = [SELECT Id, Program__c FROM Program_Term__c WHERE Id = :progTermId];
        List<Course__c> courseSearchList = new List<Course__c>();
        //Only want to search for courses with a Host Institution Record type
        Id hostCourseRecordTypeId = Schema.SObjectType.Course__c.getRecordTypeInfosByName().get('Host Institution').getRecordTypeId();

        // Do the search
        try{
            if(reqIdList == null || reqIdList.isEmpty()){
                courseSearchList = [SELECT Id, Name FROM Course__c WHERE Name Like :formattedSearchTerm AND RecordTypeId =: hostCourseRecordTypeId AND Id IN (SELECT Course__c FROM Program_Course__c WHERE Program__c =: progTerm.Program__c)];
            }
            else{
                courseSearchList = [SELECT Id, Name FROM Course__c WHERE Name Like :formattedSearchTerm AND RecordTypeId =: hostCourseRecordTypeId AND Id IN (SELECT Course__c FROM Program_Course__c WHERE Program__c =: progTerm.Program__c) AND Id NOT IN :reqIdList];
            }
        }
        catch(exception e){
            system.debug(e);
        }

        return courseSearchList;
    }

    /**
     * Search for Program Term based just off a search term
     * @param searchTerm A string to search program terms by
     * @return List<Program_Term__c> that match the search term
     */
    @AuraEnabled (cacheable=true)
    public static List<Program_Term__c> progTermSearch(string searchTerm){
        Id cifId = Schema.SObjectType.Application_Requirement__c.getRecordTypeInfosByName().get('Class Interest Form').getRecordTypeId();
        // format the search term to fit the standard LIKE format
        String formattedSearchTerm = '%' + searchTerm + '%';
        List<Program_Term__c> progTermList = new List<Program_Term__c>();
        List<Program_Term__c> returnList = new List<Program_Term__c>();

        // do the search
        try{
            progTermList = [SELECT Id, Name, (SELECT Id, Dynamic_Form__c FROM Application_Requirements__r WHERE recordTypeId = :cifId) FROM Program_Term__c WHERE Name Like :formattedSearchTerm ORDER BY Name];
        }
        catch(exception e){
            system.debug(e);
        }

        for(Program_Term__c progTerm : progTermList){
            if(progTerm.Application_Requirements__r.IsEmpty()){
                returnList.add(progTerm);
            }
            else{
                for(Application_Requirement__c appReq : progTerm.Application_Requirements__r){
                    if(appReq.Dynamic_Form__c == null){
                        returnList.add(progTerm);
                    }
                }
            }
        }

        return returnList;
    }

    /**
     * Sets the Program Term fields on the Form Wrapper, Also deletes any rules that are program term specific
     * @param jsonWrapper a JSON serialized Form
     * @param progrTermName Name of a program term
     * @param progTermId Id of a program
     * @return Form an instance of Form
     */
    @AuraEnabled (cacheable=true)
    public static Form setProgTerm(String jsonWrapper, String progTermName, String progTermId){
        Form formWrap = (Form)JSON.deserialize(jsonWrapper, Form.class);
        System.debug(formWrap);
        formWrap.progTermName = progTermName;
        formWrap.progTermId = progTermId;
        formWrap.avaliableAppReqs = returnAppReqs(progTermId);

        Integer j = 0;
        //While loops used to find the form rule that needs to be deleted
        if(formWrap.formRules != null){
            while(j < formWrap.formRules.size()){
                // Remove the Rule
                if(formWrap.formRules[j].ruleName == 'Must_Select_Course_X' || formWrap.formRules[j].ruleName == 'Must_Select_n_Courses' || formWrap.formRules[j].ruleName == 'Change_Phase_of_App_Item_X' || formWrap.formRules[j].ruleName == 'Advertise_X_Courses_in_List'){
                    formWrap.formRules.remove(j);
                }
                // Go to the Next Rule
                else{
                    j++;
                }
            }
        }

        return formWrap;
    }

    /**
     * Search for an Object based just off a search term
     * @param searchTerm Search string
     * @return List<EntityDefinition>
     */
    @AuraEnabled (cacheable=true)
    public static List<EntityDefinition> objectSearch(string searchTerm){
        // format the search term to fit the standard LIKE format
        String formattedSearchTerm = '%' + searchTerm + '%';
        List<EntityDefinition> objectList = new List<EntityDefinition>();

        // Do the search
        try{
            objectList = [SELECT QualifiedApiName, 
                          Label, 
                          NamespacePrefix 
                          FROM EntityDefinition 
                          WHERE IsSearchable = True 
                          AND QualifiedApiName IN ('Account', 'Contact', 'Application__c', 'Application_Item__c')
                          AND Label LIKE :formattedSearchTerm 
                          ORDER BY NamespacePrefix ASC];
        }
        catch(exception e){
            system.debug(e);
        }

        return objectList;
    }

    /**
     * Find all fields related to an object, given the object api name and the type of fields requested
     * @param objectType the name of the object to get fields for
     * @param fieldTypes A list of field types
     * @return List<String> field names for the specified object
     */
    @AuraEnabled (cacheable=true)
    public static List<String> fieldSearch(String objectType, List<String> fieldTypes){
        List<String> returnFieldList = new List<String>();
        // get all fields related to the passed in object
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectType).getDescribe().fields.getMap();

        // parse the fields to only return the ones that have an object type matching the fieldType list
        for(String key : fieldMap.keySet()){
            Schema.SObjectField field = fieldMap.get(key);
            for(String fieldType : fieldTypes){
                if(String.valueOf(field.getDescribe().getType()) == fieldType){
                    returnFieldList.add(key);
                }
            }
        }
        return returnFieldList;
    } 

    /**
     * Returns a list off all Application Requirements that have a Program term related to that parameter
     * @param progTermId The Id of the program term to get application requirements for
     * @return List<Application_Requirement__c>
     */
    public static List<Application_Requirement__c> returnAppReqs(Id progTermId){
        List<Application_Requirement__c> appReqList = new List<Application_Requirement__c>();

        appReqList = [SELECT Id, Name FROM Application_Requirement__c WHERE Program_Term__c = :progTermId];

        return appReqList;
    }
    /**
     * Clone Helper, used with Program Term Cloner
     * @param jsonWrap a JSON serialized Form
     * @param appReqId an Application_Requiremen__c Id 
     * @return Form an instance of Form
     */
    public static Form cloneHelper(String jsonWrap, String appReqId){
        Form formWrap = (Form)JSON.deserialize(jsonWrap, Form.class);
        Application_Requirement__c appReq = new Application_Requirement__c();

        try{
            appReq = [SELECT Id, Program_Term__r.Id, Program_Term__r.Name FROM Application_Requirement__c WHERE Id = :appReqId];
        }
        catch(exception e){
            system.debug(e);
            return null;
        }
        formWrap.progTermId = appReq.Program_Term__r.Id;
        formWrap.progTermName = appReq.Program_Term__r.Name;
        formWrap.formStatus = 'Draft';
        formWrap.activated = false;

        return formWrap;
    }

    /**
     * Gets the name of an Application_Requirement__c record by it's Id
     * @param appReqId
     * @return String
     */
    @AuraEnabled (cacheable = true)
    public static String returnAppReqName(String appReqId){
        try{
            return [SELECT Name FROM Application_Requirement__c WHERE Id = :appReqId LIMIT 1].Name;
        }
        catch(exception e){
            return null;
        }
    }
    /**
     * An exception class for formBuilderComponentController
     */
    public class formBuilderComponentControllerException extends Exception {}
}