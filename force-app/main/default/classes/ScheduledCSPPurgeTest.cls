//Created by PowerFluence req_dt:03/29/2022 ref email from Clayton starts
@isTest
public class ScheduledCSPPurgeTest {
	@TestSetup
	static void makeData(){
		BaseTriggerHandler.bypass('applicationItemTriggerHandler');
		Map<String, SObject> testInfo = apexMockDataUtility.createIfsaDataCollection();
	}
    
    public static testMethod void testSchedule()
    {
    	Test.startTest();
    	String jobId = System.schedule('Test_ScheduledCSPPurge' + Datetime.now().format(),'0 0 0 * * ? *', new ScheduledCSPPurge());        
        Test.stopTest();
    }
}
//Created by PowerFluence req_dt:03/29/2022 ref email from Clayton ends