/**
 * Service class for interacting with Course__c records
 * @author Brock Barlow
 */
// ApexDoc updated 1/28/2021 Brock Barlow
public without sharing class courseService 
{
	/**
	 * Updates the short description field used in CHART search results by only saving the first 250 characters of the course description
	 * @param newRecords
	 */
	public static void updateShortDescription(List<Course__c> newRecords)
	{
		for(Course__c c: newRecords)
		{
			String stripped = c.Course_Description__c != null ? c.Course_Description__c.unescapeHtml4() : '';
			if(stripped.length() > 250)
			{
				stripped = stripped.left(250) + '...';
			}
			c.Course_Description_Short__c = stripped;
		}
	}
	/**
	 * Unchecks Approved_for_CHART__c if Expiration_Reason__c is NOT '5 years since last renewal'
	 * @param newRecords
	 */
	public static void unapproveExpiredCourses(List<Course__c> newRecords)
	{
		for(Course__c c: newRecords)
		{
			if(c.Is_Expired__c && c.Expiration_Reason__c != '5 years since last renewal')
			{
				c.Approved_for_CHART__c = false;
			}
		}
	}
}