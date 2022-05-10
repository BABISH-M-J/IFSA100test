/**
 * Apex controller to clone Program_Term__c (Standard Program Term or Parent Program Term record types) and their related records for a new Term__c
 * @author Brock Barlow
*/
// ApexDoc updated 2/16/2021 Brock Barlow
public without sharing class internalTermCloneController extends internalBaseController
{
    /**
     * Viewmodel
     */
    public internalTermCloneViewModel viewModel {get;set;}
    /**
     * Constructor
     */
    public internalTermCloneController()
    {
        super();

        Id ptId = ApexPages.currentPage().getParameters().get('ptId');
        this.viewModel = new internalTermCloneViewModel(ptId);

        this.populateViewModel();
    }

    private internalTermCloneViewModel populateViewModel()
	{
		return (internalTermCloneViewModel) super.populateInternalBaseViewModel(this.viewModel);
    }
    /**
     * Checks for a term for the specified section and year and creates a record if one does not exist.
     * @param sectionName The section of the term to return or create ('Spring', 'Fall', 'Summer', etc)
     * @param year The year of the term  to return or create (2020, 2021, etc)
     * @return Id of the returned or created Term__c record
     */
    @RemoteAction
    public static String createNewTerm(String sectionName, Integer year)
    {
        Term__c newTerm = new Term__c(Name = sectionName + ' ' + year, Section__c = sectionName, Year__c = year);
        List<Term__c> terms = [SELECT Id FROM Term__c WHERE Section__c =: sectionName AND Year__c =: year];
        if(!terms.isEmpty())
            return terms.get(0).Id;
        
        Database.SaveResult result = Database.insert(newTerm);

        if(result.isSuccess())
            return newTerm.Id;

        return null;
    }
    /**
     * Checks the status of an asynchronous apex job
     * @param jIds stringifyed list of job ids
     * @return The job's status
     */
    @RemoteAction
    public static String checkApexJobs(String jIds)
    {
        // Unescape JSON and clean up for processing
        jIds = jIds.unescapeEcmaScript();        
        jIds = jIds.removeStart('"');
        jIds = jIds.removeEnd('"');
        // Convert JSON to List of Job Ids
        List<String> jobIds = (List<String>) JSON.deserialize(jIds, List<String>.class);
        // Find Jobs
        List<AsyncApexJob> jobs = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE Id IN: jobIds];
        if(jobs.isEmpty())
            return 'Failed';
        Boolean completed = true;
        for(AsyncApexJob job: jobs)
        {
            system.debug(job.Status);
            if(job.Status == 'Aborted')
                return 'Aborted';
            else if(job.Status == 'Failed')
                return 'Failed';
            else if(job.Status == 'Running')
                completed = false;
        }
        if(completed)
        {
            return 'Completed';
        }        
        return 'Processing';
    }
    /**
     * Initializes a clone job
     * @param programTermId the Program_Term__c to clone
     * @param newTermId the Term__c to clone to
     * @return String - JSON serialized List<String> of Apex Job Ids
     */
    @RemoteAction
    public static String initializeCloneJob(String programTermId, String newTermId)
    {
        try
        {
            internalTermCloneViewModel vm = new internalTermCloneViewModel(programTermId, newTermId);
            return JSON.serialize(vm.programTerm.cloneRecords(newTermId, null));
            
        }
        catch (Exception e)
        {
            return null;
        }
    }
    public static String initializeCloneJob_OppWon(Id programTermId, Id newTermId, Id oppId)
    {
        try
        {
            internalTermCloneViewModel vm = new internalTermCloneViewModel(programTermId, newTermId);
            return JSON.serialize(vm.programTerm.cloneRecords(newTermId, null, oppId));
            
        }
        catch (Exception e)
        {
            return null;
        }
    }
    /**
     * Returns a Program_Term__c id for the specified Program__c and Term__c ids
     * @param programId
     * @param termId
     * @return String - Program_Term__c Id
     */
    @RemoteAction
    public static String getNewProgramTermId(String programId, String termId)
    {
        try
        {
            return [SELECT Id FROM Program_Term__c WHERE Program__c =: programId AND Term__c =: termId].get(0).Id;
        }
        catch (Exception e)
        {
            return null;
        }
    }
}