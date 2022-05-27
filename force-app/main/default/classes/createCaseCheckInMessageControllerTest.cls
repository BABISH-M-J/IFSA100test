@IsTest
public class createCaseCheckInMessageControllerTest 
{
    @TestSetup
    static void makeData(){
        Case c = new Case(Subject = 'Test Case - Check In', None_of_These_Apply_Other_Factors__c = true);
        
        Database.insert(c);
    }
    @IsTest
    static void testComponent(){
        User contextuser = new User(Id = UserInfo.getUserId());
        Case c = [SELECT Id FROM Case WHERE Subject = 'Test Case - Check In' LIMIT 1].get(0);
        String message1 = 'Test Message 1';
        String result;
        Test.startTest();
        System.runAs(contextuser){
            result = createCaseCheckInMessageController.createCaseCheckIn(c.Id, message1);

            System.assertEquals('Success', result);
            Case record = [SELECT Id, Student_Check_In_Sent__c, Student_Check_In_Message__c FROM Case WHERE Id =: c.Id];
            record.Student_Check_In_Sent__c = Datetime.now();
            System.assertEquals(message1, record.Student_Check_In_Message__c);
            try
            {
                createCaseCheckInMessageController.createCaseCheckIn(c.Id, message1);    
            }
            catch (createCaseCheckInMessageController.createCaseCheckInMessageControllerException e)
            {
                System.assertEquals('Error: A check in message has already been sent today', e.getMessage());
            }
        }
        Test.stopTest();
    }
   
    
    @IsTest
    static void testComponent1(){
        User contextuser1 = new User(Id = UserInfo.getUserId());
        
        Case c = [SELECT Id FROM Case WHERE Subject = 'Test Case - Check In' LIMIT 1].get(0);
        String message1 = 'Test Message 1';
        String result1;
        
        Test.startTest();
       // System.runAs(contextuser1){
      // Id f= 'dsjidishdihi123';
            result1 = createCaseCheckInMessageController.createCaseCheckIn(c.Id, message1);

            System.assertEquals('Success', result1);
            Case record1 = [SELECT Id, Student_Check_In_Sent__c, Student_Check_In_Message__c FROM Case WHERE Id =:c.Id].get(0);
                 //record1.Id='null';
                record1.Student_Check_In_Sent__c =null ;
        System.debug('record1'+record1);
        	update record1;
            System.assertEquals(message1, record1.Student_Check_In_Message__c);
            try
            {
                createCaseCheckInMessageController.createCaseCheckIn(record1.id, message1);    
            }
            catch (createCaseCheckInMessageController.createCaseCheckInMessageControllerException e)
            {
                System.assertEquals('Error: A check in message has already been sent today', e.getMessage());
            }
           //}
                 Test.stopTest();
      
    }
        }