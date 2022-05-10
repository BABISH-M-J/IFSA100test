@isTest
public without sharing class model_programAuthorizationTest
{
      @TestSetup
       static void makedata(){
        
       World__c world = new World__c(Name = 'Global');
    database.insert(world);

    Region__c international = new Region__c(Name = 'International Support', World__c = world.Id);
    Region__c local = new Region__c(Name = 'Local Support', World__c = world.Id);
    database.insert(new List<Region__c>{international, local});
    
        Country__c country = apexMockDataUtility.createCountry(international.Id);
Host_Institution__c hc= apexMockDataUtility.createHostInstitution(country.Id);
        List<String> names = new List<String>{'Test 1', 'Test 2', 'Undecided'};
        User academicAffiarsUser = apexMockDataUtility.CreateSysAdmin();
     
    Home_Institution__c homeInstitution=apexMockDataUtility.createHomeInstitution('testhomei',country.Id);
     Account act= apexMockDataUtility.createAccount('testaccount',homeInstitution.Id);

       List<Program__c> programs = apexMockDataUtility.createPrograms(hc, names, academicAffiarsUser.Id);

    
    Program_Authorization__c pa=new Program_Authorization__c(Account__c=act.Id, Program__c=programs[0].Id,Term__c='Spring;Fall');
    Database.insert(pa);
       }
       
       
         @isTest static void testdata(){
         Program_Authorization__c sc=[Select Id,Name,Account__c,Program__c,Program__r.Name,Program__r.Country__r.Name,Do_Not_Allow_Students_To_Apply__c,Term__c from Program_Authorization__c limit 1];
         
           Test.StartTest();
           
             model_programAuthorization  msp=new model_programAuthorization();
             model_programAuthorization msp1=new model_programAuthorization(sc);
             Boolean Springterm;
             Boolean summerTerm ;
   Boolean winterTerm ;
   Boolean fallTerm ;
   Boolean notApproved ;
   Boolean academicYear ;
   Boolean calendarYear ;
   Boolean selectAllAvalibleTerms ;
   Boolean showSpringTerm ;
   Boolean showSummerTerm ;
   Boolean showWinterTerm ;
   Boolean showFallTerm ;
   Boolean showAcademicYear ;
   Boolean showCalendarYear ;
   Boolean showNotApproved ;
             msp1.Springterm=false;
                msp1.summerTerm=false;
   msp1.winterTerm=false;
   msp1.fallTerm=false;
   msp1.notApproved=false;
   msp1.academicYear=false;
   msp1.calendarYear=false;
   msp1.selectAllAvalibleTerms=false;
   msp1.showSpringTerm=false;
   msp1.showSummerTerm=false;
   msp1.showWinterTerm=false;
   msp1.showFallTerm=false;
   msp1.showAcademicYear=false;
   msp1.showCalendarYear=false;
   msp1.showNotApproved=false;
                  model_programAuthorization msp2=new model_programAuthorization(sc.Id);
                  model_programAuthorization.convertFromJson('{"firstName":"John", "lastName":"Doe"}');
                  model_programAuthorization.convertFromJsonToList('[{"firstName":"John", "lastName":"Doe"}]');
               msp2.save();
               model_programAuthorization.saveList(new List<model_programAuthorization>{msp2});
            Test.StopTest();
         }
         
          @isTest static void testdata1(){
    Program_Authorization__c sc=[Select Id,Name,Account__c,Program__c,Program__r.Name,Program__r.Country__r.Name,Do_Not_Allow_Students_To_Apply__c,Term__c from Program_Authorization__c limit 1];
          
           Test.StartTest();
                 model_programAuthorization msp=new model_programAuthorization();
                 msp.equals((Object)msp);
                   msp.equals((Object)sc);
            Test.StopTest();
         }
         
         
         
}