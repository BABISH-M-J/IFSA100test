@isTest
private class CreateUserRestTest {
    static testMethod void validateCreateUser() {
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        String authorizationKey=System.Label.CreateUserAuthKey;
        system.debug('authorizationKey='+authorizationKey);        
        String returnData = CreateUserRest.doPost('Test2321@gmail.com',true,'password','Rahul','Sighn','572354543',2,authorizationKey);
        
        contact objcontact = new contact();
        objcontact.First_Access_Global_Wayfinder__c =  system.now();
        objContact.Contact_Source__c = 'Global Wayfinder';
        objContact.Graduation_Year__c  = 2020;
        objcontact.HasOptedOutOfEmail = false;
        objcontact.Email = 'devorg@cloudnerd.com';
        objcontact.LastName = 'Test2 Con';
        insert objcontact;
        
        List<User> user = new List<user>();
        System.runAs (thisUser) {
            Profile prof = [select id from profile where name LIKE '%IFSA Student User'];
            UserRole ur = new UserRole(Name = 'CEO');
        insert ur;
            user obj = new user();
            obj.firstName = 'test1';
            obj.lastName = 'test2';
            obj.profileId = prof.id;
            obj.ContactId = objcontact.id;   
            obj.username = 'test@test.com';
            obj.email = 'erobinson@ifsa-butler.org';
            obj.Alias = 'alias';
            obj.TimeZoneSidKey = 'America/Los_Angeles';
            obj.EmailEncodingKey = 'UTF-8';
            obj.LanguageLocaleKey = 'en_US';
            obj.LocaleSidKey = 'en_US';
            obj.UserRoleId = ur.Id;//'00E61000000QpO7EAK';
            user.add(obj);
            //insert user;
        }
        UpdateUserContact.ContactInsert(user);
        
    }
    
}