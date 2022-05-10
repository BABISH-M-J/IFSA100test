/**
 * Controller class used to import custom student rosters from CSV file. Work has been done to replace this Visualforce Page with a Lightning Web Component.
 * @author Brock Barlow
 */
// ApexDoc updated 1/28/2021 Brock Barlow
public class CustomImportController 
{
    public Blob csvFileBody {get;set;}
    public string csvAsString {get;set;}
    public String[] csvFileLines {get;set;}
    public List<account> acclist {get;set;}
    public List<RowLine> rowLines {get;set;}
    List<Account> accounts {get;set;}
    List<Contact> contacts {get;set;}
    List<Application__c> apps {get;set;}
    List<User> users {get;set;}
    public Program_Term__c progTerm {get;set;}
    public Account homeInst {get;set;}
    public Boolean showSaveAccounts {get; set;}
    public Boolean showSaveContacts {get; set;}
    public Boolean showSaveApplications {get;set;}
    public Boolean showSaveUsers {get;set;}
    public Boolean showGetJobStatus {get;set;}
    public String jobStatus {get;set;}
    public Id appJobId {get;set;}
    public Map<String, RowLine> newRecords {get;set;}

	public CustomImportController()
    {
        csvFileLines = new String[]{};
    	acclist = new List<Account>(); 
        rowLines = new List<RowLine>();
        accounts = new List<Account>();
        contacts = new List<Contact>();
        apps = new List<Application__c>();
        users = new List<User>();
        showSaveAccounts = false;
        showSaveContacts  = false;
        showSaveApplications = false;
        showSaveUsers = false;
        showGetJobStatus = false;
        jobStatus = null;
        Id programTermId = Id.valueOf(ApexPages.currentPage().getParameters().get('programTermId'));
        progTerm = [SELECT Id, Name, Program__r.Category__c, Program__r.Custom_Program_Home_Instituiton_Account__c, Program__r.Student_Access_to_Portal__c, OwnerId FROM Program_Term__c WHERE Id =: programTermId];
        homeInst = [SELECT Id, Name, Institution__c FROM Account WHERE Id =: progTerm.Program__r.Custom_Program_Home_Instituiton_Account__c];        
  	}
  
