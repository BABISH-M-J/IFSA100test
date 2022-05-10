/**
 * @description Controller class for LWC affectedComponent
 * @see ifsaCaseControllerTests.testAffectedComponentController for unit tests
 * @author Brock Barlow
 */
// ApexDoc updated 1/25/2021 Brock Barlow
public without sharing class affectedComponentController 
{
	/**
	 * Gets the students and their home school and personal emergency contacts to be displayed in the Lightning Web Component affectedComponent. The type and status parameters for this method are set when adding affectedComponent to Lightning pages
	 * @param recordId
	 * @param type
	 * @param status
	 * @return affectedComponentViewModel
	 */
    @AuraEnabled(cacheable=true)
    public static affectedComponentViewModel getContacts(Id recordId, String type, String status)
    {
        Case selectedCase = [SELECT Id, Status, RecordTypeId, RecordType.Name, Parent.CaseNumber, Owner.Name, (SELECT Id, Student__c, Reason_Affected__c, Student__r.Home_Institution__r.Account__c FROM Case_Students__r), (SELECT Id, Student__c, Reason_Affected__c, Student__r.Home_Institution__r.Account__c FROM 	Affected_Entities__r WHERE RecordType.Name =  'Student') FROM Case WHERE Id =: recordId].get(0);
        Boolean isClosed;
        Boolean isCustom = type == 'Custom' ? true : false;
        affectedComponentViewModel vm = new affectedComponentViewModel();

		if(selectedCase.recordType.Name == 'Academic Appeal')
			//this.getApplicationById(selectedCase.Application__c);
		// Determine if the case is closed
		isClosed = selectedCase.Status == 'Closed' ? true : false;
		// Related Lists
		// Get the Affected Students
		List<Id> hiAccounts = new List<Id>();
		Set<Id> studentIdAffectedStudent = new Set<Id>();
		for(Case_Student__c studentCase: selectedCase.Case_Students__r)
		{
			hiAccounts.add(studentCase.Student__r.Home_Institution__r.Account__c);
			studentIdAffectedStudent.add(studentCase.Student__c);
		}
		for(Affected_Entity__c studentCase: selectedCase.Affected_Entities__r )
		{
			hiAccounts.add(studentCase.Student__r.Home_Institution__r.Account__c);
			studentIdAffectedStudent.add(studentCase.Student__c);
		}
		
		List<Contact> relatedContacts =  new List<Contact>();
        Boolean isPredeparture = false;
        
		if(!studentIdAffectedStudent.isEmpty() && (selectedCase.recordType.Name != 'Pre Departure' && selectedCase.recordType.Name != 'Academic Appeal'))
		{
			String studentIds = apexQueryUtility.buildInClause(studentIdAffectedStudent);
			String queryString = 'SELECT Id, Name, Email, Address_Abroad_Cell_Phone__c, Home_Institution__r.Name, On_Site_Application__r.Program_Term__c, On_Site_Application__r.Is_Custom__c, On_Site_Application__r.Program_Term__r.Name, On_Site_Application__r.Program_Country__c, ' +
                'On_Site_Application__r.First_Departure__c, On_Site_Application__r.Program_Term__r.Start_Date__c, On_Site_Application__r.Program_Term__r.Parent_Program_Term__r.Start_Date__c, On_Site_Application__r.Program_Term__r.End_Date__c, On_Site_Application__r.Program_Term__r.Parent_Program_Term__r.End_Date__c, ' +
                'Active_Application__r.Program_Term__c, Active_Application__r.Is_Custom__c, Active_Application__r.Program_Term__r.Name, Active_Application__r.Program_Country__c, Active_Application__r.First_Departure__c, Active_Application__r.Program_Term__r.Start_Date__c, ' +
                'Active_Application__r.Program_Term__r.Parent_Program_Term__r.Start_Date__c, Active_Application__r.Program_Term__r.End_Date__c, Active_Application__r.Program_Term__r.Parent_Program_Term__r.End_Date__c, ' + 
                    '(SELECT Id, Name, Support_Personnel__c, Support_Personnel__r.Account__r.Name, Support_Personnel__r.Email__c, Support_Personnel__r.Emergency_contact__c, Support_Personnel__r.Home_institution__c, Support_Personnel__r.Host_institution__c, Support_Personnel__r.Phone__c, Support_Personnel__r.Program_option__c, Support_Personnel__r.Program_Term__c, Support_Personnel__r.Program__c, Support_Personnel__r.SP_Plain_Text_Name__c, Support_Personnel__r.Support_Personnel_Name__c, Support_Personnel__r.Support_Role_Type__c, Support_Personnel__r.RecordType.Name, Support_Personnel__r.Support_Type__c, Support_Personnel__r.Non_IFSA_Staff__c, Support_Personnel__r.Non_IFSA_Staff__r.Phone, Support_Personnel__r.Non_IFSA_Staff__r.MobilePhone, Support_Personnel__r.Non_IFSA_Staff__r.Email FROM Contact_Support_Personnel__r WHERE Support_Personnel__r.Type__c = \'Non IFSA Staff\' AND (((Support_Personnel__r.RecordType.Name = \'Contact\' OR Support_Personnel__r.RecordType.Name = \'Account\') AND Support_Personnel__r.Emergency_Contact__c = TRUE) OR ((Support_Personnel__r.RecordType.Name = \'Account\' OR Support_Personnel__r.RecordType.Name = \'Program Term\' OR Support_Personnel__r.RecordType.Name = \'Program Option\' OR Support_Personnel__r.RecordType.Name = \'Program\'))))' +
				'FROM Contact WHERE Id IN ' + studentIds + ' AND On_Site_Application__r.Is_Custom__c = ' + isCustom;
			switch on status {
				when 'On_Site' {
					queryString = queryString + ' AND On_Site_Application__r.Status__c = \'On Site\'';
				}
				when 'Traveling' {
					queryString = queryString + ' AND On_Site_Application__r.Status__c IN (\'Accepted\', \'Accepted (with Conditions)\') AND Traveling_Status__c = \'Pre-Program\'';
				}
				when 'Program_Completed' {
					queryString = queryString + ' AND On_Site_Application__r.Status__c = \'Program Completed\'';
				}
				when else {
					throw new ifsaBadParamException();
				}
			}
			system.debug(queryString);
			relatedContacts = Database.query(queryString);
		}
		else if(!studentIdAffectedStudent.isEmpty() && selectedCase.recordType.Name != 'Pre Departure')			
		{
            relatedContacts = [SELECT Id, Name, Email, Address_Abroad_Cell_Phone__c, Home_Institution__r.Name, Active_Application__r.Program_Term__c, Active_Application__r.Is_Custom__c, Active_Application__r.Program_Term__r.Name, Active_Application__r.Program_Country__c,
                    (SELECT Id, Name, Support_Personnel__c, Support_Personnel__r.Account__r.Name, Support_Personnel__r.Email__c, Support_Personnel__r.Emergency_contact__c, Support_Personnel__r.Home_institution__c, Support_Personnel__r.Host_institution__c, Support_Personnel__r.Phone__c, Support_Personnel__r.Program_option__c, Support_Personnel__r.Program_Term__c, Support_Personnel__r.Program__c, Support_Personnel__r.SP_Plain_Text_Name__c, Support_Personnel__r.Support_Personnel_Name__c, Support_Personnel__r.Support_Role_Type__c, Support_Personnel__r.RecordType.Name, Support_Personnel__r.Support_Type__c, Support_Personnel__r.Non_IFSA_Staff__c, Support_Personnel__r.Non_IFSA_Staff__r.Phone, Support_Personnel__r.Non_IFSA_Staff__r.MobilePhone, Support_Personnel__r.Non_IFSA_Staff__r.Email FROM Contact_Support_Personnel__r WHERE Support_Personnel__r.Type__c = 'Non IFSA Staff' AND (((Support_Personnel__r.RecordType.Name = 'Contact' OR Support_Personnel__r.RecordType.Name = 'Account') AND Support_Personnel__r.Emergency_Contact__c = TRUE) OR ((Support_Personnel__r.RecordType.Name = 'Account' OR Support_Personnel__r.RecordType.Name = 'Program Term' OR Support_Personnel__r.RecordType.Name = 'Program Option' OR Support_Personnel__r.RecordType.Name = 'Program'))))
                FROM Contact WHERE Id IN: studentIdAffectedStudent AND Active_Application__r.Is_Custom__c  =:  isCustom];
			isPredeparture = true;
        }
        
        vm.contacts = relatedContacts;

        Set<Id> cMembers = new Set<Id>();
		{
			for(CampaignMember cm: [SELECT Id, ContactId FROM CampaignMember WHERE Campaign.Case__c =: recordId OR Campaign.Parent.Case__c =: recordId])
			{
				cMembers.add(cm.ContactId);
			}
        }
        vm.campaignMemberIds = new List<Id>(cMembers);

        return vm;
    }
	/**
	 * Adds specific contact to a case campaign
	 * @param contactId
	 * @param caseId
	 * @param campaignType
	 * @return Map<String, String>
	 */
    @AuraEnabled
	public static Map<String, String> addToCaseCampaign(String contactId, String caseId, String campaignType)
	{
		Map<String, String> result = new Map<String, String>();

		Case caseRecord = [SELECT Id, CaseNumber FROM Case WHERE Id =: caseId];
		//Contact contactRecord = [SELECT Id, Name, FirstName, LastName, Email, Phone, MobilePhone, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry FROM Contact WHERE Id =: contactId];
		List<Campaign> campaigns = [SELECT Id, Name, (SELECT Id, ContactId FROM CampaignMembers ) FROM Campaign WHERE Type =: campaignType AND Case__c =: caseId LIMIT 1];
        Campaign campaignRecord = new Campaign();
		if(campaigns.isEmpty())
		{
			campaignRecord.Name = String.format('Case {0} {1}', new List<Object>{caseRecord.CaseNumber, campaignType});
			campaignRecord.Type = campaignType;
			campaignRecord.Case__c = caseId;
			database.insert(campaignRecord);
			//campaignRecord.CampaignMembers = new List<CampaignMember>();
			result.put('Created_Campaign', 'Created ' + campaignRecord.Name);
		}
		else
		{
			campaignRecord = campaigns[0];
			result.put('Campaign_Exists', 'Campaign ' + campaignRecord.Name + ' already exists');
		}

		Boolean hasMember = false;
		for(CampaignMember cm: campaignRecord.CampaignMembers)
		{
			if(cm.ContactId == contactId)
			{
				result.put('Error', 'Contact is already part of this Campaign.');
				hasMember = true;
				break;
			}
		}
		if(!hasMember)
		{
			CampaignMember cm = new CampaignMember();
			cm.ContactId = contactId;
			cm.CampaignId = campaignRecord.Id;
			database.insert(cm);
			result.put('Created Campaign Member', String.format('Added Contact "{0}" to campaign "{1}"', new List<Object>{contactId, campaignRecord.Id}));
		}
		return result;
	}

	/**
	 * Viewmodel class for affectedComponentController
	 */
    public without sharing class affectedComponentViewModel
    {
		/**
		 * Contacts retrieved
		 */
		@AuraEnabled public List<Contact> contacts {get; set;}
		/**
		 * CampaginMember Id
		 */
        @AuraEnabled public List<Id> campaignMemberIds {get;set;}

		/**
		 * Constructor, initializes member lists
		 */
        public affectedComponentViewModel()
        {
            contacts = new List<Contact>();
            campaignMemberIds = new List<Id>();
        }    
    }
}