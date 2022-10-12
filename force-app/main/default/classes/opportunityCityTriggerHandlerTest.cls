@isTest
private with sharing class opportunityCityTriggerHandlerTest {
    @TestSetup
    static void makeData(){
        User fieldDirector = apexMockDataUtility.CreateSysAdmin();
        fieldDirector.FirstName = 'Field';
        fieldDirector.LastName = 'Director';
        User programOwner = apexMockDataUtility.CreateSysAdmin();
        programOwner.FirstName = 'Program';
        programOwner.LastName = 'Advisor';
        User residentDirector = apexMockDataUtility.CreateSysAdmin();
        residentDirector.FirstName = 'Resident';residentDirector.LastName = 'Director';
        Database.insert(new List<User>{fieldDirector, programOwner, residentDirector});
        World__c world = new World__c(Name = 'Global');
        database.insert(world);

        Region__c international = new Region__c(Name = 'International Support', World__c = world.Id);
        Region__c local = new Region__c(Name = 'Local Support', World__c = world.Id);
        database.insert(new List<Region__c>{international, local});
        Country__c usa = apexMockDataUtility.createLocalCountry(local.Id);
      Country__c country = apexMockDataUtility.createCountry(international.Id);
        Locality__c testCity = new Locality__c(Name = 'Test City', Country__c = country.Id);
        Locality__c testCity1 = new Locality__c(Name = 'Test City1', Country__c = country.Id);
        database.insert(new list<Locality__c>{testCity,testCity1});
        List<Home_Institution__c> homeInstitutions = apexMockDataUtility.createHomeInstitution('Test Institution', 1, usa.Id);
        List<Account> accounts = [SELECT Id, Name, Institution__c FROM Account WHERE Institution__c IN: homeInstitutions];
        accounts.get(0).OwnerId = fieldDirector.Id;
        Database.update(accounts);
        Contact schoolAdvisor = new Contact(AccountId = accounts[0].Id, FirstName = 'Test', LastName = 'Advisor', Email = 'tadvisor@email.test', OwnerId = fieldDirector.Id);
        database.insert(schoolAdvisor);
        Id oppRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Custom Program (New)').getRecordTypeId();
        Integer fee = 2000;
        Decimal profit = 500;
        Integer enrollment = 10;
        Opportunity o = new Opportunity(RecordTypeId = oppRT,Country__c = country.Id,City__c = testCity.Id,AccountId = accounts[0].Id,Sending_Institution_Advisor__c = schoolAdvisor.Id,
Program_Name__c = 'New Custom Program',Projected_Enrollment__c = enrollment,Fee__c = fee,
StageName = 'Lead',Name = 'Test Oppy',CloseDate = Date.today().addDays(90),Profit__c = profit );
Opportunity o1 = new Opportunity(
RecordTypeId = oppRT,
Country__c = country.Id,
City__c = testCity.Id,
AccountId = accounts[0].Id,
Sending_Institution_Advisor__c = schoolAdvisor.Id,Program_Name__c = 'New Custom Program',Projected_Enrollment__c = enrollment,Fee__c = fee,StageName = 'Lead',Name = 'Test Oppy1',CloseDate = Date.today().addDays(90),Profit__c = profit );
Database.insert(new List<Opportunity>{o,o1});
    }
    @IsTest
    static void testmt(){
        Account schoolAccount = [SELECT Id, Name FROM Account WHERE RecordType.Name = 'Home Institution' LIMIT 1].get(0);
        Contact schoolAdvisor = [SELECT Id, Name FROM Contact WHERE AccountId =: schoolAccount.Id LIMIT 1].get(0);
        Country__c country = [SELECT Id, Name FROM Country__c WHERE Name = 'England' LIMIT 1].get(0);
        Locality__c[] city = [SELECT Id, Name FROM Locality__c limit 2];
        Opportunity o=[Select Id,Cities__c from Opportunity limit 1];
        Opportunity_City__c oci=new Opportunity_City__c(City__c=city[0].Id,Opportunity__c=o.Id);
        Opportunity_City__c oci1=new Opportunity_City__c(City__c=city[1].Id,Opportunity__c=o.Id);
        Test.startTest();
        Database.insert(new list<Opportunity_City__c>{oci,oci1}); 
        System.debug(o.Cities__c);
        System.assert(o.Cities__c==city[0].Name);
        oci.CurrencyIsoCode='AED';
        Database.update(oci);
        System.debug(o.Cities__c);
        System.assert(o.Cities__c==city[0].Name);
        Database.delete(oci.Id);
        System.debug(o.Cities__c);
        System.assert(o.Cities__c==city[0].Name);
        Database.undelete(oci.Id);
        System.debug(o.Cities__c);
        System.assert(o.Cities__c==city[0].Name);
        Test.stopTest();}
}