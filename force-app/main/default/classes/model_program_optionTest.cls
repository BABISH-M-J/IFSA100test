@isTest
public without sharing class model_program_optionTest
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
    

       List<Program__c> programs = apexMockDataUtility.createPrograms(hc, names, academicAffiarsUser.Id);
       Program_Option__c po=new Program_Option__c(Name='test option', Country__c=usa.Id, Locality__c=testCity.Id, Program__c=programs[0].Id,Program_Option_Active__c=true);
           database.insert(po);

       }
       
       
         @isTest static void testdata(){
         Program_Option__c po=[Select Id,Name,Country__c,Locality__c,Program__c,Program_Option_Active__c from Program_Option__c  limit 1];
           Test.StartTest();
           model_program_option c=new model_program_option();
                      model_program_option c1=new model_program_option(po);

            Test.StopTest();
         }
         
          @isTest static void testdata1(){
                   Program_Option__c po=[Select Id,Name,Country__c,Locality__c,Program__c,Program_Option_Active__c  from Program_Option__c  limit 1];

           Test.StartTest();
                      model_program_option c=new model_program_option();

            c.Equals((Object)c);
            c.Equals((Object)po);
            Test.StopTest();
         }
         
         
         
}