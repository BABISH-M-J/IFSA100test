/**
 * Controller for progAuthWebComponent Lightning Web Controller
 * @author Matt Eck
 */
public without sharing class programAuthComponentController {
    // SORT_BY and sortParam are only used in the progAuthWrapperClass CompareTo Method
    /** The ways that the progAuthWrapperClass CompareTo function sorts */
    public enum SORT_BY{country, program}
    /** Determines how the CompareTo method sorts */
    public static SORT_BY sortParam {get;set;}

    /****************************** Wrappers ******************************/
    /**
     * Parent Wrapper to hold list of child wrappers as well as a couple other propetries
     */
    public class wrapperClass{
        /**
         * List of Program / Program Authorization Records for a home institution
         */
        @AuraEnabled public List<progAuthWrapperClass> progList{get;set;}
        /**
         * The avaiable term section names
         */
        @AuraEnabled public List<String> sections{get;set;}
        /**
         * The sections that have been changed
         */
        @AuraEnabled public List<String> modifiedSections{get;set;}
        /**
         * A list of checkboxWrapper objects (Probably used to select all programs for a specific section)
         */
        @AuraEnabled public List<checkboxWrapper> parentCheckboxes {get;set;}
        /**
         * The stautus of the home institution's Approves_All_Calendar_Programs__c checkbox
         */
        @AuraEnabled public Boolean approveAllSemester {get;set;}
        /**
         * The stautus of the home institution's Approves_All_Summer_Programs__c checkbox
         */
        @AuraEnabled public Boolean approveAllSummer {get;set;}
        /**
         * The stautus of the home institution's Approves_All_Winter_Programs__c checkbox
         */
        @AuraEnabled public Boolean approveAllWinter {get;set;}
        /**
         * The stautus of the home institution's Updating_Program_Authorizations__c checkbox
         */
        @AuraEnabled public Boolean updatingProgAuth {get;set;}
        /**
         * Determines if the component is in read only mode. If the current user does not have this permission set - "Program_Authorizations_Component_Full_Access" then they are in read only mode.
         */
        @AuraEnabled public Boolean readOnly {get;set;}
    }

    /** 
     * Wrapper class to hold Program Authorization information
     * Data is split into variables for easier access
    */
    public class progAuthWrapperClass implements Comparable{
        /** Name of Program */
        @AuraEnabled public String programName {get;set;}
        /** Program's Country */
        @AuraEnabled public String programCountry {get;set;}
        /** Full Program Authorization */
        @AuraEnabled public Program_Authorization__c progAuth {get;set;}
        /** Checks if Program Authorization has been updated */
        @AuraEnabled public Boolean updated {get;set;}
        /** Terms avaliable to this Program Authorization */
        @AuraEnabled public Set<String> avaliableTerms {get;set;}
        /** Each Wrapper will a checkboxWrapper for each of the modifiedSections in the parent Wrapper */
        @AuraEnabled public List<checkboxWrapper> checkboxes {get;set;}
        /** Stores the original sections so if the Program Auth is updated, then updated again back to how it started, we don;t have to actually update it */
        @AuraEnabled public String originalSections {get;set;}
        /** Provides the URL to the program authorization record so that the component can provide a link to the record  */
        @AuraEnabled public String recordUrl {get;set;}
        /** If this value is true, the home institution has temporary access to the program's classes in CHART */
        @AuraEnabled public Boolean shownInCHART {get;set;}
        
        /**
         * CompareTo function required by Comparable interface required so the program authorizations can be sorted
         */
        public Integer compareTo(Object objToCompare){
            progAuthWrapperClass otherWrapper = (progAuthWrapperClass)objToCompare;
            //checks the enum to see what field to sort by
            if(sortParam == SORT_BY.country){
                if(programCountry < otherWrapper.programCountry){
                    return -1;
                }
                if(programCountry > otherWrapper.programCountry){
                    return 1;
                }
            }
            else if(sortParam == SORT_BY.program){
                if(programName < otherWrapper.programName){
                    return -1;
                }
                if(programName > otherWrapper.programName){
                    return 1;
                }
            }
            return 0;
        }
    }

    /*
     * @visible: True if visible
     * @checked: True if checked
     * @section: Name of the Section associated to this checkbox
    */
    /**
     * Wrapper to store checkbox information
     */
    public class checkboxWrapper{
        /** The visibility of the checkbox */
        @AuraEnabled public Boolean visible {get;set;}
        /** The status of the checkbox */
        @AuraEnabled public Boolean checked {get;set;}
        /** The name of the term section  */
        @AuraEnabled public String section {get;set;}
    }

    /****************************** Query Methods ******************************/
    /**
     * Query for Programs with a search parameter
     * @param accId The Id of the active account
     * @param searchTerm The program or country name the user is searching for
     * @return List<Program__c> A list of Program__c records
     */
    public static List<Program__c> querySearchedPrograms(Id accId, string searchTerm){
        List<Program__c> progList = new List<Program__c>();
        // Set search term have a LIKE format
        searchTerm = '%' + searchTerm + '%';
        // Searched fields are Program Name and Program Country
        progList = [SELECT Id, 
                    Name,
                    Country__r.Name,
                    Available_Sections__c,
                    (SELECT Id, Term__c, Account__c, Program__c, Program__r.Name, Program_Country__c, Show_Unauthorized_Program_In_CHART__c FROM Program_Authorizations__r WHERE Account__c = :accId AND is_Active__c = true Order By CreatedDate DESC), 
                    (SELECT Id, Term__c, Term__r.Section__c FROM Program_Terms__r  WHERE Term__r.Year__c >=: Date.today().year()) 
                    FROM Program__c
                    WHERE Name != 'Undecided'
                        AND Active__c = TRUE
                        AND (Name LIKE :searchTerm
                            OR Country__r.Name LIKE :searchTerm)
                        AND Category__c = 'Catalog'
                    ORDER BY Name];

        return progList;
    }

    /**
     * Query for Programs WITHOUT a search parameter (just based on account)
     * @param accId The Id of the active account
     * @return List<Program__c> A list of Program__c records
     */
    public static List<Program__c> queryPrograms(Id accId){
        List<Program__c> progList = new List<Program__c>();
/*
        progList = [SELECT Id, 
                    Name,
                    Country__r.Name,
                    (SELECT Id, Term__c, Account__c, Program__c, Program__r.Name, Program_Country__c, Show_Unauthorized_Program_In_CHART__c FROM Program_Authorizations__r WHERE Account__c = :accId AND is_Active__c = true), 
                    (SELECT Id, Term__c, Term__r.Section__c FROM Program_Terms__r WHERE Term__r.Year__c >=: Date.today().year()) 
                    FROM Program__c
                    WHERE Name != 'Undecided'
                        AND Active__c = TRUE
                        AND Category__c = 'Catalog'
                    ORDER BY Name];
*/
            // changed by powerfluence - req no. 11a  starts here
            progList = [SELECT Id, 
                    Name,
                    Country__r.Name,
                    Available_Sections__c,
                    (SELECT Id, Term__c, Account__c, Program__c, Program__r.Name, Program_Country__c, Show_Unauthorized_Program_In_CHART__c FROM Program_Authorizations__r WHERE Account__c = :accId AND is_Active__c = true Order By CreatedDate DESC LIMIT 1   ), 
                    (SELECT Id, Term__c, Term__r.Section__c FROM Program_Terms__r WHERE Term__r.Year__c >=: Date.today().year()) 
                    FROM Program__c 
                    WHERE Name != 'Undecided'
                        AND Active__c = TRUE
                        AND Category__c = 'Catalog' 
                    ORDER BY Name  ];
                    system.debug('progList' + progList);
            // changed by powerfluence - req no. 11a  starts here
            return progList;
    }


    /****************************** Init Methods ******************************/
    /**
     * Initialization Method, this is called by the Lightning Web Component when it is loaded via the "@wire" service.
     * Called with searchTeerm or a null searchTemm, Lighting cannot currently overload
     * @param accId The Id of the active account
     * @param searchTerm The program or country name the user is searching for
     * @return wrapperClass
     */
    @AuraEnabled(cacheable=true)
    public static wrapperClass initWrapper(Id accId, string searchTerm){
        wrapperClass returnWrapper = new wrapperClass();
        returnWrapper.sections = returnSections();
        returnWrapper.modifiedSections = returnModifiedSections(returnWrapper.sections);
        returnWrapper.parentCheckboxes = createParentCheckboxes(returnWrapper.modifiedSections);
        returnWrapper.progList = returnPrograms(accId, searchTerm);
        // Get Approves All * Programs Status
        Account a = [SELECT Id, Approves_All_Calendar_Programs__c, Approves_All_Summer_Programs__c, Approves_All_Winter_Programs__c, Updating_Program_Authorizations__c FROM Account WHERE Id =: accId  ];
      
        returnWrapper.approveAllSemester = a.Approves_All_Calendar_Programs__c;
        returnWrapper.approveAllSummer = a.Approves_All_Summer_Programs__c;
        returnWrapper.approveAllWinter = a.Approves_All_Winter_Programs__c;
        returnWrapper.updatingProgAuth = a.Updating_Program_Authorizations__c;
        returnWrapper.readOnly = checkPermissions();

        return returnWrapper;
    }

    /**
     * Sets all values for progAuthWrapperClass
     * @param accId The Id of the active account
     * @param searchTerm The program or country name the user is searching for
     * @return List<progAuthWrapperClass>
     */
    public static List<progAuthWrapperClass> returnPrograms(Id accId, string searchTerm){
        List<progAuthWrapperClass> returnWrapper = new List<progAuthWrapperClass>();
        List<Program__c> progList = new List<Program__c>();
        // Decide query based of searchTerm
        if(searchTerm != null){
            progList = querySearchedPrograms(accId, searchTerm);
           
        }
        else{
            progList = queryPrograms(accId);
        }
        
        // This should NOT happen on initial load, only with searchTerm
        if(progList.isEmpty()){
            
            return null;
        }
        
        //Loop Through Each Program to find / generate Program Authorizations
        for(Program__c prog : progList){
           
            progAuthWrapperClass progAuthWrap = new progAuthWrapperClass();
            progAuthWrap.programName = prog.Name;
            progAuthWrap.programCountry = prog.Country__r.Name;
            // If no Program Authorization exists for this program create one with just Account and Program Assigned
            if(prog.Program_Authorizations__r.isEmpty()){
                Program_Authorization__c newProgAuth = new Program_Authorization__c(Account__c = accId,
                                                                                 Program__c = prog.Id);
                progAuthWrap.progAuth = newProgAuth;
            }
            // If a program Authorization does exists, assign is to the Wrapper
            else{
                progAuthWrap.progAuth = prog.Program_Authorizations__r[0];
                progAuthWrap.shownInCHART = prog.Program_Authorizations__r[0].Show_Unauthorized_Program_In_CHART__c;
                progAuthWrap.originalSections = prog.Program_Authorizations__r[0].Term__c;
                progAuthWrap.recordUrl = '/' + progAuthWrap.progAuth.Id;
            }
            
            // Grab all sections on the Related Terms to see which will be avaliable
            // changed by powerfluence - req no. 11a  starts here
            list<string> termlist = new list<string>();
            String availbleSec = prog.Available_Sections__c; //Fall;Summer;Winter
          
            if(availbleSec == null)
            {
               // system.debug('availbleSec'+ availbleSec);
                availbleSec = 'Not Apporved';
            }
            termlist = availbleSec.split(';'); ////Fall,Summer,Winter
            system.debug('termlist'+ termlist);
            Set<String> termSet = new Set<String>(termlist);
           // system.debug('termset-->'+termSet);
             // changed by powerfluence - req no. 11a  ends here

            /* commented by powerfluence - to match code 
                prior to IFSA refresh
             Set<String> termSet = new Set<String>();
            for(Program_Term__c term : prog.Program_Terms__r){
                if(term.Term__c != null){
                    if(term.Term__r.Section__c != null){
                        termSet.add(term.Term__r.Section__c);
                    }
                }
            }
            */

            // Grab all the modified sections
            List<String> allSections = returnSections();
            List<String> modifiedSections = returnModifiedSections(allSections);
            List<checkboxWrapper> checkboxWrapperList = new List<checkboxWrapper>();

            // Set Checkbox wrappers based on term and modified sections
            for(String section : modifiedSections){
                checkboxWrapper checkbox = new checkboxWrapper();
                checkbox.visible = false;
                checkbox.checked = false;
                checkbox.section = section;
                // Not Approved is always visible
                if(section == 'Not Approved'){
                    checkbox.visible = true;
                    if(!prog.Program_Authorizations__r.isEmpty()){
                        // If the Program Authorzation Contains Not Apporved it starts checked
                        if(prog.Program_Authorizations__r[0].Term__c.contains(section)){
                            checkbox.checked = true;
                        }
                    }
                }
                else{
                    // loop through the terms
                    for(String term : termSet){
                        //if term equals the current sections make it visible, and if the prog auth contains theterm, set it to checked
                        if(term == section){
                            checkbox.visible = true;
                            if(!prog.Program_Authorizations__r.isEmpty()){
                                if(prog.Program_Authorizations__r[0].Term__c.contains(section)){
                                    checkbox.checked = true;
                                }
                            }
                        }
                    }
                }
                checkboxWrapperList.add(checkbox);
            }

            // Add all the fields to the ProgAuth Wrapper
            progAuthWrap.checkboxes = checkboxWrapperList;
            progAuthWrap.avaliableTerms = termSet;
            progAuthWrap.updated = false;

            // add that wrapper to the parent Wrapper
            returnWrapper.add(progAuthWrap);
        }

        if(!returnWrapper.isEmpty()){
            return returnWrapper;
        }
        return null;
    }

    /**
     * Finds all sections based off avaliable picklist values on Program_Authorization__c.Term__c
     * @return List<String>
     */
    public static List<String> returnSections(){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Program_Authorization__c.Term__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }
        return pickListValuesList;
    }

    /**
     * Modify the sections to remove Semester 1, and Semester 2
     * This method used to remove "Winter" sections, but we now offer Catalog Winter programs so that has been removed
     * @param picklistValues The current avaliable section values
     * @return List<String> The current list of sections used for Catalog programs
     */
    public static List<String> returnModifiedSections(List<String> picklistValues){
        List<String> pickListValuesList= new List<String>();
        for( String pickListVal : picklistValues){
            // Ignores Semester 1 and Semseter 2 Options
            if(pickListVal == 'Semester 1' || pickListVal == 'Semester 2'){
                continue;
            }
            else{
                pickListValuesList.add(pickListVal);
            }
        }
        return pickListValuesList;

    }

    /**
     * Parent Checkboxes should contain one for each Modify Section
     * @param modifiedSections The section names to create checkboxes for
     * @return List<checkboxWrapper>
     */
    public static List<checkboxWrapper> createParentCheckboxes(List<String> modifiedSections){
        List<checkboxWrapper> parentCheckboxs = new List<checkboxWrapper>();
        for(String section : modifiedSections){
            checkboxWrapper cb = new checkboxWrapper();
            cb.visible = true;
            cb.section = section;
            cb.checked = false;
            parentCheckboxs.add(cb);
        }
        return parentCheckboxs;
    }

    /****************************** Update Methods ******************************/
    @AuraEnabled(cacheable = true)
    /**
     * Only one checkbox update requires a JSON string, program Name, Section, and whether to check or uncheck
     * @param jsonWrapper JSON serialized wrapperClass
     * @param progName The name of the program that is being modified
     * @param section The section that is being modified
     * @param checked The value of the section that is being modified
     * @return wrapperClass
     */
    public static wrapperClass singleCheckboxUpdate(String jsonWrapper, String progName, String section, Boolean checked){
        wrapperClass returnWrapper = (wrapperClass)JSON.deserialize(jsonWrapper, wrapperClass.class);
        // Loop through Program Authorizations
        for(progAuthWrapperClass paWrap : returnWrapper.progList){
            system.debug('paWrap405' + paWrap);
            // Find the Program Authorization related to the Program we passed in
            if(paWrap.programName == progName){
                system.debug('paWrap408' + paWrap);
                paWrap.updated = true;

                //Loop through the Checkboxes related to the Program Authorization
                for(checkboxWrapper cbWrap : paWrap.checkboxes){
                    // If Section is Not Apporved and Checked is True, Set that Checkbox to checked and all others on the Prog Auth to Unchecked
                  
                    if(section == 'Not Approved' && checked){
                        if(cbWrap.section == section){
                            cbWrap.checked = checked;
                        }
                        else{
                            cbWrap.checked = false;
                            // Set all parent level CheckBoxes to unchecked
                            for(checkboxWrapper parentCb : returnWrapper.parentCheckboxes){
                                system.debug('parentCb' + parentCb);
                                parentCb.checked = false;
                            }
                        }
                    }
                    // Check the box of the section that matches the section we checked
                    if(cbWrap.section == section && checked){
                        cbWrap.checked = checked;
                        for(checkboxWrapper parentCb : returnWrapper.parentCheckboxes){
                            //Uncheck parent Not Approved Box
                            if(parentCb.section == 'Not Approved'){
                                parentCb.checked = false;
                            }
                        }
                    }
                    // Uncheck the box of the section that matches the section we checked
                    else if(cbWrap.section == section && !checked){
                        cbWrap.checked = checked;
                        for(checkboxWrapper parentCb : returnWrapper.parentCheckboxes){
                            //Uncheck the parent of the section we are on
                            if(parentCb.section == cbWrap.section){
                                parentCb.checked = checked;
                            }
                        }
                    }
                    //This will uncheck the Not approved child checkbox
                    else if(section != 'Not Approved' && cbWrap.section == 'Not Approved' && cbWrap.checked == true){
                        cbWrap.checked = false;
                    }
                }
            }
        }

        return returnWrapper;
    }

    /**
     * Uncheck the Boxes to unapprove all program Authorizations
     * @param wrapper The current state of the account's program authorizations
     * @return wrapperClass
     */
    public static wrapperClass unapproveAllAuths(wrapperClass wrapper){
        // Loop through all Program Authorizations and All Checkboxes and Set them all to Unchecked
        for(progAuthWrapperClass paWrap : wrapper.progList){
            paWrap.updated = true;
            for(checkboxWrapper cbWrap : paWrap.checkboxes){
                //The only checkbox set to true is the Not Approved checkbox
                if(cbWrap.section != 'Not Approved'){
                    cbWrap.checked = false;
                }
                else{
                    cbWrap.checked = true;
                }
            }
        }
        // Loop through all parent level checkboxes and set them to Unchecked
        for(checkboxWrapper parentCb : wrapper.parentCheckboxes){
            //the only parent level checkbox set to true is the Not Approved checkbox
            if(parentCb.section != 'Not Approved'){
                parentCb.checked = false;
            }
            else{
                parentCb.checked = true;
            }
        }
        return wrapper;
    }

    /**
     * Check all the boxes along a full column for a section
     * @param jsonWrapper JSON serialized wrapperClass
     * @param section The section that is being modified
     * @param checked The value of the section that is being modified
     * @return wrapperClass
     */
    @AuraEnabled(cacheable = true)
    public static wrapperClass fullColumnUpdate(String jsonWrapper, String section, Boolean checked){
        wrapperClass returnWrapper = (wrapperClass)JSON.deserialize(jsonWrapper, wrapperClass.class);
        // Checking the Not Approved parent checkbox is handled in the unapproveAllAuths method
        if(section == 'Not Approved' && checked){
            returnWrapper = unapproveAllAuths(returnWrapper);
        }
        else{
            //Loop though All Prog Auths and all Checkboxes
            for(progAuthWrapperClass paWrap : returnWrapper.progList){
                for(checkboxWrapper cbWrap : paWrap.checkboxes){
                    // When finding matching sections, set them to the checked value (only if visible)
                    if(cbwrap.section == section && cbWrap.visible){
                        cbWrap.checked = checked;
                        paWrap.updated = true;
                    }
                    // Not Approved set to False
                    else if(cbWrap.section == 'Not Approved'){
                        cbWrap.checked = false;
                        paWrap.updated = true;
                    }
                }
            }
            // Loop thought parents and check the Parent checkbox for the section we passed in
            for(checkboxWrapper parentCb : returnWrapper.parentCheckboxes){
                if(parentCb.section == section){
                    parentCb.checked = checked;
                }
                // Parent checkbox for Not Approved set to false
                else if(parentCb.section == 'Not Approved'){
                    parentCb.checked = false;
                }
            }
        }
        return returnWrapper;
    }

    // created by powerfluence - req no.1 - 001 starts here
    /**
     * This is the method that will actually create / update program Authorizations
     * @param jsonWrapper JSON serialized wrapperClass
     * @return wrapperClass
     */
    @AuraEnabled(cacheable = true)
    public static wrapperClass approveAllSemesterColumn(String jsonWrapper){
        jsonWrapper = JSON.serialize(fullColumnUpdate(jsonWrapper, 'Not Approved', false));
        jsonWrapper = JSON.serialize(fullColumnUpdate(jsonWrapper, 'Spring', true));
        jsonWrapper = JSON.serialize(fullColumnUpdate(jsonWrapper, 'Fall', true));
        jsonWrapper = JSON.serialize(fullColumnUpdate(jsonWrapper, 'Calendar Year', true));
        jsonWrapper = JSON.serialize(fullColumnUpdate(jsonWrapper, 'Academic Year', true));
        wrapperClass returnWrapper = (wrapperClass)JSON.deserialize(jsonWrapper, wrapperClass.class);
        for(checkboxWrapper parentCb : returnWrapper.parentCheckboxes){
            system.debug('parentCb' + parentCb);
            parentCb.checked = false;
        
        }
        return returnWrapper;
    }
    // created by powerfluence - req no.1 - 001 ends here

    // created by powerfluence - req no.1 - 002 starts here
    /**
     * This is the method that will actually create / update program Authorizations
     * @param jsonWrapper JSON serialized wrapperClass
     * @return wrapperClass
     */
    @AuraEnabled(cacheable = true)
    public static wrapperClass approveAllSummerColumn(String jsonWrapper){
        jsonWrapper = JSON.serialize(fullColumnUpdate(jsonWrapper, 'Not Approved', false));
        jsonWrapper = JSON.serialize(fullColumnUpdate(jsonWrapper, 'Summer', true));
        wrapperClass returnWrapper = (wrapperClass)JSON.deserialize(jsonWrapper, wrapperClass.class);
        for(checkboxWrapper parentCb : returnWrapper.parentCheckboxes){
                parentCb.checked = false;
                system.debug('parentCb' + parentCb);
                
        }
        return returnWrapper;
    }
    // created by powerfluence - req no.1 - 002 ends here

    // created by powerfluence - req no.1 - 003 starts here
    /**
     * This is the method that will actually create / update program Authorizations
     * @param jsonWrapper JSON serialized wrapperClass
     * @return wrapperClass
     */
    @AuraEnabled(cacheable = true)
    public static wrapperClass approveAllWinterColumn(String jsonWrapper){
        jsonWrapper = JSON.serialize(fullColumnUpdate(jsonWrapper, 'Not Approved', false));
        jsonWrapper = JSON.serialize(fullColumnUpdate(jsonWrapper, 'Winter', true));
        wrapperClass returnWrapper = (wrapperClass)JSON.deserialize(jsonWrapper, wrapperClass.class);
        for(checkboxWrapper parentCb : returnWrapper.parentCheckboxes){
            system.debug('parentCb' + parentCb);
            parentCb.checked = false;
          
        }
        return returnWrapper;
    }
    // created by powerfluence - req no.1 - 003 ends here

    // created by powerfluence - 10 b - 001 starts here
    /**
     * This is the method that will actually create / update program Authorizations
     * @param jsonWrapper JSON serialized wrapperClass
     * @return wrapperClass
     */
    @AuraEnabled(cacheable = true)
    public static wrapperClass approveAllColumn(String jsonWrapper){
        jsonWrapper = JSON.serialize(fullColumnUpdate(jsonWrapper, 'Not Approved', false));
        jsonWrapper = JSON.serialize(fullColumnUpdate(jsonWrapper, 'Spring', true));
        jsonWrapper = JSON.serialize(fullColumnUpdate(jsonWrapper, 'Fall', true));
        jsonWrapper = JSON.serialize(fullColumnUpdate(jsonWrapper, 'Calendar Year', true));
        jsonWrapper = JSON.serialize(fullColumnUpdate(jsonWrapper, 'Academic Year', true));
        jsonWrapper = JSON.serialize(fullColumnUpdate(jsonWrapper, 'Winter', true));
        jsonWrapper = JSON.serialize(fullColumnUpdate(jsonWrapper, 'Summer', true));
        wrapperClass returnWrapper = (wrapperClass)JSON.deserialize(jsonWrapper, wrapperClass.class);
        for(checkboxWrapper parentCb : returnWrapper.parentCheckboxes){
         system.debug('parentCb'+ parentCb);
            parentCb.checked = false;
        }
        return returnWrapper;
    }
    // created by powerfluence - 10 b - 001 ends here

    /**
     * This is the method that will actually create / update program Authorizations
     * @param jsonWrapper JSON serialized wrapperClass
     * @return wrapperClass
     */
    @AuraEnabled
    public static wrapperClass updateProgAuths(String jsonWrapper){
        wrapperClass returnWrapper = (wrapperClass)JSON.deserialize(jsonWrapper, wrapperClass.class);
       
        List<Program_Authorization__c> upsertPAList = new List<Program_Authorization__c>();
        // Loop though all Program Authorizations in Wrapper
        for(progAuthWrapperClass paWrap : returnWrapper.progList){
            system.debug('paWrap' + paWrap);
            String newSections;
            // Only do anything if the program has been updated
            if(paWrap.updated){
                // Loop through checkboxes
                for(checkboxWrapper cbWrap : paWrap.checkboxes){
                   system.debug('cbWrap' + cbWrap);
                    //if this section is checked, add the string to the newSections string
                    if(cbWrap.checked){
                        if(newSections == null){
                            newSections = cbWrap.section + ';';
                        }
                        else{
                            newSections += cbWrap.section + ';';
                        }
                    }
                }

                //If we have no strings at the end, set to Not Approved
                if(newSections == null){
                    newSections = 'Not Approved;';
                    for(checkboxWrapper cbWrap : paWrap.checkboxes){
                     
                        if(cbWrap.section == 'Not Approved'){
                            cbWrap.checked = true;
                        }
                    }
                 }
                 //remove the trailing ;
                newSections = newSections.removeEnd(';');

                //check to see if the newSections list is the same as the Original Sections list
                if(paWrap.originalSections != newSections){
                    paWrap.progAuth.Term__c = newSections;
                    //add to the upsertPAList
                    upsertPAList.add(paWrap.progAuth);
                    system.debug('upsertPAList' + upsertPAList.size());
                }
            }
        }

        //Upsert if there are any to update
        if(!upsertPAList.isEmpty()){
            system.debug(upsertPAList.size());
            system.debug(upsertPAList);
            
          database.upsert(upsertPAList);
          
        }
        return returnWrapper;
    }

    
    /**
     * Call out to the CompareTo method on the Program Auth Wrapper
     * @param jsonWrapper JSON serialized wrapperClass
     * @param sortParamater The parameter to sort the programs
     * @return wrapperClass
     */
    @AuraEnabled(cacheable = true)
    public static wrapperClass sortWrapper(String jsonWrapper, String sortParamater){
        wrapperClass returnWrapper = (wrapperClass)JSON.deserialize(jsonWrapper, wrapperClass.class);
        //Choose what to sort
        if(sortParamater == 'country'){
            sortParam = SORT_BY.country;
        }
        else if(sortParamater == 'program'){
            sortParam = SORT_BY.program;
        }
        //initiate the sort
        returnWrapper.progList.sort();
        return returnWrapper;
    }
    /**
     * Sets a field value and updates the account to approve all * programs.
     * @param accountId The Id of account record to update.
     * @param field The field to update on account record.
     * @param value The value to update in the specified field
     * @return Boolean returns true if the operation is successfull
     */
    @AuraEnabled
    public static Boolean approveAll(String accountId, String field, Boolean value){
        try {
            Account a = new Account(Id = accountId );
            a.put(field, value);
            Database.update(a);
            return true;
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
     * Checks the status of Updating_Program_Authorizations__c on the specified account
     * @param accountId The Id of the account to query Updating_Program_Authorizations__c
     * @return Boolean returns the current statue of Updating_Program_Authorizations__c
     */
    @AuraEnabled
    public static Boolean checkUpdatingProgAuths(String accountId){
        try {
            Account a = [SELECT Id, Updating_Program_Authorizations__c FROM Account WHERE Id =: accountId];
           
            // changed by powerfluence - req no. 15 - starts here
            system.debug('a.Updating_Program_Authorizations__c'+a.Updating_Program_Authorizations__c);
            system.debug('a--start'+a);
            if(a.Updating_Program_Authorizations__c == true)
            {
                a.Updating_Program_Authorizations__c=false;
            }
            update a;
            
            // changed by powerfluence - req no. 15 - ends here
            return a.Updating_Program_Authorizations__c;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static Boolean checkPermissions() 
    {
        List<PermissionSetAssignment> permSets = [SELECT Id, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId =: UserInfo.getUserId() AND PermissionSet.Name = 'Program_Authorizations_Component_Full_Access'];
        return permSets.isEmpty();
    }

}