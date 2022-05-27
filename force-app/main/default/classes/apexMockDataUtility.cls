/**
 * Utility class which generates mock data. Will not enter it into the database, just in case someone calls this in live code.
 * @author Cameron Ames
 */
// ApexDoc updated 1/25/2021 Brock Barlow
@isTest
public without sharing class apexMockDataUtility
{
    
    private static Map<String,Map<String, RecordType>> recordTypeMap = new Map<String,Map<String,RecordType>>();
    private static Id studentUserProfileId;
    private static Id adminUserProfileId;
    private static Id advisorUserProfileId;
    private static Id paUserProfileId;
    private static UserRole userRole;
    private static Id payableAccount;
    private static Id receivableAccount;
    private static Id fdUserId;

    /**
     * Create an instance of IFSA Email Settings
     * @param name The name of the settings
     * @return an instance of IFSA Email Settings
     */
    public static IFSA_Email_Settings__c createEmailSettings(String name)
    {
        if(IFSA_Email_Settings__c.getInstance(name) != null)
        {
            return IFSA_Email_Settings__c.getInstance(name);
        }
        
        IFSA_Email_Settings__c settings = new IFSA_Email_Settings__c(
            Name = name,
            Description__c = 'Test Settings',
            New_Advisor_Alert_Enabled__c = true,
            New_Advisor_Alert_Recipients__c = 'admin@ifsa-butler.org;testaccount@ifsa-butler.org'
        );

        Database.insert(settings);
        return settings;
    }

    /**
     * Create an instance of IFSA Code Settings
     * @param name The name of the settings
     * @return an instance of IFSA Code Settings
     */
    public static IFSA_Code_Execution_Settings__c createCodeSettings(String name)
    {
        if(IFSA_Code_Execution_Settings__c.getInstance(name) != null)
        {
            return IFSA_Code_Execution_Settings__c.getInstance(name);
        }
        
        IFSA_Code_Execution_Settings__c settings = new IFSA_Code_Execution_Settings__c(
            Name = name,
            Description__c = 'Test Settings',
            Debug_Enabled__c = true
        );

        Database.insert(settings);
        return settings;
    }

    /**
     * Create an instance of IFSA Configuration Settings
     * @param name The name of the settings
     * @param codeSettings The value to use for the IFSA_Code_Settings__c field
     * @param emailSettings The value to use for the IFSA_Email_Settings__c field
     * @return an instance of IFSA Configuration Settings
     */
    public static IFSA_Configuration_Settings__c createConfigurationSettings(String name, String codeSettings, String emailSettings)
    {
        if(IFSA_Configuration_Settings__c.getInstance(name) != null)
        {
            return IFSA_Configuration_Settings__c.getInstance(name);
        }
        
        IFSA_Configuration_Settings__c settings = new IFSA_Configuration_Settings__c(
            Name = name,
            Description__c = 'Test Settings',
            IFSA_Code_Execution_Settings__c = codeSettings,
            IFSA_Email_Settings__c = emailSettings
        );

        Database.insert(settings);
        return settings;
    }

    /**
     * Create an instance of an Account
     * @param name The name of the Account
     * @param homeInstitutionId The Id of the affiliated home institution
     * @return an instance of an account
     */
    public static Account createAccount(String name, Id homeInstitutionId)
    {
        Account acct = new Account(
            Name = name,
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Home Institution').getRecordTypeId(),
            Institution__c = homeInstitutionId
        );      
        
        Database.insert(acct);
        return acct;
    }

    /**
     * Create an instance of an Account
     * @param name The name of the Account
     * @return an instance of an account
     */
    public static Account createAccount(String name)
    {
        Account acct = new Account(
            Name = name,
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Student Account').getRecordTypeId(),
            c2g__CODAAccountTradingCurrency__c = 'USD',
            c2g__CODAAccountsPayableControl__c = payableAccount,
            c2g__CODAAccountsReceivableControl__c = receivableAccount
        );
        Database.insert(acct);
        return acct;
    }
    /**
     * Create a list of accounts
     * @param name The name of the account
     * @param qty The number of accounts to create
     * @return list of accounts
     */
    public static List<Account> createAccounts(String name, Integer qty)
    {
        List<Account> accounts = new List<Account>();   
        Account acct = new Account(RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Student Account').getRecordTypeId());
        Account clone;
        for(Integer i=0; i<qty; i++)
        {
            clone = acct.clone(false, false, false, false);
            clone.Name = name + i;
            accounts.add(clone);
        }       
        Database.insert(accounts);      
        return accounts;
    }

    /**
     * Create an instance of a contact
     * @param name The last name of the contact
     * @param accountId The id of the account to associate this contact to. Can also be null.
     * @return an instance of a contact
     */
    public static Contact createContact(String name, Id accountId)
    {
        Contact ctc = new Contact(
            LastName = name,
            AccountId = accountId,
            Email = 'test' + Math.random() + '@ifsa-butler.org',
            RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId()
        );
        
        Database.insert(ctc);
        return ctc;
    }

    /**
     * Create a list of contacts
     * @param name The last name of the contact
     * @param accountId The id of the account to associate this contact to. Can also be null.
     * @return an instance of a contact
     */
    public static List<Contact> createContacts(String name, List<Account> accounts, List<Home_Institution__c> homeInstitutions)
    {       
        Id recordType = null;
        String type = '';
        if(homeInstitutions != null)
        {
            recordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
                //recordType = contactStudentRecordType != null ? contactStudentRecordType :[SELECT Id FROM RecordType WHERE sObjectType = 'Contact' AND Name = 'Student'].get(0).Id;
            type = 'Student';
        }
        else
        {
            recordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Advisor').getRecordTypeId();
            //recordType = contactAdvisorRecordType != null ? contactAdvisorRecordType :[SELECT Id FROM RecordType WHERE sObjectType = 'Contact' AND Name = 'Advisor'].get(0).Id;
            type = 'Advisor';           
        }

        List<Contact> contacts = new List<Contact>();    
        Integer i = 0;
        Contact ctc = new Contact(
            LastName = name,
            RecordTypeId = recordType
        );
        Contact cloned;
        
        for(Account acct: accounts)
        {
            cloned = ctc.clone(false, false, false, false);
            
            cloned.AccountId = acct.Id;
            cloned.Email = 'test' + Math.random() + '@ifsa-butler.org';
            if(type == 'Student')
            {
                cloned.FirstName = 'John' + Math.random();
                cloned.Home_Institution__c = homeInstitutions.get(i).Id;
                i = i == homeInstitutions.size() - 1 ? 0 : i + 1;
            }
            else
            {
                contacts.add(cloned);
                cloned = cloned.clone(false, false, false, false);
                cloned.Email = 'testSch' + Math.random() + '@ifsa-butler.org';
                cloned.Personal_Email__c = 'testPer' + Math.random() + '@ifsa-butler.org';
            }
            contacts.add(cloned);

        }       
        Database.insert(contacts);
        return contacts;
    }
    /**
     * Create an instance of a home institution
     * @param name The name of the home institution
     * @return an instance of a home institution
     */
    public static Home_Institution__c createHomeInstitution(String name, String countryId)
    {
        Home_Institution__c homeInstitution = new Home_Institution__c(
            Name = name,
            Country__c = countryId,
            Field_Director__c = fdUserId
        );
        
        Database.insert(homeInstitution);
        return homeInstitution;
    }
    /**
     * Creates multiple instances of Home Institutions
     * @param name The name of the home institution
     * @param qty The number of records to create
     * @param countryId The Id of the country the records belong to
     * @return List<Home_Institution__c> the new created records
     */
    public static List<Home_Institution__c> createHomeInstitution(String name, Integer qty, String countryId)
    {
        List<Home_Institution__c> hts = new List<Home_Institution__c>();
        for(Integer i = 0; i < qty; i++)
        {
            hts.add(new Home_Institution__c(
                Name = name + ' ' + i,
                Country__c = countryId,
                Field_Director__c = fdUserId
            ));
        }
        database.insert(hts);
        return hts;
    }

    /**
     * Create an instance of a guardian
     * @param studentId The id of the student    
     * @return an instance of a (guardian) contact
     */
    public static Contact createGuardian(Id studentId)
    {
        return apexMockDataUtility.createGuardian(studentId, false);        
    }
    /**
     * Create an instance of a guardian
     * @param studentId The id of the student
     * @param isParent Is a parent contact
     * @return an instance of a (guardian) contact
     */  
    public static Contact createGuardian(Id studentId, Boolean isParent)
    {
        Contact ctc = new Contact(
            LastName = 'Guardian',
            Student__c = studentId,
            Email = 'test' + Math.random() + '@ifsa-butler.org'
        );      

        ctc.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Other').getRecordTypeId();
        Database.insert(ctc);
        return ctc;
    }

    /**
     * Create an instance of a student user
     * @param contactId The Id of the cooresponding contact. Will throw an exception if this isn't a portal user.
     * @return an instance of a user
     */
    public static User createUser(Id contactId)
    {
        Integer rand = Math.round(Math.random()*999);
        String orgId = userInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        
        User testUser = new User(
            FirstName = 'Unit',
            LastName = 'Test',
            email = 'ifsa' + uniqueName + '@test' + orgId + '.org.test',
            Username = 'ifsa' + uniqueName + '@test' + orgId + '.org.test.ifsa',
            Alias = uniqueName.substring(18, 23),
            CommunityNickname = uniqueName,
            UserRole = userRole != null ? userRole : [SELECT Id FROM Userrole WHERE Name =: 'President'].get(0),
            ProfileId = studentUserProfileId != null ? studentUserProfileId : [SELECT Id FROM Profile WHERE Name =: 'IFSA Student User'].get(0).Id,
            contactId = contactId,
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            UserPermissionsMobileUser = false,
            Email_Confirmed_For_CHART__c = true
        );
        return (testUser);
    }

    /**
     * Create an instance of a system administrator
     * @return an instance of a sys admin
     */
    public static User createSysAdmin()
    {
        Integer rand = Math.round(Math.random()*999);
        String orgId = userInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        
        User testUser = new User(
            FirstName = 'Unit',
            LastName = 'Test',
            email = 'ifsa' + uniqueName + '@test' + orgId + '.org.test.ifsa',
            Username = 'ifsa' + uniqueName + '@test' + orgId + '.org.test.ifsa',
            Alias = uniqueName.substring(18, 23),
            CommunityNickname = uniqueName,
            UserRole = userRole != null ? userRole : [SELECT Id FROM Userrole WHERE Name =: 'President'],
            ProfileId = adminUserProfileId != null ? adminUserProfileId : [SELECT Id FROM Profile WHERE Name =: 'System Administrator'].Id,
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            UserPermissionsMobileUser = false
        );
        
        return testUser;
    }

    /**
     * Create an instance of an application
     * @param contactId The Id of the cooresponding contact.
     * @return an instance of an application
     */
    public static Application__c createApplication(Id contactId)
    {
        Application__c application = new Application__c(
            Name = 'Unit Test Application',
            Status__c = 'Registered',
            Applicant__c = contactId
        );
        Database.insert(application);
        return application;
    }
    /**
     * Create mulitiple instances of applications
     * @param studentContacts A list of Contact
     * @param programTerms A list of Program_Term__c
     * @param programOptions A list of Program_Term__c
     * @param homeInstitutionAdvisor The home institution advisor for the applicaitons
     * @param status A list of String
     * @param dates A list of Date
     * @param designation A list of String
     * @return List<Application__c> The generate applications
     */
    public static List<Application__c> createApplications(List<Contact> studentContacts, List<Program_Term__c> programTerms, List<Program_Term__c> programOptions, Id homeInstitutionAdvisor, List<String> status, List<Date> dates, List<String> designation)
    {
        List<Application__c> applications = new List<Application__c>();
        Integer counter = 0;
        Application__c app = new Application__c(
            Name = 'Unit Test Application',
            Home_Institution_Advisor__c = homeInstitutionAdvisor
        );
        Application__c cloned;
        for(Contact ctc: studentContacts)
        {
            cloned = app.clone(false, false, false, false);
            cloned.Status__c = status.get(counter);
            cloned.Designation__c = designation.get(counter);
            cloned.Applicant__c = ctc.Id;
            cloned.Last_Application_Update__c = dates.get(counter);
            
            if(!programOptions.isEmpty() && programOptions.get(counter) != null)
            {
                cloned.Program_Term__c = programOptions.get(counter).Id;
            }
            else
            {
                cloned.Program_Term__c = programTerms.get(counter).Id;
            }
            
            applications.add(cloned);
            counter = counter+1;
            system.debug(cloned.Program_Term__c);
        }
        Database.insert(applications);
        return applications;
    }
    /**
     * Create an instance of a program term. This will insert the record during the method
     * @param programId The Id of the program
     * @param termId The Id of the term
     * @return an instance of a program term
     */
    public static Program_Term__c createProgramTerm(Program__c program, Term__c term)
    {
        return createProgramTerm(program, term, true);
    }
    /**
     * Create an instance of a program term. 
     * @param programId The Id of the program
     * @param termId The Id of the term
     * @param doInsert If true, the record will be inserted during the method, if false, the record will not be inserted into the database
     * @return an instance of a program term
     */
    public static Program_Term__c createProgramTerm(Program__c program, Term__c term, Boolean doInsert)
    {
        Program_Term__c programTerm = new Program_Term__c(
            Name = program.Name + ' ' + term.Name,
            RecordTypeId = Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Standard Program Term').getRecordTypeId(),
            Country__c = program.Country__c,
            Program__c = program.Id,
            Term__c = term.Id,
            Start_Date__c = Date.today().addDays(-1),
            End_Date__c = Date.today().addDays(30),
            Application_Deadline__c = date.Today().addMonths(4)
        );
        if(doInsert)
        {
            Database.insert(programTerm);
        }
        return programTerm;
    }
    /**
     * Create muliple Program_Term__c records. 
     * @param programs A list of Program__c to create Program_Term__c records for
     * @param term A Term__c record
     * @param owner A user to be the owner of the new created Program_Term__c records
     * @return List<Program_Term__c> New Program_Term__c records
     */
    public static List<Program_Term__c> createProgramTerms(List<Program__c> programs, Term__c term, User owner)
    {
        Integer counter = 0;
        List<Program_Term__c> programTerms = new List<Program_Term__c>();
        for(Program__c program: programs)
        {
            programTerms.add(new Program_Term__c(
                OwnerId = owner.Id,
                RecordTypeId = Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Standard Program Term').getRecordTypeId(),
                Name = program.Name + ' ' + term.Name,
                Program__c = program.Id,
                Country__c = program.Country__c,
                Term__c = term.Id,
                Start_Date__c = Date.today().addDays(90),
                End_Date__c = Date.today().addDays(120),
                Application_Deadline__c = date.Today().addMonths(4 + counter)
            ));
            counter = counter++;
        }
        Database.insert(programTerms);
        return programTerms;
    }
    
    /**
     * Create an instance of a program option.
     * @param programId The Id of the program
     * @param termId The Id of the term
     * @return an instance of a program term
     */
    public static Program_Term__c createProgramOption(Program_Term__c programTerm)
    {
        Program_Term__c programOption = new Program_Term__c(
            RecordTypeId = Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Program Option without Dates').getRecordTypeId(),
            Name = 'Test Option',
            Parent_Program_Term__c = programTerm.Id,
            Country__c = programTerm.Country__c,
            OwnerId = programTerm.OwnerId
        );
        programTerm.RecordTypeId = Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Parent Program Term with Dates').getRecordTypeId();
        
        Database.update(programTerm);
        return programOption;
    }

    /**
     * Create an instance of a program with predfined name.
     * @param hostInstitutionId The Host institution to which this program belongs.
     * @return an instance of a program
     */
    public static Program__c createProgram(Host_Institution__c hostInstitution)
    {       
        return apexMockDataUtility.createProgram(hostInstitution, 'Test');
    }

    /**
     * Create an instance of a program with a name set at runtime.
     * @param hostInstitutionId The Host institution to which this program belongs.
     * @return an instance of a program
     */
    public static Program__c createProgram(Host_Institution__c hostInstitution, String name)
    {
        Program__c program = new Program__c(
            Name = name,
            Active__c = true,
            Category__c = 'Catalog',
            Country__c = hostInstitution.Country__c,
            Host_Institution__c = hostInstitution.Id,
            Available_Sections__c = 'Spring;Fall'
        );
                
        Database.insert(program);
        return program;
    }

    
    /**
     * Create an instance of a program with predfined name.
     * @param hostInstitutionId The Host institution to which this program belongs.
     * @return an instance of a program
     */
    public static Program__c createProgram(Id hostInstitutionId)
    {       
        return apexMockDataUtility.createProgram(hostInstitutionId, 'Test');
    }
    
    /**
     * Create an instance of a program with a name set at runtime.
     * @param hostInstitutionId The Host institution to which this program belongs.
     * @return an instance of a program
     */
    public static Program__c createProgram(Id hostInstitutionId, String name)
    {
        return createProgram(hostInstitutionId, name, 'Catalog');
    }

    /**
     * @description Create an instance of a program with a name set at runtime.
     * @param hostInstitutionId The Host institution to which this program belongs.
     * @return an instance of a program
     */
    public static Program__c createProgram(Id hostInstitutionId, String name, String category)
    {
        Host_Institution__c hostInstitution = [SELECT Id, Country__c FROM Host_Institution__c WHERE Id =: hostInstitutionId];
        Program__c program = new Program__c(
            Name = name,
            Active__c = true,
            Category__c = category,
            Host_Institution__c = hostInstitution.Id,
            Country__c = hostInstitution.Country__c
        );
        if(category == 'Custom')
        {
            program.Custom_Program_Home_Instituiton_Account__c = [SELECT Id FROM Account WHERE RecordType.Name = 'Home Institution' LIMIT 1].get(0).Id;
        }
        
        Database.insert(program);
        return program;
    }
    /**
     * Create an instance of a program with a name set at runtime.
     * @param hostInstitutionId The Host institution to which this program belongs.
     * @return an instance of a program
    */
    public static List<Program__c> createPrograms(Host_Institution__c hostInstitution, List<String> names, Id academicAffiarsUser)
    {
        List<Program__c> programs = new List<Program__c>();
        for(String name: names)
        {
            programs.add(new Program__c(
                Name = name,
                Active__c = true,
                Category__c = 'Catalog',
                Non_Refundable_Advance_Deposit__c = 500,
                Host_Institution__c = hostInstitution.Id,
                Country__c = hostInstitution.Country__c
            ));
        }

        Database.insert(programs);
        return programs;
    }


    /**
     * Create an instance of a term with predefined Section and Year.
     * @return an instance of a term
     */
    public static Term__c createTerm()
    {       
        return apexMockDataUtility.createTerm('Spring', Date.today().year());
    }

    /**
     * Create an instance of a term. Allows for greater customization than the simpler method.
     * @param Section The section option for the term.
     * @param Year The year of the term.
     * @return an instance of a term
     */
    public static Term__c createTerm(String section, Decimal year)
    {
        Term__c term = new Term__c(
            Name = 'Test',
            Section__c = section,
            Year__c = year
        );
        
        Database.insert(term);
        return term;
    }

    /**
     * Create mulitple Term__c records.
     * @param sections A List of section names
     * @param Year The year of the term.
     * @return List<Term__c> The newly created Term__c records
     */
    public static List<Term__c> createTerms(List<String> sections, Decimal year)
    {
        List<Term__c> terms = new List<Term__c>();
        for(String section: sections)
        {
            terms.add(new Term__c(
                Name = 'Test',
                Section__c = section,
                Year__c = year
            ));
        }
        Database.insert(terms);
        return terms;
    }

    /**
     * Create an instance of a country.
     * @return an instance of a country.
     */
    public static Country__c createLocalCountry(Id region)
    {
        Country__c country = new Country__c(
            Name = 'United States',
            Region__c = region,
            Active__c = true,
            Country_Code__c = 'USA'
        );

        Database.insert(country);
        return country;
    }

    /**
     * Create an instance of a country.
     * @return an instance of a country.
     */
    public static Country__c createCountry(Id region)
    {
        Country__c country = new Country__c(
            Name = 'England',
            Region__c = region,
            Active__c = true,
            Country_Code__c = 'GB',
            Regional_Director__c = fdUserId
        );
        
        Database.insert(country);
        return country;
    }

    /**
     * Create an instance of a host institution.
     * @param countryId The Id of the country in which this host institution is.
     * @return an instance of a host institution.
     */
    public static Host_Institution__c createHostInstitution(Id countryId)
    {
        Host_Institution__c hostInstitution = new Host_Institution__c(
            Name = 'Unit Test University',
            Country__c = countryId
        );

        Database.insert(hostInstitution);
        return hostInstitution;
    }
    /**
     * Create a list of a host institutions.
     * @param countryId The Id of the country in which this host institution is.
     * @param qty The number of host institutions to create.
     * @return a list of a host institutions.
     */
    public static List<Host_Institution__c> createHostInstitutions(Id countryId, Integer qty)
    {
        List<Host_Institution__c> hosts = new List<Host_Institution__c>();
        Host_Institution__c host = new Host_Institution__c(
            Name = 'Unit Test University',
            Country__c = countryId
        );
        Host_Institution__c cloned;
        for(Integer i=0; i<qty;i++)
        {
            cloned = host.clone(false, false, false, false);
            cloned.Name = cloned.Name + 'i';
            hosts.add(cloned);
        }

        Database.insert(hosts);
        return hosts;
    }

    /**
     * Create an instance of an application requirement.
     * @param countryId The Id of the program term that this app req belongs to.
     * @return an instance of an application requirement.
     */
    public static Application_Requirement__c createApplicationRequirement(Id programTermId)
    {
        Application_Requirement__c appReq = new Application_Requirement__c(
            Name = 'Unit Test',
            //Do 1 because of academic/personal statement,
            RecordTypeId = Schema.SObjectType.Application_Requirement__c.getRecordTypeInfosByName().get('Academic/Personal Statement').getRecordTypeId(),
            Phase__c = 'Pre-Admit',
            Program_Term__c = programTermId
        );
        
        Database.insert(appReq);
        return appReq;
    }
    
    /**
     * Creates an instance of a host course.
     * @return the instance of the course.
     */
    public static Course__c createHostCourse(Id hostInstitutionId, Butler_Department_Code__c deptCode, Id programId)
    {
        Course__c course = new Course__c(
            RecordTypeId = Schema.SObjectType.Course__c.getRecordTypeInfosByName().get('Host Institution').getRecordTypeId(),
            Name = 'Test Course',
            Course_Title_2__c = 'Test Course',
            Butler_Department_Code__c = deptCode.Id,
            Host_Institution__c = hostInstitutionId,
            Is_Top_25_Fall__c = true,
            Is_Top_25_Spring__c = true,
            Is_Top_25_Summer__c = true,
            Host_Credits__c = 15,
            US_Terms__c = 'Spring;Fall;Summer'
        );
        
        Database.insert(course);
        if(programId != null)
        {
            Program_Course__c programCourse = new Program_Course__c(Course__c = course.Id, Program__c = programId);

            Database.insert(programCourse);
        }
        return course;
    }

    /**
     * Creates an instance of a host course.
     * @return the instance of the course.
     */
    public static Course__c createHostCourse(Id hostInstitutionId, Butler_Department_Code__c deptCode)
    {
        return apexMockDataUtility.createHostCourse(hostInstitutionId, deptCode, null);
    }
    /**
     * Creates an instance of a host course.
     * @return the instance of the course.
     */
    public static Course__c createHostCourse()
    {
        return apexMockDataUtility.createHostCourse(null, null, null);
    }
    
    /**
     * Creates an instance of a host course.
     * @return the instance of the course.
     */
    public static List<Course__c> createParentAndChildCourses()
    {
        List<Course__c> courses = new List<Course__c>();
        Course__c course = new Course__c(
            RecordTypeId = Schema.SObjectType.Course__c.getRecordTypeInfosByName().get('Host Institution').getRecordTypeId(),
            Name = 'Parent Course',
            Course_Title_2__c = 'Parent Course',
            //Course_Code__c = deptCode.Id,
            //Host_Institution__c = hostInstitutionId,
            Is_Top_25_Fall__c = true,
            Is_Top_25_Spring__c = true,
            Is_Top_25_Summer__c = true,
            Type__c = 'Generic'
        );
        Database.insert(course);
        for (Integer x = 1 ; x < 4 ; x++) {
            Course__c crs = new Course__c(
            RecordTypeId = Schema.SObjectType.Course__c.getRecordTypeInfosByName().get('Host Institution').getRecordTypeId(),
            Name = 'Child Course ' + x,
            Course_Title_2__c = 'Child Course ' + x,
            //Course_Code__c = deptCode.Id,
            //Host_Institution__c = hostInstitutionId,
            Is_Top_25_Fall__c = true,
            Is_Top_25_Spring__c = true,
            Is_Top_25_Summer__c = true,
            Type__c = 'Standard',
            Parent_Generic_Course__c = course.Id
        );
        courses.add(crs);
        }
        System.debug('PandC courses added are: ' + courses);
        Database.insert(courses);
        /*if(programId != null)
        {
            Program_Course__c programCourse = new Program_Course__c(Course__c = course.Id, Program__c = programId);

            Database.insert(programCourse);
        }*/
        return courses;
    }


    /**
     * creates an instance of a course registration.
     * @param courseId The id of the course.
     * @param applicationId The Id of the application.
     * @return the instance of the course registration.
     */
    public static Course_Registration__c createCourseRegistration(Id courseId, Id applicationId, Butler_Department_Code__c deptCode)
    {

        Course_Registration__c courseReg = new Course_Registration__c(
            Application__c = applicationId,
            Course__c = courseId,
            Course_Code__c = 'ASD',
            Host_Credits__c = 1,
            Butler_Department_Code__c = deptCode.Id,
            Instructor_First_Name__c = 'Test',
            Instructor_Last_Name__c = 'Professor',
            Name = 'Intro to testing',
            Course_Title__c = 'Intro to testing',
            US_Semester_Credit_Hours__c = 2
        );

        Database.insert(courseReg);
        return courseReg;
    }
    
    /**
     * Creates an instance of a home course.
     * @return the instance of the course.
     */
    public static Course__c createHomeCourse()
    {
        List<Account> accounts = [SELECT Id FROM Account WHERE RecordType.Name = 'Home Institution Account' LIMIT 1];
        Course__c course = new Course__c(
            RecordTypeId = Schema.SObjectType.Course__c.getRecordTypeInfosByName().get('Home Institution').getRecordTypeId(),
            Name = 'Test Course',
            Course_Code__c = 'ASDF'
        );
        if(!accounts.isEmpty())
        {
            course.Home_Institution_Account__c = accounts.get(0).Id;
        }
        Database.insert(course);
        return course;
    }
    /**
     * Creates an instance of Housing_Option__c
     * @return Housing_Option__c an instance of a Housing_Option__c
     */
    public static Housing_Option__c createHousingOption()
    {
        Housing_Option__c housingOption = new Housing_Option__c(
            Name = 'Test',
            Display_Name__c = 'Testa',
            Description__c = 'this is a test'
        );
        
        Database.insert(housingOption);
        return housingOption;
    }
    /**
     * Creates an instance of Housing_Assignment__c. This record is not inserted into the database in this method.
     * @param housingOption The Housing_Option__c this Housing_Assignment__c is related to
     * @param country The Country__c this Housing_Assignment__c is related to.
     * @return Housing_Assignment__c an instance of Housing_Assignment__c
     */
    public static Housing_Assignment__c createHousingAssignment(Housing_Option__c housingOption, Country__c country)
    {
        Housing_Assignment__c housingAssignment = new Housing_Assignment__c(
            Name = 'Test',
            Display_Name__c = 'Test Housing Assignment',
            Description__c = 'this is a test',
            Country__c = country.Id,
            Dependent_Locality__c = 'Test_State',
            Locality__c = 'Test_City',
            Cell_Phone__c = '1234567890',
            Email__c = 'testemail@text.com',
            Housing_Option__c = housingOption.Id,
            Landline__c = '1234567981',
            Street_1__c = '123 Test St.',
            Street_2__c = 'Apt C',
            Zip_Code__c = '98765'
        );
        
        //Database.insert(housingAssignment);
        return housingAssignment;
    }
    
    /**
     * Creates an instance of a recommendation.
     * @param appItemId The Id of the application item to whcih this recommendation belongs.
     * @return the instance of the recommendation.
     */
    public static Recommendation__c createRecommendation(Id appItemId)
    {
        Recommendation__c recommendation = new Recommendation__c(
            Name = 'Test',
            Application_Item__c = appItemId,
            Status__c = 'Incomplete',
            Email_Address__c = 'asdf@ifsa-butler.net',
            Recommender_Name__c = 'Test Person'
        );

        Database.insert(recommendation);
        return recommendation;
    }
    
    /**
     * Creates an instance of an application item.
     * @param appItemId The Id of the application item to whcih this item belongs.
     * @return the instance of the application item.
     */
    public static Application_Item__c createApplicationItem(Id applicationId)
    {
        Application_Item__c applicationItem = new Application_Item__c(
            Name = 'Test item',
            Directions__c = 'asdf',
            RecordTypeId = Schema.SObjectType.Application_Item__c.getRecordTypeInfosByName().get('Academic/Personal Statement').getRecordTypeId(),
            Application__c = applicationId,
            Phase__c = 'Pre-Admit'
        );
        
        Database.insert(applicationItem);
        return applicationItem;
    }
    
    /**
     * Creates an instance of an application line item.
     * @param appItemId The Id of the application item to whcih this item belongs.
     * @return the instance of the application line item.
     */
    public static Application_Line_Item__c createApplicationLineItem(Id applicationId)
    {
        Application_Line_Item__c applicationItem = new Application_Line_Item__c(
            Name = 'Test item',
            Application__c = applicationId,
            Charge__c = 5
        );
                
        Database.insert(applicationItem);
        return applicationItem;
    }
    
    /**
     * creates an instance of and application item.
     * @param applicationId THe Id of the application.
     * @param recordTypeId The recordType of the application item.
     * @return the instance of a program approval.
     */
    public static Application_Item__c createApplicationItem(Id applicationId, Id recordTypeId)
    {
        Application_Item__c applicationItem = new Application_Item__c(
            Name = 'Test item',
            Directions__c = 'asdf',
            RecordTypeId = recordTypeId,
            Application__c = applicationId,
            Phase__c = 'Pre-Admit'
        );
        
        Database.insert(applicationItem);
        return applicationItem;
    }
    
    /**
     * Creates Application_Item__c for an application
     * @param applicationId The application the new Application_Item__c records will relate to.
     * @param recordTypes The different record types of Application_Item__c to create.
     * @return List<Application_Item__c> the created Application_Item__c records
     */
    public static List<Application_Item__c> createListApplicationItem(Id applicationId, List<Schema.RecordTypeInfo> recordTypes)
    {
        Integer phase = 1;
        List<Application_Item__c> appItems = new List<Application_Item__c>();
        Application_Item__c applicationItem = new Application_Item__c( Directions__c = 'asdf',Application__c = applicationId);
        Application_Item__c cloned;

        for(Schema.RecordTypeInfo rt: recordTypes)
        {
            cloned = applicationItem.clone(false, false, false, false);
            String rtName = rt.getName();
            if(rtName == 'No Action')
            {
                cloned.Name = 'Transcript';
            }
            else
            {
                cloned.Name = rtName;
            }
            if(rtName == 'Passport Copy')
            {
                cloned.Passport_In_Renewal__c = true;
            }               
            cloned.RecordTypeId = rt.getRecordTypeId();
            if(phase == 1)
            {
                cloned.Phase__c = 'Pre-Admit';
                phase = 2;
            }            
            else if(phase == 2)
            {
                cloned.Phase__c = 'Pre-Acceptance';
                phase = 3;
            }
            else if(phase == 3)
            {
                cloned.Phase__c = 'Post-Acceptance';
                phase = 1;
            }
            else if(cloned.Name == 'Program Approval')
            {
                cloned.Phase__c = 'Pre-Admit';
                phase = 2;
            }
            if(rtName != 'Master')
                appItems.add(cloned);   
        }
        
        //Database.insert(appItems);
        return appItems;
    }

    /**
     * Creates an instance of a portal advisor
     * @param contactId The Id of the contact to associate this user to.
     * @return the instance of the portal advisor.
     */
    public static User createAdvisor(Id contactId)
    {
        Integer rand = Math.round(Math.random()*999);
        String orgId = userInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        
        User testUser = new User(
            FirstName = 'Unit',
            LastName = 'Test',
            email = uniqueName + '@test' + orgId + '.org.test',
            Username = uniqueName + '@test' + orgId + '.org.test.ifsa',
            Alias = uniqueName.substring(18, 23),
            CommunityNickname = uniqueName,
            ProfileId = advisorUserProfileId != null ? advisorUserProfileId : [SELECT Id FROM Profile WHERE Name =: 'IFSA Advisor User'].Id,
            contactId = contactId,
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            UserPermissionsMobileUser = false
        );
        return testUser;
    }
    
    /**
     * Creates an instance of a program advisor
     * @return the instance of the program advisor.
     */
    public static User createProgramAdvisor()
    {
        Integer rand = Math.round(Math.random()*999);
        String orgId = userInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        
        User testUser = new User(
            FirstName = 'Unit',
            LastName = 'Test',
            email = uniqueName + '@test' + orgId + '.org.test',
            Username = uniqueName + '@test' + orgId + '.org.test',
            CommunityNickname = uniqueName,
            Alias = uniqueName.substring(18, 23),
            UserRole = userRole != null ? userRole : [SELECT Id FROM Userrole WHERE Name =: 'President'],
            ProfileId = paUserProfileId != null ? paUserProfileId : [SELECT Id FROM Profile WHERE Name =: 'IFSA Program Advisor'].Id,
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            UserPermissionsMobileUser = false
        );
        return testUser;
    }

    /**
     * Creates Billing_Arrangement__c records. These records are not inserted into the database in this method.
     * @param programs The programs to create Billing_Arrangement__c records for
     * @param homeInstitutions The accounts to create Billing_Arrangement__c records for
     * @return List<Billing_Arrangement__c> The new Billing_Arrangement__c records
     */
    public static List<Billing_Arrangement__c> createBillingArrangements(List<Program__c> programs, List<Account> homeInstitutions)
    {
        Boolean paysTuition = true;
        List<Billing_Arrangement__c> billingArrangements = new List<Billing_Arrangement__c>();
        Billing_Arrangement__c ba = new Billing_Arrangement__c(Direct_Bill__c = true, Pays_Tuition__c = paysTuition, Pays_Accomodation__c = paysTuition,
            Pays_Deposit__c = paysTuition, Term__c = 'Spring; Summer; Fall; Calendar Year; Academic Year;', Discount_Amount__c = 750,
            Discount_Recipient__c = paysTuition == false ? 'Student' : 'School', Status__c = 'Verified'
        );
        Billing_Arrangement__c cloned;
        for(Program__c program: programs)
        {
            for(Account homeInstitution: homeInstitutions)
            {
                cloned = ba.clone(false, false, false, false);
                cloned.Account__c = homeInstitution.Id;
                cloned.Program__c = program.Id;
                billingArrangements.add(cloned);
            }
            paysTuition = !paysTuition;
        }
       
        database.insert(billingArrangements);

        return billingArrangements;
    }
    /**
     * Creates Program_Authorization__c records. These records are not inserted into the database in this method.
     * @param programs The programs to create Program_Authorization__c records for
     * @param homeInstitutions The accounts to create Program_Authorization__c records for
     * @return List<Program_Authorization__c> The new Billing_Arrangement__c records
     */
    public static List<Program_Authorization__c> createProgramAuthorizations(List<Program__c> programs, List<Account> homeInstitutions)
    {
        Boolean paysTuition = true;
        List<Program_Authorization__c> programAuths = new List<Program_Authorization__c>();
        Program_Authorization__c pa = new Program_Authorization__c(Term__c = 'Spring; Summer; Fall; Calendar Year; Academic Year;');
        Program_Authorization__c cloned;
        for(Program__c program: programs)
        {
            for(Account homeInstitution: homeInstitutions)
            {
                cloned = pa.clone(false, false, false, false);
                cloned.Account__c = homeInstitution.Id;
                cloned.Program__c = program.Id;
                programAuths.add(cloned);
            }
        }
        return programAuths;
    }
    /**
     * Creates a Support_Personnel__c record.
     * @param myObj The SObject the Support_Personnel__c relates to.
     * @param userId The user (For Type__c 'IFSA Staff') or contact (for Type__c 'Non IFSA Staff') the Support_Personnel__c relates to.
     * @return Support_Personnel__c an instance of Support_Personnel__c
     */
    public static Support_Personnel__c createSupportPersonnel(SObject myObj, Id userId)
    {
        Support_Personnel__c sp = new Support_Personnel__c();
        if(apexConversionUtility.Compare(myObj, 'World__c'))
        {
            sp.RecordTypeID =  Schema.SObjectType.Support_Personnel__c.getRecordTypeInfosByName().get('World').getRecordTypeId();
            sp.World__c = myObj.Id;
            sp.IFSA_Staff__c = userId;
            sp.Support_Role_Type__c = 'Academic Records Coordinator Administration';
            sp.Type__c = 'IFSA Staff';
        }
        if(apexConversionUtility.Compare(myObj, 'Region__c'))
        {
            sp.RecordTypeID =  Schema.SObjectType.Support_Personnel__c.getRecordTypeInfosByName().get('Region').getRecordTypeId();
            sp.Region__c = myObj.Id;
            sp.IFSA_Staff__c = userId;
            sp.Support_Role_Type__c = 'Academic Records Coordinator Administration';
            sp.Type__c = 'IFSA Staff';
        }
        if(apexConversionUtility.Compare(myObj, 'Host_Institution__c'))
        {
            sp.RecordTypeID =  Schema.SObjectType.Support_Personnel__c.getRecordTypeInfosByName().get('Host Institution').getRecordTypeId();
            sp.Host_Institution__c = myObj.Id;
            sp.IFSA_Staff__c = userId;
            sp.Support_Role_Type__c = 'Academic Records Coordinator Administration';
            sp.Type__c = 'IFSA Staff';
        }
        else if(apexConversionUtility.Compare(myObj, 'Home_Institution__c'))
        {
            sp.RecordTypeID =  Schema.SObjectType.Support_Personnel__c.getRecordTypeInfosByName().get('Home Institution').getRecordTypeId();
            sp.Home_Institution__c = myObj.Id;
            sp.IFSA_Staff__c = userId;
            sp.Support_Role_Type__c = 'Academic Records Coordinator Administration';
            sp.Type__c = 'IFSA Staff';
        }
        else if(apexConversionUtility.Compare(myObj, 'Program__c'))
        {
            sp.RecordTypeID =  Schema.SObjectType.Support_Personnel__c.getRecordTypeInfosByName().get('Program').getRecordTypeId();
            sp.Program__c = myObj.Id;
            sp.IFSA_Staff__c = userId;
            sp.Support_Role_Type__c = 'Academic Records Coordinator Administration';
            sp.Type__c = 'IFSA Staff';
        }
        else if(apexConversionUtility.Compare(myObj, 'Program_Term__c'))
        {
            sp.RecordTypeID =  Schema.SObjectType.Support_Personnel__c.getRecordTypeInfosByName().get('Program Term').getRecordTypeId();
            sp.Program_Term__c = myObj.Id;
            sp.IFSA_Staff__c = userId;
            sp.Support_Role_Type__c = 'Academic Records Coordinator Administration';
            sp.Type__c = 'IFSA Staff';
        }
        else if(apexConversionUtility.Compare(myObj, 'Program_Term__c'))
        {
            sp.RecordTypeID =  Schema.SObjectType.Support_Personnel__c.getRecordTypeInfosByName().get('Program Term').getRecordTypeId();
            sp.Program_Term__c = myObj.Id;
            sp.IFSA_Staff__c = userId;
            sp.Support_Role_Type__c = 'Academic Records Coordinator Administration';
            sp.Type__c = 'IFSA Staff';
        }
        else if(apexConversionUtility.Compare(myObj, 'Contact'))
        {
            sp.RecordTypeID =  Schema.SObjectType.Support_Personnel__c.getRecordTypeInfosByName().get('Contact').getRecordTypeId();
            sp.Contact__c = myObj.Id;
            sp.Non_IFSA_Staff__c = userId;
            sp.Support_Role_Type__c = 'Parent';
            sp.Type__c = 'Non IFSA Staff';
        }
        else if(apexConversionUtility.Compare(myObj, 'Account'))
        {
            sp.RecordTypeID =  Schema.SObjectType.Support_Personnel__c.getRecordTypeInfosByName().get('Account').getRecordTypeId();
            sp.Account__c = myObj.Id;       
            sp.Non_IFSA_Staff__c = userId;
            sp.Support_Role_Type__c = 'Advisor';
            sp.Type__c = 'Non IFSA Staff';
        }

        database.insert(sp);

        return sp;
    }
    /**
     * Creates a Contact_Support_Personnel__c record. Does not insert the record in the method.
     * @param studentContact The student contact to relate the CSP record to
     * @param spRecord The SP record the CSP relates to
     * @return Contact_Support_Personnel__c a new Contact_Support_Personnel__c
     */
    public static Contact_Support_Personnel__c createContactSupport(Contact studentContact, Support_Personnel__c spRecord)
    {
        Contact_Support_Personnel__c cspRecord = new  Contact_Support_Personnel__c(Contact__c = studentContact.Id, Support_Personnel__c = spRecord.Id);

        return cspRecord;
    }
    /**
     * Creates Incident_Matrix__c records for a specific user id
     * @param userId. The user to create an IM record for.
     * @return Incident_Matrix__c an instance of Incident_Matrix__c
     */
    public static List<Incident_Matrix__c> createMatrix(Id userId)
    {
        List<Incident_Matrix__c> matrices = new List<Incident_Matrix__c>();
        Incident_Matrix__c m1 = new Incident_Matrix__c(IFSA_Staff__c = userId, Incident_Category__c = 'Physical Health', Incident_Sub_Category__c = 'Illness', Severity__c = 'Critical', Support_Role_Type__c = 'Health and Safety');
        matrices.add(m1);
        Incident_Matrix__c m2 = new Incident_Matrix__c(IFSA_Staff__c = userId, Incident_Category__c = 'Conduct', Incident_Sub_Category__c = 'Arrest/Allegation', Incident_Sub_Subcategory__c = 'Arson', Severity__c = 'Critical', Support_Role_Type__c = 'Health and Safety');
        matrices.add(m2);

        database.insert(matrices);

        return matrices;
    }

    /**
     * Creates a Butler_Department_Code__c record
     * @return Butler_Department_Code__c a instance of Butler_Department_Code__c
     */
    public static Butler_Department_Code__c createBUDepartmentCode()
    {
        Butler_Department_Code__c buCode = new Butler_Department_Code__c(College__c = 'Courses Not Offered at Butler', Department_Code__c = 'TEST', Department_Name__c = 'Test Department');
        
        Database.insert(buCode);

        return buCode;
    }

    /**
     * Creates just about every type of test data for Unit Testing. Every option is enabled, no extra trigger handlers bypassed.
     * @return The test data instance that was created.
     */
    public static Map<String, sObject> createIfsaDataCollection()
    {
        return createIfsaDataCollection(new List<String>(), new Set<String>{'Billing', 'Housing', 'CMS', 'Courses', 'Support_Personnel', 'Program_Auths'/*, 'ParentAndChildCourses'*/});
    }
    
    /**
     * Creates just about every type of test data for Unit Testing. Every option is enabled, but the calling test method has bypassed additional trigger handlers.
     * @param bypassTriggerHandlers A list of string of Trigger Handlers to bypass
     * @return The test data instance that was created.
     */
    public static Map<String, SObject> createIfsaDataCollection(List<String> bypassTriggerHandlers)
    {
    return createIfsaDataCollection(bypassTriggerHandlers, new Set<String>{'Billing', 'Housing', 'CMS', 'Courses', 'Support_Personnel', 'Program_Auths'/*, 'ParentAndChildCourses'*/});
    }
    
    /**
     * Creates the most basic test data, with the option of some additional test data types, but with no additional trigger handler bypasses
     * @param options A set of strings that determines what additional data is genereated.
     * @return The test data instance that was created.
     */
    public static Map<String, SObject> createIfsaDataCollection(Set<String> options)
    {
        return createIfsaDataCollection(new List<String>(), options);
    }

    /**
     * Creates unit test data, with trigger bypasses and data options
     * @param bypassTriggerHandlers A list of string of Trigger Handlers to bypass
     * @param options A set of strings that determines what additional data is genereated.
     * @return The test data instance that was created.
     */
    public static Map<String, sObject> createIfsaDataCollection(List<String> bypassTriggerHandlers, Set<String> options)
    {
	
        Map<String, sObject> returnMap = new Map<String, sObject>();

        contactTriggerHandler.bypassTrigger = true;
        applicationTriggerHandler.bypassTrigger = true;
        BaseTriggerHandler.bypass('applicationItemTriggerHandler');
        BaseTriggerHandler.bypass('applicationRequirementTriggerHandler');
        BaseTriggerHandler.bypass('userTriggerHandler');
        for(String bypassTH: bypassTriggerHandlers)
        {
            BaseTriggerHandler.bypass(bypassTH);
        }
        //BaseTriggerHandler.bypass('accountTriggerHandler');

        List<SObject> objectsToAdd = new List<SObject>();
        List<SObject> objectsToUpdate = new List<SObject>();

        User fdUser = [SELECT Id FROM User WHERE Name = 'Migration User'].get(0);
        fdUserId = fdUser.Id;
        returnMap.put('fdUser', fdUser);

        if(options.contains('Billing'))
        {
            List<c2g__codaGeneralLedgerAccount__c> glAccounts = [SELECT Id, Name FROM c2g__codaGeneralLedgerAccount__c];
            for(c2g__codaGeneralLedgerAccount__c glAccount: glAccounts)
            {
                if(glAccount.Name == '2099 - Accounts Payable')
                     payableAccount = glAccount.Id;
            
                else if(glAccount.Name == '1110 - Student Receivables')
                    receivableAccount = glAccount.Id;
            }
        }

        World__c world = new World__c(Name = 'Global');
        database.insert(world);

        Region__c international = new Region__c(Name = 'International Support', World__c = world.Id);
        Region__c local = new Region__c(Name = 'Local Support', World__c = world.Id);
        database.insert(new List<Region__c>{international, local});

        Country__c usa = apexMockDataUtility.createLocalCountry(local.Id);
        returnMap.put('localCountry', usa);

        List<Home_Institution__c> homeInstitutions = apexMockDataUtility.createHomeInstitution('Test Institution', 2, usa.Id);      
        Integer counter = 1;
        for(Home_Institution__c homeInstitution: homeInstitutions)
        {
            returnMap.put('homeInstitution' + counter, homeInstitution);
            //system.debug(homeInstitution.Name);
            
            counter = counter++;
        }
        
        List<Account> accounts = apexMockDataUtility.createAccounts('Test', 2);

        BaseTriggerHandler.bypass('accountTriggerHandler');
        
        Account studentAcct = accounts.get(0);
        Account studentAcct2 = accounts.get(1);
        returnMap.put('studentAccount', studentAcct);
        returnMap.put('studentAccount2', studentAcct2);
        
        List<Contact> studentContacts = apexMockDataUtility.createContacts('Test Contact', accounts, homeInstitutions);
        Contact studentCtc = studentContacts.get(0);
        Contact studentCtc2 = studentContacts.get(1);

        User academicAffiarsUser = apexMockDataUtility.CreateSysAdmin();
        returnMap.put('academicAffiarsUser', academicAffiarsUser);

        User studentUsr = apexMockDataUtility.createUser(studentCtc.Id);
        returnMap.put('studentUser', studentUsr);

        User studentUsr2 = apexMockDataUtility.createUser(studentCtc2.Id);
        returnMap.put('studentUser2', studentUsr2);
        
        Contact guardianCtc = apexMockDataUtility.createGuardian(studentCtc.Id, true);
        returnMap.put('guardianContact', guardianCtc);

        //Clear account and lists to create home institution advisors
        accounts.clear();
        counter = 1;
        accounts = [SELECT Id, Name, Institution__c FROM Account WHERE Institution__c IN: homeInstitutions];
        //system.debug('accounts..'+accounts);
        for(Account acct: accounts)
        {
            acct.Institution_Type__c = 'Public';
            returnMap.put('institutionAccount' + counter, acct);
            counter = counter++;
            objectsToUpdate.add(acct);
        }
        
        List<Contact> contacts = apexMockDataUtility.createContacts('Test', accounts, null);
        Contact ctc = contacts.get(0);
        Contact ctc2 = contacts.get(1);
        Contact ctc3 = contacts.get(2);
        //system.debug('123c'+ctc+ctc2+ctc3);
        ctc.Program_Approver__c = true;
        ctc.Transcript_Recipient__c = true;
        ctc2.Program_Approver__c = true;
        ctc2.Transcript_Recipient__c = true;
        ctc3.Program_Approver__c = true;
        ctc3.Transcript_Recipient__c = true;
        ctc.Receive_Alerts__c = true;
        ctc2.Receive_Alerts__c = true;
        ctc3.Receive_Alerts__c = true;
        ctc3.Summer_Only__c = true;
        ctc.Approval_Countries__c = 'China,England,Test';
        ctc2.Approval_Countries__c = 'China,India';
        Database.update(new List<Contact> {ctc, ctc2, ctc3});
        returnMap.put('advisorContact1', ctc);
        returnMap.put('advisorContact2', ctc2);
        returnMap.put('advisorContact3', ctc3);
        
       // User advisorUser = apexMockDataUtility.createAdvisor(ctc.Id);
        //returnMap.put('advisorUser1', advisorUser);
        //system.debug('checkingBeforeInsert'+new List<User>{academicAffiarsUser, studentUsr, studentUsr2});
        List<User> ur = new List<User>{academicAffiarsUser, studentUsr, studentUsr2};
        Database.insert(ur);
        //Need to add world, region, country, program, term, hi, because of selective program approval      

        Country__c country = apexMockDataUtility.createCountry(international.Id);
        returnMap.put('country', country);

        Locality__c testCity = new Locality__c(Name = 'Test City', Country__c = country.Id);
        database.insert(testCity);
        returnMap.put('city', testCity);
        
        List<Host_Institution__c> hosts = apexMockDataUtility.createHostInstitutions(country.Id, 3);
        Host_Institution__c hostInstitution = hosts.get(0);
        returnMap.put('hostInstitution', hostInstitution);
        
        Host_Institution__c hostInstitution2 = hosts.get(1);
        returnMap.put('hostInstitution2', hostInstitution2);

        Host_Institution__c hostInstitution3 = hosts.get(2);
        returnMap.put('IFSA-Butler', hostInstitution3);     

        List<String> names = new List<String>{'Test 1', 'Test 2', 'Undecided'};
        List<Program__c> programs = apexMockDataUtility.createPrograms(hostInstitution, names, academicAffiarsUser.Id);
        Program__c program = programs.get(0);
        Program__c program2 = programs.get(1);
        Program__c program3 = programs.get(2);
        
        returnMap.put('program', program);
        returnMap.put('program2', program2);
        returnMap.put('program3', program3);

        if(options.contains('Courses'))
        {
            Butler_Department_Code__c buCode = apexMockDataUtility.createBUDepartmentCode();
            returnMap.put('buCode', buCode);
            Course__c course = apexMockDataUtility.createHostCourse(hostInstitution.Id, buCode, program.Id);
            returnMap.put('hostCourse', course);
        }
        
        List<String> sections = new List<String>{'Spring', 'Fall', 'Summer', 'Calendar Year', 'Academic Year', 'Winter'};
        List<Term__c> terms = apexMockDataUtility.createTerms(sections, Date.today().year());
        Term__c springTerm = terms.get(0);
        Term__c fallTerm = terms.get(1);
        Term__c summerTerm = terms.get(2);
        returnMap.put('term', terms.get(0));
        returnMap.put('springTerm', terms.get(0));
        returnMap.put('fallTerm', terms.get(1));
        returnMap.put('summerTerm', terms.get(2));
        returnMap.put('calendarTerm', terms.get(3));
        returnMap.put('academicTerm', terms.get(4));

        List<Program_Term__c> programTerms = apexMockDataUtility.createProgramTerms(new List<Program__c>{program, program2}, springTerm, academicAffiarsUser);
        Program_Term__c programTerm = programTerms.get(0);
        returnMap.put('programTerm', programTerm);
        
        Program_Term__c programTerm2 = programTerms.get(1);        
        returnMap.put('programTerm2', programTerm2);
        programTerms.add(programTerm);
        
        
        Program_Term__c programOption1 = apexMockDataUtility.createProgramOption(programTerm2);
        returnMap.put('programOption1', programOption1);
        objectsToAdd.add(programOption1);

        Application_Requirement__c appReq = apexMockDataUtility.createApplicationRequirement(programTerm.Id);
        returnMap.put('applicationRequirement', appReq);
        objectsToAdd.add(appReq);
		
        database.upsert(objectsToAdd);
        objectsToAdd.clear();
        
        List<String> status = new List<String>{'Program Selected', 'Program Selected', 'Registered'};
        List<String> designation = new List<String>{'Primary', 'Secondary', 'Primary'};
        List<Program_Term__c> programOptions = new List<Program_Term__c>{null, programOption1, programOption1};
        List<Date> dates = new List<Date>();

        dates.add(date.Today().addDays(-29));
        dates.add(date.Today().addDays(-15));
        dates.add(null);

        studentContacts.clear();
        studentContacts.add(studentCtc);
        studentContacts.add(studentCtc);
        studentContacts.add(studentCtc2);

        List<Application__c> applications = apexMockDataUtility.createApplications(studentContacts, programTerms, programOptions, ctc.Id, status, dates, designation);

        Application__c studentApplication = applications.get(0);
        Application__c studentApplication2 = applications.get(1);
        Application__c studentApplication3 = applications.get(2);       

        studentCtc.Active_Application__c = studentApplication.Id;
        studentCtc.LastName = 'Student1';
        studentCtc2.LastName = 'Student2';
        studentCtc2.Active_Application__c = studentApplication3.Id;
                
        objectsToUpdate.addAll(new List<SObject>{studentCtc, studentCtc2});
        
        returnMap.put('studentApplication', studentApplication);
        returnMap.put('studentApplication3', studentApplication3);
        returnMap.put('studentApplication2', studentApplication2);
        returnMap.put('studentContact', studentCtc);
        returnMap.put('studentContact2', studentCtc2);
        
        Schema.DescribeSObjectResult R = Application_Item__c.SObjectType.getDescribe();
        List<Application_Item__c> appItems = apexMockDataUtility.createListApplicationItem(studentApplication.Id, R.getRecordTypeInfos());              
        returnMap.put('applicationItem', appItems.get(0));
        for(Application_Item__c appItem: appItems)
        {
            objectsToAdd.add(appItem);
        }
        if(options.contains('Support_Personnel'))
        {
            Support_Personnel__c supportPersonnel = apexMockDataUtility.createSupportPersonnel(accounts.get(0), ctc.Id);
            Support_Personnel__c supportPersonnel2 = apexMockDataUtility.createSupportPersonnel(world, academicAffiarsUser.Id);
            returnMap.put('supportPersonnel', supportPersonnel);
            Contact_Support_Personnel__c contactSupport = apexMockDataUtility.createContactSupport(studentCtc, supportPersonnel);
            returnMap.put('contactSupport', contactSupport);
            objectsToAdd.add(contactSupport);
        }
        if(options.contains('Housing'))
        {
            Housing_Option__c housingOption = apexMockDataUtility.createHousingOption();
            returnMap.put('housingOption', housingOption);
            Housing_Assignment__c housingAssignment = apexMockDataUtility.createHousingAssignment(housingOption, country);
            returnMap.put('housingAssignment', housingAssignment);
            objectsToAdd.add(housingAssignment);
        }
        
        if(options.contains('Program_Auths'))
        {
            List<Program_Authorization__c> programAuthorizations = apexMockDataUtility.createProgramAuthorizations(programs, accounts);
            counter = 1;
            for(Program_Authorization__c programAuthorization: programAuthorizations)
            {
                returnMap.put('programAuthorization' + counter, programAuthorization);
                counter = counter++;
                objectsToAdd.add(programAuthorization);
            }
        }
        if(options.contains('Billing'))
        {
            List<Billing_Arrangement__c> billingArrangements = apexMockDataUtility.createBillingArrangements(programs, accounts);
            counter = 1;
            for(Billing_Arrangement__c billingArrangement: billingArrangements)
            {
                returnMap.put('billingArrangement' + counter, billingArrangement);
                counter = counter++;
                objectsToAdd.add(billingArrangement);
            }
        }
        if(options.contains('ParentAndChildCourses'))
        {
            List<Course__c> pandcCourses = apexMockDataUtility.createParentAndChildCourses();
            counter = 1;
            for(Course__c course : pandcCourses)
            {
                returnMap.put('Course' + counter, course);
                counter = counter++;
                objectsToAdd.add(course);
            }
        }
        if(options.contains('Billing'))
        {
            //Quick and Dirty Products and Program Fees
            Product2 grant = new Product2(ProductCode = 'PRG', Name = 'Program Grants', IsActive = true);
            returnMap.put('product1', grant);        
            Product2 programFee = new Product2(ProductCode = 'TUT', Name = 'Program Fees', IsActive = true);
            objectsToAdd.addAll(new List<SObject>{grant, programFee});      
            objectsToAdd.add(new Product2(ProductCode = 'GSC', Name = 'Guaranteed Scholarship', IsActive = true));
            objectsToAdd.add(new Product2(ProductCode = 'ADV', Name = 'Non-Refundable Deposit', IsActive = true));
            for(Program_Term__c pt: new List<Program_Term__c>{programTerm, programTerm2, programOption1})
            {
                objectsToAdd.add(new Program_Fee__c(Name = 'Tuition', Amount__c = 18000, Direct_Bill_Category__c = 'Tuition', Product__c = programFee.Id, Program_Term__c = pt.Id));
            }

            // Populate Dimension records
            objectsToAdd.add(new c2g__codaDimension2__c(Name = '3 Program Launch Scholarship', c2g__ReportingCode__c = 'GUS' ));
            objectsToAdd.add(new c2g__codaDimension1__c(Name = 'Indianapolis, Administration', c2g__ReportingCode__c = 'INDY'));
        }
        
        if(options.contains('CMS'))
        {
            // Create CMS record for 'program'
            CMS__c cms1 = new CMS__c(SF_Program__c = program.Id);
            CMS__c cms2 = new CMS__c(SF_Program__c = program2.Id);
            objectsToAdd.addAll(new List<SObject>{cms1, cms2});

            returnMap.put('cms1', cms1);
            returnMap.put('cms2', cms2);
        }

        //Insert new items and update existing items
        database.upsert(objectsToAdd);
        database.update(objectsToUpdate);

        contactTriggerHandler.bypassTrigger = false;
        applicationTriggerHandler.bypassTrigger = false;
        BaseTriggerHandler.clearAllBypasses();
        system.debug('------------------MOCK DATA CREATED------------------');
        return returnMap;
    }

    /**
     * Sets fdUserId
     * @param fdUser A user record
     */
    public static void setFdUserId(User fdUser)
    {
        fdUserId = fdUser.Id;
    }
}