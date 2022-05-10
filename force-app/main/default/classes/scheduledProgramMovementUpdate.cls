global class scheduledProgramMovementUpdate implements Database.Batchable<SObject>, Schedulable {
	
	String query;
	Id programMovementRT = Schema.SObjectType.Schedule__c.getRecordTypeInfosByName().get('Program Movement').getRecordTypeId();
	
	global scheduledProgramMovementUpdate() 
	{
		//Pull all Program Terms that have child Program Movement schedule records that have a start date equal to or past today
		query = 'SELECT Id, Locality__c, Country__c, ' +
					'(SELECT Id, Locality__c, Country__c FROM Schedules__r WHERE Start_Date__c <= TODAY AND RecordTypeId = :programMovementRT ORDER BY Start_Date__c DESC) ' + 
				'FROM Program_Term__c ' + 
				'WHERE Id IN (SELECT Program_Term__c FROM Schedule__c WHERE Program_Term__c != null AND RecordTypeId = :programMovementRT)';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) 
	{
		return Database.getQueryLocator(query);

	}
   	global void execute(Database.BatchableContext BC, List<Program_Term__c> scope) 
   	{
		List<Program_Term__c> ptList = new List<Program_Term__c>();

		for(Program_Term__c pt : scope)
		{
			//If there are Program Movement schedule records, set the program term's locality and/or country
			if(pt.Schedules__r.size() > 0)
			{
				pt.Locality__c = pt.Schedules__r[0].Locality__c;
				pt.Country__c = pt.Schedules__r[0].Country__c;
				//add to updateList
				ptList.add(pt);
			}
		}
		//if Update list isn't empty update items in it
		if(!ptList.isEmpty())
		{
			update ptList;
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	public void execute(SchedulableContext c)
	{
		scheduledProgramMovementUpdate b = new scheduledProgramMovementUpdate(); //ur batch class
      	database.executebatch(b);
	}
	
}