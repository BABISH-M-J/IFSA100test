/**
 * A queueable class that works with <<batchCaseTeamGenerator>> for case team creation for Health & Safety cases. As of December 2020, the case record types used by this class are no longer being  used by IFSA and case team creation is handled by <<promiseHealthSafetyCase>>
 * @author Brock Barlow
 */
public class caseTeamQueueable implements Queueable {
	
	public Case theCase {get;set;}
	public List<Case_Student__c> relatedStudents {get;set;}
	public List<Id> applicationIds {get;set;}

	public caseTeamQueueable(Case c, List<Case_Student__c> rs, List<Id> appIds)
	{
		this.theCase = c;
		this.relatedStudents = rs;
		this.applicationIds = appIds;
		system.debug('Created caseTeamQueueable');
	}
	
	public void execute(QueueableContext context) {
		theCase.Case_Team_Job_Id__c = Database.executeBatch(new batchCaseTeamGenerator(theCase, relatedStudents, applicationIds));
		theCase.Generate_Case_Team__c = false;
		Database.update(theCase);
	}
}