  	public void importCSVFile(){
        this.rowLines = new List<RowLine>();
        // Read the CSV File
        try{
            csvAsString = csvFileBody.toString();
            csvFileLines = csvAsString.split('\n'); 
           
            //Read each line
            for(Integer i=1;i<csvFileLines.size();i++)
            {           
                // Create a RowLine for each line of the CSV file
                rowLines.add(new RowLine(csvFileLines[i], progTerm, homeInst));
            }
            showSaveAccounts = true;
        }
        catch (Exception e)
        {
            System.debug(e.getMessage());
            ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.severity.ERROR,'An error has occured while importing data. ' + e.getMessage());
            ApexPages.addMessage(errorMessage);
        }  
  	}
    public void SaveAccounts()
    {
        // Create a map so that we can link records together properly
        newRecords = new Map<String, RowLine>();
        // Create the account records
        for(RowLine row: rowLines)
        {
            newRecords.put(row.accountRecord.Name, row);
            accounts.add(row.accountRecord);
        }
        System.debug(LoggingLevel.INFO, 'Inserting Accounts');
        Database.insert(accounts);
        System.debug(LoggingLevel.INFO, 'Accounts Inserted: ' + accounts.size());
        ApexPages.Message accountMessge = new ApexPages.Message(ApexPages.severity.INFO,'Accounts Inserted: ' + accounts.size());
        ApexPages.addMessage(accountMessge);
        showSaveAccounts = false;
        showSaveContacts = true;
    }
    public void SaveContacts()
    {
        // Create the student contact records
        for(Account a: accounts)
        {
			newRecords.get(a.Name).accountRecord = a;
            newRecords.get(a.Name).contactRecord.AccountId = a.Id;
            system.debug(newRecords.get(a.Name).contactRecord);
            contacts.add(newRecords.get(a.Name).contactRecord);
        }
        System.debug(LoggingLevel.INFO, 'Inserting Contacts');
        Database.insert(contacts);
        System.debug(LoggingLevel.INFO, 'Contacts Inserted: ' + contacts.size());
        ApexPages.Message contactMessge =  new ApexPages.Message(ApexPages.severity.INFO,'Contacts Inserted: ' + contacts.size());
        ApexPages.addMessage(contactMessge);
        showSaveContacts = false;
        showSaveApplications = true;
    }
    public void SaveApplications()
    {
        Id profileId;
        if(progTerm.Program__r.Student_Access_to_Portal__c != 'None')
        {
            String profileName = progTerm.Program__r.Student_Access_to_Portal__c == 'Custom' ? 'IFSA Custom Student User' : 'IFSA Student User';
            profileId = [SELECT Id FROM Profile WHERE Name =: profileName].get(0).Id;
        }
        // Create the application and if required user records
        for(Contact c: contacts)
        {
			newRecords.get(c.FirstName + ' ' + c.LastName).contactRecord = c;
            newRecords.get(c.FirstName + ' ' + c.LastName).applicationRecord.Applicant__c = c.Id;
            newRecords.get(c.FirstName + ' ' + c.LastName).applicationRecord.Account__c = c.AccountId;
            newRecords.get(c.FirstName + ' ' + c.LastName).userRecord.ContactId = c.Id;
            newRecords.get(c.FirstName + ' ' + c.LastName).userRecord.ProfileId = profileId;
            apps.add(newRecords.get(c.FirstName + ' ' + c.LastName).applicationRecord);
            
            if(progTerm.Program__r.Student_Access_to_Portal__c != 'None')
            {
                users.add(newRecords.get(c.FirstName + ' ' + c.LastName).userRecord);
            }
        }
        System.debug(LoggingLevel.INFO, 'Inserting Applications');
        if(apps.size() < 20)
        {
            Database.insert(apps);
            System.debug(LoggingLevel.INFO, 'Applications Inserted: ' + apps.size());
            ApexPages.Message appMessge = new ApexPages.Message(ApexPages.severity.INFO,'Applications Inserted: ' + apps.size());
            ApexPages.addMessage(appMessge);
        }
        else
        {
            appJobId = sObjectBatchUpdater.batchUpdate(apps, 20, sObjectBatchUpdater.dmlTypes.dmlInsert);
            System.debug(LoggingLevel.INFO, 'Batch Inserting Applications: ' + apps.size());
            System.debug(LoggingLevel.INFO, 'Batch Job ID: ' + appJobId);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO,'Batch Inserting Applications: ' + apps.size()));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO,'Batch Job ID: ' + appJobId));
            showGetJobStatus = true;
        }
        
        showSaveApplications = false;
        showSaveUsers = users.size() > 0 && !showGetJobStatus;
    }
    public void GetJobStatus()
    {
        jobStatus = [SELECT Id, Status FROM AsyncApexJob WHERE Id =: appJobId].get(0).Status;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO,'Batch Job ID: ' + appJobId + ' Status: ' + jobStatus));
        if(jobStatus == 'Completed')
        {
            appJobId = null;
            showGetJobStatus = false;
            showSaveUsers = users.size() > 0;
        }
    }

    public void SaveUsers()
    {
        ApexPages.Message userMessage = null;
        
        System.debug(LoggingLevel.INFO, 'Inserting Users');
        Database.insert(users);
        System.debug(LoggingLevel.INFO, 'Users Inserted: ' + users.size());
        userMessage = new ApexPages.Message(ApexPages.severity.INFO,'Users Inserted: ' + users.size());
    
        ApexPages.addMessage(userMessage);
    }
    public class RowLine
    {
        //Constants
        private final List<String> columnNames = new List<String>{
            'Last Name',
            'First Name',
            'Prefered Name',
            'Middle Name',
            'Pronouns',
            'Gender',
            'Date of Birth',
            'Passport Number',
            'Passport Expiration Date',
            'Citizenship',
            'E-mail',
            'Cell Phone Number'
        };
        // Properties
        public String LastName {get;set;}
        public String FirstName {get;set;}
        public String PreferedName {get;set;}
        public String MiddleName {get;set;}
        public String Pronouns {get;set;}
        public String Gender {get;set;}
        public String DateOfBirth {get;set;}
        public String PassportNumber {get;set;}
        public String PassportExpiration {get;set;}
        public String Citizenship {get;set;}
        public String EmailAddress {get;set;}
        public String PhoneNumber {get;set;}
        
        public Account accountRecord {get;set;}
        public Application__c applicationRecord {get;set;}
        public Contact contactRecord {get;set;}
        public User userRecord {get;set;}
        private final Id accountRT = sObjectType.Account.getRecordTypeInfosByName().get('Student Account').getRecordTypeId();
        private final Id contactRT = sObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();

        // Constuctor
		Public RowLine(String RowData, Program_Term__c pt, Account hi)
        {   
            // Parse the CSV line
            string[] csvRecordData = RowData.split(',');
            system.debug(RowData);
            system.debug(csvRecordData);
            system.debug(csvRecordData.size());
            Integer counter = 0;
            // Verify the data being imported is good
            if(csvRecordData.size() < 12)
            {
                throw new RowLineException('The are not enough columns in on the row with the name ' + csvRecordData[0] + ', ' + csvRecordData[2]);
            }
            for(String cell: csvRecordData)
            {
                System.debug('Column Title: ' + columnNames[counter] + ' Column Index: ' + counter);
                System.debug('Cell Data:' + cell);
                
                System.debug(cell == '' && (columnNames[counter] == 'Last Name' || columnNames[counter] == 'First Name' || columnNames[counter] == 'Gender' || columnNames[counter] == 'Date of Birth' || columnNames[counter] == 'Cell Phone Number'));
                if(cell == '' && (columnNames[counter] == 'Last Name' || columnNames[counter] == 'First Name' || columnNames[counter] == 'Gender' || columnNames[counter] == 'Date of Birth' || columnNames[counter] == 'Cell Phone Number'))
                {
                    throw new RowLineException('Value: "'+ csvRecordData[counter] + '" in column: "' + columnNames[counter] + '" on the row with the name: "' + csvRecordData[0] + ' ' + csvRecordData[2] + '" is empty and is required. Please correct your file and try again');
                }
                counter = counter+1;
            }
            if(csvRecordData[5] != 'Male' && csvRecordData[5] != 'Female')
            {
                throw new RowLineException('Value: "'+ csvRecordData[4] + '" in column: "' + columnNames[4] + '" on the row with the name: "' + csvRecordData[0] + ' ' + csvRecordData[2] + '" is invalid. Please correct your file and try again');
            }
            
            // Assign row data to object properties
            this.LastName = csvRecordData[0];
            this.FirstName = csvRecordData[1];
            this.PreferedName = csvRecordData[2];
            this.MiddleName = csvRecordData[3];
            this.Pronouns = csvRecordData[4];
            this.Gender = csvRecordData[5];
            this.DateOfBirth = csvRecordData[6];
            this.PassportNumber = csvRecordData[7];
            this.PassportExpiration = csvRecordData[8];
            this.Citizenship = csvRecordData[9];
            this.EmailAddress = csvRecordData[10];
            this.PhoneNumber = csvRecordData[11];
            // Create Student Account Record for the row
            this.accountRecord = new Account(
                RecordTypeId = accountRT, 
                Name = this.FirstName + ' ' + this.LastName
                /* BillingStreet = this.MailingStreet,
                BillingCity = this.MailingCity,
                BillingPostalCode = this.MailingZip,
                BillingCountry = this.MailingCountry */
            );
            // Create Student Contact Record for the row
            try
            {
                this.contactRecord = new Contact(
                    RecordTypeId = contactRT,
                    FirstName = this.FirstName,
                    Middle_Name__c = this.MiddleName,
                    LastName = this.LastName,
                    Email = this.EmailAddress,
                    Phone = this.PhoneNumber,
                    Preferred_Pronouns__c = this.Pronouns,
                    /* MailingStreet = this.MailingStreet,
                    MailingCity = this.MailingCity,
                    MailingPostalCode = this.MailingZip,
                    MailingCountry = this.MailingCountry,*/
                    Passport_Country_of_Issuance__c = this.Citizenship, 
                    Passport_Expiration_Date__c = this.PassportExpiration != '' ? convertStringToDate(this.PassportExpiration, 'Passport Expiration Date') : null,
                    Passport_Number__c = this.PassportNumber,
                    Citizenship__c = this.Citizenship == 'United States' ? 'U.S. Citizen' : 'Non-U.S. Citizen',
                    Non_US_Citizenship__c = this.Citizenship != 'United States' ? this.Citizenship : null,
                    Sex__c = this.Gender,
                    Custom_No_Contact__c = pt.Program__r.Student_Access_to_Portal__c == 'none' ? true : false,
                    Created_for_Custom__c = pt.Program__r.Category__c == 'Custom' ? true : false,
                    Birthdate = convertStringToDate(this.DateOfBirth, 'Date of Birth'),
                    Home_Institution__c = hi.Institution__c,
                    OwnerId = pt.OwnerId
                );
            }
            catch(RowLineException ex)
            {
                throw new RowLineException('Invalid data for ' + this.FirstName + ' ' + this.LastName + '. ' + ex.getMessage());
            }
            // Create Application Record for the row
            this.applicationRecord = new Application__c(
                Name = this.accountRecord.Name + ' New Custom Application',
                Status__c =  pt.Program__r.Category__c == 'Custom' ? 'Accepted' : 'Program Selected',
                Program_Term__c = pt.Id,
                OwnerId = pt.OwnerId
            );
            // Create Student User Record for the row
            this.userRecord = new User(
                FirstName = this.FirstName,
                LastName = this.LastName,
                Email = this.EmailAddress,
                UserName = this.EmailAddress + '.ifsa',
                Alias = this.FirstName.subString(0, 1) + this.LastName.subString(0, this.LastName.length() < 4 ? this.LastName.length() : 4),
                TimeZoneSidKey = 'GMT',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'ISO-8859-1',
                LanguageLocaleKey = 'en_US'
            );
        }
        private Date convertStringToDate(String dateValue, String fieldName)
        {
            // Converts a date string in the formats "MM-DD-YYYY" and "MM/DD/YYYY" to an apex date object
            System.debug(dateValue);
            String dateSeparator = '';
            if(dateValue.contains('-'))
            {
                dateSeparator = '-';
            }
            else if(dateValue.contains('/'))
            {
                dateSeparator = '/';
            }
            else
            {
                throw new RowLineException(fieldName + ' is not a valid date, please correct your spreadsheet.');
            }
            String[] dateParts = dateValue.split(dateSeparator);
            String year = dateParts[2];
            String month = dateParts[0];
            String day = dateParts[1];
            String hour = '0';
            String minute = '0';
            String second = '0';
            String stringDate = year + '-' + month
            + '-' + day + ' ' + hour + ':' + 
            minute + ':' + second;
            Date myDate = date.valueOf(stringDate);
            return myDate;
        }
    }
    
    // Exception class that can be thrown by the controller by developer when necessary
    public class RowLineException extends Exception
    {
        
    }
}