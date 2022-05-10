/**
 * Utility class which generates mock data for sandboxes. A series of checks will not allow it to insert data 
 * into a production database, just in case someone calls this in production. 
 * BBARLOW 3-9-2018 - Commenting out this class and its test class so that it is not counted against apex limits and 
 * code coverage requirements. Developers will need to uncomment this class when needing to create mock data in 
 * Developer sandboxes.
 * @author Brock Barlow
 */
// ApexDoc updated 1/25/2021 Brock Barlow
public with sharing class apexSandboxData {
    /**
	 * Generates mock data for sandboxes
	 */
	
	public static void generateSandboxData()
	{		
		Boolean isSandBox = [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
		Boolean isTestMode = configurationManager.isTestMode();
		//If running in a sandbox create data
		if(isSandBox)
		{
			system.debug('Running Test of sandbox data generation in a sandbox');
			createSandboxData();
		}
		//If running in production and in a test create data
		else if(!isSandBox && isTestMode)
		{
			system.debug('Running Test of sandbox data generation in production');
			createSandboxData();			
		}
		//Otherwise do nothing
		else
		{
			system.debug('YOU CAN NOT RUN THIS CODE IN PRODUCTION!!');
		}		
	}
	
	 /**
	 * creates sandbox data	 
	 */
	
	private static void createSandboxData()
	{
			//Create World
			World__c world = new World__c();
			world.Name = 'Global';
			database.insert(world);
			//Create Regions
			Region__c international = new Region__c();
			international.Name = 'International Support';
			international.World__c = world.Id;
			Region__c local = new Region__c();
			local.Name = 'Local Support';
			local.World__c = world.Id;
			database.insert(new List<Region__c>{international, local});

			List<SObject> objs = new List<SObject>();
			//Populate Countries
			Country__c country1 = new Country__c();
			country1.Name = 'England';
			country1.Region__c = international.Id;
			country1.Marketing_Region__c = 'Europe';
			country1.Active__c = true;
			objs.add(country1);
			Country__c country2 = new Country__c();
			country2.Name = 'Ireland';
			country2.Region__c = international.Id;
			country2.Marketing_Region__c = 'Europe';
			country2.Active__c = true;
			objs.add(country2);
	        Country__c country3 = new Country__c();
	        country3.Name = 'Spain';
	        country3.Region__c = international.Id;
			country3.Marketing_Region__c = 'Europe';
	        country3.Active__c = true;
			objs.add(country3);
	        Country__c country4 = new Country__c();
	        country4.Name = 'Undecided';
	        country4.Region__c = international.Id;
	        country4.Active__c = true;
			objs.add(country4);
	        Country__c country5 = new Country__c();
	        country5.Name = 'United States';
	        country5.Region__c = local.Id;
	        country5.Active__c = true;
			objs.add(country5);
			
			//Populate Terms
			for(Integer y: new List<Integer>{Date.today().year(), Date.today().year() + 1, Date.today().year() + 2})
			{
				for(String s: new List<String>{'Spring', 'Summer', 'Fall'})
				{
					objs.add(new Term__c(
						Name = s + ' ' + y,
						Year__c = y,
						Section__c = s
					));
				}
			}
			
	        Database.insert(objs);

			List<Term__c> terms = new List<Term__c>();
			for(SObject obj: objs)
			{
				switch on obj 
				{
					when Term__c t 
					{
					terms.add(t);
					}	
				}
			}

	        //Populated Localities
			Id stateProvRT = Schema.SObjectType.Locality__c.getRecordTypeInfosByName().get('State/Province').getRecordTypeId();
			Id cityTownRT = Schema.SObjectType.Locality__c.getRecordTypeInfosByName().get('City/Town').getRecordTypeId();
	        Locality__c indiana = new Locality__c(Name = 'Indiana', Code__c = 'IN', Country__c = country5.Id, RecordTypeId = stateProvRT);
	        Locality__c arizona = new Locality__c(Name = 'Arizona', Code__c = 'AZ', Country__c = country5.Id, RecordTypeId = stateProvRT);
	        Locality__c london = new Locality__c(Name = 'London', Country__c = country1.Id, RecordTypeId = cityTownRT);
	        Locality__c dublin = new Locality__c(Name = 'Dublin', Country__c = country2.Id, RecordTypeId = cityTownRT);
	        Locality__c belfast = new Locality__c(Name = 'Belfast', Country__c = country2.Id, RecordTypeId = cityTownRT);
	        Locality__c barcelona = new Locality__c(Name = 'Barcelona', Country__c = country3.Id, RecordTypeId = cityTownRT);


	        Database.insert(new List<sObject>{indiana, arizona, london, belfast, dublin, barcelona});
			
			//Populate Home Institutions
			Home_Institution__c homeInstitution1 = new Home_Institution__c(Name = 'University of Arizona', Country__c = country5.Id);
			Home_Institution__c homeInstitution2 = new Home_Institution__c(Name = 'Butler University', Country__c = country5.Id);
	        Home_Institution__c homeInstitution3 = new Home_Institution__c(Name = 'Indiana University', Country__c = country5.Id);
	        Home_Institution__c homeInstitution4 = new Home_Institution__c(Name = 'Purdue University', Country__c = country5.Id);
	        Home_Institution__c homeInstitution5 = new Home_Institution__c(Name = 'Ball State University', Country__c = country5.Id);
			
			Database.insert(new List<sObject>{homeInstitution1, homeInstitution2, homeInstitution3, homeInstitution4, homeInstitution5});
			List<Id> homeInstIDs = new List<Id>{homeInstitution1.Id, homeInstitution2.Id, homeInstitution3.Id, homeInstitution4.Id, homeInstitution5.Id};


			List<Account> homeAccounts = [SELECT Id, OwnerId FROM Account WHERE Institution__c IN: homeInstIDs];
			
			//Populate Host Institutions
			Host_Institution__c hostInstitution1 = new Host_Institution__c();
			Host_Institution__c hostInstitution2 = new Host_Institution__c();
	        Host_Institution__c hostInstitution3 = new Host_Institution__c();
	        Host_Institution__c hostInstitution4 = new Host_Institution__c();
	        Host_Institution__c hostInstitution5 = new Host_Institution__c();
	        Host_Institution__c hostInstitution6 = new Host_Institution__c();
			hostInstitution1.Name = 'Queen\'s University Belfast';
			hostInstitution2.Name = 'University College London';
	        hostInstitution3.Name = 'King\'s College London';
			hostInstitution4.Name = 'Trinity College Dublin';
	        hostInstitution5.Name = 'Universitat Autonòma de Barcelona';
	        hostInstitution6.Name = 'IFSA-Butler';
			hostInstitution1.Locality__c = belfast.Id;
	        hostInstitution2.Locality__c = london.Id;
			hostInstitution3.Locality__c = london.Id;
			hostInstitution4.Locality__c = dublin.Id;
	        hostInstitution5.Locality__c = barcelona.Id;
	        hostInstitution1.Country__c = belfast.Country__c;
	        hostInstitution2.Country__c = london.Country__c;
	        hostInstitution3.Country__c = london.Country__c;
	        hostInstitution4.Country__c = dublin.Country__c;
	        hostInstitution5.Country__c = barcelona.Country__c;
	        hostInstitution6.Country__c = country4.Id;
			hostInstitution1.Picture_URL__c = 'http://old.ifsa-butler.org/salesforce/queens-university-belfast.jpg';
			hostInstitution2.Picture_URL__c = 'http://old.ifsa-butler.org/salesforce/university-college-london.JPG';
	        hostInstitution3.Picture_URL__c = 'http://old.ifsa-butler.org/salesforce/kings-college-london.jpg';
			hostInstitution4.Picture_URL__c = 'http://old.ifsa-butler.org/salesforce/trinity-college-dublin.jpg';
	        hostInstitution5.Picture_URL__c = 'http://old.ifsa-butler.org/salesforce/engage-barcelona.jpg';
			
			Database.insert(new List<SObject>{hostInstitution1, hostInstitution2, hostInstitution3, hostInstitution4, hostInstitution5, hostInstitution6});			
			
			//Populate Program
			Program__c program1 = new Program__c();
			Program__c program2 = new Program__c();
	        Program__c program3 = new Program__c();
	        Program__c program4 = new Program__c();
	        Program__c program5 = new Program__c();
	        Program__c programUndecided = new Program__c();
			program1.Name = 'Queen\'s University Belfast';
			program2.Name = 'University College London';
	        program3.Name = 'King\'s College London';
	        program4.Name = 'Trinity College Dublin';
	        program5.Name = 'Universitat Autonòma de Barcelona';
	        programUndecided.Name = 'Undecided';	
			program1.Host_Institution__c = hostInstitution1.Id;
			program2.Host_Institution__c = hostInstitution2.Id;
	        program3.Host_Institution__c = hostInstitution3.Id;
			program4.Host_Institution__c = hostInstitution4.Id;
	        program5.Host_Institution__c = hostInstitution5.Id;
	        programUndecided.Host_Institution__c = hostInstitution6.Id;
			program1.Category__c = 'Catalog';
			program2.Category__c = 'Catalog';
	        program3.Category__c = 'Catalog';
			program4.Category__c = 'Catalog';
	        program5.Category__c = 'Catalog';
	        program1.Country__c = hostInstitution1.Country__c;
	        program2.Country__c = hostInstitution2.Country__c;
	        program3.Country__c = hostInstitution3.Country__c;
	        program4.Country__c = hostInstitution4.Country__c;
	        program5.Country__c = hostInstitution5.Country__c;
	        programUndecided.Category__c = 'Catalog';
			programUndecided.Country__c = country5.Id;
			program1.Available_Sections__c = 'Spring;Fall;Summer';
			program2.Available_Sections__c = 'Spring;Fall;Summer';
			program3.Available_Sections__c = 'Spring;Fall;Summer';
			program4.Available_Sections__c = 'Spring;Fall;Summer';
			program5.Available_Sections__c = 'Spring;Fall;Summer';
	        List<Program__c> programs = new List<Program__c>{program1, program2, program3, program4, program5, programUndecided};
			
			Database.insert(programs);
			
			//Populate Program Term
	        List<Program_Term__c> programTerms = new List<Program_Term__c>();
	        for (Program__c p : programs)
	        {
	            for (Term__c t : terms)
	            {
	                Program_Term__c pt = new Program_Term__c();
	                pt.Name = p.Name + ' ' + t.Name;
	                pt.Program__c = p.Id;
	                pt.Country__c = p.Country__c;
	                pt.Term__c = t.Id;
					pt.RecordTypeId = Schema.SObjectType.Program_Term__c.getRecordTypeInfosByName().get('Standard Program Term').getRecordTypeId();
	                //Descriptions
	                if(p.Name == program1.Name) {
	                    pt.Description__c = 'A major center of cutting-edge academics and research located in the heart of Belfast, Queens offers students a true Northern Ireland academic experience in a friendly, academically enriching environment. Housing is within walking distance to classes.';
	                } else if (p.Name == program2.Name) {
	                    pt.Description__c = 'The oldest and largest college within the University of London, UCL is one of the top ranked universities in the world and an excellent choice for nearly any subject. Special study in fine arts, global citizenship or international health is available.';
	                } else if (p.Name == program3.Name) {
	                    pt.Description__c = 'One of the worlds top universities, Kings provides an outstanding academic experience in a central London setting. State-of-the-art teaching and research facilities combine with a friendly atmosphere for a well-rounded study abroad opportunity.';
	                } else if (p.Name == program4.Name) {
	                    pt.Description__c = 'Founded in 1592, Trinity College is the oldest university in Ireland and one of the most prestigious in the world. The alma mater of Ireland\'s most famous figures, Trinity is a great place to focus on traditional humanities or challenging sciences.';
	                } else if (p.Name == program5.Name) {
	                    pt.Description__c = 'Based at the prestigious Universitat Autònoma de Barcelona (UAB), Engage Barcelona is ideal for the career-focused student who wants great courses taught in English or Spanish in one of Europes most amazing cities. An internship is part of the program.';
	                }
	                programTerms.add(pt);
	            }
	        }		
			Database.insert(programTerms);
			
	        //Application Requirements and Program Fees
	        List<SObject> reqs = new List<SObject>();
			List<SObject> fees = new List<SObject>();
			List<SObject> reqsAndFees = new List<SObject>();

	        for (Program_Term__c pt : programTerms)
	        {
	        	//Application Requirements
	            Application_Requirement__c appReq1 = new Application_Requirement__c();
	            Application_Requirement__c appReq2 = new Application_Requirement__c();
	            Application_Requirement__c appReq3 = new Application_Requirement__c();
	            Application_Requirement__c appReq4 = new Application_Requirement__c();
	            Application_Requirement__c appReq5 = new Application_Requirement__c();
	            appReq1.Name = 'Addresses';
	            appReq2.Name = 'Medical Form';
	            appReq3.Name = 'Travel Plan';
	            appReq4.Name = 'Housing Preferences Form';
	            appReq5.Name = 'Program Approval';
	            appReq1.RecordTypeId = Schema.SObjectType.Application_Requirement__c.getRecordTypeInfosByName().get(appReq1.Name).getRecordTypeId();
	            appReq2.RecordTypeId = Schema.SObjectType.Application_Requirement__c.getRecordTypeInfosByName().get(appReq2.Name).getRecordTypeId();
	            appReq3.RecordTypeId = Schema.SObjectType.Application_Requirement__c.getRecordTypeInfosByName().get(appReq3.Name).getRecordTypeId();
	            appReq4.RecordTypeId = Schema.SObjectType.Application_Requirement__c.getRecordTypeInfosByName().get(appReq4.Name).getRecordTypeId();
	            appReq5.RecordTypeId = Schema.SObjectType.Application_Requirement__c.getRecordTypeInfosByName().get(appReq5.Name).getRecordTypeId();
	            appReq1.Phase__c = 'Pre-Admit';
				appReq2.Phase__c = 'Pre-Acceptance';
				appReq3.Phase__c = 'Pre-Admit';
				appReq4.Phase__c = 'Pre-Admit';
				appReq5.Phase__c = 'Pre-Admit';
	            appReq1.Program_Term__c = pt.Id;
	            appReq2.Program_Term__c = pt.Id;
	            appReq3.Program_Term__c = pt.Id;
	            appReq4.Program_Term__c = pt.Id;
	            appReq5.Program_Term__c = pt.Id;            
	            reqs.add(appReq1);
	            reqs.add(appReq2);
	            reqs.add(appReq3);
	            reqs.add(appReq4);
	            reqs.add(appReq5);
	            //Program Fees
	            Program_Fee__c programFee1 = new Program_Fee__c();
	            Program_Fee__c programFee2 = new Program_Fee__c();
	            programFee1.Name = 'Housing Fee';
	            programFee2.Name = 'Application Fee';
				programFee1.Amount__c = 1500;
				programFee2.Amount__c = 1500;	            
	            programFee1.Program_Term__c = pt.Id;
	            programFee2.Program_Term__c = pt.Id;
	            fees.add(programFee1);
	            fees.add(programFee2);            
	        }
			reqsAndFees.addAll(reqs);
			reqsAndFees.addAll(fees);
			system.enqueueJob(new sObjectQueueableUpdater(reqsAndFees, sObjectQueueableUpdater.dmlOperation.isInsert));
	                
	        //Create Portal Users (Advisors and Students)
	        List<Profile> profileList = [SELECT Name, Id FROM Profile WHERE Name = 'IFSA Advisor User' OR Name = 'IFSA Student User'];
	        Map<String, Id> profileMap = new Map<String, Id>();
	        for(Profile rt: profileList)
	        {
	        	profileMap.put(rt.Name, rt.Id);
	        }
	                        
	        List<Contact> AdvisorContacts = new List<Contact>();
	        List<Account> StudentAccounts = new List<Account>();
	        List<Contact> StudentContacts = new List<Contact>();        
	        List<User> StudentUsers = new List<User>();
	        List<User> AllUsers = new List<User>();
	        
	        //Create Advisors	        
	        Contact advisorContact1 = new Contact();
	        advisorContact1.FirstName =  'Brandon';
	        advisorContact1.LastName = 'Martin';        
	        advisorContact1.Email = 'bmartin' + Integer.valueOf(math.rint(math.random()*1000000)) + '@arizona.edu.test';
	        advisorContact1.AccountId = homeAccounts.get(0).Id;
	        //advisorContact1.Home_Institution__c = homeInstitution1.Id;
	        advisorContact1.Program_Approver__c = true;
	        advisorContact1.Approval_Countries__c = 'Ireland,England,Spain';
	        AdvisorContacts.add(advisorContact1);
	        
	        Contact advisorContact2 = new Contact();
	        advisorContact2.FirstName =  'Kenneth';
	        advisorContact2.LastName = 'Romero';        
	        advisorContact2.Email = 'kromero' + Integer.valueOf(math.rint(math.random()*1000000)) + '@butler.edu.test';
	        advisorContact2.AccountId = homeAccounts.get(1).Id;
	        //advisorContact2.Home_Institution__c = homeInstitution2.Id;
	        advisorContact2.Program_Approver__c = true;
	        advisorContact2.Approval_Countries__c = 'Ireland,England,Spain';
	        AdvisorContacts.add(advisorContact2);
	        
	        Contact advisorContact3 = new Contact();
	        advisorContact3.FirstName =  'Teresa';
	        advisorContact3.LastName = 'Ortiz';        
	        advisorContact3.Email = 'tortiz' + Integer.valueOf(math.rint(math.random()*1000000)) + '@indiana.edu.test';
	        advisorContact3.AccountId = homeAccounts.get(2).Id;
	        //advisorContact3.Home_Institution__c = homeInstitution3.Id;
	        advisorContact3.Program_Approver__c = true;
	        advisorContact3.Approval_Countries__c = 'Ireland,England,Spain';
	        AdvisorContacts.add(advisorContact3);
	        
	        Contact advisorContact4 = new Contact();
	        advisorContact4.FirstName =  'Patrick';
	        advisorContact4.LastName = 'Carr';        
	        advisorContact4.Email = 'pcarr' + Integer.valueOf(math.rint(math.random()*1000000)) + '@purdue.edu.test';
	        advisorContact4.AccountId = homeAccounts.get(3).Id;
	        //advisorContact4.Home_Institution__c = homeInstitution4.Id;
	        advisorContact4.Program_Approver__c = true;
	        advisorContact4.Approval_Countries__c = 'Ireland,England,Spain';
	        AdvisorContacts.add(advisorContact4);
	        
	        Contact advisorContact5 = new Contact();
	        advisorContact5.FirstName =  'Nicole';
	        advisorContact5.LastName = 'Fisher';        
	        advisorContact5.Email = 'nfisher' + Integer.valueOf(math.rint(math.random()*1000000)) + '@ballstate.edu.test';
	        advisorContact5.AccountId = homeAccounts.get(4).Id;
	        //advisorContact5.Home_Institution__c = homeInstitution5.Id;
	        advisorContact5.Program_Approver__c = true;
	        advisorContact5.Approval_Countries__c = 'Ireland,England,Spain';
	        AdvisorContacts.add(advisorContact5);
	
	        for (Contact newContact : AdvisorContacts)
	        {                    
	            newContact.Approved_for_Advising__c = true;
	        	newContact.Created_for_Custom__c = false;
	        	newContact.Advisor_Type__c = 'Primary Contact';
	            newContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Advisor').getRecordTypeId();
	        }
	        //Insert AdvisorContacts into database
	        Database.insert(AdvisorContacts);
	                
	        for (Contact newContact : AdvisorContacts)
	        {            
	            AllUsers.add(CreateAdvisorUser(profileMap.get('IFSA Advisor User'), newContact));            
	        }
	        
	        //database.insert(AllUsers);
	        
	        //Create Students                
			Id studentAccountRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Student Account').getRecordTypeId();
	        Account studentAccount1 = new Account();
	        Contact studentContact1 = new Contact();
	        studentContact1.FirstName = 'Nicholas';
	        studentContact1.LastName = 'Snyder';
	        studentContact1.Email = 'nsnyder'+ Integer.valueOf(math.rint(math.random()*1000000)) +'@yahoo.com.test';
	        studentContact1.Home_Institution__c = homeInstitution1.Id;
	        studentContact1.Birthdate = Date.newInstance(1996, 12, 18);
	        studentContact1.Major__c = 'Business';
	        studentContact1.Sex__c = 'Male';
	        studentContact1.GPA__c = 3.4;
	        studentContact1.Citizenship__c = 'U.S. Citizen';
	        studentContact1.Grade_Level__c = 'Sophmore';
	        studentContact1.Phone = '555-123-9876';
	        studentAccount1.RecordTypeId = studentAccountRecordType;
	        studentAccount1.Name = studentContact1.FirstName + ' ' + studentContact1.LastName;
	        studentAccounts.add(studentAccount1);
	        studentContacts.add(studentContact1);
	        
	        Account studentAccount2 = new Account();
	        Contact studentContact2 = new Contact();
	        studentContact2.FirstName = 'Daniel';
	        studentContact2.LastName = 'Clark';
	        studentContact2.Email = 'dclark'+ Integer.valueOf(math.rint(math.random()*1000000)) +'@yahoo.com.test';
	        studentContact2.Home_Institution__c = homeInstitution2.Id;
	        studentContact2.Birthdate = Date.newInstance(1996, 12, 18);
	        studentContact2.Major__c = 'Medical';
	        studentContact2.Sex__c = 'Male';
	        studentContact2.GPA__c = 3.5;
	        studentContact2.Citizenship__c = 'U.S. Citizen';
	        studentContact2.Grade_Level__c = 'Junior';
	        studentContact2.Phone = '555-123-7895';
	        studentAccount2.RecordTypeId = studentAccountRecordType;
	        studentAccount2.Name = studentContact2.FirstName + ' ' + studentContact2.LastName;
	        studentAccounts.add(studentAccount2);
	        studentContacts.add(studentContact2);
	        
	        Account studentAccount3 = new Account();
	        Contact studentContact3 = new Contact();
	        studentContact3.FirstName = 'Betty';
	        studentContact3.LastName = 'Moreno';
	        studentContact3.Email = 'bmoreno'+ Integer.valueOf(math.rint(math.random()*1000000)) +'@yahoo.com.test';
	        studentContact3.Home_Institution__c = homeInstitution3.Id;
	        studentContact3.Birthdate = Date.newInstance(1996, 12, 18);
	        studentContact3.Major__c = 'Education';
	        studentContact3.Sex__c = 'Female';
	        studentContact3.GPA__c = 3.7;
	        studentContact3.Citizenship__c = 'U.S. Citizen';
	        studentContact3.Grade_Level__c = 'Senior';
	        studentContact3.Phone = '555-123-4567';
	        studentAccount3.RecordTypeId = studentAccountRecordType;
	        studentAccount3.Name = studentContact3.FirstName + ' ' + studentContact3.LastName;
	        studentAccounts.add(studentAccount3);
	        studentContacts.add(studentContact3);
	        
	        Account studentAccount4 = new Account();
	        Contact studentContact4 = new Contact();
	        studentContact4.FirstName = 'Harold';
	        studentContact4.LastName = 'Hawkins';
	        studentContact4.Email = 'hhawkins'+ Integer.valueOf(math.rint(math.random()*1000000)) +'@yahoo.com.test';
	        studentContact4.Home_Institution__c = homeInstitution4.Id;
	        studentContact4.Birthdate = Date.newInstance(1996, 12, 18);
	        studentContact4.Major__c = 'Computer Science';
	        studentContact4.Sex__c = 'Male';
	        studentContact4.GPA__c = 3.6;
	        studentContact4.Citizenship__c = 'U.S. Citizen';
	        studentContact4.Grade_Level__c = 'Freshman';
	        studentContact4.Phone = '555-123-9876';
	        studentAccount4.RecordTypeId = studentAccountRecordType;
	        studentAccount4.Name = studentContact4.FirstName + ' ' + studentContact4.LastName;
	        studentAccounts.add(studentAccount4);
	        studentContacts.add(studentContact4);
	        
	        Account studentAccount5 = new Account();
	        Contact studentContact5 = new Contact();
	        studentContact5.FirstName = 'Sharon';
	        studentContact5.LastName = 'Warren';
	        studentContact5.Email = 'swarren'+ Integer.valueOf(math.rint(math.random()*1000000)) +'@yahoo.com.test';
	        studentContact5.Home_Institution__c = homeInstitution5.Id;
	        studentContact5.Birthdate = Date.newInstance(1996, 12, 18);
	        studentContact5.Major__c = 'History';
	        studentContact5.Sex__c = 'Female';
	        studentContact5.GPA__c = 3.65;
	        studentContact5.Citizenship__c = 'U.S. Citizen';
	        studentContact5.Grade_Level__c = 'Sophmore';
	        studentContact5.Phone = '555-123-9876';
	        studentAccount5.RecordTypeId = studentAccountRecordType;
	        studentAccount5.Name = studentContact5.FirstName + ' ' + studentContact5.LastName;
	        studentAccounts.add(studentAccount5);
	        studentContacts.add(studentContact5);
	        
	        for (Contact newContact : studentContacts)
	        {                                
	            newContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
	        }
	        
	        Database.insert(studentAccounts);
	        
	        Integer counter = 0;
	        for (Contact c : studentContacts)
	        {
	        	c.AccountId = studentAccounts[counter].Id;
	        	counter++;
	        }
	        counter = 0;
	        Database.insert(studentContacts);
	        
	        for (Contact newContact : studentContacts)
	        {
	            AllUsers.Add(CreatePortalUser(profileMap.get('IFSA Student User'), newContact));            
	        }
	        //Insert StudentUsers into database
	        database.insert(AllUsers);

	        List<Id> csIds = new List<Id>();
	        for(Contact sc: studentContacts)
	        {
	        	csIds.add(sc.Id);
	        }
	        List<Id> ptIds = new List<Id>();
	        for(Program_Term__c pt: programTerms)
	        {
	        	ptIds.add(pt.Id);
	        }

	        system.debug('To finish creating records run "apexSandboxData.createOtherRecords()" from anonynmus apex ');
	        
			if(!configurationManager.isTestMode())
			{
				//apexSandboxData.createOtherRecords();
			}
	}

	public static void createOtherRecords()
	{
		List<Contact> studentContacts = [SELECT Id, Name, FirstName, LastName FROM Contact WHERE RecordType.Name = 'Student'];
		List<Program_Term__c> programTerms = [SELECT Id, Name, Program__c, RecordType.Name FROM Program_Term__c WHERE Program__r.Name != 'Undecided' AND (NOT RecordType.Name LIKE 'Parent Program Term%')];
		//Create Applications
        List<Application__c> applications = new List<Application__c>();
        
		Integer loopLimit = !configurationManager.isTestMode() ? 5 : studentContacts.size();
        for (Integer i = 0; i < loopLimit; i++)
        {
        	Integer x = configurationManager.isTestMode() ? i : i * 2;
        	Application__c newApplication = new Application__c();
        	//Contact c = studentContacts[i];
        	newApplication.Name = studentContacts.get(i).Name + ' ' + programTerms.get(x).Name;
        	newApplication.Program_Term__c = programTerms.get(x).Id; 
        	newApplication.Applicant__c = studentContacts.get(i).Id;
        	newApplication.Status__c = 'Program Selected';
        	applications.add(newApplication);
        }
        database.insert(applications);

        List<User> users = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = TRUE];
		List<SObject> sps = new List<SObject>();
		List<SObject> ims = new List<SObject>();
		Id rt = Schema.SObjectType.Support_Personnel__c.getRecordTypeInfosByName().get('World').getRecordTypeId();
		Id globalId = [SELECT Id FROM World__c WHERE Name = 'Global'].get(0).Id;
		
		for(User u: users)
		{
			Support_Personnel__c sp = new Support_Personnel__c();
			sp.RecordTypeID = rt;
			sp.World__c = globalId;
			sp.IFSA_Staff__c = u.Id;
			sp.Support_Role_Type__c = 'Administration';
			sp.Type__c = 'IFSA Staff';
			
			sps.add(sp);

			Incident_Matrix__c im1 = new Incident_Matrix__c();
			im1.IFSA_Staff__c = u.Id;
			im1.Support_Role_Type__c = 'Administration';
			im1.Severity__c = 'Non-Emergency';
			im1.Incident_Category__c = 'Physical Health';
			im1.Incident_Sub_Category__c = 'Illness';
			im1.Incident_Sub_Subcategory__c = '';

			ims.add(im1);

			Incident_Matrix__c im2 = new Incident_Matrix__c();
			im2.IFSA_Staff__c = u.Id;
			im2.Support_Role_Type__c = 'Administration';
			im2.Severity__c = 'Non-Emergency';
			im2.Incident_Category__c = 'Physical Health';
			im2.Incident_Sub_Category__c = 'Accident/Injury';
			im2.Incident_Sub_Subcategory__c = '';
			
			ims.add(im2);
		}
		List<SObject> objToInsert = new list<SObject>();
		objToInsert.addAll(sps);
		objToInsert.addAll(ims);
		system.enqueueJob(new sObjectQueueableUpdater(objToInsert, sObjectQueueableUpdater.dmlOperation.isInsert));
		List<Account> homeAccounts = [SELECT Id, OwnerId FROM Account WHERE Institution__c != null];
		for (Account a : homeAccounts) 
		{
			a.Approves_All_Calendar_Programs__c = true;
			a.Approves_All_Summer_Programs__c = true;
		}
		Database.update(homeAccounts);

		Map<Id, Course__c> courses = new Map<Id, Course__c>();
		List<Program__c> programs = [SELECT Id, Name, Host_Institution__c FROM Program__c WHERE Name != 'Undecided'];

		for(Program__c program: programs)
		{
			Course__c c = new Course__c();
			c.Host_Institution__c = program.Host_Institution__c;
			c.Name = 'Test course at ' + program.Name;
			c.Course_Title_2__c = c.Name;
			c.Approved_For_CHART__c = true;

			courses.put(program.Id, c);
		}
		Database.insert(courses.values());
		List<Program_Course__c> programCourses = new List<Program_Course__c>();
		for(Id programId: courses.keySet())
		{
			Program_Course__c pc = new Program_Course__c();
			pc.Program__c = programId;
			pc.Course__c = courses.get(programId).Id;
			programCourses.add(pc);
		}
		system.enqueueJob(new sObjectQueueableUpdater(programCourses, sObjectQueueableUpdater.dmlOperation.isInsert));
	}
	
    private static User CreatePortalUser(Id studentProfileId, Contact newContact)
    {    	        
        Contact c = newContact;
        User newUser = new User();
        newUser.Alias = c.FirstName.substring(0,0) + c.LastName.substring(0,4);
        newUser.LastName = c.LastName;
        newUser.FirstName = c.FirstName;
        newUser.Email = c.Email;
        newUser.Username = c.Email + '.ifsa';
        newUser.CommunityNickname = newUser.Username;
        newUser.UserRole = [SELECT Id FROM Userrole WHERE Name =: 'President'];
	    newUser.ProfileId = studentProfileId;
	    newUser.contactId = c.Id;
	    newUser.TimeZoneSidKey = 'GMT';
	    newUser.LocaleSidKey = 'en_US';
	    newUser.EmailEncodingKey = 'ISO-8859-1';
	    newUser.LanguageLocaleKey = 'en_US';
	    newUser.UserPermissionsMobileUser = false;
		newUser.Email_Confirmed_For_CHART__c = true;
	    
	    return newUser;
    }
    private static User CreateAdvisorUser(Id advisorProfileId, Contact newContact)
    {        		
		Contact advisorContact = newContact;

		User advisorUser = new User();
		advisorUser.FirstName = advisorContact.FirstName;
		advisorUser.LastName = advisorContact.LastName;
		advisorUser.Email = advisorContact.Email;
		advisorUser.Phone = advisorContact.Phone;
		if(advisorContact.Email.split('@').get(0).length() > 20)
		{
			advisorUser.CommunityNickname = advisorContact.Email.split('@').get(0).substring(0,20) + String.valueOf(Math.random() * 100);
		}
		else
		{
			advisorUser.CommunityNickname = advisorContact.Email.split('@').get(0) + String.valueOf(Math.random() * 100);
		}
		
		Integer aliasEnding = 4;
		if(advisorContact.FirstName.length() < 4)
		{
			aliasEnding = advisorContact.FirstName.length();
		}
		
		advisorUser.Alias = advisorContact.FirstName.substring(0,1) + advisorContact.LastName.substring(0,aliasEnding);
		advisorUser.Username = advisorContact.Email + '.ifsa';
		advisorUser.ProfileId = advisorProfileId;
		advisorUser.EmailEncodingKey = 'UTF-8';
		advisorUser.LanguageLocaleKey = 'en_US';
		advisorUser.LocaleSidKey = 'en_US';
		advisorUser.TimeZoneSidKey = 'America/Indiana/Indianapolis';
		advisorUser.ContactId = advisorContact.Id;
		advisorUser.Email_Confirmed_For_CHART__c = true;

		return advisorUser;			
	}
}