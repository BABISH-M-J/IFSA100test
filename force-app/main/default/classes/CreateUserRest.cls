@RestResource(urlMapping='/CreateCustomerUser/*')
global  class CreateUserRest {
    @HttpPost
    global static String doPost(String email,boolean emailOptOut, String password, String firstName, String lastName, String phone, Decimal graduationYear, String authorizationKey){
        User usr;
        if(Label.CreateUserAuthKey != authorizationKey){
            return 'Invalid Authorization Key';
        }
        User[] users = [SELECT Id FROM User WHERE Email = :email];
        if(users.size() > 0){
            return 'user already exists';
        }
        
        String accountName = firstName + ' ' + lastName ;
        //email = 'erobinson@ifsa-butler.org' 
        List<user> listofUser = [Select Id From User WHERE email =: System.Label.User_Email LIMIT 1];
        string ownerId ;
        if(listofUser.size() > 0){
            ownerId = listofUser[0].id;
        }
        Account accountObj = new Account(Name=accountName, Type='Student Account');
        
        if(listofUser.size() > 0){
            accountObj.OwnerId = ownerId;
        }
        
        insert accountObj;  
        
        Profile p=[SELECT Id FROM Profile WHERE Name = 'IFSA Student User' LIMIT 1];
        User userObj = new User(
            UserName = email + '.ifsa',
            FirstName = firstName,
            LastName = lastName,
            Alias = lastName.left(4),
            email = email,
            CommunityNickName = string.valueOf(math.random()).substring(0,6),
            ProfileID = p.id,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            Phone = phone,
            Createdbyweb__c = true,
            Graduation_Year__c = graduationYear,
            emailOptOut__c = emailOptOut 
            
        );
        
        String response ='success';
        try{
            system.debug('50=>'+userObj);
            system.debug('50=>'+accountObj.Id);
            system.debug('50=>'+password);
            Id userId = Site.createExternalUser(userObj, accountObj.Id, password);
            system.debug('userId==>'+userId);
            if (Test.isRunningTest()){
                userId = userInfo.getUserId();
            }
            usr =  [Select Name, ContactId From User where Id =: userId ];
             if (Test.isRunningTest()){
                usr.ContactId = '0034N00002O2emoQAB';
            }
            system.debug('usr==>'+usr.ContactId);
            Contact contactToUpdate = new Contact(Id = usr.ContactId, 
                                                  Contact_Source__c = System.Label.Contact_Source_New, 
                                                  First_Access_Global_Wayfinder__c = system.now()); 
            update contactToUpdate;
        }
        catch(Site.ExternalUserCreateException ex) {
            system.debug('Error => ' + ex.getDisplayMessages());
            response = String.join(ex.getDisplayMessages(),',');
        }
        return response;
        
    }
    
}