/**
 * DEPRECIATED
 */
global without sharing class ifsaApplicationAutoAssign
{
	/*@InvocableMethod(
					label='Assign Application and Contact Owner'
					description='Assigns application and applicant based on program term owner.')
	public static void applicationAutoAssign(List<Id> applicationIdsToAssign)
	{
		List<Application__c> applicationList = [SELECT Id, OwnerId, Applicant__c, Program_Term__c, Program_Option__c, Designation__c FROM Application__c WHERE Id IN: applicationIdsToAssign];
		List<Id> contactIds = new List<Id>();
		List<Id> programTermIds = new List<Id>();
		List<Id> programOptionIds = new List<Id>();

		for(Application__c app: applicationList)
		{
			contactIds.add(app.Applicant__c);
			programTermIds.add(app.Program_Term__c);			
			if(app.Program_Option__c != null)
			{
				programOptionIds.add(app.Program_Option__c);
			}
		}
		
		List<Contact> applicantList = [SELECT Id, OwnerId FROM Contact WHERE Id IN: contactIds];
		List<Program_Term__c> programTermList = [SELECT Id, OwnerId FROM Program_Term__c WHERE Id IN: programTermIds];
		List<Program_Option__c> programOptionList = programOptionIds.isEmpty() == false ? [SELECT Id, Program_Advisor__c FROM Program_Option__c WHERE Id IN: programOptionIds] : new List<Program_Option__c>();

		for(Application__c application : applicationList)
		{
			for(Contact applicant : applicantList)
			{
				if(application.Applicant__c == applicant.Id)
				{
					for(Program_Term__c programTerm : programTermList)
					{
						if(programOptionList.size() > 0 && application.Program_Option__c != null)
						{
							for(Program_Option__c programOption : programOptionList)
							{
								if(programOption.Id == application.Program_Option__c)
								{
									application.OwnerId = programOption.Program_Advisor__c;
									if(application.Designation__c == 'Primary')
									{
										applicant.OwnerId = programOption.Program_Advisor__c;
										system.debug('Contact Owner changed to option advior');
									}
								}
							}
						}
						else if(programTerm.Id == application.Program_Term__c)
						{
							application.OwnerId = programTerm.OwnerId;
							if(application.Designation__c == 'Primary')
							{
								applicant.OwnerId = programTerm.OwnerId;
								system.debug('Contact Owner changed to term owner');
							}							
						}
					}
				}
			}
		}
		List<SObject> objectsToUpdate = new List<SObject>();
		for(Application__c app: applicationList)
		{
			objectsToUpdate.add(app);
		}
		for(Contact c: applicantList)
		{
			objectsToUpdate.add(c);
		}
		
		Database.update(objectsToUpdate);

		//Database.update(applicationList);
		//Database.update(applicantList);
	}*/
}