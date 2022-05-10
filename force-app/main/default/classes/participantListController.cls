public with sharing class participantListController {

    // VARIABLES
    public Integer selectedYear {get;set;}
    public String selectedSection {get;set;}
    public Boolean hasRecords {get;set;}
    public Integer recordCount {get;set;}
    public Transient List<participantListViewModel> participants {get;set;}
    public Boolean exportStarted {get;set;}
    public String cvTitle {get;set;}
    public List<String> section = new List<String>();
    
    // METHODS
    public participantListController(){
    }

    // Get available years for selectedYear picklist
    public List<SelectOption> getYears(){
        // Get terms
        List<Term__c> terms = new List<Term__c>([SELECT Year__c FROM Term__c]);
        // Store all year values in new list
        List<Integer> listYears = new List<Integer>();
        for(Term__c t: terms){
            listYears.add(Integer.valueOf(t.Year__c));
        }
        // Convert to Set and back to List to dedupe year values, then sort
        Set<Integer> setYears = new Set<Integer>(listYears);
        List<Integer> years = new List<Integer>(setYears);
        years.sort();
        // Create an option for each year in setYears
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', 'Select Year'));
        for(Integer y: years){
            options.add(new SelectOption(String.valueOf(y), String.valueOf(y)));
        }
        return options;
    }

    // Query for apps and clean the data
    public void getParticipants(){
        // Clear previous page values
        clear();

        // Set Section variable
        if (selectedSection == 'Spring') {
            section = new List<String>{'Spring','Calendar Year'};
        } else if (selectedSection == 'Summer'){ 
            section = new List<String>{'Summer'};
        } else if (selectedSection == 'Fall') {
            section = new List<String>{'Fall','Academic Year','Calendar Year'};
        } else if (selectedSection == 'Winter'){ 
            section = new List<String>{'Winter'};
        }

        // Query for records and store in list. Two different paths based on selectedSection -- Spring requires different SOQL
        List<Application__c> apps = new List<Application__c>();
        if (selectedSection == 'Spring'){
            Integer springAYyear = selectedYear - 1;
            apps = [
                SELECT 
                    Applicant__r.Id,
                    Applicant__r.LastName, 
                    Applicant__r.FirstName,
                    Applicant__r.Middle_Name__c,
                    Applicant__r.Suffix__c, 
                    Applicant__r.Birthdate, 
                    Applicant__r.Sex__c,
                    Applicant__r.MailingStreet,
                    Applicant__r.MailingCity,
                    Applicant__r.MailingState,
                    Applicant__r.MailingPostalCode,
                    Applicant__r.MailingCountry,
                    Applicant__r.Phone,
                    Applicant__r.Home_Institution__r.Name,
                    Applicant__r.Home_Institution__r.Butler_Ex_Org_ID__c,
                    Program_Term__r.Program__r.Name,
                    Program_Term__r.Name,
                    Program_Term__r.Term__r.Section__c,
                    Program_Term__r.Term__r.Year__c
                FROM 
                    Application__c
                WHERE 
                    Status__c IN ('Accepted','Accepted (with Conditions)','On Site') AND
                    Designation__c = 'Primary' AND
                    Status_Contract_Signed__c != null AND
                    Applicant__r.Home_Institution__r.Name != 'Yuqapuca' AND
                    Program_Term__r.Program__r.Transcript__c IN ('Butler','Hybrid') AND
                    (
                        (Program_Term__r.Term__r.Section__c IN :section AND Program_Term__r.Term__r.Year__c = :selectedYear) OR
                        (Program_Term__r.Term__r.Section__c = 'Academic Year' AND Program_Term__r.Term__r.Year__c = :springAYyear)
                    )
                ORDER BY Program_Term__r.Program__r.Name, Applicant__r.Id
            ];
        } else {
            apps = [
                SELECT 
                    Applicant__r.Id,
                    Applicant__r.LastName, 
                    Applicant__r.FirstName,
                    Applicant__r.Middle_Name__c,
                    Applicant__r.Suffix__c, 
                    Applicant__r.Birthdate, 
                    Applicant__r.Sex__c,
                    Applicant__r.MailingStreet,
                    Applicant__r.MailingCity,
                    Applicant__r.MailingState,
                    Applicant__r.MailingPostalCode,
                    Applicant__r.MailingCountry,
                    Applicant__r.Phone,
                    Applicant__r.Home_Institution__r.Name,
                    Applicant__r.Home_Institution__r.Butler_Ex_Org_ID__c,
                    Program_Term__r.Program__r.Name,
                    Program_Term__r.Name,
                    Program_Term__r.Term__r.Section__c,
                    Program_Term__r.Term__r.Year__c
                FROM 
                    Application__c
                WHERE 
                    Status__c IN ('Accepted','Accepted (with Conditions)','On Site') AND
                    Designation__c = 'Primary' AND
                    Status_Contract_Signed__c != null AND
                    Applicant__r.Home_Institution__r.Name != 'Yuqapuca' AND
                    Program_Term__r.Program__r.Transcript__c IN ('Butler','Hybrid') AND
                    Program_Term__r.Term__r.Section__c IN :section AND
                    Program_Term__r.Term__r.Year__c = :selectedYear
                ORDER BY Program_Term__r.Program__r.Name, Applicant__r.Id
            ];
        }

        // Manipulate the data
        if (apps.size() > 0) {
            
            hasRecords = true;
            recordCount = apps.size();
            
            participants = new List<participantListViewModel>();

            for (Application__c a: apps) {

                participantListViewModel participant = new participantListViewModel();
                

                participant.id = a.Applicant__r.Id;
                participant.lastName = a.Applicant__r.LastName == null ? '-' : a.Applicant__r.LastName;
                participant.firstName = a.Applicant__r.FirstName == null ? '-' : a.Applicant__r.FirstName;
                participant.middleName = a.Applicant__r.Middle_Name__c == null ? '-' : a.Applicant__r.Middle_Name__c;
                if(a.Applicant__r.Suffix__c == null){
                    participant.suffix = '-';
                } else {
                    participant.suffix = a.Applicant__r.Suffix__c;
                    // Eliminate special characters
                    participant.suffix = participant.suffix.replace('.','');
                }
                participant.birthdate = String.valueof(a.Applicant__r.Birthdate) == null ? '-' : a.Applicant__r.Birthdate.format();
                participant.sex = a.Applicant__r.Sex__c == null ? '-' : a.Applicant__r.Sex__c;
                // Mailing Street 1 & 2
                if (a.Applicant__r.MailingStreet == null) {
                    participant.mailingStreet = '-';
                    participant.mailingStreet2 = '-';
                } else if (a.Applicant__r.MailingStreet.length() <= 50) {
                    participant.mailingStreet = a.Applicant__r.MailingStreet.left(50);
                    participant.mailingStreet2 = '-';
                } else {
                    participant.mailingStreet = a.Applicant__r.MailingStreet.left(50);
                    participant.mailingStreet2 = a.Applicant__r.MailingStreet.substring(50);
                }
                participant.mailingCity = a.Applicant__r.MailingCity == null ? '-' : a.Applicant__r.MailingCity;
                participant.mailingState = a.Applicant__r.MailingState == null ? '-' : a.Applicant__r.MailingState; // Convert to 2 character iso code
                participant.mailingPostalCode = a.Applicant__r.MailingPostalCode == null ? '-' : a.Applicant__r.MailingPostalCode;
                participant.mailingCountry = a.Applicant__r.MailingCountry == null ? '-' : a.Applicant__r.MailingCountry; // Convert to 3 character iso code
                // Phone
                // participant.phone = a.Applicant__r.Phone == null ? '-' : a.Applicant__r.Phone; 
                if(a.Applicant__r.Phone == null){
                    participant.phone = '-';
                } else {
                    participant.phone = a.Applicant__r.Phone;
                    // Eliminate special
                    String specialChars = '(|)|-| |';
                    for(integer i=0; i < specialChars.split('|').size(); i++) {
                        participant.phone = participant.phone.replace(specialChars.split('|')[i],'');
                    }
                }
                participant.homeInstitutionName = a.Applicant__r.Home_Institution__r.Name == null ? '-' : a.Applicant__r.Home_Institution__r.Name;
                participant.homeInstitutionCode = a.Applicant__r.Home_Institution__r.Butler_Ex_Org_ID__c == null ? '-' : a.Applicant__r.Home_Institution__r.Butler_Ex_Org_ID__c;
                participant.pName = a.Program_Term__r.Program__r.Name == null ? '-' : a.Program_Term__r.Program__r.Name;
                participant.ptName = a.Program_Term__r.Name == null ? '-' : a.Program_Term__r.Name;
                participant.ptSection = a.Program_Term__r.Term__r.Section__c == null ? '-' : selectedSection; // convert to spring, summer, fall
                participant.ptYear = String.valueOf(a.Program_Term__r.Term__r.Year__c) == null ? '-' : string.valueOf(selectedYear); // convert to appropriate year for AY and CY

                participants.add(participant);
            }
        }
    }

    // Create text file and save to Files
    public void export(){

        getParticipants();

        // Assemble blob
        cvTitle = 'Participant List - ' + selectedSection + ' ' + selectedYear;
        String body = '';
        for (ParticipantListViewModel p: participants) {
            body = body + 
                p.id + '\t' + 
                p.lastName + '\t' + 
                p.firstName + '\t' +
                p.middleName + '\t' +
                p.suffix + '\t' +
                p.birthdate + '\t' +
                p.sex + '\t' +
                p.mailingStreet + '\t' +
                p.mailingStreet2 + '\t' +
                p.mailingCity + '\t' +
                p.mailingState + '\t' +
                p.mailingCountry + '\t' +
                p.mailingPostalCode + '\t' +
                p.phone + '\t' +
                p.homeInstitutionName + '\t' +
                p.homeInstitutionCode + '\t' +
                p.pName + '\t' +
                p.ptSection + '\t' +
                p.ptYear + 
                '\n';
        }

        // Check to see if there is an existing document with the same name
        List<ContentDocument> cd = [SELECT id FROM ContentDocument WHERE title = :cvTitle LIMIT 1];

        // Set new ContentVersion values
        ContentVersion cv = new ContentVersion();
        cv.VersionData = Blob.valueOf(body);
        cv.Title = cvTitle;
        cv.PathOnClient = cvTitle + '.txt';
        
        // If a ContendDocument existed with the same name, assign that value to the ContentVersion to parent it
        if(!cd.isEmpty()){
            cv.ContentDocumentId = cd[0].id;
        }

        Id jobId = system.enqueueJob(new sObjectQueueableUpdater(new List<SObject>{cv}, true));
        exportStarted = true;
    }

    // This is run when the user submits a new search. This will reset the view so results tables and other features are hidden when not needed.
    public void clear(){
        // Clear previous page values
        section.clear();
        hasRecords = false;
        exportStarted = false;
    }
}