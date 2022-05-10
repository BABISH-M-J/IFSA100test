/**
 * @description Controller for the "Register" page on the Student Portal.
 * @author Cameron Ames
 */
public without sharing class studentRegisterController extends studentBaseController
{
	public studentRegisterViewModel viewModel {get;set;}

	private Contact parent {get;set;}
	private Home_Institution__c homeInstitution {get;set;}

	public studentRegisterController()
	{
		super();

		/*
		List<Contact> guardianList = [SELECT Id, FirstName, LastName, Phone, Email FROM Contact WHERE Student__c =: studentContact.Id];
		Contact parent = guardianList.size() > 0 ? guardianList.get(0) : new Contact();
		*/
		this.homeInstitution = this.studentContact.Home_Institution__c != null ? [SELECT Id, Name FROM Home_Institution__c WHERE Id =: this.studentContact.Home_Institution__c] : null;

		this.viewModel = new studentRegisterViewModel();
		this.populateViewModel();
	}

	private void populateViewModel()
	{
		this.viewModel = (studentRegisterViewModel) super.populateViewModel(this.viewModel);
		this.viewModel.PreferredName = this.studentContact.Preferred_Name__c;
		this.viewModel.MiddleName = this.studentContact.Middle_Name__c;
		this.viewModel.Suffix = this.studentContact.Suffix__c;
		this.viewModel.Email = this.studentContact.Email;
		this.viewModel.personalEmail = this.studentContact.Personal_Email__c;
		this.viewModel.Phone = this.studentContact.Phone;
		this.viewModel.TwitterHandle = this.studentContact.Twitter_Handle__c;
		this.viewModel.Major = this.studentContact.Major_New__c;
		this.viewModel.FirstGeneration = this.studentContact.First_Generation_PL__c;
		this.viewModel.Sex = this.studentContact.Sex__c;
		this.viewModel.CitizenshipDetails = this.studentContact.Citizenship_Details__c;
		this.viewModel.SpokenWithAlumni = this.studentContact.Spoken_with_alumni__c;
		this.viewModel.HomeInstitution = this.homeInstitution != null ? this.homeInstitution.Id : null;
		this.viewModel.HomeInstitutionName = this.homeInstitution != null ? this.homeInstitution.Name : this.studentContact.Unlisted_School__c;
		this.viewModel.UnlistedSchool = this.studentContact.Unlisted_School__c;
		// this.viewModel.GuardianFirstName = this.parent.FirstName;
		// this.viewModel.GuardianLastName = this.parent.LastName;
		// this.viewModel.GuardianEmail = this.parent.Email;
		// this.viewModel.GuardianPhone = this.parent.Phone;
		this.viewModel.Citizenship = this.studentContact.Citizenship__c;
		this.viewModel.NonUsCitizenship = this.studentContact.Non_US_Citizenship__c;
		this.viewModel.GradeLevel = this.studentContact.Grade_Level__c;
		this.viewModel.Degree = this.studentContact.Degree__c;
		this.viewModel.MultipleUniversities = this.studentContact.Multiple_Universities__c;
		this.viewModel.Birthdate = this.studentContact.Birthdate;
		this.viewModel.GPA = this.studentContact.GPA__c != null ? this.studentContact.GPA__c : null;
		this.viewModel.OtherMajor = this.studentContact.Major_Other__c;
		this.viewModel.Ethnicity = this.studentContact.Ethnicity__c;
		this.viewModel.FAFSA = this.studentContact.FAFSA__c;
		this.viewModel.CommunityCollege = this.studentContact.Community_College_Student__c;
		this.viewModel.GenderIdentity = this.studentContact.Gender_Identity__c;
		this.viewModel.PreferredPronounsOther = this.studentContact.Preferred_Pronouns_Other__c;
		this.viewModel.ActiveDutyVeteran = this.studentContact.Active_Duty_or_Veteran__c;
		this.viewModel.ClassesReqd = this.studentContact.Classes_Required__c;
		this.viewModel.SportDivision = this.studentContact.Division_of_Sport__c;
		this.viewModel.ImmigrantUS = this.studentContact.Immigrant_to_US__c;
		this.viewModel.LGBTQplus = this.studentContact.LGBTQplus__c;
		this.viewModel.IntlStudent = this.studentContact.International_Student__c;
		this.viewModel.NatlStudentSuccess = this.studentContact.Natl_Student_Success_Programs__c;
		this.viewModel.PreferredPronouns = this.studentContact.Personal_Pronouns__c;
		this.viewModel.Sport = this.studentContact.Student_Sport__c;
		this.viewModel.GuardiansNotUSBorn = this.studentContact.Guardians_Not_Born_IN_US__c;
		this.viewModel.SecondMajor = this.studentContact.Second_Major__c;
		this.viewModel.Minor = this.studentContact.Minor__c;
		this.viewModel.SecondMinor = this.studentContact.Second_Minor__c;
		this.viewModel.MinorOther = this.studentContact.Minor_Other__c;
		this.viewModel.WorkingHours = this.studentContact.Working_Hours_per_Week__c;
		this.viewModel.TravelTopics = this.studentContact.Travel_Topics__c;
		this.viewModel.TravelConcerns = this.studentContact.Travel_Concerns__c;
		this.viewModel.PellGrant = this.studentContact.Eligible_for_Pell_Grant__c;
		this.viewModel.GenderIdentityOther = this.studentContact.Gender_Identity_Other_2__c;
		this.viewModel.Race = this.studentContact.Race__c;

		system.debug(this.viewModel.PreferredPronouns);
		/*
		try
		{
			Contact parent = [SELECT Id, FirstName, LastName, Email, Phone FROM Contact WHERE Student__c =: studentContact.Id  AND RecordType.Name = 'Other'].get(0);
			if(parent != null)
			{
				this.viewModel.GuardianId = parent.Id;
				this.viewModel.GuardianFirstName = parent.FirstName;
				this.viewModel.GuardianLastName = parent.LastName;
				this.viewModel.GuardianEmail = parent.Email;
				this.viewModel.GuardianPhone = parent.Phone;
			}
		}
		catch(ListException e)
		{
			system.debug('Student does not have any parent contacts');
			system.debug(e);
		}
		*/
	}
	/*
	public override PageReference validateAccess()
	{
		if(this.viewModel.isLockDownActive)
		{
			return new PageReference('/SP_Home');
		}
		return null;
	}

    @RemoteAction
    public static List<Home_Institution__c> searchHomeInstitution(String SearchTerm) 
    {
        List<Home_Institution__c> schools = Database.query('Select Id, Name from Home_Institution__c where name like \'%' + String.escapeSingleQuotes(searchTerm) + '%\'');
        return schools;
    }

	@RemoteAction
	public static Boolean saveData(String jsonData, Boolean registrationComplete)
	{
		studentRegisterViewModel viewModel;
		if(jsonData == null)
		{
			return false;
		}
		try
		{
			viewModel = (studentRegisterViewModel) JSON.createParser(jsonData).readValueAs(Type.forName('studentRegisterViewModel'));
		}
		catch(Exception e)
		{
			System.debug(LoggingLevel.WARN, e.getMessage());
			return false;
		}

		User studentUser = [SELECT Id, ContactId FROM User WHERE Id =: UserInfo.getUserId()];

		Contact studentContact = (Contact) apexQueryUtility.selectAllFrom('Contact', 'Id = \'' + studentUser.ContactId + '\'').get(0);
		Account studentAccount = (Account) [SELECT Id, Name, c2g__CODAAccountTradingCurrency__c FROM Account WHERE Id =: studentContact.AccountId];
		Application__c activeApplication = studentBaseController.getActiveApplication(studentContact);
		studentContact.Active_Application__c = activeApplication.Id;
		
		List<Contact> guardianList = [SELECT Id, FirstName, LastName, Phone, Email FROM Contact WHERE Student__c =: studentContact.Id];
		List<sObject> toUpdate = new List<sObject>();
		Contact parent = guardianList.size() > 0 ? guardianList.get(0) : new Contact();
		System.debug(guardianList.size());

		studentContact.FirstName = viewModel.studentFirstName != null ? viewModel.studentFirstName.normalizeSpace() : null;
		studentContact.LastName = viewModel.studentLastName.normalizeSpace();
		//ACARSON Dec.05.2017 SW #5910 fixed issue of preferred name not autopopulating
		//studentContact.Preferred_Name__c = viewModel.PreferredName != null ? viewModel.PreferredName : studentContact.FirstName;
		studentContact.Preferred_Name__c = (!String.isBlank(viewModel.PreferredName)) ? viewModel.PreferredName : studentContact.FirstName;
		studentContact.Middle_Name__c = viewModel.MiddleName;
		studentContact.Suffix__c = viewModel.Suffix;
		studentContact.Email = viewModel.Email;
		studentContact.Phone = viewModel.Phone;
		studentContact.Twitter_Handle__c = viewModel.TwitterHandle;
		//ACARSON
		//studentContact.Major__c = viewModel.Major;
		studentContact.First_Generation__c = viewModel.FirstGeneration;
		studentContact.Sex__c = viewModel.Sex;
		studentContact.Citizenship_Details__c = viewModel.CitizenshipDetails;
		studentContact.Spoken_with_alumni__c = (!String.isBlank(viewModel.SpokenWithAlumni)) ? viewModel.SpokenWithAlumni : 'No';
		parent.Id = viewModel.GuardianId;
		parent.FirstName = viewModel.GuardianFirstName;
		parent.LastName = viewModel.GuardianLastName;
		parent.Email = viewModel.GuardianEmail;
		parent.Phone = viewModel.GuardianPhone;
		parent.Student__c = studentContact.Id;
		parent.Send_Marketing_Materials__c = true;
		parent.RecordTypeId = [SELECT Id FROM RecordType WHERE sObjectType = 'Contact' AND Name = 'Other'].Id;
		parent.OwnerId = studentContact.OwnerId;
		studentContact.Citizenship__c = viewModel.Citizenship;
		studentContact.Non_US_Citizenship__c = viewModel.NonUsCitizenship;
		studentContact.Grade_Level__c = viewModel.GradeLevel;
		studentContact.Degree__c = viewModel.Degree;
		studentContact.Multiple_Universities__c = viewModel.MultipleUniversities;
		studentContact.Birthdate = viewModel.Birthdate;
		studentContact.GPA__c = viewModel.GPA;
		//ACARSON
		studentContact.Major_New__c = viewModel.Major;
		studentContact.Major_Other__c = viewModel.OtherMajor;
		studentContact.Ethnicity__c = viewModel.Ethnicity;
		studentContact.Race__c = viewModel.Race;
		studentContact.FAFSA__c = viewModel.FAFSA;
		studentContact.Active_Duty_or_Veteran__c = viewModel.ActiveDutyVeteran;
		studentContact.Gender_Identity__c = viewModel.GenderIdentity;
		studentContact.Preferred_Pronouns_Other__c = viewModel.PreferredPronounsOther;
		studentContact.Classes_Required__c = (!String.isBlank(viewModel.ClassesReqd)) ? viewModel.ClassesReqd : 'No';
		studentContact.Division_of_Sport__c = viewModel.SportDivision;
		studentContact.LGBTQplus__c = viewModel.LGBTQplus;
		studentContact.Natl_Student_Success_Programs__c = viewModel.NatlStudentSuccess;
		studentContact.Preferred_Pronouns__c = viewModel.PreferredPronouns;
		studentContact.Student_Sport__c = viewModel.Sport;
		studentContact.Guardians_Not_Born_IN_US__c = viewModel.GuardiansNotUSBorn;
		studentContact.Second_Major__c = viewModel.SecondMajor;
		studentContact.Minor__c = viewModel.Minor;
		studentContact.Second_Minor__c = viewModel.SecondMinor;
		studentContact.Minor_Other__c = viewModel.MinorOther;
		studentContact.Working_Hours_per_Week__c = viewModel.WorkingHours;
		studentContact.Travel_Topics__c = viewModel.TravelTopics;
		studentContact.Travel_Concerns__c = viewModel.TravelConcerns;
		studentContact.Eligible_for_Pell_Grant__c = viewModel.PellGrant;
		studentContact.Gender_Identity_Other__c = viewModel.GenderIdentityOther;

		if(studentContact.FirstName + ' ' + studentContact.LastName != studentAccount.Name)
		{
			studentAccount.Name = studentContact.FirstName + ' ' + studentContact.LastName;
			toUpdate.add(studentAccount);
		}


		List<Home_Institution__c> schools = [SELECT Id FROM Home_Institution__c WHERE Name LIKE: viewModel.HomeInstitutionName];

		if(schools.size() > 0)
		{
			studentContact.Home_Institution__c = schools.get(0).Id;
			studentContact.Unlisted_School__c = null;
		}
		else
		{
			studentContact.Unlisted_School__c = viewModel.HomeInstitutionName;
			studentContact.Home_Institution__c = null;
		}

		activeApplication.Status__c = activeApplication.Status__c == 'New' ? 'Registered' : activeApplication.Status__c;
		studentContact.Profile_Completed__c = true;

		toUpdate.add(studentContact);			
		toUpdate.add(activeApplication);

		System.debug(logginglevel.WARN, parent.LastName);
		if(guardianList.size() > 0 && parent.Id != null)
		{
			toUpdate.add(parent);
		}
		else if(parent.LastName != null && parent.Id == null)
		{
			System.debug(LoggingLevel.WARN, 'Inserting parent');
			Database.insert(parent);
		}
		system.debug(toUpdate.size());
		try
		{
			system.debug(toUpdate.get(0).Id);
			system.debug(toUpdate.get(1).Id);
			system.debug(toUpdate.get(2).Id);
			system.debug(toUpdate.get(3));
		} catch (Exception e) {

		}
		Boolean isSuccess = Database.update(toUpdate).get(0).isSuccess();
		// this needs commented out to not cause duplicate records
		// if(activeApplication.Status__c == 'Program Selected' && registrationComplete)
		// {
		// 	applicationService.createPaWelcomeTaskAsync(new Set<Id>{activeApplication.Id});
		// }
		return isSuccess;
	}
	*/
}