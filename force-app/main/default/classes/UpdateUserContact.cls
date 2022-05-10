public without sharing class UpdateUserContact {
    public static void ContactInsert(List<User> userlist){  
        List<Contact> objcontactList = new  List<Contact>();
        for(user obj : userlist){
            if(obj.contactId != null && obj.Createdbyweb__c == true){
                Contact objContact =  new Contact();
                objContact .id = obj.contactId;
                objContact.First_Access_Global_Wayfinder__c = system.now();
                objContact.Contact_Source__c = 'Global Wayfinder';
                objContact.Graduation_Year__c = obj.Graduation_Year__c; 
                if(obj.emailOptOut__c == false) {
                    objContact.HasOptedOutOfEmail = true ;
                } else {
                    objContact.HasOptedOutOfEmail = false ;
                }                
                objContact.Home_Institution__c = chartLoginController.getHomeInstituitionFromEmailAddress(obj.email);
                objcontactList.add(objContact);
                system.debug('objContact==>'+objContact); 
            }
        }
        update objcontactList;        
    }
}