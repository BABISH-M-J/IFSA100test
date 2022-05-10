@isTest
public without sharing class model_homeInstitutionTest
{
    @TestSetup
 static void makedata(){
   World__c world = new World__c();
        world.Name = 'Global';
        database.insert(world);
        //Create Regions
        Region__c international = new Region__c();
        international.Name = 'International Support';
        international.World__c = world.Id;
        Region__c local = new Region__c();
        local.Name = 'Local Support';
        local.World__c = world.Id;
        database.insert(new List<Region__c>{international, local});

        //Creating test Country
    Country__c testCountry = new Country__c();
    testCountry.Name = 'UnitTestLandia';
        testCountry.Region__c = international.Id;
        testCountry.Active__c = true;
        Database.Insert(testCountry);
        System.assertNotEquals(testCountry.Id, null, 'Something went wrong while inserting the test Country.');

    Home_Institution__c homeInstitution = new Home_Institution__c();
    homeInstitution.Name = 'testUniversity';
    homeInstitution.Country__c = testCountry.Id;
    
    Database.insert(homeInstitution);

  }
  
   @isTest static void testdata(){
         
         Home_Institution__c c=[Select Id,name from Home_Institution__c ];
         Test.StartTest();
         model_homeInstitution con=new model_homeInstitution();
          model_homeInstitution con1=new model_homeInstitution(c);
         // con1.setBaseValues();
          con1.equals((object)con1);
           con1.equals((object)c);
         Test.StopTest();
         }
  }