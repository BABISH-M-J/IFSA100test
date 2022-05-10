/**
 * Callable, TriggerHandlerExtendable class for IFSA Health and Safety
 */
public without sharing class HealthSafety_CaseTriggerHandlerExtension implements Callable, TriggerHandlerExtendable 
{
    // CONSTANTS
    final String NEW_MAP = 'newMap';
    final String NEW_RECORDS = 'newRecords';
    final String OLD_MAP = 'oldMap';
    final String OLD_RECORDS = 'oldRecords';
    // MEMBER VARIABLES
    List<Case> newRecords;
    List<Case> oldRecords;
    Map<Id,Case> newMap;
    Map<Id,Case> oldMap;
    List<Case> newRecordsLegacyIncidents;
	List<Case> oldRecordsLegacyIncidents;
	Map<Id, Case> oldMapLegacyIncidents;
	Map<Id, Case> newMapLegacyIncidents;
	List<Case> newRecordsIncidents;
	List<Case> oldRecordsIncidents;
	Map<Id, Case> oldMapIncidents;
	Map<Id, Case> newMapIncidents;
    // METHODS

    // Implemented TriggerHandlerExtendable Methods
    /**
     * Called in BEFORE INSERT trigger
     */
    public void beforeInsert()
    {
        if(!newRecordsLegacyIncidents.isEmpty())
		{
			caseService.generateCaseTeam(newRecordsLegacyIncidents);
		}
    }
    /**
     * Called in BEFORE UPDATE trigger
     */
    public void beforeUpdate()
    {
        
    }
    /**
     * Called in BEFORE DELETE trigger
     */
    public void beforeDelete()
    {
        
    }
    /**
     * Called in BEFORE UNDELETE trigger
     */
    public void beforeUndelete()
    {
        
    }
    /**
     * Called in AFTER INSERT trigger
     */
    public void afterInsert()
    {
        if(!newRecordsIncidents.isEmpty()){
            System.Debug(LoggingLevel.INFO, 'Process After Insert');
            caseService.addCaseCreatorToCaseTeam(newRecordsIncidents);
			caseService.processNewIncidents(newRecordsIncidents);
		}
		if(!newRecordsLegacyIncidents.isEmpty())
		{
			caseService.linkStudentsToGlobalCase(newRecordsLegacyIncidents);
			caseService.linkStudentsToStudentCase(newRecordsLegacyIncidents);
			caseService.linkCaseToAffected(newRecordsLegacyIncidents);
		}
    }
    /**
     * Called in AFTER UPDATE trigger
     */
    public void afterUpdate()
    {
        if(!newRecordsIncidents.isEmpty()){
            System.Debug(LoggingLevel.INFO, 'Process After Update');
			caseService.processIncidentUpdates(newRecords);
		}
    }
    /**
     * Called in AFTER DELETE trigger
     */
    public void afterDelete()
    {
        
    }
    /**
     * Called in AFTER UNDELETE trigger
     */
    public void afterUndelete()
    {
        
    }

    // Implemented Callable Method
    public Object call(String action, Map<String, Object> arg)
    {
        switch on action {
            when 'beforeInsert' {
                newRecords = getConcreteList(arg.get(NEW_RECORDS));
                splitHealthAndSafetyCases();
                beforeInsert();
                return true;
            }
            when 'beforeUpdate' {
                newMap = getConcreteMap(arg.get(NEW_MAP));
                oldMap = getConcreteMap(arg.get(OLD_MAP));
                newRecords = getConcreteList(arg.get(NEW_RECORDS));
                oldRecords = getConcreteList(arg.get(OLD_RECORDS));
                splitHealthAndSafetyCases();
                beforeUpdate();
                return true;
            }
            when 'beforeDelete' {
                oldMap = getConcreteMap(arg.get(OLD_MAP));
                oldRecords = getConcreteList(arg.get(OLD_RECORDS));
                splitHealthAndSafetyCases();
                beforeDelete();
                return true;
            }
            when 'beforeUndelete' {
                newRecords = getConcreteList(arg.get(NEW_RECORDS));
                splitHealthAndSafetyCases();
                beforeUndelete();
                return true;
            }
            when 'afterInsert' {
                newMap = getConcreteMap(arg.get(NEW_MAP));
                newRecords = getConcreteList(arg.get(NEW_RECORDS));
                splitHealthAndSafetyCases();
                afterInsert();
                return true;
            }
            when 'afterUpdate' {
                newMap = getConcreteMap(arg.get(NEW_MAP));
                oldMap = getConcreteMap(arg.get(OLD_MAP));
                newRecords = getConcreteList(arg.get(NEW_RECORDS));
                oldRecords = getConcreteList(arg.get(OLD_RECORDS));
                splitHealthAndSafetyCases();
                afterUpdate();
                return true;
            }
            when 'afterDelete' {
                oldMap = getConcreteMap(arg.get(OLD_MAP));
                oldRecords = getConcreteList(arg.get(OLD_RECORDS));
                splitHealthAndSafetyCases();
                afterDelete();
                return true;
            }
            when 'afterUndelete' {
                newMap = getConcreteMap(arg.get(NEW_MAP));
                newRecords = getConcreteList(arg.get(NEW_RECORDS));
                splitHealthAndSafetyCases();
                afterUndelete();
                return true;
            }
            when else {
                throw new HealthSafety_CaseTriggerHandlerExtensionMalformedCallException('Method not implemented');
            }
        }
    }
    /**
     * casts generic object to Map<Id, Case>
     */
    Map<Id, Case> getConcreteMap(Object toConvert)
    {
        Map<Id,Case> result = (Map<Id, Case>) toConvert;
        return result;
    }
    /**
     * casts generic object to List<Case>
     */
    List<Case> getConcreteList(Object toConvert)
    {
        List<Case> result = (List<Case>) toConvert;
        return result;
    }
    
    void splitHealthAndSafetyCases()
    {
        Set<Id> legacyRT = caseService.legacyHSRT;
		Set<Id> hsRT = caseService.hsRT;
		Map<Id, Case> tempHSLegacyOld = new Map<Id, Case>();
		Map<Id, Case> tempHSLegacyNew = new Map<Id, Case>();
		Map<Id, Case> tempHSOld = new Map<Id, Case>();
		Map<Id, Case> tempHSNew = new Map<Id, Case>();
		for(Case c: newRecords){
			//Legacy HS cases
			if(legacyRT.contains(c.RecordTypeId))
			{
				if(newMap != null && newMap.containsKey(c.Id))
				{
					tempHSLegacyNew.put(c.Id, newMap.get(c.Id));
				}
				if(oldMap != null && oldMap.containsKey(c.Id))
				{
					tempHSLegacyOld.put(c.Id, oldMap.get(c.Id));
				}
			}
			// New HS cases
			else if(hsRT.contains(c.RecordTypeId))
			{
				if(newMap != null && newMap.containsKey(c.Id))
				{
					tempHSNew.put(c.Id, newMap.get(c.Id));
				}
				if(oldMap != null && oldMap.containsKey(c.Id))
				{
					tempHSOld.put(c.Id, oldMap.get(c.Id));
				}
			}
		}
		oldRecordsIncidents = tempHSOld.values();
		oldMapIncidents = tempHSOld;
		newRecordsIncidents = tempHSNew.values();
		newMapIncidents = tempHSNew;
		oldRecordsLegacyIncidents = tempHSLegacyOld.values();
		oldMapLegacyIncidents = tempHSLegacyOld;
		newRecordsLegacyIncidents = tempHSLegacyNew.values();
		newMapLegacyIncidents = tempHSLegacyNew;
    }
    /**
     * Exception class for HealthSafety_CaseTriggerHandlerExtension
     */
    public class HealthSafety_CaseTriggerHandlerExtensionMalformedCallException extends Exception {}
}