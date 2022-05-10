@isTest
public class CommunityLogin_ApiTest {
    static testMethod void communityLogin(){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/WorkdayIntegration/';
        req.httpMethod = 'POST';
        RestContext.request = req;
        String str = '{\"StartDate\": \"2019-08-01\",\"EndDate\": \"2019-12-03\"}';
        req.requestBody= Blob.valueOf(str);
        RestContext.response= res;
        
        
        test.setMock(HttpCalloutMock.class, new calloutMock());
        
        Test.startTest();
        CommunityLogin_ApiClass.login();
        Test.stopTest();
        
    }
    
}