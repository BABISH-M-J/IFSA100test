/**
 * @description Controller fore the Select Program page of the student portal
 * @author Cameron Ames
 */
public without sharing class studentSelectController extends studentBaseController
{
    /**
     * @description Container for all view data.
     * @see studentSelectViewModel
     */
    public studentSelectViewModel viewModel {get;set;}
    private Program_Term__c programTerm {get;set;}
    private Program_Term__c parentProgramTerm {get;set;}
    private User programAdvisor {get;set;}

    /**
     * @description Constructor function. Gets the list of valid countries with active program terms and allows the student to go from there.
     * @return void
     */
    public studentSelectController()
    {
        super();
        if(this.application != null)
        {
            List<Program_Term__c> programTerms = apexQueryUtility.selectAllFrom('Program_Term__c', 'Program__r.Host_Institution__r.Country__r.Name', 'Id = \'' + this.application.Id + '\'');
            
            if(this.application.Program_Term__c != null)
            {
                this.programTerm = [SELECT Id, Name, OwnerId, Parent_Program_Term__c, Program__r.Name, Program__r.Webpage_Url__c, Program__r.Host_Institution__r.Country__r.Name FROM Program_Term__c WHERE ID =: this.application.Program_Term__c];
                this.programAdvisor = [SELECT Id, FirstName, LastName, Email, Phone, FullPhotoUrl, Calendly_Link__c, PA_Intro_Video__c FROM User WHERE Id =: programTerm.OwnerId];
                try
                {
                    this.parentProgramTerm = [SELECT Id, Name, OwnerId, Program__r.Name, Program__r.Webpage_Url__c, Program__r.Host_Institution__r.Country__r.Name FROM Program_Term__c WHERE ID =: this.programTerm.Parent_Program_Term__c];
                }
                catch (QueryException ex) 
                {
                    system.debug('Program Term: ' + this.programTerm.Name + ' does not have a program term.');
                }
            }
            else
            {
                this.programTerm = programTerms.size() > 0 ? programTerms.get(0) : null;
            }
            this.viewModel = new studentSelectViewModel();
            this.populateViewModel();
        }
    }

    private void populateViewModel()
    {
        this.viewModel = (studentSelectViewModel) super.populateViewModel(this.viewModel);
        this.viewModel.countryName = this.programTerm != null ? this.programTerm.Program__r.Host_Institution__r.Country__r.Name : null;
        this.viewModel.programTermName = this.programTerm != null ? this.programTerm.Name : null;        
        Set<Id> countryIds = new Set<Id>();
        
        this.viewModel.countryOptions = new List<String>();

        for(Country__c country : programTermService.getCountriesForProgramSelector())
        {
            this.viewModel.countryOptions.add(country.Name);
        }
        
        this.viewModel.advisorEmail = this.programAdvisor.Email;
        this.viewModel.advisorFirstName = this.programAdvisor.FirstName;
        this.viewModel.advisorLastName = this.programAdvisor.LastName;
        this.viewModel.advisorPhone = this.programAdvisor.Phone;
        this.viewModel.advisorPhotoUrl = this.programAdvisor.FullPhotoUrl;
        this.viewModel.advisorCalendlylink = this.programAdvisor.Calendly_Link__c;
        this.viewModel.paIntroVideo = this.programAdvisor.PA_Intro_Video__c;
        this.viewModel.applications = portalRemotingMethods.getApplications(this.studentContact.Id);
    }
    
    /**
     * @description Authorization function. If the student has not yet registered, redirect to the register page.
     * @return PageReference
     */
    /*
    public override PageReference validateAccess()
    {   
        if(this.viewModel.isLockDownActive)
        {
            return new PageReference('/SP_Home');
        }
        else if(this.application == null)
        {
            return new PageReference('/SP_ApplicationSelector');
        }
        if(!this.viewModel.isRegistered)
        {
            return new PageReference('/SP_Register');
        }
        return null;
    }

    
    */
    /**
     * @description Searches for a list of valid terms based on valid program terms by country.
     * @return List<String>
     */
    /*
    @RemoteAction
    public static List<String> searchByCountry(String countryName)
    {   
        User studentUser = [SELECT Id, ContactId FROM User WHERE id =: userInfo.getUserId()];                
        Set<Id> duplicateTermIds = new Set<Id>();
        try 
        {
            LinkedList divertedTerms = new LinkedList();
            for(Application__c app : [SELECT Id, Program_Term__r.Term__c FROM Application__c WHERE Status__c = 'Diverted' AND Applicant__c =: studentUser.ContactId])
            {            
                divertedTerms.addToList(null, null, app.Program_Term__r.Term__c);
            }
            
            LinkedListNode compared = divertedTerms.head;
            LinkedListNode node = divertedTerms.head;
            while (node.getNext() != null)
            {            
                while (compared.getNext() != null)
                {
                    if(node.getIdValue() == compared.getIdValue() && !duplicateTermIds.contains(node.getIdValue()))
                    {
                        duplicateTermIds.add(node.getIdValue());
                    }
                    compared = compared.getNext();
                }
                node = node.getNext();
            }
        } 
        catch(NullPointerException e) 
        {
            system.debug(e);
        }
        List<Id> poRecordTypes = new List<Id>();
        poRecordTypes.add(Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Program Option with Dates').getRecordTypeId());
        poRecordTypes.add(Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Program Option without Dates').getRecordTypeId());

        Id standardPT = Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Standard Program Term').getRecordTypeId();

        Date todayPlus28 = Date.today().addDays(28);
        List<Program_Term__c> programTerms = new List<Program_Term__c>();
        if(!duplicateTermIds.isEmpty())
        {
            //ACARSON 10.15.2017 Changed query to limit Program Terms to only ones that have a start date 28 days in the future
            //programTerms = [SELECT Id, Term__c, Program__r.Active__c FROM Program_Term__c WHERE Program__r.Host_Institution__r.Country__r.Name =: countryName AND (NOT Term__c IN: duplicateTermIds)];
            
            //programTerms = [SELECT Id, Term__c, Program__r.Active__c, RecordTypeId FROM Program_Term__c WHERE Program__r.Host_Institution__r.Country__r.Name =: countryName AND (NOT Term__c IN: duplicateTermIds) AND ((Start_Date__c >=: todayPlus28 OR Start_Date__c = null) AND Program__r.Active__c = true)];
            programTerms = [SELECT Id, Term__c, Program__r.Active__c, RecordTypeId, (SELECT Id FROM Program_Terms__r WHERE Start_Date__c >=: todayPlus28 OR Start_Date__c = null) FROM Program_Term__c WHERE Program__r.Host_Institution__r.Country__r.Name =: countryName AND (NOT Term__c IN: duplicateTermIds) AND ((Start_Date__c >=: todayPlus28 OR Start_Date__c = null) AND Program__r.Active__c = true)];
        }
        else
        {
            //ACARSON 10.15.2017 Changed query to limit Program Terms to only ones that have a start date 28 days in the future
            //programTerms = [SELECT Id, Term__c, Program__r.Active__c FROM Program_Term__c WHERE Program__r.Host_Institution__r.Country__r.Name =: countryName];
            
            //programTerms = [SELECT Id, Term__c, Program__r.Active__c, RecordTypeId FROM Program_Term__c WHERE Program__r.Host_Institution__r.Country__r.Name =: countryName AND ((Start_Date__c >=: todayPlus28 OR Start_Date__c = null) AND Program__r.Active__c = true)];
            programTerms = [SELECT Id, Term__c, Program__r.Active__c, RecordTypeId, (SELECT Id FROM Program_Terms__r WHERE Start_Date__c >=: todayPlus28 OR Start_Date__c = null) FROM Program_Term__c WHERE Program__r.Host_Institution__r.Country__r.Name =: countryName AND ((Start_Date__c >=: todayPlus28 OR Start_Date__c = null) AND Program__r.Active__c = true)];
        }
        List<Id> progTermIds = new List<Id>();
        for(Program_Term__c progTerm : programTerms)
        {           
            //if(progTerm.Program__r.Active__c){
            if(progTerm.Program__r.Active__c && (progTerm.RecordTypeId == standardPT || progTerm.Program_Terms__r.size() > 0))
            {
                progTermIds.add(progTerm.Term__c);
            }
        }

        List<Term__c> terms = [SELECT Id, Name, Display_Name__c FROM Term__c WHERE Id IN: progTermIds ORDER By Name];

        List<String> termNames = new List<String>();
        for(Term__c term: terms)
        {
            termNames.add(term.Display_Name__c);
        }

        return termNames;
    }
    */
    /**
     * @description Searches for a list of valid program terms based on country and term.
     * @return List<String>
     */
     /*
    @RemoteAction
    public static List<String> searchByTerm(String country, String term)
    {
        User studentUser = [SELECT Id, ContactId FROM User WHERE id =: userInfo.getUserId()];       
        List<Id> poRecordTypes = new List<Id>();
        poRecordTypes.add(Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Program Option with Dates').getRecordTypeId());
        poRecordTypes.add(Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Program Option without Dates').getRecordTypeId());
        List<Application__c> apps = [SELECT Program_Term__c, Program_Term__r.Parent_Program_Term__c, Program_Term__r.Name FROM Application__c WHERE Applicant__c =: studentUser.ContactId AND (NOT Program_Term__c = null)];
        Boolean oxfordOrCambridge = false;
        List<ID> hiddenPTIds = new List<ID>();
        for(Application__c app : apps)
        {
            hiddenPTIds.add(app.Program_Term__c);
            //ACARSON
            if(app.Program_Term__r.Parent_Program_Term__c != null){
                System.debug('### : ' + app.Program_Term__r.Parent_Program_Term__c);
                hiddenPTIds.add(app.Program_Term__r.Parent_Program_Term__c);
            }

            system.debug(app.Program_Term__r.Name);
            oxfordOrCambridge = app.Program_Term__r.Name.contains('Oxford') ? true : oxfordOrCambridge;
            oxfordOrCambridge = app.Program_Term__r.Name.contains('Cambridge') ? true : oxfordOrCambridge;
        }
        if(oxfordOrCambridge)
        {
            List<Program_Term__c> oxfordAndCambridge = [SELECT Id, Name FROM Program_Term__c WHERE Term__r.Display_Name__c =: term AND(Name LIKE '%Oxford%' OR Name LIKE '%Cambridge%') AND (NOT RecordTypeId IN: poRecordTypes)];
            for(Program_Term__c pt : oxfordAndCambridge)
            {
                hiddenPTIds.add(pt.Id);
            }
        }
        
        hiddenPTIds.addAll(getRestrictedProgramTermIds(studentUser.ContactId, country, term));
        Id standardPT = Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Standard Program Term').getRecordTypeId();
        
        Date todayPlus28 = Date.today().addDays(28);
        //ACARSON 10.15.2017 Changed query to limit Program Terms to only ones that have a start date 28 days in the future 
        //List<Program_Term__c> programTerms = [SELECT Id, Term__c, Display_Name__c, Program__r.Active__c FROM Program_Term__c WHERE Program__r.Host_Institution__r.Country__r.Name =: country AND Term__r.Display_Name__c =: term  AND Program__r.Category__c != 'Custom' AND (NOT Hidden__c = true) AND (NOT ID IN : hiddenPTIds) ORDER BY Name];
        //ACARSON 08.22.2018 Changed query to pull in child program terms
        //List<Program_Term__c> programTerms = [SELECT Id, Term__c, Display_Name__c, Program__r.Active__c
        List<Program_Term__c> programTerms = [SELECT Id, Term__c, Display_Name__c, Program__r.Active__c, RecordTypeId, (SELECT Id FROM Program_Terms__r WHERE Start_Date__c >=: todayPlus28 OR Start_Date__c = null) 
                    FROM Program_Term__c WHERE Program__r.Host_Institution__r.Country__r.Name =: country AND Term__r.Display_Name__c =: term  AND Program__r.Category__c != 'Custom'
                    AND (NOT Hidden__c = true) AND (NOT ID IN : hiddenPTIds) AND ((Start_Date__c >=: todayPlus28 OR Start_Date__c = null) AND (NOT RecordTypeId IN: poRecordTypes) AND Program__r.Active__c = true)];

        List<String> programTermNames = new List<String>();
        for(Program_Term__c programTerm : programTerms)
        {
            //ACARSON 08.22.2018 add criteria to pull out program terms where 
            //if(programTerm.Program__r.Active__c)
            if(programTerm.Program__r.Active__c && (programTerm.RecordTypeId == standardPT || programterm.Program_Terms__r.size() > 0))
            {
                programTermNames.add(programTerm.Display_Name__c);
            }
        }

        return programTermNames;
    }
    */
    /**
     * @description Obtains data for a particular program.
     * @return Map<String, String>
     */
    /* @RemoteAction
    public static Map<String, String> getProgramTermInfo(String programTermName)
    {
        String displayName = programTermName.unescapeHtml4();
        system.debug(displayName);
        Program_Term__c programTerm = [SELECT Id, Display_Name__c, Description__c, Description_Long__c, Program__r.Host_Institution__r.Name, Program__r.Host_Institution__r.Picture_URL__c, Program__r.Host_Institution__r.Description__c, Program__r.Host_Institution__r.Country__r.Name, Apply_URL__c FROM Program_Term__c WHERE Display_Name__c =: displayName];
        List<Program_Term__c> programOptions = [SELECT ID FROM Program_Term__c WHERE Parent_Program_Term__r.Display_Name__c =: displayName];

        Map<String, String> programTermData = new Map<String, String>();
        programTermData.put('programTermId', programTerm.Id);
        programTermData.put('displayName', programTerm.Display_Name__c);
        programTermData.put('description', programTerm.Description_Long__c == null ? programTerm.Description__c : programTerm.Description_Long__c);
        programTermData.put('hostInstitutionName', programTerm.Program__r.Host_Institution__r.Name);
        programTermData.put('pictureUrl', programTerm.Program__r.Host_Institution__r.Picture_URL__c);
        programTermData.put('hostInstitutionDescription', programTerm.Program__r.Host_Institution__r.Description__c);
        programTermData.put('country', programTerm.Program__r.Host_Institution__r.Country__r.Name);
        programTermData.put('noApply', programTerm.Apply_URL__c);        
        if (programOptions.size() > 0)
        {
            programTermData.put('hasOptions', 'true');          
        }
        else
        {
            programTermData.put('hasOptions', 'false');
        }

        return programTermData;
    } */
    
    /**
     * @description Obtains program option data
     * @return List<Program_Term__c>
     */
    /* @RemoteAction
    public static List<Program_Term__c> getProgramOptions(String programTermId)
    {
        return [SELECT Id, Name, Program_Option_Name__c, Description__c, Description_Long__c FROM Program_Term__c WHERE Parent_Program_Term__r.Id =: programTermId];     
    } */

    /**
     * @description Select a program for a student. The program-term field on the application is directed to this program-term, the application requirements are populated, and their data inserted into the application.
     * @return Boolean
     */
    /* @RemoteAction
    public static Boolean selectProgramTerm(String programTermId)
    {
        //String displayName = programTermName.unescapeHtml4();
        User studentUser = [SELECT Id, ContactId FROM User WHERE id =: userInfo.getUserId()];
        System.debug(LoggingLevel.WARN, studentUser.Id);
        Contact studentContact = [SELECT Id, Name, Active_Application__c, Compare_Name_to_Active_Application__c, Citizenship__c, Non_US_Citizenship__c, Home_Institution__r.Account__c FROM Contact WHERE Id =: studentUser.ContactId];
        Application__c activeApplication;
        if(studentContact.Active_Application__c != null)
        {
            activeApplication = [SELECT Id, Applicant__c, Previous_Application__c FROM Application__c WHERE Id =: studentContact.Active_Application__c];
        }
        else
        {
            activeApplication = studentBaseController.getActiveApplication(studentContact);
            studentContact.Active_Application__c = activeApplication.Id;
        }
        Program_Term__c programTerm = [SELECT Id, OwnerId, Program__c, Term__r.Section__c FROM Program_Term__c WHERE Id =: programTermId].get(0);
        activeApplication.Program_Term__c = programTerm.Id;
        activeApplication.Program_Option__c = null;
        activeApplication.Status__c = 'Program Selected';
        activeApplication.OwnerId = programTerm.OwnerId;        
        Database.SaveResult result = Database.update(activeApplication);

        // Generate Task for PA if student selects program that isn't authorized by their home institution
        if(result.isSuccess())
        {
            applicationService.checkProgramAuthorizations(new List<Application__c>{activeApplication});
        }
        try
        {
            studentContact.OwnerId = setContactOwner(studentContact).OwnerId;
        }
        catch (ListException e)
        {
            System.debug(LoggingLevel.WARN, 'Student does not have a primary application');
            studentContact.OwnerId = activeApplication.OwnerId;
        }
        
                
        if(activeApplication.Previous_Application__c != null)
        {
            portalRemotingMethods.cloneApplicationItems(activeApplication.Previous_Application__c, activeApplication);
        }
        else
        {
            applicationService.createPaWelcomeTask(new List<Application__c>{activeApplication});
        }
        //ACARSON Jul.09.2018
        //If the student is a non-u.s. citizen create a task for PA to review student citizenship
        if(studentContact.Citizenship__c == 'Non-U.S. Citizen'){
            Task t = new Task(WhoId = studentContact.Id, WhatId = activeApplication.Id, Subject='Review Student Citizenship', ActivityDate = Date.today().addDays(2), Description='Review Student Citizenship: ' + studentContact.Non_US_Citizenship__c);
            t.OwnerId = activeApplication.OwnerId;
            insert t;
        }
        Database.update(studentContact);
                

        return result.isSuccess();
    } */
    /**
     * @description Select a program with program option for a student. The program-term field on the application is directed to this program-term, the application requirements are populated, and their data inserted into the application.
     * @return Boolean
     */
    /*
    @RemoteAction
    public static Boolean selectProgramOption(String programOptionName, String programTermName)
    {
        String displayName = programOptionName.unescapeHtml4();
        String ptDisplayName = programTermName.unescapeHtml4();
        User studentUser = [SELECT Id, ContactId FROM User WHERE id =: userInfo.getUserId()];
        System.debug(LoggingLevel.WARN, studentUser.Id);        
        Contact studentContact = [SELECT Id, Active_Application__c, Compare_Name_to_Active_Application__c FROM Contact WHERE Id =: studentUser.ContactId];
        Application__c activeApplication;
        if(studentContact.Active_Application__c != null)
        {
            activeApplication = [SELECT Id FROM Application__c WHERE Id =: studentContact.Active_Application__c];
        }
        else
        {
            activeApplication = studentBaseController.getActiveApplication(studentContact);
            studentContact.Active_Application__c = activeApplication.Id;
        }
        Program_Option__c programOption = [SELECT Id, Program_Term__c, Program_Advisor__c FROM Program_Option__c WHERE Name =: displayName AND Program_Term__r.Display_Name__c =: ptDisplayName];
        //Program_Term__c programTerm = [SELECT Id, OwnerId FROM Program_Term__c WHERE Id =: programOption.Program_Term__c];

        activeApplication.Program_Option__c = programOption.Id;
        activeApplication.Program_Term__c = programOption.Program_Term__c;
        activeApplication.Status__c = 'Program Selected';
        activeApplication.OwnerId = programOption.Program_Advisor__c;
        Database.SaveResult result = Database.update(activeApplication);
        studentContact.OwnerId = setContactOwner(studentContact).OwnerId;        
        
        if(activeApplication.Previous_Application__c != null)
        {
            portalRemotingMethods.cloneApplicationItems(activeApplication.Previous_Application__c, activeApplication);
        }
        else
        {
            createPaWelcomeTask(activeApplication);
        }
        Database.update(studentContact);        

        return result.isSuccess();
    }
    */
    /**
     * @description [DEPRECIATED - MOVED TO APPLICATION SERVICE] Assigns a "Welcome Task" task to the application's owner
     */
    /* private static void createPaWelcomeTask(Application__c application)
    {
        //Create task for PA to review            
        Task welcomeCall = new Task(WhoId = application.Applicant__c, WhatId = application.Id, Subject = 'Welcome Email', ActivityDate = Date.today().addDays(2));
        welcomeCall.OwnerId = application.OwnerId;

        Contact student = [SELECT Name, Id, Classes_Required__c, Travel_Concerns__c, Travel_Topics__c FROM Contact WHERE Active_Application__c =: application.Id];
        welcomeCall.Description = '';
        if(student.Classes_Required__c == 'Yes')
        {
            welcomeCall.Description += (student.Name + ' requires specific classes to be able to study abroad. \n\n');
        }
        if(!String.isBlank(student.Travel_Concerns__c)){
            welcomeCall.Description += (student.Name + ' has the following concerns about traveling:\n' + student.Travel_Concerns__c +'\n\n');
        }
        if(!String.isBlank(student.Travel_Topics__c)){
            List<String> topics = student.Travel_Topics__c.split(';');
            welcomeCall.Description += (student.Name +' is interested in recieving information on the following topics: \n');
            for(String topic : topics){
                welcomeCall.Description += (topic + '\n');
            }
        }

        database.insert(welcomeCall);            
    }
    private static Application__c setContactOwner(Contact studentContact)
    {
        //Find the student's oldest application with primary designation
        
        Application__c oldestPrimaryApp = [SELECT Id, OwnerId FROM Application__c WHERE Applicant__c =: studentContact.Id AND Designation__c = 'Primary' ORDER BY CreatedDate DESC LIMIT 1].get(0);     
        
        return oldestPrimaryApp;
    }
    private static List<Id> getRestrictedProgramTermIds(Id contactId, String country, String term)
    {
        List<Id> hiddenPTIds = new List<Id>();
        Contact studentContact = [SELECT Id, Name, Home_Institution__c FROM Contact WHERE id =: contactId];
        Boolean hasRestrictedProgams = [SELECT Id FROM Restricted_Program__c WHERE Home_Institution__c =: studentContact.Home_Institution__c AND Program_Country__c =: country].size() > 0;
        if(hasRestrictedProgams)
        {   
            List<Restricted_Program__c> restrictedPrograms = [SELECT Id, Name, Home_Institution__c, Program__c, Program_Country__c, Allows_Other_Programs_in_Country__c FROM Restricted_Program__c WHERE Home_Institution__c =: studentContact.Home_Institution__c AND Program_Country__c =: country];
            Boolean allowsOtherPrograms = false;
            List<Id> AllowedPrograms = new List<Id>();
            for(Restricted_Program__c restrictedProgram: restrictedPrograms)
            {
                if(restrictedProgram.Allows_Other_Programs_in_Country__c || allowsOtherPrograms)
                {
                    allowsOtherPrograms = true;
                }
                AllowedPrograms.add(restrictedProgram.Program__c);              
            }
            if(!allowsOtherPrograms)
            {
                
                List<Program_Term__c> programsInCountry = [SELECT Id, Name, Program__c FROM Program_Term__c WHERE Term__r.Display_Name__c =: term AND Program__r.Host_Institution__r.Country__r.Name =: country AND (NOT Program__c IN: AllowedPrograms)];
                for(Program_Term__c pt : programsInCountry)
                {
                    for(Restricted_Program__c restrictedProgram: restrictedPrograms)
                    {
                        if(restrictedProgram.Program__c != pt.Program__c)
                        {
                            hiddenPTIds.add(pt.Id);
                        }
                    }
                }               
            }
            else
            {
                restrictedPrograms = [SELECT Id, Name, Home_Institution__c, Program__c, Program_Country__c, Allows_Other_Programs_in_Country__c FROM Restricted_Program__c WHERE Program_Country__c =: country AND Home_Institution__c !=: studentContact.Home_Institution__c];
                List<Id> restrictedIdList = new List<Id>();
                for(Restricted_Program__c restrictedProgram: restrictedPrograms)
                {
                    restrictedIdList.add(restrictedProgram.Program__c);
                }
                List<Program_Term__c> programsInCountry = [SELECT Id, Name, Program__c FROM Program_Term__c WHERE Term__r.Display_Name__c =: term AND Program__c IN: restrictedIdList];
                for(Program_Term__c pt : programsInCountry)
                {
                    hiddenPTIds.add(pt.Id);
                } 
            }   
        }
        else
        {
            List<Restricted_Program__c> restrictedPrograms = [SELECT Id, Name, Home_Institution__c, Program__c, Program_Country__c, Allows_Other_Programs_in_Country__c FROM Restricted_Program__c WHERE Program_Country__c =: country];
            List<Id> restrictedIdList = new List<Id>();
            for(Restricted_Program__c restrictedProgram: restrictedPrograms)
            {
                restrictedIdList.add(restrictedProgram.Program__c);
            }
            List<Program_Term__c> programsInCountry = [SELECT Id, Name, Program__c FROM Program_Term__c WHERE Term__r.Display_Name__c =: term AND Program__c IN: restrictedIdList];
            for(Program_Term__c pt : programsInCountry)
            {
                hiddenPTIds.add(pt.Id);
            } 
        }
        return hiddenPTIds;
    } */
}