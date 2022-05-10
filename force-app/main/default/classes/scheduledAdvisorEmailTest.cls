@isTest
public class scheduledAdvisorEmailTest {
	@TestSetup
	static void makeData(){
		Map<String, SObject> testInfo = apexMockDataUtility.createIfsaDataCollection();
	}
    
    public static testMethod void testSchedule()
    {
    	Test.startTest();
    	String jobId = System.schedule('testscheduledAdvisorEmail' + Datetime.now().format(),
            '0 0 0 * * ? *', new scheduledAdvisorEmail());
        
        Test.stopTest();
    }
}