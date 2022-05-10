/**
 * Controller class for Cases
 * @author Brock Barlow
 */
// ApexDoc updated 2/16/2021 Brock Barlow
public without sharing class ifsaCaseController extends ifsaBaseController
{
	// Properties
	public ifsaCaseViewModel viewModel {get;set;}
	public Boolean isHealthAndSafety {get;set;}
	public Id recordTypeId {get;set;}
	public Id caseId {get;set;}
	static Map<String, CaseTeamRole> roleMap = new Map<String, CaseTeamRole>();
	/**
	 * Constructor Gets parameters from query string and initializes values
	 */
	public ifsaCaseController(ApexPages.StandardController caseController)
	{
		//Get query string values
		String caseId = ApexPages.currentPage().getParameters().get('caseId');
		String recordType = ApexPages.currentPage().getParameters().get('recordType');
		String studentId = ApexPages.currentPage().getParameters().get('studentId');		
		String parentCaseId = ApexPages.currentPage().getParameters().get('parentCaseId');
		String countryId = ApexPages.currentPage().getParameters().get('countryId');
		String hostInstitutionId = ApexPages.currentPage().getParameters().get('hostInstitutionId');
		String programId = ApexPages.currentPage().getParameters().get('programId');
		String cityId = ApexPages.currentPage().getParameters().get('cityId');
		String applicationId = ApexPages.currentPage().getParameters().get('appId');
		system.debug(parentCaseId);
		//Load view model from query string values
		if(ApexPages.currentPage().getParameters().get('caseId') != null || caseController.getId() != null)
		{
			if(caseController.getId() != null)			
				viewModel = new ifsaCaseViewModel(caseController.getId());
			else
				viewModel = new ifsaCaseViewModel(caseId);
			this.caseId = viewModel.caseId;
		}
		if(viewModel == null)
		{
			viewModel = new ifsaCaseViewModel();
		}
		if(recordType != null)
		{
			Id rtId;
			try {
				rtId = recordType;
				viewModel.getRecordTypeById(rtId);
			} catch (Exception e) {
				viewModel.getRecordTypeByName(recordType);	
			}
		}
		if(studentId != null)
		{			
			viewModel.getStudentById(studentId);			
		}
		if(parentCaseId != null)
		{			
			viewModel.getParentCaseById(parentCaseId);
		}
		if(countryId != null)
		{
			viewModel.getCountryById(countryId);
		}
		if(cityId != null)
		{
			viewModel.getCityById(cityId);			
		}
		if(hostInstitutionId != null)
		{
			viewModel.getHostInstitutionById(hostInstitutionId);
		}
		if(programId != null)
		{
			viewModel.getProgramById(programId);
		}
		if(applicationId != null)
		{
			viewModel.getApplicationById(applicationId);
		}
		if(viewModel.recordType != null)
		{
			this.isHealthAndSafety = viewModel.recordType.name.contains('Incident') || viewModel.recordType.name == 'Pre-Departure';
			this.recordTypeId = viewModel.recordType.recordTypeId;
			system.debug(this.isHealthAndSafety);
		}		
	}
	/**
	 * Allows certian record types of case not to be affected by VF page override that used with Cases
	 * @return PageReference
	 */
	public PageReference checkRecordType()
	{
		system.debug(this);
		if(!this.isHealthAndSafety)
		{
			return new PageReference('/500/e?RecordTypeId=' + this.recordTypeId + '&nooverride=1');
		}
		return null;
	}

	/**
	* Refreshes the viewModel object by using the Case Id
	* @param caseId - Id of the case
	* @return String - JSON serialized version of the viewModel object
	*/
	@RemoteAction
	public static String refreshViewModel(String caseId)
	{
		ifsaCaseViewModel returnedViewModel = new ifsaCaseViewModel(caseId);
		string returnString = JSON.serialize(returnedViewModel);	
		return returnString;
	}
	/**
	* Deserializes JSON data into an instance of ifsaCaseViewModel
	* @param jsonData - JSON Serialized version of a ifsaCaseViewModel object
	* @return ifsaCaseViewModel - Instance of ifsaCaseViewModel from deserialized JSON
	*/
	@RemoteAction
	public static ifsaCaseViewModel populateViewModel(String jsonData)
	{
		ifsaCaseViewModel viewModel = new ifsaCaseViewModel();
		if(jsonData == null)
		{
		  return null;
		}
		try
		{			
			//Unescape the json string
			//jsonData = jsonData.unescapeEcmaScript();
			//Remove leading and trailing '"' characters			
			jsonData = jsonData.removeStart('"');
			jsonData = jsonData.removeEnd('"');
			system.debug(jsonData);
		  	viewModel = (ifsaCaseViewModel) JSON.createParser(jsonData).readValueAs(Type.forName('ifsaCaseViewModel'));
		  	return viewModel;
		}
		catch(Exception e)
		{
		  System.debug(LoggingLevel.ERROR, e.getMessage());
		  return null;
		}
	}
	/**
	* Cancels edits made on ifsaCase VF page by regenerating the viewModel from the database
	* @param caseId - Id of the case
	* @return ifsaCaseViewModel - An instance of the viewModel
	*/
	@RemoteAction
	public static ifsaCaseViewModel cancelEdit(String caseId)
	{
		try
		{
			ifsaCaseViewModel viewModel = new ifsaCaseViewModel(caseId);
			return viewModel;
		}
		catch (Exception e)
		{
			return null;
		}
		return null;
	}
	/**
	* Creates a new case or updates an existing case
	* @param jsonData - JSON serialized instance of the viewModel
	* @return String - Id of the case saved
	*/
	@RemoteAction
	public static String saveCase(String jsonData)
	{
		// Deserialize viewModel
		ifsaCaseViewModel viewModel = ifsaCaseController.populateViewModel(jsonData);
		system.debug(viewModel.recordType.Name);
		// Convert viewModel to instance of a case SObject
		Case newCase = viewModel.convertViewModelToCase();
		Boolean caseTeamCreated = false;
		Id caseTeamGenJobId;
		Boolean isNewCase = newCase.Id == null ? true : false;
		Database.SaveResult success;
		if(!isNewCase && newCase.Status == 'Closed')
		{
			// If the case is being closed create a closed case comment and return back to the case page
			model_caseComment closeComment = new model_caseComment();
			closeComment.commentText = viewModel.closeComment;
			closeComment.caseId = newCase.Id;
			closeComment.saveComment();
			//ACARSON Nov.20.2017 changed return to newCase.Id from null so 'case not saved error doesn't display
			// return null;
			Database.update(newCase);
			return newCase.Id;
		}
		else if(isNewCase)
		{	
			// Insert the new case
			AssignmentRule AR = new AssignmentRule(); 
			//Assignment Rule Query
			AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
			//Creating DML Options
			Database.DMLOptions dmlOpts = new Database.DMLOptions();
			if(AR != null){
				dmlOpts.assignmentRuleHeader.assignmentRuleID = AR.ID;
				newCase.setOptions(dmlOpts);
				success = Database.insert(newCase);
			}
		}
		// Create Case Junction Objects to relate the case with students and other records(Country, Program, etc)
		// Temporary vars
		
		List<SObject> objectsToUpdate = new List<SObject>();
		List<SObject> objectsToInsert = new List<SObject>();		
		List<String> affectedStatuses = new List<String>{'Accepted', 'Accepted (with Conditions)'};
		List<String> statuses = new List<String>{'On Site'};
		caseService.relatedToCase masterrtc = new caseService.relatedToCase();
		// Link individual student with a "Incident_Student" case or "Pre_Departure" case
		if(viewModel.recordType.developerName == 'Incident_Student' || viewModel.recordType.developerName == 'Pre_Departure')// && viewModel.createdBy.userId == null )
		{
			masterrtc.import(caseService.studentCase(newCase, isNewCase, affectedStatuses));
		}
		// Link Countries and Students with "Incident_Country" case
		else if(viewModel.recordType.developerName == 'Incident_Country')
		{
			masterrtc.import(caseService.countryCase(newCase, viewModel.affectedCountries, affectedStatuses));
		}
		// Link City and Students with "Incident_City" case
		else if(viewModel.recordType.developerName == 'Incident_City')
		{
			masterrtc.import(caseService.cityCase(newCase, viewModel.affectedCities, affectedStatuses));
		}
		// Link Host Institutions and Students with "Incident_Host_Institution"
		else if(viewModel.recordType.developerName == 'Incident_Host_Institution')
		{
			masterrtc.import(caseService.hostCase(newCase, viewModel.affectedHostInstitutions, affectedStatuses));
		}
		// Link Programs and Students with "Incident_Program"
		else if(viewModel.recordType.developerName == 'Incident_Program')
		{
			masterrtc.import(caseService.programCase(newCase, viewModel.affectedPrograms, affectedStatuses));
		}
		// Gets all the students that are Traveling, On Site or recently program completed and links them to a massive case
		else if(viewModel.recordType.developerName == 'Incident_Global')
		{
			//masterrtc.import(caseService.globalCase(newCase, affectedStatuses));
		}
		Id caseTeamJobId;
		// Handles Incident and Pre-Departure cases, this allows us to use cases in other aspects of the business
		if(viewModel.recordType.developerName.contains('Incident_') || viewModel.recordType.developerName == 'Pre_Departure')
		{
			for(CaseTeamRole role: [SELECT Id, Name FROM CaseTeamRole])
			{
				roleMap.put(role.Name, role);
			}
			List<Id> applicationIds = new List<Id>();
			for(Application__c app: masterrtc.affectedApplications)
			{
				applicationIds.add(app.Id);
			}
			// Determine what records need updated or inserted and if the Case Team needs updated
			system.debug((!masterrtc.relatedStudents.isEmpty() && isNewCase) || !isNewCase);
			Boolean updateCaseTeam = false;
			if(((!masterrtc.objectsToInsert.isEmpty() || !masterrtc.objectsToUpdate.isEmpty()) && isNewCase) || (!masterrtc.relatedStudents.isEmpty() && isNewCase) || !isNewCase)
			{
				for(Case_Student__c cs: masterrtc.relatedStudents)
				{
					if(cs.Id == null)
					{
						masterrtc.objectsToInsert.add(cs);
						updateCaseTeam = true;
					}
					else
					{
						masterrtc.objectsToUpdate.add(cs);
						updateCaseTeam = true;
					}
				}
				// Insert or update related objects
				if(!masterrtc.objectsToInsert.isEmpty())
				{
					// THIS NEEDS TO BE BATCH
					String supportName = '';
					
					if([SELECT Id FROM CaseTeamMember WHERE MemberId =: UserInfo.getUserId() AND ParentId =: newCase.Id].isEmpty())
					{
						try
						{
							supportName = [SELECT Support_Role_Type__c FROM Support_Personnel__c WHERE IFSA_Staff__c =: UserInfo.getUserId() AND Support_Role_Type__c IN: roleMap.keySet()].get(0).Support_Role_Type__c;
						}
						catch (Exception e)
						{
							supportName = 'Other';
						}
						masterrtc.objectsToInsert.add(new CaseTeamMember(
							ParentId = newCase.Id,
							MemberId = UserInfo.getUserId(),
							TeamRoleId = roleMap.get(supportName).Id
						));
						sObjectBatchUpdater.batchUpdate(masterrtc.objectsToInsert, 200, sObjectBatchUpdater.dmlTypes.dmlInsert);
					}
				}
				if(!masterrtc.objectsToUpdate.isEmpty())
				{
					sObjectBatchUpdater.batchUpdate(masterrtc.objectsToUpdate, 75, sObjectBatchUpdater.dmlTypes.dmlUpdate);
				}
				// Generate case team from Incident Matrix and Support Personnel/Contact Support Personnel records only for new cases, the case update trigger handles this for updates
				if(isNewCase)
				{
					// Moved case team generation to batchable class so that in the event of a wide spread incident the case can save.
					// Brock Barlow
					// SW-12003 | Unable to Create a Global Incident Case
					// bug-4705 | Unable to Create a Global Incident Case
					//caseTeamCreated = generateCaseTeam(newCase, relatedStudents, applicationIds);
					newCase.Case_Team_Job_Id__c = Database.executeBatch(new batchCaseTeamGenerator(newCase, masterrtc.relatedStudents, applicationIds));
					newCase.Generate_Case_Team__c = false;
				}
				else {
					newCase.Generate_Case_Team__c = true;
				}
			}
			else
			{
				// Delete the case if there is an error
				if(!Test.isRunningTest())
					delete(newCase);
				return null;
			}
		}
		// This branch can be used if other aspects of the business uses cases for their processes
		else
		{

		}
		// Update the case and return the Id of the case to the page
		if(!isNewCase || success.isSuccess())
		{			
			newCase.Case_Team_Added__c = false;
			database.update(newCase);
			return JSON.serialize(new caseSaveResult(newCase.Id, caseTeamJobId));
		}
		return null;
	}
	
	/**
	* Method used to get the picklist items of a dependent picklist. This uses custom metadata types.
	* @param objectType - The name of the SObject being pulled
	* @param parentFieldName - The name of the controlling field
	* @param dependentFieldName - The name of the dependent field
	* @param parentValue - The value of the controlling field
	* @return List<String> - List dependent field values
	*/
	@RemoteAction
	public static List<String> getDependentPicklist(String objectType, String parentFieldName, String dependentFieldName, String parentValue)
	{
		Set<String> returnValues = new Set<String>();
		List<Incident_Category__mdt> dependentValues = new List<Incident_Category__mdt>();
		if(dependentFieldName == 'Incident_Sub_Subcategory__c')
		{
			dependentValues = [SELECT Sub_Sub_Category__c FROM Incident_Category__mdt WHERE Sub_Category__c =: parentValue AND Sub_Sub_Category__c != NULL];
		}
		else if(dependentFieldName == 'Incident_Sub_Category__c')
		{
			dependentValues = [SELECT Sub_Category__c FROM Incident_Category__mdt WHERE Category__c =: parentValue AND Sub_Category__c != NULL];
		}
		if(dependentValues.isEmpty())
		{
			return null;
		}
		else
		{
			for(Incident_Category__mdt incidentCategory: dependentValues)
			if(dependentFieldName == 'Incident_Sub_Subcategory__c')
			{
				returnValues.add(incidentCategory.Sub_Sub_Category__c);
			}
			else if(dependentFieldName == 'Incident_Sub_Category__c')
			{
				returnValues.add(incidentCategory.Sub_Category__c);
			}
			return new List<String>(returnValues);
		}
		return null;	
	}
	/**
	* Method used to save a case comment
	* @param commentText - The text of the comment
	* @param caseId - The ID of the case
	* @param isPublic - Is this record public
	* @return List<model_caseComment> - List of comments related to the case
	*/
	@RemoteAction
	public static List<model_caseComment> saveCaseComment(String commentText, String caseId, Boolean isPublic)
	{
		model_caseComment newComment = new model_caseComment();
		newComment.commentText = commentText;
		newComment.isPublic = isPublic;
		newComment.caseId = caseId;		

	  	if(newComment.saveComment())
	  		return getCaseComments(newComment.caseId);
  		else
  			return null;
	}
	/**
	* Method to retrieve case comments
	* @param caseId - The ID of the case
	* @return List<model_caseComment> - List of comments related to the case
	*/
	private static List<model_caseComment> getCaseComments(String caseId)
	{
		List<model_caseComment> theComments = new List<model_caseComment>();
		List<CaseComment> caseCommentRecords = apexQueryUtility.selectAllFrom('CaseComment', 'CreatedBy.FirstName, CreatedBy.LastName, LastModifiedBy.FirstName, LastModifiedBy.LastName', 'ParentId = \'' + caseId + '\'');
		for(CaseComment cc: caseCommentRecords)
		{
			theComments.add(new model_caseComment(cc));
		}
		return theComments;
	}
	/**
	* Method to perform lookups with TypeAhead on VF pages
	* @param objectName - The table to do a lookup on
	* @param searchTerm - The term to search
	* @return List<ifsaRecordLookupViewModel> - List of ifsaRecordLookupViewModel objects that represent the result of the search
	*/
	@RemoteAction
    public static List<ifsaRecordLookupViewModel> searchForRecord(String objectName, String searchTerm) 
    {
    	return ifsaRecordLookupMethods.searchForRecord(objectName, searchTerm);
    }
	/**
	* Method to perform lookups on a specific record type with TypeAhead on VF pages
	* @param objectName - The table to do a lookup on
	* @param searchTerm - The term to search
	* @param recordTypeDeveloperName - The record type developer name to limit the search to.
	* @return List<ifsaRecordLookupViewModel> - List of ifsaRecordLookupViewModel objects that represent the result of the search
	*/
    @RemoteAction
    public static List<ifsaRecordLookupViewModel> searchForRecordWithRecordType(String objectName, String searchTerm, String recordTypeDeveloperName) 
    {
    	return ifsaRecordLookupMethods.searchForRecordWithRecordType(objectName, searchTerm, recordTypeDeveloperName);
    }
	@RemoteAction
	public static String getCaseTeam(String caseId)
	{
		List<model_CaseTeamMember> caseTeam = new List<model_CaseTeamMember>();

		List<CaseTeamMember> caseTeamRecords = apexQueryUtility.selectAllFrom('CaseTeamMember', 'TeamRole.Name, TeamRole.accesslevel, Member.Email, Member.FirstName, Member.LastName' , 'ParentId = \'' + caseId + '\' AND Member.IsActive = TRUE');
		for(CaseTeamMember ctm: caseTeamRecords)
		{
			caseTeam.add(new model_CaseTeamMember(ctm));
		}

		return JSON.serialize(caseTeam);
	}
	/**
	 * This method checks the status of an asynchronous apex job
	 * @param jobId - The Id of the job
	 * @return Boolean
	 */
	@RemoteAction
	public static Boolean checkJob(String jobId)
	{
		AsyncApexJob jobInfo = [SELECT Status,NumberOfErrors FROM AsyncApexJob WHERE Id=:jobID];
		if(jobInfo.Status != 'Completed')
			return false;
		
		return true;
	}
	/**
	 * Provides information to ifsaCase VF page about the case that was saved and if an asynchronous job has been started
	 */
	public class caseSaveResult
	{
		/**
		 * Case Id
		 */
		public String caseId {get;set;}
		/**
		 * Asynchronous job id
		 */
		public String caseTeamJobId {get;set;}
		/**
		 * Constructor, only provides case id
		 */
		public caseSaveResult(Id cId)
		{
			this.caseId = cId;
		}
		/**
		 * Constructor, provides both case id and job id
		 */
		public caseSaveResult(Id cId, Id jobId)
		{
			this(cId);
			this.caseTeamJobId = jobId;
		}
	}
}