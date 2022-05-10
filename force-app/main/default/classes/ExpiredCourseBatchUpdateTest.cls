/**
 * Unit tests for <<ExpiredCourseBatchUpdate>>
 * @author Audrey Carson
 */
// ApexDoc updated 2/1/2021 Brock Barlow
@isTest
private class ExpiredCourseBatchUpdateTest {
	
	@isTest static void testBatch() {
		List<Course__c> courseList = new List<Course__c>();
		Butler_Department_Code__c code = apexMockDataUtility.createBUDepartmentCode();
		for(Integer i = 0; i<20; i++){
			Course__c c = new Course__c(Name='test'+i, Approved_for_CHART__c = true, Is_Expired__c = false, Butler_Department_Code__c = code.Id);
			if(i< 10){
				c.Last_Renewed_Date__c = System.today().addYears(-8);
			}
			else if(i>15){
				c.Last_Renewed_Date__c = System.today().addYears(-1);
			}
			courseList.add(c);
		
		}
		insert courseList;

		test.startTest();
		ExpiredCourseBatchUpdate batchJob = new ExpiredCourseBatchUpdate();
		Database.executeBatch(batchJob);
		test.stopTest();

		List<Course__c> expiredCourses = [SELECT Id FROM Course__c WHERE Is_Expired__c = true];
		System.assertEquals(10, expiredCourses.size());
	}
	@isTest static void testScheduleExecute() {
		Test.startTest();
		Datetime dt = Datetime.now().addMinutes(1);
		String chron = '0 ' + dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
		String jobId = System.schedule('testmethod', chron, new ExpiredCourseBatchUpdate());
		Test.stopTest();
	}
	
}