/**
* @description Controller for SP_Resources page
* @author Cameron Ames
*/
public without sharing class studentResourcesController extends studentBaseController
{
	public studentResourcesViewModel viewModel {get;set;}
	private ifsaApplicationWrapper application {get;set;}
	private ifsaProgramTermWrapper programTerm {get;set;}
	// BBARLOW Unused property
	//private Program_Option__c programOption {get;set;}
	
	public studentResourcesController()
	{
		super();
		
		this.application = new ifsaApplicationWrapper(this.studentContact.Active_Application__c);
		this.programTerm = new ifsaProgramTermWrapper(this.application.getProgramTermId());
		
		this.viewModel = this.populateViewModel(new studentResourcesViewModel());
	}

	public override PageReference validateAccess()
	{
		if(this.viewModel.isLockDownActive)
		{
			return new PageReference('/SP_Home');
		}
		return null;
	}
	
	public studentResourcesViewModel populateViewModel(studentResourcesViewModel viewModel)
	{
		viewModel = (studentResourcesViewModel) super.populateViewModel(viewModel);
		// BBARLOW - Modified SOQL query so that the body of attachments does not get pulled into viewmodel
		// viewModel.attachments = apexQueryUtility.selectAllFrom('Attachment', 'ParentId IN (\'' + this.application.getProgramTermId() + '\', \'' + this.programTerm.getCountryId() + '\', \'' + this.programTerm.getProgramId() + '\', \'' + this.programTerm.getTermId() + '\')');
		List<Id> resourceGroupIds = new List<Id>{this.application.getProgramTermId(), this.programTerm.getCountryId(), this.programTerm.getProgramId(), this.programTerm.getTermId()};
		if(this.application.getParentProgramTermId() != null) resourceGroupIds.add(this.application.getParentProgramTermId());
		// Get Files
		Id appId = this.studentContact.Active_Application__c;
		//viewModel.files = [SELECT Id, ContentDocument.Description, ContentDocument.Title, ContentDocument.LatestPublishedVersionId, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: appId];
		viewModel.files = apexQueryUtility.selectAllFrom('ContentDocumentLink', 'ContentDocument.Description, ContentDocument.Title, ContentDocument.LatestPublishedVersionId', 'LinkedEntityId = \'' + appId + '\'');
		// Get Attachments
		viewModel.attachments = [SELECT Id, Name, Description FROM Attachment WHERE ParentId IN: resourceGroupIds];
		List<Schedule__c> schedules = apexQueryUtility.selectAllFrom('Schedule__c', 'RecordType.Name, Country__r.Name', 'Program_Term__c IN ' + apexQueryUtility.buildInClause(resourceGroupIds));
		for(Schedule__c schedule: schedules)
		{
			if(schedule.Status__c == 'Approved')
			{
				viewModel.scheduleList.add(new model_schedule(schedule));
			}
		}
		// Get Resource Items
		if(this.application.getParentProgramTermId() != null)
		{
			viewModel.resourceList = [SELECT Name, Category__c, Content__c FROM Resource_Item__c WHERE Country__c =: this.programTerm.getCountryId() OR Program__c =: this.programTerm.getProgramId() OR Program_Term__c =: this.application.getProgramTermId() OR Program_Term__r.Parent_Program_Term__c =: this.application.getParentProgramTermId()];
		}
		else
		{
			viewModel.resourceList = [SELECT Name, Category__c, Content__c FROM Resource_Item__c WHERE Country__c =: this.programTerm.getCountryId() OR Program__c =: this.programTerm.getProgramId() OR Program_Term__c =: this.application.getProgramTermId()];
		}
		// Get Resource Categories
		Map<String, String> catMap = new Map<String, String>(); 
		for(Resource_Item__c r: viewModel.resourceList)
		{
			catMap.put(r.Category__c, r.Category__c);
		}
		for(String cat: catMap.values())
		{
			viewModel.categories.add(cat);
			system.debug(cat);
		}

		// Get Program Term Dates
		Program_Term__c pt = (Program_Term__c) apexQueryUtility.selectAllFrom('Program_Term__c', 'Id = \'' + this.application.getProgramTermId() + '\'').get(0);
		Program_Term__c ppt =  this.programTerm.getParentProgramTermId() != null ? (Program_Term__c) apexQueryUtility.selectAllFrom('Program_Term__c', 'Id = \'' + this.programTerm.getParentProgramTermId() + '\'').get(0) : new Program_Term__c();
		
		viewModel.applicationDeadline = pt.Application_Deadline__c != null ? isApproved(pt.Date_Approval_Status__c, pt.Application_Deadline__c) : isApproved(ppt.Date_Approval_Status__c, ppt.Application_Deadline__c);
		viewModel.assessmentsBegin = pt.Assessments_Begin__c != null ? isApproved(pt.Date_Approval_Status__c, pt.Assessments_Begin__c) : isApproved(ppt.Date_Approval_Status__c, ppt.Assessments_Begin__c);
		viewmodel.assessmentsEnd = pt.Assessments_End__c != null ? isApproved(pt.Date_Approval_Status__c, pt.Assessments_End__c) : isApproved(ppt.Date_Approval_Status__c, ppt.Assessments_End__c);
		viewModel.classesBegin = pt.Classes_Begin__c != null ? isApproved(pt.Date_Approval_Status__c, pt.Classes_Begin__c) : isApproved(ppt.Date_Approval_Status__c, ppt.Classes_Begin__c);
		viewModel.classesEnd = pt.Classes_End__c != null ? isApproved(pt.Date_Approval_Status__c, pt.Classes_End__c) : isApproved(ppt.Date_Approval_Status__c, ppt.Classes_End__c);
		viewModel.endDate = pt.End_Date__c != null ? isApproved(pt.Date_Approval_Status__c, pt.End_Date__c) : isApproved(ppt.Date_Approval_Status__c, ppt.End_Date__c);
		viewModel.examBegin = pt.Exam_End_Date__c != null ? isApproved(pt.Date_Approval_Status__c, pt.Exam_End_Date__c) : isApproved(ppt.Date_Approval_Status__c, ppt.Exam_End_Date__c);
		viewModel.examEnd = pt.Exam_Start_Date__c != null ? isApproved(pt.Date_Approval_Status__c, pt.Exam_Start_Date__c) : isApproved(ppt.Date_Approval_Status__c, ppt.Exam_Start_Date__c);
		viewModel.groupTransferToHostCity = pt.Group_Transfer_to_Host_City__c != null ? isApproved(pt.Date_Approval_Status__c, pt.Group_Transfer_to_Host_City__c) : isApproved(ppt.Date_Approval_Status__c, ppt.Group_Transfer_to_Host_City__c);
		viewModel.ifsaOrientationEndDate = pt.IFSA_Orientation_End_Date__c != null ? isApproved(pt.Date_Approval_Status__c, pt.IFSA_Orientation_End_Date__c) : isApproved(ppt.Date_Approval_Status__c, ppt.IFSA_Orientation_End_Date__c);
		viewModel.ifsaOrientationStartDate = pt.IFSA_Orientation_Start_Date__c != null ? isApproved(pt.Date_Approval_Status__c, pt.IFSA_Orientation_Start_Date__c) : isApproved(ppt.Date_Approval_Status__c, ppt.IFSA_Orientation_Start_Date__c);
		viewModel.moveIntoTermHousing = pt.Move_into_Term_Housing__c != null ? isApproved(pt.Date_Approval_Status__c, pt.Move_into_Term_Housing__c) : isApproved(ppt.Date_Approval_Status__c, ppt.Move_into_Term_Housing__c);
		viewModel.programDueDate = pt.Program_Due_Date__c != null ? isApproved(pt.Date_Approval_Status__c, pt.Program_Due_Date__c) : isApproved(ppt.Date_Approval_Status__c, ppt.Program_Due_Date__c);
		viewModel.startDate = pt.Start_Date__c != null ? isApproved(pt.Date_Approval_Status__c, pt.Start_Date__c) : isApproved(ppt.Date_Approval_Status__c, ppt.Start_Date__c);
		viewModel.startOfSecondTerm = pt.Start_Of_Second_Term__c != null ? isApproved(pt.Date_Approval_Status__c, pt.Start_Of_Second_Term__c) : isApproved(ppt.Date_Approval_Status__c, ppt.Start_Of_Second_Term__c);
		viewModel.suggestedDepartureFromUS = pt.Suggested_Departure_from_U_S__c != null ? isApproved(pt.Date_Approval_Status__c, pt.Suggested_Departure_from_U_S__c) : isApproved(ppt.Date_Approval_Status__c, ppt.Suggested_Departure_from_U_S__c);
		viewModel.universityOrientationEnds = pt.University_Orientation_Ends__c != null ? isApproved(pt.Date_Approval_Status__c, pt.University_Orientation_Ends__c) : isApproved(ppt.Date_Approval_Status__c, ppt.University_Orientation_Ends__c);
		viewModel.universityOrientationStarts = pt.University_Orientation_Starts__c != null ? isApproved(pt.Date_Approval_Status__c, pt.University_Orientation_Starts__c) : isApproved(ppt.Date_Approval_Status__c, ppt.University_Orientation_Starts__c);
		viewModel.arrivalWindowEndTime = pt.Arrival_Window_End_Time__c != null ? isApproved(pt.Date_Approval_Status__c, pt.Arrival_Window_End_Time__c) : isApproved(ppt.Date_Approval_Status__c, ppt.Arrival_Window_End_Time__c);
		viewModel.arrivalWindowStartTime = pt.Arrival_Window_Start_Time__c != null ? isApproved(pt.Date_Approval_Status__c, pt.Arrival_Window_Start_Time__c) : isApproved(ppt.Date_Approval_Status__c, ppt.Arrival_Window_Start_Time__c);

		
		//ACARSON Jun.25.2018 Setting viewModel variables based on what it states on the program term or parent program term
		List<Program_Fee__c> progFees = [SELECT Id, Name, Program_Term__c, Amount__c, Product__c, Product__r.Name FROM Program_Fee__c WHERE Program_Term__c =:pt.Id OR Program_Term__c =:ppt.Id];
		for(Program_Fee__c pf : progFees){
			if(pf.Name == 'Tuition')
			{
				viewModel.tuition = pf.Amount__c;
			}
			else if(pf.Name == 'Accommodation' || pf.Name == 'Housing Fee')
			{
				viewModel.baseHousing = pf.Amount__c;
			}
			else if(pf.Name == 'Non-Refundable Deposit')
			{
				viewmodel.deposit = pf.Amount__c;
			}

		}
		viewModel.airfare = pt.Airfare__c != null ? pt.Airfare__c : ppt.Airfare__c;
		viewmodel.startupCosts = pt.Startup_Costs__c != null ? pt.Startup_Costs__c : ppt.Startup_Costs__c;
		viewModel.meals = pt.Meals__c != null ? pt.Meals__c : ppt.Meals__c;
		viewModel.visaUS = pt.Visa_United_States__c != null ? pt.Visa_United_States__c : ppt.Visa_United_States__c;
		viewModel.visaAbroad = pt.Visa_Abroad__c != null ? pt.Visa_Abroad__c : ppt.Visa_Abroad__c;
		viewModel.booksAndSupplies = pt.Books_Supplies__c != null ? pt.Books_Supplies__c : ppt.Books_Supplies__c;
		viewModel.localTransport = pt.Local_Transportation__c != null ? pt.Local_Transportation__c : ppt.Local_Transportation__c;
		viewModel.personalExpenses = pt.Personal_Expenses__c != null ? pt.Personal_Expenses__c : ppt.Personal_Expenses__c;
		viewModel.courseCharges = pt.Course_Related_Charges_Description__c != null ? pt.Course_Related_Charges_Description__c : ppt.Course_Related_Charges_Description__c;

		
		//List<Program_Term_Housing_Option__c> suppList = new List<Program_Term_Housing_Option__c>();
		viewModel.suppHousing = [SELECT Id, Name, Program_Term__c, Supplemental_Housing_Price__c, Housing_Option__r.Name FROM Program_Term_Housing_Option__c WHERE Program_Term__c = :pt.Id OR Program_Term__c = :ppt.Id ORDER BY Housing_Option__r.Name];
		viewModel.displayHousingOptions = false;
		for(Program_Term_Housing_Option__c ptho : viewModel.suppHousing)
		{
			if(ptho.Supplemental_Housing_Price__c != null || ptho.Supplemental_Housing_Price__c > 0)
			{
				viewModel.displayHousingOptions = true;
			}
		}


		viewModel.totalBaseCosts = viewModel.tuition != null && viewmodel.baseHousing != null ? viewmodel.tuition + viewmodel.baseHousing : null;
		if(viewmodel.totalBaseCosts != null)
		{
			viewmodel.totalBaseCosts += viewModel.deposit != null ? viewmodel.deposit : 0;
		}
		viewModel.totalEstCosts = viewModel.airfare != null ? viewModel.airfare : 0;
		viewModel.totalEstCosts += viewmodel.startupCosts != null ? viewmodel.startupCosts : 0;
		viewModel.totalEstCosts += viewModel.meals != null ? viewModel.meals : 0;
		viewModel.totalEstCosts += viewModel.visaUS != null ? viewModel.visaUS : 0;
		viewModel.totalEstCosts += viewModel.visaAbroad != null ? viewModel.visaAbroad : 0;
		viewModel.totalEstCosts += viewModel.booksAndSupplies != null ? viewModel.booksAndSupplies : 0;
		viewModel.totalEstCosts += viewModel.localTransport != null ? viewModel.localTransport : 0;
		viewModel.totalEstCosts += viewModel.personalExpenses != null ? viewModel.personalExpenses : 0;		

		return viewModel;
	}
	/**
	* @description Returns the provided date if the dates on the program term are approved
	* param approvalStatus - The Date_Approval_Status__c value from the program term
	* param dateToReturn - The date to return if the program term dates are approved
	*/
	private Date isApproved(String approvalStatus, Date dateToReturn)
	{
		if(approvalStatus == 'Approved')
		{
			return dateToReturn;
		}
		return null;
	}
	/**
	* @description Returns the provided string if the dates on the program term are approved
	* param approvalStatus - The Date_Approval_Status__c value from the program term
	* param stringToReturn - The string to return if the program term dates are approved
	*/
	private String isApproved(String approvalStatus, String stringToReturn)
	{
		if(approvalStatus == 'Approved')
		{
			return stringToReturn;
		}
		return null;
	}
}