public with sharing class model_programAuthorization extends model_base
{
	public String programAuthorizationId {get; set;}
	public String accountId {get; set;}
	public String programId {get; set;}
	public String programName {get; set;}
	public Boolean doNotAllowStudentsToApply {get; set;}
	public List<String> terms {get; set;}
	public List<String> availableTerms {get; set;}
	public String selectedTerms {get; set;}
	public Boolean springTerm {get; set;}
	public Boolean summerTerm {get; set;}
	public Boolean winterTerm {get; set;}
	public Boolean fallTerm {get; set;}
	public Boolean notApproved {get; set;}
	public Boolean academicYear {get; set;}
	public Boolean calendarYear {get; set;}
	public Boolean selectAllAvalibleTerms {get; set;}
	public Boolean showSpringTerm {get; set;}
	public Boolean showSummerTerm {get; set;}
	public Boolean showWinterTerm {get; set;}
	public Boolean showFallTerm {get; set;}
	public Boolean showAcademicYear {get; set;}
	public Boolean showCalendarYear {get; set;}
	public Boolean showNotApproved {get; set;}
	public String countryName {get; set;}

	public model_programAuthorization() 
	{
		this.availableTerms = new List<String>();
	}

	public model_programAuthorization(Program_Authorization__c pAuth)
	{
		this();
		this.programAuthorizationId = pAuth.Id;
		this.recordName = pAuth.Name;
		this.accountId = pAuth.Account__c;
		this.programId = pAuth.Program__c;
		this.programName = pAuth.Program__r.Name != null ? pAuth.Program__r.Name : null;
		this.countryName = pAuth.Program__r.Country__r.Name != null ? pAuth.Program__r.Country__r.Name : null;
		this.doNotAllowStudentsToApply = pAuth.Do_Not_Allow_Students_To_Apply__c;
		this.terms = apexConversionUtility.getPicklistStringValues(Program_Authorization__c.Term__c);
		this.selectedTerms = pAuth.Term__c != null ? pAuth.Term__c : '';
	}
	
	public model_programAuthorization(String pAuthId) 
	{
		this([SELECT Id, Name, Account__c, Program__c, Program__r.Name, Do_Not_Allow_Students_To_Apply__c, Term__c, Program__r.Country__r.Name FROM Program_Authorization__c WHERE Id =: pAuthId]);
	}

	public static model_programAuthorization convertFromJson(String jsonData)
	{
		//Unescape the json string
		jsonData = jsonData.unescapeEcmaScript();
		//Remove leading and trailing '"' characters			
		jsonData = jsonData.removeStart('"');
		jsonData = jsonData.removeEnd('"');
		jsonData = jsonData.replace('\n', '\\n');
		//jsonData = jsonData.replaceAll('T04:00:00.000Z', '');
		system.debug(jsonData);			
		return (model_programAuthorization) JSON.createParser(jsonData).readValueAs(Type.forName('model_programAuthorization'));
	}
	public static List<model_programAuthorization> convertFromJsonToList(String jsonData)
	{
		//Unescape the json string
		jsonData = jsonData.unescapeEcmaScript();
		//Remove leading and trailing '"' characters			
		jsonData = jsonData.removeStart('"');
		jsonData = jsonData.removeEnd('"');
		jsonData = jsonData.replace('\n', '\\n');
		//jsonData = jsonData.replaceAll('T04:00:00.000Z', '');
		system.debug(jsonData);
		return (List<model_programAuthorization>) JSON.deserialize(jsonData, List<model_programAuthorization>.class);
	}

	public String save()
	{
		Program_Authorization__c pAuth = new Program_Authorization__c();
		pAuth.Id = this.programAuthorizationId != '' ? this.programAuthorizationId : null;
		if(pAuth.Id == null)
		{
			pAuth.Account__c = this.accountId;
		}
		pAuth.Program__c = this.programId;
		pAuth.Do_Not_Allow_Students_To_Apply__c = this.doNotAllowStudentsToApply == true ? true : false;
		pAuth.Term__c = this.selectedTerms;

		try 
		{
			Database.upsert(pAuth);
			this.programAuthorizationId = pAuth.Id;
			return pAuth.Id;
		}
		catch(Exception e)
		{
			throw e;
		}
	}
	
	public static Boolean saveList(List<model_programAuthorization> models)
	{
		List<Program_Authorization__c> pAuths = new List<Program_Authorization__c>();
		for(model_programAuthorization mpa: models)
		{
			Program_Authorization__c pAuth = new Program_Authorization__c();
			pAuth.Id = mpa.programAuthorizationId != '' ? mpa.programAuthorizationId : null;
			if(pAuth.Id == null)
			{
				pAuth.Account__c = mpa.accountId;
			}
			pAuth.Program__c = mpa.programId;
			pAuth.Do_Not_Allow_Students_To_Apply__c = mpa.doNotAllowStudentsToApply == true ? true : false;
			pAuth.Term__c = mpa.selectedTerms;
			system.debug(pAuth.Term__c);
			pAuths.add(pAuth);
		}

		try 
		{
			Database.upsert(pAuths);
			return true;
		}
		catch(Exception e)
		{
			throw e;
		}
	}

	private void setBaseValues()
	{
		this.recordId = this.programAuthorizationId;
		//this.recordName = this.name;
		this.sObjectName = 'Program_Authorization__c';
	}
	
	public override Boolean equals(Object o)
	{
		if(o instanceof model_programAuthorization)
		{
			model_programAuthorization obj = (model_programAuthorization)o;
			return (this.recordId == obj.recordId && this.recordName == obj.recordName);
		}
		return false;
	}
}