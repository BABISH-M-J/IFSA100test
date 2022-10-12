@isTest
public class model_courseEquivalency_Test {
    
    @testSetup
    public static void mockData(){
        //Create test account
        Account acct = apexMockDataUtility.createAccount('TestAcct');
        
        //Create test contact
        Contact ctc = apexMockDataUtility.createContact('TestCtc', acct.Id);
        
        //Create test user
        User u= apexMockDataUtility.createUser(ctc.id);
        insert u;
        
        //Cretae World Test Record
        World__c world = new World__c(Name = 'Global');
		database.insert(world);

        //Cretae Region Test Record
		Region__c reg = new Region__c(Name = 'Local Support', World__c = world.Id);
        database.insert(reg);
        
        //Cretae Country Test Record
        Country__c cou = apexMockDataUtility.createCountry(reg.id);
        
        //Cretae Home Institute Test Record
        Host_Institution__c hostIns = apexMockDataUtility.createHostInstitution(cou.id);
        
        //Create Butler Department Cose Test Record
        Butler_Department_Code__c buCode = apexMockDataUtility.createBUDepartmentCode();
        
        //Create Host Course record
        Course__c hostcour = apexMockDataUtility.createHostCourse(hostIns.id,buCode);
        

        
        //Create Home Course record
        List<Course__c> Homecour = new List<Course__c>();
        for(integer i =0 ; i<5 ;i++){
            Course__c currHomeCurr = new Course__c();
            currHomeCurr.RecordTypeId = Schema.SObjectType.Course__c.getRecordTypeInfosByName().get('Home Institution').getRecordTypeId();
            currHomeCurr.Name = 'Test Course' + i;
            currHomeCurr.Course_Code__c = 'ASDF';
            currHomeCurr.Host_Institution__c = hostIns.id;
            currHomeCurr.US_Terms__c = 'Spring;Fall;Summer';
            if(i == 0){
            	currHomeCurr.Year_in_Degree_Plan__c = '1 of 3';
            }else{
                currHomeCurr.Year_in_Degree_Plan__c = i+' of 4';
            }
            Homecour.add(currHomeCurr);
        }
        Database.insert(Homecour);
        
        //Cretae Course Matching Project Test Record
        CMP__c newCMP = new CMP__c(Status__c = 'Submitted',
                                   Custom_Message_Text__c = 'Test Text',
                                   Contact__c = ctc.id);
        Database.insert(newCMP);
        
        //Create Course Equivalency Test Record
        List<Course_Equivalency__c> courEquiList = new List<Course_Equivalency__c>();
        for(integer i=0; i<5;i++){
            Course_Equivalency__c courEqui = new Course_Equivalency__c();
            courEqui.CMP_of_Home_Course_Request__c = newCMP.id;
            courEqui.Home_Institution_Course__c = homecour[i].id;
            courEqui.Host_Institution_Course__c = hostcour.id;
            courEqui.Denied_Reason__c = 'Missing essential learning components';
            courEqui.Denied_Reason_Other__c = 'Test' + i;
            courEqui.Status__c ='Potential Match';
            courEqui.Last_Approved_Rejected_By__c = u.id;
            courEqui.Last_Approved_Rejected__c = System.today();
            courEquiList.add(courEqui);
        }
        database.insert(courEquiList);
    }
    
    @isTest
    public static void testmodel_courseEquivalency1of4(){
        test.startTest();
        List<Course_Equivalency__c> corEquList = [Select id,Name,CMP_of_Home_Course_Request__c,Host_Institution_Course__c,Home_Institution_Course__c,Denied_Reason__c,Denied_Reason_Other__c,
                                                 Status__c,Last_Approved_Rejected_By__c,Last_Approved_Rejected__c,Home_Institution_Course__r.Course_Code__c,Home_Institution_Course__r.Course_Title_2__c,
                                                 Host_Institution_Course__r.Host_Institution__r.Name,Host_Institution_Course__r.Host_Institution__r.Country__r.Name,Host_Institution_Course__r.Course_Code__c,
                                                 Host_Institution_Course__r.Course_Title_2__c,Last_Approved_Rejected_By__r.Name,Home_Institution_Course__r.Year_in_Degree_Plan__c
                                                 From Course_Equivalency__c Where Home_Institution_Course__r.Year_in_Degree_Plan__c =: '1 of 4'];
        model_courseEquivalency modCourEqu = new model_courseEquivalency(corEquList[0]);
        test.stopTest();
        System.assertEquals(modCourEqu.yearInDegreePlan, 'Freshman');
    }
    
