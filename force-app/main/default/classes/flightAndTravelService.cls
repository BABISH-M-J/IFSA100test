/**
 * Service class for Flight__c and Travel_Plan__c
 * @author Brock Barlow
 */
// ApexDoc updated 2/8/2021 Brock Barlow
public with sharing class flightAndTravelService 
{
	//When flights are entered we need to tell the associated travel plan what flight leaves first and arrives last
	/**
	 * Updates Travel_Plan__c records with the first departure and final arrival dates
	 * @param newRecords New Flight__c records from <<flightTriggerHandler>>
	 * @param oldRecords Old Flight__c records from <<flightTriggerHandler>>
	 * @param type The type of trigger operation
	 */
	public static void getFirstDepartureAndLastArrival(List<Flight__c> newRecords, List<Flight__c> oldRecords, TriggerOperation type)
	{
		Set<Id> travelPlanIds = new Set<Id>();
		switch on type {
			when AFTER_INSERT, AFTER_UPDATE {
				for(Flight__c f: newRecords)
				{
					if(f.Travel_Plan__c != null)
					{
						travelPlanIds.add(f.Travel_Plan__c);
					}
				}
			}
			when BEFORE_DELETE{
				for(Flight__c f: oldRecords)
				{
					if(f.Travel_Plan__c != null)
					{
						travelPlanIds.add(f.Travel_Plan__c);
					}
				}
			}
		}
		List<Flight__c> flights = [SELECT Id, Flight_Departure__c, Flight_Arrival__c, Travel_Plan__c FROM Flight__c WHERE Type__c = 'Outgoing' AND Travel_Plan__c IN: travelPlanIds];

		//Group flights together by travel plan
		Map<Id, List<Flight__c>> tpFlights = new Map<Id, List<Flight__c>>();
		for(Flight__c f: flights)
		{
			if(f.Travel_Plan__c != null)
			{
				if(!tpFlights.containsKey(f.Travel_Plan__c))
					tpFlights.put(f.Travel_Plan__c, new List<Flight__c>());

				tpFlights.get(f.Travel_Plan__c).add(f);
			}			
		}

		Map<Id, Travel_Plan__c> tpMap = new Map<Id, Travel_Plan__c>([SELECT Id, First_Departure__c, Final_Arrival__c FROM Travel_Plan__c WHERE Id IN: tpFlights.keySet()]);

		for(Travel_Plan__c tp: tpMap.values())
		{
			Date fd;
			Date fa;
			for(Flight__c f: tpFlights.get(tp.Id))
			{
				//Set the earliest flight departure
				if(f.Flight_Departure__c < fd || fd == NULL)
				{
					fd = f.Flight_Departure__c;
				}
				//Set the final flight arrival
				if(f.Flight_Arrival__c > fa || fa == NULL)
				{
					fa = f.Flight_Arrival__c;
				}				
			}
			tp.First_Departure__c = fd;
			tp.Final_Arrival__c = fa;
		}
		Database.update(tpMap.values());
	}
}