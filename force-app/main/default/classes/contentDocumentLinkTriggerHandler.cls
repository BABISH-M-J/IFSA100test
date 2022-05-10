/**
 * Trigger handler for ContentDocumentLink, executes methods on <<contentDocumentLinkService>>
 * @author Brock Barlow
 */
// ApexDoc updated 1/28/2021 Brock Barlow
public without sharing class contentDocumentLinkTriggerHandler extends BaseTriggerHandler
{
    final List<ContentDocumentLink> newRecords;
	final List<ContentDocumentLink> oldRecords;
	final Map<Id, ContentDocumentLink> oldMap;
	final Map<Id, ContentDocumentLink> newMap;
	/**
	 * Constructor, populates lists and maps from the Trigger object
	 */
	public contentDocumentLinkTriggerHandler()
	{
		this.newRecords = (List<ContentDocumentLink>) Trigger.new;
		this.oldRecords = (List<ContentDocumentLink>) Trigger.old;
		this.oldMap = (Map<Id, ContentDocumentLink>) Trigger.oldMap;
		this.newMap = (Map<Id, ContentDocumentLink>) Trigger.newMap;
	}
    /**
     * Before Insert
     */
	public override void beforeInsert()
	{
        contentDocumentLinkService.setVisibility(newRecords);
	}
    /**
     * After Insert
     */
	public override void afterInsert()
    {
        contentDocumentLinkService.setRecentUploadField(newRecords);
	}
}