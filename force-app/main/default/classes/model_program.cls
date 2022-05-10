/**
 * @description Model class used to describe a program
 * @author Brock Barlow
 */
public with sharing class model_program extends model_base{
	public Id programId {get;set;}
	public String Name {get;set;}
	public Id hostInstitutionId {get;set;}
	public Id countryId {get;set;}
	public Id localityId {get;set;}
	public String academicURLSemester {get;set;}
	public String academicURLSummer {get;set;}
	public Id programOptionId {get;set;}
	public String programOptionName {get;set;}
	public String countryName {get;set;}
	public List<model_program_term> programTerms {get;set;}
	public model_programAuthorization activeProgramAuthorization {get;set;}
	public Boolean hasAcademicYearProgramTerms {get; set;} // Has_Academic_Year_Program_Terms__c
	public Boolean hasFallProgramTerms {get; set;} // Has_Fall_Program_Terms__c
	public Boolean hasSpringProgramTerms {get; set;} // Has_Spring_Program_Terms__c
	public Boolean hasSummerProgramTerms {get; set;} // Has_Summer_Program_Terms__c
	public Boolean hasWinterProgramTerms {get;set;} // Has_Winter_Program_Terms__c
	
	public model_program() {
		this.selectedInSearch = false;
		this.programTerms = new List<model_program_term>();
	}
	public model_program(Program__c program)
	{
		this();
		this.programId = program.Id;
		this.Name = program.Name;
		try {
			this.hostInstitutionId = program.Host_Institution__c;
		}
		catch (SObjectException sobEx) {
			this.hostInstitutionId = null;
		}
		try {
			this.countryId = program.Country__c;
		}
		catch (SObjectException sobEx) {
			this.countryId = null;
		}
		try {
			this.countryName = program.Country_Name__c;
		}
		catch (SObjectException sobEx) {
            system.debug(sobEx.getMessage());
			this.countryName = null;
		}
		try {
			this.localityId = program.Locality__c;
		}
		catch (SObjectException sobEx) {
			this.localityId = null;
		}
		try {
			this.hasAcademicYearProgramTerms = program.Has_Academic_Year_Program_Terms__c || program.Has_Calendar_Year_Program_Terms__c;
		}
		catch (SObjectException sobEx) {
			this.hasAcademicYearProgramTerms = null;
		}
		try {
			this.hasFallProgramTerms = program.Has_Fall_Program_Terms__c;
		}
		catch (SObjectException sobEx) {
			this.hasFallProgramTerms = null;
		}
		try {
			this.hasSpringProgramTerms = program.Has_Spring_Program_Terms__c;
		}
		catch (SObjectException sobEx) {
			this.hasSpringProgramTerms = null;
		}
		try {
			this.hasSummerProgramTerms = program.Has_Summer_Program_Terms__c;
		}
		catch (SObjectException sobEx) {
			this.hasSummerProgramTerms = null;
		}
		try {
			this.hasWinterProgramTerms = program.Has_Winter_Program_Terms__c;
		}
		catch (SObjectException sobEx) {
			this.hasWinterProgramTerms = null;
		}
		if(!program.Program_Authorizations__r.isEmpty())
		{
			this.activeProgramAuthorization = new model_programAuthorization(program.Program_Authorizations__r.get(0));
		}
		this.setBaseValues();
	}
	private void setBaseValues()
	{
		this.recordId = this.programId;
		this.recordName = this.name;
		this.sObjectName = 'Program__c';
	}
	
	public override Boolean equals(Object o)
	{
		if(o instanceof model_program)
		{
			model_program obj = (model_program)o;
			return (this.recordId == obj.recordId && this.recordName == obj.recordName);
		}
		return false;
	}

	public static List<model_program> modelList(List<Program__c> programs)
	{
		List<model_program> models = new List<model_program>();
		for(Program__c program: programs)
		{
			models.add(new model_program(program));
		}
		return models;
	}

	public static Map<Id, model_program> modelMap(List<Program__c> programs)
	{
		Map<Id, model_program> models = new Map<Id, model_program>();
		for(Program__c program: programs)
		{
			models.put(program.Id, new model_program(program));
		}
		return models;
	}
}