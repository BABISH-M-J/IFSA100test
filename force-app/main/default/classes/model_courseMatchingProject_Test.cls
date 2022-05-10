@isTest
public class model_courseMatchingProject_Test {
	@testSetup
    public static void mockData(){
        //Cretae World Test Record
        World__c world = new World__c(Name = 'Global');
		database.insert(world);

        //Cretae Region Test Record
		Region__c reg = new Region__c(Name = 'Local Support', World__c = world.Id);
        database.insert(reg);
        
        //Cretae Country Test Record
        Country__c cou = apexMockDataUtility.createCountry(reg.id);
        
        //Cretae Host Institute Test Record
        Host_Institution__c hostIns = apexMockDataUtility.createHostInstitution(cou.id);
        
        //Create Home Institution Test Record
        Home_Institution__c homeIns = apexMockDataUtility.createHomeInstitution('Test', cou.id);
        
        //Create Butler Department Cose Test Record
        Butler_Department_Code__c buCode = apexMockDataUtility.createBUDepartmentCode();
        
        //Cretae Program Test Record
        Program__c prog = apexMockDataUtility.createProgram(hostIns, 'Test Program');
        
        //Create test account
        Account acct = apexMockDataUtility.createAccount('TestAcct',homeIns.id);
        
        //Create test contact
        Contact ctc = apexMockDataUtility.createContact('TestCtc', acct.Id);
        
        //Create test user
        User u= apexMockDataUtility.createUser(ctc.id);
        insert u;
        
        //Create Host Course record
        Course__c hostcour = apexMockDataUtility.createHostCourse(hostIns.id,buCode);
        
        //Create Home Course record
        List<Course__c> Homecour = new List<Course__c>();
        for(integer i =0 ; i<5 ;i++){
            Course__c currHomeCurr = new Course__c();
            currHomeCurr.RecordTypeId = Schema.SObjectType.Course__c.getRecordTypeInfosByName().get('Home Institution').getRecordTypeId();
            currHomeCurr.Name = 'Test Course' + i;
            currHomeCurr.Course_Code__c = 'ASDF';
            currHomeCurr.Course_Title_2__c = 'Title'+ i;
            currHomeCurr.Host_Institution__c = hostIns.id;
            currHomeCurr.Home_Institution_Account__c = acct.id;
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
        List<CMP__c> cmpList = new List<CMP__c>();
        CMP__c newCMP1 = new CMP__c(Status__c = 'Submitted',
                                   Custom_Message_Text__c = 'Test Text',
                                   Regions__c = 'Latin America & Caribbean;Europe',
                                   Terms_Abroad__c = 'Spring;Summer',
                                   Years_Abroad__c = 'Test1;Test2',
                                   Contact__c = ctc.id,
                                   Home_Institution_Account__c = acct.id);
		cmpList.add(newCMP1);       
        CMP__c newCMP2 = new CMP__c(Status__c = 'Submitted',
                                   RecordTypeId = Schema.SObjectType.CMP__c.getRecordTypeInfosByName().get('Curriculum Integration').getRecordTypeId(),
                                   Custom_Message_Text__c = 'Test Text',
                                   Regions__c = 'Latin America & Caribbean;Europe',
                                   Terms_Abroad__c = 'Spring;Summer',
                                   Years_Abroad__c = 'Test1;Test2',
                                   Contact__c = ctc.id,
                                   Home_Institution_Account__c = acct.id);
        cmpList.add(newCMP2);
        Database.insert(cmpList);
        
        //Cretare CMP Country test record
        List<CMP_Country__c> cmpCouList = new List< CMP_Country__c>();
        CMP_Country__c cmpCou1 = new CMP_Country__c();
        cmpCou1.Course_Matching_Project__c = newCMP1.id;
        cmpCou1.Country__c = cou.id;
        cmpCouList.add(cmpCou1);
        CMP_Country__c cmpCou2 = new CMP_Country__c();
        cmpCou2.Course_Matching_Project__c = newCMP2.id;
        cmpCou2.Country__c = cou.id;
        cmpCouList.add(cmpCou2);
        database.insert(cmpCouList);
        
        //Create CMP Program Test Record
        List<CMP_Program__c> cmpProgList = new List< CMP_Program__c>();
        CMP_Program__c cmpProg1 = new CMP_Program__c();
        cmpProg1.Course_Matching_Project__c = newCMP1.id;
        cmpProg1.Program__c = prog.id;
        cmpProgList.add(cmpProg1);
        CMP_Program__c cmpProg2 = new CMP_Program__c();
        cmpProg2.Course_Matching_Project__c = newCMP2.id;
        cmpProg2.Program__c = prog.id;
        cmpProgList.add(cmpProg2);
        database.insert(cmpProgList);
        
        //Create Course Equivalency Test Record
        List<Course_Equivalency__c> courEquiList = new List<Course_Equivalency__c>();
        for(integer i=0; i<5;i++){
            Course_Equivalency__c courEqui = new Course_Equivalency__c();
            courEqui.CMP_of_Home_Course_Request__c = newCMP1.id;
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
        
        //Create CMP Course Equivalency Test Record
        List<CMP_Course_Equivalency__c> cmpCouEqList = new List<CMP_Course_Equivalency__c>();
        CMP_Course_Equivalency__c cmpCouEq1 = new CMP_Course_Equivalency__c();
        cmpCouEq1.Course_Matching_Project__c = newCMP1.id;
        cmpCouEq1.Course_Equivalency__c = courEquiList[0].id;
        cmpCouEqList.add(cmpCouEq1);
        CMP_Course_Equivalency__c cmpCouEq2 = new CMP_Course_Equivalency__c();
        cmpCouEq2.Course_Matching_Project__c = newCMP2.id;
        cmpCouEq2.Course_Equivalency__c = courEquiList[1].id;
        cmpCouEqList.add(cmpCouEq2);
        database.insert(cmpCouEqList);
    }
    
    @isTest
    public static void testmodelcourseMatchingProjectCMP(){
        test.startTest();
        List<CMP__c> cmp = [Select id,Academic_Advisor_Email__c,Additional_Details__c,Additional_Information__c,Completed_Date__c,Last_Viewed_Date__c,Contact__c,Degree_Requirements__c,
                           Faculty_Names__c,Home_Institution_Account__c,Home_Institution_Account__r.Name,Include_Directed_Research__c,Include_Internship_Options__c,Include_Non_Approved_Programs__c,
                           Major__c,Regions__c,Status__c,CreatedDate,Summary_of_Results__c,Terms_Abroad__c,Year_in_School__c,Years_Abroad__c,RecordType.Name,Title__c
                           From CMP__c];
        model_courseMatchingProject mcmp = new model_courseMatchingProject(cmp[0]);
        test.stopTest();
        System.assertEquals(mcmp.additionalDetails, cmp[0].Additional_Details__c);
        System.assertEquals(mcmp.facultyNames, cmp[0].Faculty_Names__c);
    } 
    
    @isTest
    public static void testconvertToCMPfalse(){
        test.startTest();
        List<CMP__c> cmp = [Select id,(Select id, Country__c, Country__r.Name, Name From CMP_Countries__r),(Select id, Program__c,Program__r.Name, Name From CMP_Programs__r),Academic_Advisor_Email__c,Additional_Details__c,Additional_Information__c,Completed_Date__c,Last_Viewed_Date__c,Contact__c,Degree_Requirements__c,
                           Faculty_Names__c,Home_Institution_Account__c,Home_Institution_Account__r.Name,Include_Directed_Research__c,Include_Internship_Options__c,Include_Non_Approved_Programs__c,
                           Major__c,Regions__c,Status__c,CreatedDate,Summary_of_Results__c,Terms_Abroad__c,Year_in_School__c,Years_Abroad__c,RecordType.Name,Title__c
                           From CMP__c Where recordtype.Name = 'Course Equivalency'];
        model_courseMatchingProject mcmp = new model_courseMatchingProject(cmp[0]);   
        mcmp.convertToCMP(false);
        test.stopTest();
        System.assertEquals(mcmp.additionalDetails, cmp[0].Additional_Details__c);
        System.assertEquals(mcmp.facultyNames, cmp[0].Faculty_Names__c);
    }
    
    @isTest
    public static void testconvertToCMPtrue(){
        test.startTest();
        List<CMP__c> cmp = [Select id,(Select id, Country__c, Country__r.Name, Name From CMP_Countries__r),(Select id, Program__c,Program__r.Name, Name From CMP_Programs__r),Academic_Advisor_Email__c,Additional_Details__c,Additional_Information__c,Completed_Date__c,Last_Viewed_Date__c,Contact__c,Degree_Requirements__c,
                           Faculty_Names__c,Home_Institution_Account__c,Home_Institution_Account__r.Name,Include_Directed_Research__c,Include_Internship_Options__c,Include_Non_Approved_Programs__c,
                           Major__c,Regions__c,Status__c,CreatedDate,Summary_of_Results__c,Terms_Abroad__c,Year_in_School__c,Years_Abroad__c,RecordType.Name,Title__c
                           From CMP__c Where recordtype.Name = 'Curriculum Integration'];
        List<Course__c> currCou = [Select id,Course_Title_2__c ,Course_Code__c From Course__c Where Course_Code__c =: 'ASDF'];
        model_courseMatchingProject mcmp = new model_courseMatchingProject(cmp[0]);
        List<model_course> modcouList = new List<model_course>();
        for(Course__c currec : currCou){
            model_course mod = new model_course();
            mod.courseTitle = currec.Course_Title_2__c;
            mod.courseCode = currec.Course_Code__c;
            modcouList.add(mod);
        }
		mcmp.homeClasses = modcouList; 
        mcmp.convertToCMP(true);
        test.stopTest();
        System.assertEquals(mcmp.additionalDetails, cmp[0].Additional_Details__c);
        System.assertEquals(mcmp.facultyNames, cmp[0].Faculty_Names__c);
    }
    
    @isTest
    public static void testmodel_courseMatchingProject(){
        test.startTest();
        List<CMP__c> cmp = [Select id,(SELECT Id, Course_Equivalency__c FROM CMP_Course_Equivalencies__r),(Select id, Country__c, Country__r.Name, Name From CMP_Countries__r),(Select id, Program__c,Program__r.Name, Name From CMP_Programs__r),Academic_Advisor_Email__c,Additional_Details__c,Additional_Information__c,Completed_Date__c,Last_Viewed_Date__c,Contact__c,Degree_Requirements__c,
                           Faculty_Names__c,Home_Institution_Account__c,Home_Institution_Account__r.Name,Include_Directed_Research__c,Include_Internship_Options__c,Include_Non_Approved_Programs__c,
                           Major__c,Regions__c,Status__c,CreatedDate,Summary_of_Results__c,Terms_Abroad__c,Year_in_School__c,Years_Abroad__c,RecordType.Name,Title__c
                           From CMP__c Where recordtype.Name = 'Curriculum Integration'];
        model_courseMatchingProject mcmp = new model_courseMatchingProject(cmp[0].id);
        mcmp.convertToCMP(true);
        test.stopTest();
        System.assertEquals(mcmp.additionalDetails, cmp[0].Additional_Details__c);
        System.assertEquals(mcmp.facultyNames, cmp[0].Faculty_Names__c);
    }
    
    @isTest
    public static void testequalstrue(){
        test.startTest();
        model_courseMatchingProject mcmp = new model_courseMatchingProject();
        boolean check = mcmp.equals(mcmp);
        test.stopTest();
        System.assert(check);
    }
    
    @isTest
    public static void testequalsfalse(){
        test.startTest();
        Case cs = new Case();
        model_courseMatchingProject mcmp = new model_courseMatchingProject();
        boolean check = mcmp.equals(cs);
        test.stopTest();
        System.assert(!check);
    }
    
    @isTest
    public static void testgetJSONSerializedModel(){
        test.startTest();
        List<CMP__c> cmp = [Select id,(Select id, Country__c, Country__r.Name, Name From CMP_Countries__r),(Select id, Program__c,Program__r.Name, Name From CMP_Programs__r),Academic_Advisor_Email__c,Additional_Details__c,Additional_Information__c,Completed_Date__c,Last_Viewed_Date__c,Contact__c,Degree_Requirements__c,
                           Faculty_Names__c,Home_Institution_Account__c,Home_Institution_Account__r.Name,Include_Directed_Research__c,Include_Internship_Options__c,Include_Non_Approved_Programs__c,
                           Major__c,Regions__c,Status__c,CreatedDate,Summary_of_Results__c,Terms_Abroad__c,Year_in_School__c,Years_Abroad__c,RecordType.Name,Title__c
                           From CMP__c Where recordtype.Name = 'Curriculum Integration'];
        model_courseMatchingProject mcmp = new model_courseMatchingProject(cmp[0].id);
        String jsonString = mcmp.getJSONSerializedModel();
        test.stopTest();
        System.assert(String.isNotBlank(jsonString));
    }
}