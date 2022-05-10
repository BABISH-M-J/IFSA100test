public without sharing class studentRegisterViewModel extends studentBaseViewModel
{
    public String PreferredName {get;set;}
    public String MiddleName {get;set;}
    public String Suffix {get;set;}
    public String Email {get;set;}
	public String personalEmail {get;set;}
	public String Phone {get;set;}
    public String TwitterHandle {get;set;}
    public String Major {get;set;}
	public String FirstGeneration {get;set;}
	public String Sex {get;set;}
	public String CitizenshipDetails {get;set;}
	public String SpokenWithAlumni {get;set;}
	//ACARSON
	public String OtherMajor {get;set;}
	public String Ethnicity {get;set;}
	public String PreferredPronouns {get;set;}
	public String PreferredPronounsOther {get;set;}
	public String FAFSA {get;set;}
	public String GenderIdentity {get;set;}
	public String Sport {get;set;}
	public String SportDivision {get;set;}
	public String LGBTQplus {get;set;}
	public String NatlStudentSuccess {get;set;}
	public String ClassesReqd {get;set;}
	public String SecondMajor{get;set;}
	public String Minor{get;set;}
	public String SecondMinor{get;set;}
	public String MinorOther{get;set;}
	public String WorkingHours{get;set;}
	public String TravelTopics {get;set;}
	public String TravelConcerns {get;set;}
	public String Race {get;set;}
	public String PellGrant {get;set;}
	public Boolean CommunityCollege {get;set;}
	public Boolean ImmigrantUS {get;set;}
	public Boolean IntlStudent {get;set;}
	public String ActiveDutyVeteran {get; set;}
	public Boolean GuardiansNotUSBorn {get;set;}

	public String HomeInstitution {get;set;}
    public String HomeInstitutionName {get;set;}
	public String UnlistedSchool {get;set;}

	public String GuardianId {get;set;}
	public String GuardianFirstName {get;set;}
	public String GuardianLastName {get;set;}
	public String GuardianEmail {get;set;}
	public String GuardianPhone {get;set;}

    public String Citizenship {get;set;}
    public String NonUsCitizenship {get;set;}
    public String GradeLevel {get;set;}
    public String Degree {get;set;}

    public Boolean MultipleUniversities {get;set;}
    public Date Birthdate {get;set;}
    public Decimal GPA {get;set;}
    public String GenderIdentityOther {get;set;}

	public List<String> CitizenshipOptions {get;set;}
	public List<String> NonUsCitizenshipOptions {get;set;}
	public List<String> GradeLevelOptions {get;set;}
	public List<String> DegreeOptions {get;set;}
	public List<String> SexOptions {get;set;}
	public List<String> FirstGenerationOptions {get;set;}
	public List<String> PersonalPronounOptions {get;set;}

	//ACARSON
	public List<String> MajorOptions {get;set;}
	public List<String> EthnicityOptions {get;set;}
	public List<String> FAFSAOptions {get;set;}
	public List<String> GenderIdentityOptions {get;set;}
	public List<String> NatlStudentSuccessOptions {get;set;}
	public List<String> WorkingHoursOptions {get;set;}
	public List<String> TravelTopicsOptions {get;set;}
	public List<String> RaceOptions {get;set;}

	public studentRegisterViewModel()
	{
		this.CitizenshipOptions = apexConversionUtility.getPicklistStringValues(Contact.Citizenship__c);
		this.NonUsCitizenshipOptions = apexConversionUtility.getPicklistStringValues(Contact.Non_US_Citizenship__c);
		this.GradeLevelOptions = apexConversionUtility.getPicklistStringValues(Contact.Grade_Level__c);
		this.DegreeOptions = apexConversionUtility.getPicklistStringValues(Contact.Degree__c);
		this.SexOptions = apexConversionUtility.getPicklistStringValues(Contact.Sex__c);
		this.MajorOptions = apexConversionUtility.getPicklistStringValues(Contact.Major_New__c);
		this.EthnicityOptions = apexConversionUtility.getPicklistStringValues(Contact.Ethnicity__c);
		this.FAFSAOptions = apexConversionUtility.getPicklistStringValues(Contact.FAFSA__c);
		this.GenderIdentityOptions = apexConversionUtility.getPicklistStringValues(Contact.Gender_Identity__c);
		this.NatlStudentSuccessOptions = apexConversionUtility.getPicklistStringValues(Contact.Natl_Student_Success_Programs__c);
		this.WorkingHoursOptions = apexConversionUtility.getPicklistStringValues(Contact.Working_Hours_per_Week__c);
		this.TravelTopicsOptions = apexConversionUtility.getPicklistStringValues(Contact.Travel_Topics__c);
		this.RaceOptions = apexConversionUtility.getPicklistStringValues(Contact.Race__c);
		this.FirstGenerationOptions = apexConversionUtility.getPicklistStringValues(Contact.First_Generation_PL__c);
		this.PersonalPronounOptions = apexConversionUtility.getPicklistStringValues(Contact.Personal_Pronouns__c);
	}

}