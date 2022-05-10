public with sharing class model_courseEquivalency extends model_base
{
	private Course_Equivalency__c courseEquivalency { get; set; }
	public String cmpOfHomeCourseRequest { get; set; }
	public String homeInstitutionCourseId { get; set; }
	public String homeInstitutionCourseCode { get; set; }
	public Boolean homeInstitutionCourseRequestInCMP { get; set; }
	public String homeInstitutionCourseTitle { get; set; }
	public String hostInstitutionCourseId { get; set; }
	public String hostInstitutionCourseCode { get; set; }
	public String hostInstitutionCourseTitle { get; set; }
	public String hostInstitutionName {get; set;}
	public String hostInstitutionCountry { get; set; }
	public List<String> hostInstitutionCourseUSTerms { get; set; }
	public List<String> hostInstitutionPrograms { get; set; }
	public String deniedReason { get; set; }
	public String deniedReasonOther { get; set; }
	public String status { get; set; }
	public String lastApprovedRejectedName { get; set; }
	public Datetime lastApprovedRejectedDate { get; set; }
	public String yearInDegreePlan { get; set;}
	public String termsOffered { get; set;}
	
	public model_courseEquivalency() 
	{
		hostInstitutionCourseUSTerms = new List<String>();
		hostInstitutionPrograms = new List<String>();
	}

	public model_courseEquivalency(Course_Equivalency__c ceRecord)
	{
		courseEquivalency = ceRecord;
		cmpOfHomeCourseRequest = ceRecord.CMP_of_Home_Course_Request__c;
		homeInstitutionCourseId = ceRecord.Home_Institution_Course__c;
		homeInstitutionCourseCode = ceRecord.Home_Institution_Course__r.Course_Code__c;
		homeInstitutionCourseRequestInCMP = cmpOfHomeCourseRequest != null ? true : false;
		homeInstitutionCourseTitle = ceRecord.Home_Institution_Course__r.Course_Title_2__c;
		hostInstitutionCourseId = ceRecord.Host_Institution_Course__c;
		try
		{
			hostInstitutionName = ceRecord.Host_Institution_Course__r.Host_Institution__r.Name;
		}
		catch(Exception e)
		{
			System.debug('Host Institution Name was not queried with the Course_Equivalency__c record');
		}
		try
		{
			hostInstitutionCountry = ceRecord.Host_Institution_Course__r.Host_Institution__r.Country__r.Name;
		}
		catch(Exception e)
		{
			System.debug('Home Institution Country was not queried with the Course_Equivalency__c record');
		}
		try
		{
			hostInstitutionCourseCode = ceRecord.Host_Institution_Course__r.Course_Code__c;
		}
		catch(Exception e)
		{
			System.debug('Host Institution Course Code was not queried with the Course_Equivalency__c record');
		}
		try
		{
			hostInstitutionCourseTitle = ceRecord.Host_Institution_Course__r.Course_Title_2__c;
		}
		catch(Exception e)
		{
			System.debug('Home Institution Course Title was not queried with the Course_Equivalency__c record');
		}
		deniedReason = (String) this.populateField('Denied_Reason__c', ceRecord);
		deniedReasonOther = (String) this.populateField('Denied_Reason_Other__c', ceRecord);
		status = (String) this.populateField('Status__c', ceRecord);
		lastApprovedRejectedName = (String) this.populateField('Last_Approved_Rejected_By__r.Name', ceRecord);
		lastApprovedRejectedDate = (Datetime) this.populateField('Last_Approved_Rejected__c', ceRecord);


		// Parse US_Terms__c of Home Institution Course
		try 
		{
			if(ceRecord.Home_Institution_Course__r.US_Terms__c != null)
			{
				String[] terms = ceRecord.Home_Institution_Course__r.US_Terms__c.split(';');
				terms.sort();
				this.termsOffered = '';
				for(String t: terms)
				{
					if(this.termsOffered == '')
					{
						this.termsOffered = t;
					}
					else
					{
						this.termsOffered = this.termsOffered + ', ' + t;
					}
				}
			}
		}
		catch (Exception e) {
			System.debug('US Terms was not queried with the Course_Equivalency__c record');
		}

		// Parse Year_in_Degree_Plan__c of Home Institution Course
		try 
		{
			switch on ceRecord.Home_Institution_Course__r.Year_in_Degree_Plan__c {
				when '1 of 4' {
					this.yearInDegreePlan = 'Freshman';
				}
				when '2 of 4' {
					this.yearInDegreePlan = 'Sophmore';
				}
				when '3 of 4' {
					this.yearInDegreePlan = 'Junior';
				}
				when '4 of 4' {
					this.yearInDegreePlan = 'Senior';
				}
				when else {
					this.yearInDegreePlan = 'Other';
				}
			}
		} 
		catch (Exception e) {
			System.debug('Year in Degree Plan was not queried with the Course_Equivalency__c record');
		}
		
		setBaseValues();
	}

	private void setBaseValues() 
	{
		this.recordId = courseEquivalency.Id;
		this.recordName = courseEquivalency.Name;
		this.sObjectName = 'Course_Equivalency__c';
		
	}

	public override Boolean equals(Object o)
	{
		if(o instanceof model_courseEquivalency)
		{
			model_courseEquivalency obj = (model_courseEquivalency)o;
			return (this.recordId == obj.recordId && this.recordName == obj.recordName);
		}
		return false;
	}

	public static List<model_courseEquivalency> getModelsFromList(List<Course_Equivalency__c> ces)
	{
		List<model_courseEquivalency> returnList = new List<model_courseEquivalency>();

		for(Course_Equivalency__c ce: ces)
		{
			returnList.add(new model_courseEquivalency(ce));
		}

		return returnList;
	}
}