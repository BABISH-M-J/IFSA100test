@isTest
public without sharing class model_tagTest
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
        
  Locality__c testCity = new Locality__c(Name = 'Test City', Country__c= testCountry.Id);
    database.insert(testCity);
    Home_Institution__c homeInstitution = new Home_Institution__c();
    homeInstitution.Name = 'testUniversity';
    homeInstitution.Country__c = testCountry.Id;
    
    Database.insert(homeInstitution);
    Account act= apexMockDataUtility.createAccount('testaccount',homeInstitution.Id);
    Contact ct= apexMockDataUtility.createContact('testcont',act.Id);
    Butler_Department_Code__c buCode = apexMockDataUtility.createBUDepartmentCode();
        List<Host_Institution__c> hosts = apexMockDataUtility.createHostInstitutions(testCountry.Id, 1);
        User academicAffiarsUser = apexMockDataUtility.CreateSysAdmin();
         List<Program__c> programs = apexMockDataUtility.createPrograms(hosts[0], new List<String>{'testname'}, academicAffiarsUser.Id);
        Course__c course = apexMockDataUtility.createHostCourse(hosts[0].Id, buCode, programs[0].Id);
 Id oppRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Custom Program (New)').getRecordTypeId();
        Integer fee = 2000;
        Decimal profit = 500;
        Integer enrollment = 10;
        Opportunity o = new Opportunity(RecordTypeId = oppRT,Country__c = testCountry.Id,City__c = testCity.Id,AccountId = act.Id,Sending_Institution_Advisor__c = ct.Id,
Program_Name__c = 'New Custom Program',Projected_Enrollment__c = enrollment,Fee__c = fee,
StageName = 'Lead',Name = 'Test Oppy',CloseDate = Date.today().addDays(90),Profit__c = profit );
Database.insert(o);

Tag__c t= new Tag__c(
Area_of_Study__c='Art Education',
Department__c='Education',
Opportunity__c=o.Id,
Instructor_Contact__c=ct.Id,
Course__c=course.Id
);


Tag__c t1= new Tag__c(
Department__c='Education',
Opportunity__c=o.Id,
Instructor_Contact__c=ct.Id,
Course__c=course.Id
);
Database.insert(new List<Tag__c >{t,t1});
  }
  
   @isTest static void testdata(){
         Tag__c[] t=[Select Name,Id,Area_of_Study__c,Department__c, Opportunity__c,Instructor_Contact__c,Course__c from Tag__c];
         Test.StartTest();
          model_tag con=new model_tag();
         model_tag con1=new model_tag(t[0]);
         model_tag con2=new model_tag(t[1]);
         con1.equals((object)con1);
         con1.equals((object)t);
         Test.StopTest();
         }
  }