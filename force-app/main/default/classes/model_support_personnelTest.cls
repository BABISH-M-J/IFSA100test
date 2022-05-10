@isTest
public without sharing class model_support_personnelTest
{
      @TestSetup
       static void makedata(){
        
       World__c world = new World__c(Name = 'Global');
    database.insert(world);

    Region__c international = new Region__c(Name = 'International Support', World__c = world.Id);
    Region__c local = new Region__c(Name = 'Local Support', World__c = world.Id);
    database.insert(new List<Region__c>{international, local});
    
    Country__c usa = apexMockDataUtility.createLocalCountry(local.Id);
        Country__c country = apexMockDataUtility.createCountry(international.Id);
Host_Institution__c hc= apexMockDataUtility.createHostInstitution(country.Id);
        List<String> names = new List<String>{'Test 1', 'Test 2', 'Undecided'};
        User academicAffiarsUser = apexMockDataUtility.CreateSysAdmin();
        Locality__c testCity = new Locality__c(Name = 'Test City', Country__c = usa.Id);
    database.insert(testCity);
    Home_Institution__c homeInstitution=apexMockDataUtility.createHomeInstitution('testhomei',country.Id);
     Account act= apexMockDataUtility.createAccount('testaccount',homeInstitution.Id);
    Contact ct= apexMockDataUtility.createContact('testcont',act.Id);

       List<Program__c> programs = apexMockDataUtility.createPrograms(hc, names, academicAffiarsUser.Id);
       Program_Option__c po=new Program_Option__c(Name='test option', Country__c=usa.Id, Locality__c=testCity.Id, Program__c=programs[0].Id,Program_Option_Active__c=true);
           database.insert(po);

    Support_Personnel__c sc=new Support_Personnel__c( Account__c=act.Id, Contact__c=ct.Id, Country__c=usa.Id, Host_Institution__c=hc.Id, 
     Non_IFSA_Staff__c=ct.Id,Locality__c=testCity.Id, Program__c=programs[0].Id,
    Home_Institution__c=homeInstitution.Id, Program_Option__c=po.Id, Region__c=local.Id, World__c=world.Id,Type__c='Non IFSA Staff',Support_Role_Type__c='Advisor');
               database.insert(sc);

       }
       
       
         @isTest static void testdata(){
         Support_Personnel__c sc=[Select Id,Non_IFSA_Staff__r.Name, Support_Role_Type__c,Emergency_Contact__c,Name,Account__c,Contact__c, Country__c, Host_Institution__c, IFSA_Staff__c, Locality__c, Non_IFSA_Staff__c,
          Program__c, Home_Institution__c,Program_Option__c,  Region__c, World__c from Support_Personnel__c limit 1];
         
           Test.StartTest();
             model_support_personnel msp=new model_support_personnel();
             model_support_personnel msp1=new model_support_personnel(sc);
             msp1.contactLastName='test';
             msp1.accountName='test1';
             msp1.emailAddress='jh@test.com';
             msp1.phoneNumber='999999999';
             msp1.recordTypeName='testname';
                
            Test.StopTest();
         }
         
          @isTest static void testdata1(){
Support_Personnel__c sc=[Select Id,Non_IFSA_Staff__r.Name, Support_Role_Type__c, Emergency_Contact__c,Name,Account__c,Contact__c, Country__c, Host_Institution__c, IFSA_Staff__c, Locality__c, Non_IFSA_Staff__c,
          Program__c, Home_Institution__c,Program_Option__c,  Region__c, World__c from Support_Personnel__c limit 1];
          
           Test.StartTest();
                 model_support_personnel msp=new model_support_personnel();
                 msp.equals((Object)msp);
                   msp.equals((Object)sc);
            Test.StopTest();
         }
         
         
         
}