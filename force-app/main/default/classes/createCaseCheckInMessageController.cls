public without sharing class createCaseCheckInMessageController 
{
    @AuraEnabled()
    public static String createCaseCheckIn(Id recordId, String message)
    {
        Case c;
        try 
        {
            c = [SELECT Id, Student_Check_In_Sent__c, Student_Check_In_Message__c FROM Case WHERE Id =: recordId];    
                System.debug('check'+c);
            if(c.Student_Check_In_Sent__c?.date() == Date.today())

            {
                throw new createCaseCheckInMessageControllerException('Error: A check in message has already been sent today');
            }
        }
        catch (NullPointerException e) 
        {
            throw new createCaseCheckInMessageControllerException(e.getMessage(), e);
        }
        
        c.Student_Check_In_Message__c = message;
        c.Student_Check_In_Sent__c = Datetime.now();

        try {
            Database.update(c);    
        } catch (Exception e) {
            throw new createCaseCheckInMessageControllerException(e.getMessage(), e);
        }
        return 'Success';
    }

    public class createCaseCheckInMessageControllerException extends Exception {}
}