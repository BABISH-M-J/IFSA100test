/**
 * Unit tests for <<deleteFavoritesSchedulable>>
 * @author Jay Hold
 */
// ApexDoc updated 2/1/2021 Brock Barlow
@isTest
private class deleteFavoritesSchedulableTest {
    // Test Setup data
    public static testmethod void testScheduledJob() {
        // Create test contact
        Contact con = new Contact (
            RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Student').getRecordTypeId(),
            FirstName = 'Test',
            LastName = 'Contact'
        );
        insert con;
        // Create test course
        List<Course__c> courses = new List<Course__c>();
        for(Integer i=0; i < 200; i++) {
            courses.add(new Course__c (
                RecordTypeId = Schema.SObjectType.Course__c.getRecordTypeInfosByName().get('Host Institution').getRecordTypeId(),
                Name = 'Test Course' + i
            ));
        }
        insert courses;
        // Create favorite records, 100 old and 100 new
        List<Favorite__c> favs = new List<Favorite__c>();
        for(Course__c course: courses)
        {
            favs.add(new Favorite__c(
                Contact__c = con.Id,
                Course__c = course.Id
            ));
        }
        insert favs;
        //Get 100 of the new favorites and update CreatedDate to make them older than 4 years
        for(Integer i=0; i < 100; i++) {
            Favorite__c f = favs[i];
            Test.setCreatedDate(f.Id, DateTime.now().addYears(-4));
        }
        
        // Perform Test
        Test.startTest();

        // Verify the scheduled job has not run yet
        List<Favorite__c> verifyFavs = [SELECT Id FROM Favorite__c];                            
        System.assertEquals(200, verifyFavs.size());

        deleteFavoritesSchedulable.deleteOldFavs();

        Test.stopTest();

        // Now that the scheduled job has executed,
        // Verify only 100 remain
        List<Favorite__c> verifyFavsDeleted = [SELECT Id FROM Favorite__c];                            
        System.assertEquals(100, verifyFavsDeleted.size()); 
    }
    //added by PowerFluence req_dt:03/29/2022 ref email from Clayton starts
    private class deleteFavoritesSchedulableTest1 
    {
        deleteFavoritesSchedulable ct=new deleteFavoritesSchedulable();
        String sch = '20 30 8 10 2 ?';
        String jobID = system.schedule('Merge Job', sch, ct);

    }
//added by PowerFluence req_dt:03/29/2022 ref email from Clayton ends
}