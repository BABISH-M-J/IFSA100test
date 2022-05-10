/**
 * Service class for Contact
 * @author Brock Barlow
 */
// ApexDoc updated 1/28/2021 Brock Barlow
public without sharing class contactService 
{
	/**
	 * DML Operations
	 */	
	public enum triggerType
	{
		isInsert, isUpdate, isDelete, isBefore, isAfter
	}

	public static Id studentRecordType;
	public static Id parentRecordType;

	/**
	 * Formats 10 digit and 11 digit (starting with "1") student and emergency contact phone numbers
	 * @param List<Contact> newRecords the records that are being inserted/updated
	 */
	public static void formatPhoneNumber(List<Contact> newRecords)
	{
		Id studentRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
		Id otherRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Other').getRecordTypeId();

		for(Contact c: newRecords)
		{
			if(c.RecordTypeId == studentRT || c.RecordTypeId == otherRT)
			{
				c.Phone = c.Phone != null ? formatNumber(c.Phone) : null;
				formatNumberMC(c);
				c.HomePhone = c.HomePhone != null ? formatNumber(c.HomePhone) : null;
				c.MobilePhone = c.MobilePhone != null ? formatNumber(c.MobilePhone) : null;
				c.OtherPhone = c.OtherPhone != null ? formatNumber(c.OtherPhone) : null;
			}
		}
	}
	/**
	 * Formats 10 digit and 11 digit (starting with "1")  phone numbers
	 * @param String phoneNumber the value to be formatted
	 */
	private static String formatNumber(String phoneNumber)
	{
		String returnVar = '';
		if(phoneNumber.length() == 10 || phoneNumber.length() == 11 && phoneNumber.startsWith('1'))
		{
			phoneNumber = phoneNumber.length() == 11 ? phoneNumber.substring(1,11) : phoneNumber;
			System.debug(phoneNumber);
			returnVar = '(' + phoneNumber.substring(0, 3) + ') ' + phoneNumber.substring(3, 6) + '-' + phoneNumber.substring(6,10);
		}
		else
		{
			returnVar = phoneNumber;
		}
		return returnVar;
	}
	/**
	 * Strips "(", ")", " ", & "-" from strings
	 * @param String phoneNumber the value to be formatted
	 */
	public static String stripPhoneFormating(String phoneNumber)
	{
		phoneNumber = phoneNumber.replace('(', '');
		phoneNumber = phoneNumber.replace(')', '');
		phoneNumber = phoneNumber.replace(' ', '');
		phoneNumber = phoneNumber.replace('-', '');

		return phoneNumber;
	}
	/**
	 * formats the contacts phoneNumber for SMS with Marketing Cloud
	 * @param Contact the contact to have the phone number formatted for
	 */
	public static void formatNumberMC(Contact c)
	{
		if(c.et4ae5__Mobile_Country_Code__c == 'US' && c.Phone != null)
		{
			String regEx = '[^0-9]';
			String replacement = '';
			// Uses regex to strip phone nummber to only it's digits
			String phoneNumber = c.Phone.replaceAll(regEx, replacement);
			// Adds leading '1' to phonenumbers
			c.Mobile_For_SMS__c = '1'+ phoneNumber;
		}
	}
	public static void completeAdvisingCall(Map<Id, Contact> newMap, Map<Id, Contact> oldMap)
	{
		List<String> statuses = new List<String>{'Program Selected', 'Ready To Submit', 'Submitted', 'Accepted'};
		statuses.add('Accepted (with Conditions)');
		List<Application_Item__c> appItems = [SELECT Id, Status__c, Application__r.Applicant__c  FROM Application_Item__c WHERE Name = 'Advising Call' AND RecordType.Name = 'No Action' AND Application__r.Applicant__c IN: newMap.keySet() AND Application__r.Status__c IN: statuses];
		
		for(Application_Item__c a: appItems)
		{
			if(newMap.get(a.Application__r.Applicant__c).Appreciative_Advising_Call_Completed__c && !oldMap.get(a.Application__r.Applicant__c).Appreciative_Advising_Call_Completed__c)
			{
				a.Status__c = 'Complete';
			}
		}
		database.update(appItems);
	}

	public static void checkIFSAButlerNETEmail(Map<Id, Contact> newMap, Map<Id, Contact> oldMap)
	{
		Boolean runService = Test.isRunningTest() ? true : ![SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
		Id migrationUserId = [SELECT Id FROM User WHERE Name = 'Migration User'].get(0).Id;
		if (UserInfo.getUserId()!= migrationUserId)
		{
			for (Contact c: newMap.values())
			{
				if (c.IFSA_Butler_NET_Email_Delete__c  && runService)
				{
					c.Updating_IFSA_Butler_NET_Email__c = True;
					c.IFSA_Butler_NET_Email_Delete__c = False;
					deleteIFSAButlerNETEmail(c.IFSA_Butler_NET_Email__c, String.valueOf(c.Id));
				}
				else if (c.IFSA_Butler_NET_Forwarding_Address__c!= oldMap.get(c.Id).IFSA_Butler_NET_Forwarding_Address__c && runService)
				{
					c.Updating_IFSA_Butler_NET_Email__c = True;
					c.IFSA_Butler_NET_Old_Forwarding_Address__c = oldMap.get(c.Id).IFSA_Butler_NET_Forwarding_Address__c == null || oldMap.get(c.Id).IFSA_Butler_NET_Forwarding_Address__c.contains('@') ? oldMap.get(c.Id).IFSA_Butler_NET_Forwarding_Address__c : null;
					updateIFSAButlerNETEmail(c.IFSA_Butler_NET_Email__c, c.IFSA_Butler_NET_Forwarding_Address__c, String.valueOf(c.Id));
				}
			}
		}
	}
	@future(callout=true)
	public static void createIFSAButlerNETEmail(String studentFirstName, String studentLastName, String forwardingEmail, String contactId)
	{
		system.debug(studentFirstName);
		system.debug(studentLastName);
		system.debug(forwardingEmail);
		system.debug(contactId);

		ifsaButlerNetEmailService.BasicHttpBinding_IStudentEmail emailService = new ifsaButlerNetEmailService.BasicHttpBinding_IStudentEmail();
		ifsaButlerNetEmailService.arrayOfString result = emailService.Create(UserInfo.getUserEmail(), studentFirstName, studentLastName, forwardingEmail, contactId);
		system.debug(result);
	}

	@future (callout=true)
	public static void updateIFSAButlerNETEmail(String studentEmailAddress, String forwardingAddress, String contactId)
	{
		ifsaButlerNetEmailService.BasicHttpBinding_IStudentEmail emailService = New ifsaButlerNetEmailService.BasicHttpBinding_IStudentEmail();
        ifsaButlerNetEmailService.arrayOfString result = emailService.Edit(UserInfo.getUserEmail(), studentEmailAddress, forwardingAddress, contactId);
        system.debug(result);
	}

	@future (callout=true)
	private static void deleteIFSAButlerNETEmail(String studentEmailAddress, String contactId)
	{
		ifsaButlerNetEmailService.BasicHttpBinding_IStudentEmail emailService = New ifsaButlerNetEmailService.BasicHttpBinding_IStudentEmail();
        ifsaButlerNetEmailService.arrayOfString result = emailService.Delete_x(UserInfo.getUserEmail(), studentEmailAddress, contactId);
        system.debug(result);
	}

	/**
	 * Method to update the contact owner to equal that of the contact's primary application
	 */	
	public static void updateContactOwner(Map<Id, Contact> newMap, triggerType type)
	{
		
		if (type == triggertype.isBefore)
		{
			// Happens before update

			List<Application__c> primaryApps = [SELECT Id, Applicant__c, OwnerId FROM Application__c WHERE Designation__c = 'Primary' AND Applicant__c IN: newMap.keySet()];
			
			for(Application__c app: primaryApps)
			{
				if(newMap.get(app.Applicant__c).OwnerId != app.OwnerId)
					newMap.get(app.Applicant__c).OwnerId = app.OwnerId;
			}

		}
		else if (type == triggerType.isAfter) 
		{
			List<Id> studentIds = new List<Id>();
			for(Contact c: newMap.values())
			{
				if(c.RecordTypeId == Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId())
				{
					studentIds.add(c.Id);
				}
			}
			
			try
			{
				updateParentGuardianOwner(studentIds);
			}
			catch(AsyncException e)
			{
				System.debug('Running in Future, Cannot update parent/guardians at this time');
			}
			/*
			// Happens after update

			Id rtId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Other').getRecordTypeId();
			List<Contact> contactsToUpdate = new List<Contact>();

			// Get list of contacts where record type is 'Other' and the related student is in the trigger map
			List<Contact> contacts = [SELECT Id, OwnerId, Student__r.OwnerId FROM Contact WHERE RecordTypeId = :rtId AND Student__c IN: newMap.keySet()];


			for(Contact c: contacts)
			{
				if(c.OwnerId != c.Student__r.OwnerId)
				{
					c.OwnerId = c.Student__r.OwnerId;
					contactsToUpdate.add(c);
				}
			}
			// Update Parent/Guardians
			Database.update(contactsToUpdate);
			*/
		}
	}
	@future
	private static void updateParentGuardianOwner(List<Id> studentIds)
	{
		Id rtId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Other').getRecordTypeId();
		List<Contact> contactsToUpdate = new List<Contact>();

		// Get list of contacts where record type is 'Other' and the related student is in the trigger map
		List<Contact> contacts = [SELECT Id, OwnerId, Student__r.OwnerId FROM Contact WHERE RecordTypeId = :rtId AND Student__c IN: studentIds];

		for(Contact c: contacts)
		{
			if(c.OwnerId != c.Student__r.OwnerId)
			{
				c.OwnerId = c.Student__r.OwnerId;
				contactsToUpdate.add(c);
			}
		}
		// Update Parent/Guardians
		if(!contactsToUpdate.isEmpty())
		{
			Database.update(contactsToUpdate);
		}
	}
	/**
	 * Method to verify Contact Support Personnel Records for a contact
	 */	
	public static void verifyContactSupportPersonnelRecords(List<Contact> newRecords, Map<Id, Contact> oldMap, Map<Id, Contact> newMap, triggerType type)
	{
		/* //Remove non-students from newRecords, oldMap, newMap
		//AUCARSON 11.01.2017 Removed query call
		//studentRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Contact' And Name = 'Student'].get(0).Id;
		studentRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();

		
		newRecords = removeNonStudentsFromList(newRecords);
		oldMap = oldMap != null ? removeNonStudentsFromMap(oldMap) : null;
		newMap = newMap != null ? removeNonStudentsFromMap(newMap) : null;


		List<Contact_Support_Personnel__c> cspRecordsToAdd = new List<Contact_Support_Personnel__c>();		
		String strType = '';

		if(type == triggerType.isInsert) 			
			strType = 'isInsert';
		else if(type == triggerType.isUpdate)
			strType = 'isUpdate';

		cspRecordsToAdd.addAll(contactCSPGeneration(oldmap, newMap));

		if(!cspRecordsToAdd.isEmpty())
		{
			updateCSP(strType, cspRecordsToAdd);
		} */
		//if(!applicationTriggerContextUtility.isFirstRunAndAfter())
		//	system.enqueueJob(new contactSupportPersonnelService(newRecords, newMap, oldMap));
	}
	
	//AUCARSON
	public static void removeInactive(List<Contact> newlst, Map<Id, Contact> oldMap)
	{
		//Grabbing Record Type Id for Advisor Contacts
		Id advisorId =Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Advisor').getRecordTypeId();

		List<Id> inactiveContactIds = new List<Id>();

		for(Contact c : newlst)
		{
			//Going through the contacts in newlst, if the Contact is an advisor and the Do Not Contact field has been checked
			//Add the contact Id to the inactiveContactId list
			if(c.Do_Not_Contact__c && !oldMap.get(c.Id).Do_Not_Contact__c && c.RecordTypeId == advisorId)
			{
				inactiveContactIds.add(c.Id);
			}
		}

		//added null check
		if(!inactiveContactIds.isEmpty())
		{
			//Query related support personel records for inactive advisor contacts
			List<Support_Personnel__c> relatedSPs = [SELECT Id FROM Support_Personnel__c WHERE Non_IFSA_Staff__c IN :inactiveContactIds];

			//delete related SPs
			delete relatedSPs;
		}

	}

	public static void upsertContactSP(Map<Id,Contact> newMap, Map<Id,Contact> oldmap)
	{
		//Getting record Types for Contacts and Support Personel
		Id advisorRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Advisor').getRecordTypeId();
		Id guardianRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Other').getRecordTypeId();
		Id studentRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId();
		Id spAccountRT = Schema.SObjectType.Support_Personnel__c.getRecordTypeInfosByName().get('Account').getRecordTypeId();
		Id spContactRT = Schema.SObjectType.Support_Personnel__c.getRecordTypeInfosByName().get('Contact').getRecordTypeId();

		//List for holding Support Personnels to be created
		List<Support_Personnel__c> upsertSP = new List<Support_Personnel__c>();
		List<Application__c> relatedApplications = new List<Application__c>();
		List<Id> relatedAccountIds = new List<Id>();

		List<Support_Personnel__c> spList = [SELECT Id, Non_IFSA_Staff__c, Emergency_Contact__c, Type__c, Send_Marketing_Materials__c, Account__c, Support_Role_Type__c, RecordTypeId FROM Support_Personnel__c WHERE Non_IFSA_Staff__c In: newMap.keySet()];
		Map<Id,Support_Personnel__c> spMap = new Map<Id, Support_Personnel__c>();
		for(Support_Personnel__c sp : spList)
		{
			System.debug('#### : ' + sp.Non_IFSA_Staff__c);
			System.debug('#### : ' + sp);
			spMap.put(sp.Non_IFSA_Staff__c, sp);
		}
		for(Contact c : newMap.values())
		{
			//if there is no SP associated with 
			if(spMap.get(c.Id) == null)
			{
				//Check to see if listed as an emergency contact and either an Advisor or Parent/Guardian
				if((c.RecordTypeId == advisorRT && c.Emergency_Contact__c && !c.Created_for_Custom__c) || (c.RecordTypeId == guardianRT && (c.Emergency_Contact__c || c.Send_Marketing_Materials__c)))
				{
					Support_Personnel__c sp = new Support_Personnel__c();
					sp.Non_IFSA_Staff__c = c.Id;
					sp.Emergency_Contact__c = c.Emergency_Contact__c;
					sp.Type__c = 'Non IFSA Staff';
					sp.Send_Marketing_Materials__c = c.Send_Marketing_Materials__c;
					//if the contact is an Advisor
					if(c.RecordTypeId == advisorRT)
					{
						sp.Account__c = c.AccountId;
						//Add related Account Id to query for Later
						relatedAccountIds.add(c.AccountId);
						sp.Support_Role_Type__c = 'Advisor';
						sp.RecordTypeId = spAccountRT;
					}
					//Otherwise the contact is a Parent/Guardian
					else
					{
						sp.Contact__c = c.Student__c;
						//Add related student Id to query later
						relatedAccountIds.add(c.Student__c);
						sp.Support_Role_Type__c = 'Parent/Guardian';
						sp.RecordTypeId = spContactRT;
					}
					upsertSP.add(sp);
				}
			}
			else {
				if((c.RecordTypeId == advisorRT || c.RecordTypeId == guardianRT) && (c.Emergency_Contact__c != oldMap.get(c.Id).Emergency_Contact__c || c.Send_Marketing_Materials__c != oldMap.get(c.Id).Send_Marketing_Materials__c))
				{
					spMap.get(c.Id).Send_Marketing_Materials__c = c.Send_Marketing_Materials__c;
					spMap.get(c.Id).Emergency_Contact__c = c.Emergency_Contact__c;
					upsertSP.add(spMap.get(c.Id));
				}
			}

		}
		if(!upsertSP.isEmpty()){
			upsert upsertSP;
			//if()
			List<Id> homeInstitutionIds =  new List<Id>();
			for(Account a: [SELECT Institution__c FROM Account WHERE Id IN :relatedAccountIds])
			{
				homeInstitutionIds.add(a.Institution__c);
			}
			relatedApplications.addAll(new List<Application__c>([SELECT Id FROM Application__c WHERE Applicant__c IN (SELECT Id FROM Contact WHERE Home_Institution__c IN: homeInstitutionIds)]));
			relatedApplications.addAll(new List<Application__c>([SELECT Id FROM Application__c WHERE Applicant__c IN (SELECT Id FROM Contact WHERE Id IN :relatedAccountIds)]));
			//Get the student's supported by these SP records and
			// ghost update them to create new CSPs via batch
			sObjectBatchUpdater.batchUpdate(relatedApplications, 20, sObjectBatchUpdater.dmlTypes.dmlUpdate);

		}

	}
	//AUCARSON

	// JHOLT
	public static void checkGPARequirement(Map<Id, Contact> newMap, Map<Id, Contact> oldMap)
	{
		// Establish Task List
        List<Task> tList = new List<Task>();
		// Get Active Application Ids for students in this trigger
		Set<Id> appIds = new Set<Id>();
		for(Contact c: newmap.values())
		{
			if(c.Active_Application__c != null)
			{
				Id activeAppId = c.Active_Application__c;
				appIds.add(activeAppId);
			}
		}
		// Get application gpa information for Ids in appIds
		Map<Id, Application__c> appMap = new Map<Id, Application__c>([SELECT Id, OwnerId, Program_Term__r.Required_GPA__c FROM Application__c WHERE Id IN : appIds]);
		// For all contacts entering trigger, check to see if GPA changed. if so, continue.
		for(Contact c: newMap.values())
		{
			// Check to see if Student already has this task
			if(!c.GPA_Task_Created__c && c.GPA__c != null && c.GPA__c != oldMap.get(c.Id).GPA__c && appMap.containsKey(c.Active_Application__c))
			{
				Decimal actualGPA = c.GPA__c;
				Decimal requiredGPA = appMap.get(c.Active_Application__c).Program_Term__r.Required_GPA__c;
				if(actualGPA <requiredGPA)
				{
					// Create task
                    Task t = new Task();
                    t.OwnerId = appMap.get(c.Active_Application__c).OwnerId;
                    t.Subject = 'Student GPA does not meet program GPA requirement';
                    t.Status = 'Not Started';
                    t.Priority = 'Normal';
                    t.WhatId = c.Active_Application__c;
                    tlist.add(t);
				}
			}
		}
		// Insert Task List
        Database.insert(tList);
	}

	public static void unescapeContactName(List<Contact> newRecords)
	{
		List<String> nameFields = new List<String>{'FirstName', 'LastName', 'Middle_Name__c'};
		Map<Id, Contact> contactMap = new Map<Id, Contact>();
		for(Contact c: newRecords)
		{
			for(String field: nameFields)
			{
				if(c.get(field) != null)
				{
					String value = (String) c.get(field);
					Integer counter = 0;
					while (value.contains('&')) {
						counter = counter + 1;
						System.debug(value);
						value = value.unescapeHtml4();
						c.put(field, value);
						if(c.Id != null)
						{
							contactMap.put(c.Id, c);
						}
						if(counter == 10)
						{
							throw new ifsaDataException('Tried 10 times');
						}
					}
				}				
			}
		}
		if(!contactMap.isEmpty())
		{
			List<User> users = [SELECT Id, FirstName, LastName, ContactId FROM User WHERE ContactId IN: contactMap.keySet()];
			List<Application__c> applications = [SELECT Id, Name, Applicant__c, Program_Term__r.Name FROM Application__c WHERE Applicant__c IN: contactMap.keySet()];
			List<SObject> objectsToUpdate = new List<SObject>();
			for(Id contactId: contactMap.keySet())
			{
				Contact c = contactMap.get(contactId);
				if(c.AccountId != null){
					Account a = new Account(
						Id = c.AccountId,
						Name = c.FirstName + ' ' + c.LastName
					);
					objectsToUpdate.add(a);
				}
			}
			for(User u: users)
			{
				u.FirstName = contactMap.get(u.ContactId).FirstName;
				u.LastName = contactMap.get(u.ContactId).LastName;
			}
			database.update(users);
			for(Application__c app: applications)
			{
				app.Name = contactMap.get(app.Applicant__c).FirstName + ' ' + contactMap.get(app.Applicant__c).LastName + ' ' + app.Program_Term__r.Name;
				app.Name = app.Name.left(80);
				objectsToUpdate.add(app);
			}

			objectsToUpdate.sort();
			
			
			system.enqueueJob(new sObjectQueueableUpdater(objectsToUpdate, sObjectQueueableUpdater.dmlOperation.isUpdate, 20));
		}
	}
}