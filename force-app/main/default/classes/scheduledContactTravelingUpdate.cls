/**
 * @description Schedulable class to update application status, contact traveling status, trip status, and purges Contact Support Personnel records
 * @author Brock Barlow
 */
global class scheduledContactTravelingUpdate implements Schedulable {
	public void execute(SchedulableContext c)
	{
		updateApplicationStatuses();
		updateTravelingStatusOnContacts();
		updateTripStatus();
	}

	public static void updateApplicationStatuses()
	{
		// Get Apps to update
		/*
		This SOQL may need changed so that students on China/India/Austrailia/New Zealand programs change to "On Site" when the program start date is today because of the difference in timezones.
		To do this first, get Ids of China/India/Austrailia/New Zealand country records, place into Map<Id, Country__c> to quickly get country Ids in a set.
		Second, modify SOQL to retrieve applications "... WHERE ((Program_Term_Start_Date__c <= TODAY AND Program_Term__r.Country__c IN : countryMap.keySet()) || (Program_Term_Start_Date__c <= YESTERDAY) AMD Status__c IN ('Accepted','Accepted (with Conditions)') AND ..."
		*/
		List<Application__c> appsToUpdate = [
			SELECT Id, Status__c, Applicant__c, Program_Term_Start_Date__c, Program_Term_End_Date__c 
			FROM Application__c 
			WHERE (
				Program_Term_Start_Date__c <= YESTERDAY AND Status__c IN ('Accepted','Accepted (with Conditions)') AND ( (Applicant__r.Traveling_Status__c = 'Pre-Program' AND Final_Arrival__c <= TODAY) OR Applicant__r.Created_For_Custom__c = true)) 
				OR (Status__c = 'On Site' AND Program_Term_End_Date__c <= YESTERDAY)
		];

		List<SObject> objectsToUpdate = new List<SObject>();

		// Iterate over appsToUpdate
		for(Application__c app: appsToUpdate)
		{
			if (app.Status__c.contains('Accepted') && Datetime.now() > app.Program_Term_Start_Date__c)
			{
				app.Status__c = 'On Site';
				Contact c = new Contact(Id = app.Applicant__c);
				c.Traveling_Status__c = 'Not Traveling';
				c.On_Site_Application__c = app.Id;
				objectsToUpdate.add(c);
				objectsToUpdate.add(app);
			}
			else if (app.Status__c == 'On Site' && Datetime.now() > app.Program_Term_End_Date__c)
			{
				app.Status__c = 'Program Completed';
				objectsToUpdate.add(app);
			}
		}
		objectsToUpdate.sort();
		// Update Records in Batches
		sObjectBatchUpdater.batchUpdate(objectsToUpdate, 25, sObjectBatchUpdater.dmlTypes.dmlUpdate);
		//Database.Update(objectsToUpdate);
	}
	public static void updateTravelingStatusOnContacts()
	{		
		// Get Contacts to update
		List<Application__c> apps = [SELECT Id, Applicant__r.Traveling_Status__c FROM Application__c WHERE (First_Departure__c <= TODAY AND Applicant__r.Traveling_Status__c = 'Not Traveling' AND Status__c IN ('Accepted', 'Accepted (with Conditions)'))]; // OR (Final_Arrival__c <= TODAY AND Applicant__r.Traveling_Status__c = 'Pre-Program')];
		List<Contact> contactsToUpdate = new List<Contact>();
		// Iterate over contactsToUpdate
		for(Application__c a: apps)
		{
			Contact c = new Contact(Id = a.Applicant__c);

			if(a.Applicant__r.Traveling_Status__c == 'Not Traveling')
			{
				c.Traveling_Status__c = 'Pre-Program';
			}
			else if(a.Applicant__r.Traveling_Status__c == 'Pre-Program')
			{
				c.Traveling_Status__c = 'Not Traveling';
			}
			c.On_Site_Application__c = a.Id;
			contactsToUpdate.add(c);
		}

		// Update Records
		sObjectBatchUpdater.batchUpdate(contactsToUpdate, 25, sObjectBatchUpdater.dmlTypes.dmlUpdate);
		//Database.Update(contactsToUpdate);
	}
	public static void updateTripStatus()
	{
		// Get trips starting today or before today OR ending yesterday or before
		List<Trip__c> trips = [SELECT Id, Status__c FROM Trip__c WHERE (Status__c = 'Upcoming' AND Start_Date__c <= TODAY) OR (Status__c = 'Active' AND End_Date__c <= YESTERDAY)];
		// Update the statuses of the trips
		for(Trip__c t: trips)
		{
			// Update the status trips that are starting today
			if(t.Status__c == 'Upcoming')
			{
				t.Status__c = 'Active';
			}
			// Update the status trips that ended yesterday
			else
			{
				t.Status__c = 'Complete';
			}
		}
		// Update all the records in 'trips' using this batchable method
		sObjectBatchUpdater.batchUpdate(trips, 50, sObjectBatchUpdater.dmlTypes.dmlUpdate);
	}

	public static void updateEmailAddresses(List<Id> contactIds)
	{
		Contact c = [SELECT Id, Email, School_Email__c, Personal_Email__c, (SELECT Id FROM Applications__r WHERE Status__c IN ('Program Selected', 'Ready To Submit', 'Submitted', 'Accepted', 'Accepted (with Conditions)', 'On Site', 'Program Completed')) FROM Contact WHERE Id IN: contactIds];
		
		if(!c.Applications__r.isEmpty())
		{
			Boolean changed = false;
			String personalEmail = c.Personal_Email__c;
			String schoolEmail = c.School_Email__c;
			String defaultEmail = c.Email;
			if(personalEmail != null)
			{
				changed = true;
				if(defaultEmail != schoolEmail && schoolEmail == null)
				{
					schoolEmail = defaultEmail;
				}
				defaultEmail = personalEmail;
			}
			if(changed)
			{
				c.Personal_Email__c = personalEmail;
				c.School_Email__c = schoolEmail;
				c.Email = defaultEmail;
				system.enqueueJob(new sObjectQueueableUpdater(new List<SObject>{c}));
			}
		}		
	}
}