/**
* @description Utility class to connect Program_Term__c with their parent Program_Option__c
* @author Tim Osborn - November 2019
*/
public class programOptionService {
	/*
	public static void connectOptions() {		
		List<Program_Term__c> PTs = [SELECT Id, 											Name, 
											Program_Option__c,
											Program_Option_Name__c, 
											Program__c 
									   FROM Program_Term__c 
									  WHERE Program_Option_Name__c != null
									    AND Program_Option__c = null
										AND Parent_Program_Term__c != null
										AND Program__r.Category__c = 'Catalog']; 
		if (PTs.size() > 0) {
			List<Program_Option__c> POs = [SELECT Id, 
												  Name, 
												  Program__c 
											 FROM Program_Option__c];
			if (POs.size() > 0) {
				for (Program_Term__c pt : PTs) {
					Boolean updated = false;
					for (Program_Option__c po : POs) {
						if (pt.Program__c == po.Program__c && pt.Program_Option_Name__c.replace('\u2019', '\u0027') == po.Name){							
							if (updated) {
								System.System.debug('Program Term: ' + pt.Name + ' matches more than one Program Option.' );
							}
							pt.Program_Option__c = po.Id;
							//system.debug('Program Term ' + pt.Id);
							updated = true;								
						}
					}
					if (updated == false) {
						System.debug('Program Term: ' + pt.Name + ' does not match any Program Option.');
					}					
				}
				//pdate PTs;
				sObjectBatchUpdater.batchUpdate(PTs, 200);
			}
		}
	}*/
}