    @isTest
    public static void testmodel_courseEquivalency2of4(){
        test.startTest();
        List<Course_Equivalency__c> corEquList = [Select id,Name,CMP_of_Home_Course_Request__c,Host_Institution_Course__c,Home_Institution_Course__c,Denied_Reason__c,Denied_Reason_Other__c,
                                                 Status__c,Last_Approved_Rejected_By__c,Last_Approved_Rejected__c,Home_Institution_Course__r.Course_Code__c,Home_Institution_Course__r.Course_Title_2__c,
                                                 Host_Institution_Course__r.Host_Institution__r.Name,Host_Institution_Course__r.Host_Institution__r.Country__r.Name,Host_Institution_Course__r.Course_Code__c,
                                                 Host_Institution_Course__r.Course_Title_2__c,Last_Approved_Rejected_By__r.Name,Home_Institution_Course__r.Year_in_Degree_Plan__c
                                                 From Course_Equivalency__c Where Home_Institution_Course__r.Year_in_Degree_Plan__c =: '2 of 4'];
        model_courseEquivalency modCourEqu = new model_courseEquivalency(corEquList[0]);
        test.stopTest();
        System.assertEquals(modCourEqu.yearInDegreePlan, 'Sophmore');
    }
    
    @isTest
    public static void testmodel_courseEquivalency3of4(){
        test.startTest();
        List<Course_Equivalency__c> corEquList = [Select id,Name,CMP_of_Home_Course_Request__c,Host_Institution_Course__c,Home_Institution_Course__c,Denied_Reason__c,Denied_Reason_Other__c,
                                                 Status__c,Last_Approved_Rejected_By__c,Last_Approved_Rejected__c,Home_Institution_Course__r.Course_Code__c,Home_Institution_Course__r.Course_Title_2__c,
                                                 Host_Institution_Course__r.Host_Institution__r.Name,Host_Institution_Course__r.Host_Institution__r.Country__r.Name,Host_Institution_Course__r.Course_Code__c,
                                                 Host_Institution_Course__r.Course_Title_2__c,Last_Approved_Rejected_By__r.Name,Home_Institution_Course__r.Year_in_Degree_Plan__c
                                                 From Course_Equivalency__c Where Home_Institution_Course__r.Year_in_Degree_Plan__c =: '3 of 4'];
        model_courseEquivalency modCourEqu = new model_courseEquivalency(corEquList[0]);
        test.stopTest();
        System.assertEquals(modCourEqu.yearInDegreePlan, 'Junior');
    }
    
    @isTest
    public static void testmodel_courseEquivalency4of4(){
        test.startTest();
        List<Course_Equivalency__c> corEquList = [Select id,Name,CMP_of_Home_Course_Request__c,Host_Institution_Course__c,Home_Institution_Course__c,Denied_Reason__c,Denied_Reason_Other__c,
                                                 Status__c,Last_Approved_Rejected_By__c,Last_Approved_Rejected__c,Home_Institution_Course__r.Course_Code__c,Home_Institution_Course__r.Course_Title_2__c,
                                                 Host_Institution_Course__r.Host_Institution__r.Name,Host_Institution_Course__r.Host_Institution__r.Country__r.Name,Host_Institution_Course__r.Course_Code__c,
                                                 Host_Institution_Course__r.Course_Title_2__c,Last_Approved_Rejected_By__r.Name,Home_Institution_Course__r.Year_in_Degree_Plan__c
                                                 From Course_Equivalency__c Where Home_Institution_Course__r.Year_in_Degree_Plan__c =: '4 of 4'];
        model_courseEquivalency modCourEqu = new model_courseEquivalency(corEquList[0]);
        test.stopTest();
        System.assertEquals(modCourEqu.yearInDegreePlan, 'Senior');
    }
    
    @isTest
    public static void testgetModelsFromList(){
        test.startTest();
        List<Course_Equivalency__c> corEquList = [Select id,Name,CMP_of_Home_Course_Request__c,Host_Institution_Course__c,Home_Institution_Course__c,Denied_Reason__c,Denied_Reason_Other__c,
                                                 Status__c,Last_Approved_Rejected_By__c,Last_Approved_Rejected__c,Home_Institution_Course__r.Course_Code__c,Home_Institution_Course__r.Course_Title_2__c,
                                                 Host_Institution_Course__r.Host_Institution__r.Name,Host_Institution_Course__r.Host_Institution__r.Country__r.Name,Host_Institution_Course__r.Course_Code__c,
                                                 Host_Institution_Course__r.Course_Title_2__c,Last_Approved_Rejected_By__r.Name,Home_Institution_Course__r.Year_in_Degree_Plan__c,Home_Institution_Course__r.US_Terms__c
                                                 From Course_Equivalency__c Where Home_Institution_Course__r.Year_in_Degree_Plan__c =: '1 of 3'];
        List<model_courseEquivalency> modCorrEquList = model_courseEquivalency.getModelsFromList(corEquList);
        test.stopTest();
        System.assertEquals(modCorrEquList[0].yearInDegreePlan, 'Other');
    }
    
    @isTest
    public static void testmodel_courseEquivalencyequalsPositive(){
        test.startTest();
        model_courseEquivalency mce = new model_courseEquivalency();
        Boolean b = mce.equals(mce);
        test.stopTest();
        System.assert(b);
    }
    
    @isTest
    public static void testmodel_courseEquivalencyequalsNegative(){
        Contact_Support_Personnel__c csp = new Contact_Support_Personnel__c();
        test.startTest();
        model_courseEquivalency mce = new model_courseEquivalency();
        Boolean b = mce.equals(csp);
        test.stopTest();
        System.assert(!(b));
    }
}