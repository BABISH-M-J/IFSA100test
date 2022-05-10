/**
 * @description Trigger Handler for Account. Executes business logic in <<attachmentService>>
 * @author Brock Barlow
 */
// ApexDoc updated 1/25/2021 Brock Barlow
public without sharing class attachmentTriggerHandler extends BaseTriggerHandler 
{
	final List<Attachment> newRecords;
	final List<Attachment> oldRecords;
	final Map<Id, Attachment> oldMap;
	final Map<Id, Attachment> newMap;
	/**
	 * Constructor, populates lists and maps from the Trigger object
	 */
	public attachmentTriggerHandler()
	{
		this.newRecords = (List<Attachment>) Trigger.new;
		this.oldRecords = (List<Attachment>) Trigger.old;
		this.oldMap = (Map<Id, Attachment>) Trigger.oldMap;
		this.newMap = (Map<Id, Attachment>) Trigger.newMap;
	}
	/**
	 * Before Insert
	 */
	public override void afterInsert()
    {
        attachmentService.updateParentRecordStatus(newRecords);
    }
}