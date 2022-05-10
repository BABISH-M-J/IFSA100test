/**
 * Controller user for courseTag Visualforce page
 * @author Audrey Carson
 */
// ApexDoc updated 1/28/2021 Brock Barlow
public with sharing class courseTagController 
{
    public Course__c currentCourse;
    /**
     * List of Department tags
     */
    public List<String> departmentTags {get; set;}
    /**
     * List of Area of Study tags
     */
    public List<String> areaOfStudyTags{get; set;}
    /**
     * List of Course_Tag_Matrix__c records
     */
    public List<Course_Tag_Matrix__c> tagMatrix;
    /**
     * List of Tag__c records to be inserted
     */
    public List<Tag__c> newTags {get;set;}
    Tag__c tag = new Tag__c();

    /**
     * Constructor, initializes Visualforce page
     * @param stdController ApexPages.StandardController
     */
    public courseTagController(ApexPages.StandardController stdController) 
    {
        //set course for the page
        currentCourse = (Course__c) stdController.getRecord();

        Set<String> departmentSet = new Set<String>();
        Set<String> areaOfStudySet = new Set<String>();
        //Retrieve the Course Tag Matrix
        this.tagMatrix = [SELECT Id, Department__c, Primary_Area_Of_Study__c, Secondary_Area_Of_Study__c FROM Course_Tag_Matrix__c];

        newTags = new list<Tag__c>();
        newTags.add(tag);

        //Retrieve all the current tags related to currentCourse
        for(Tag__c t : [SELECT Id, Name, Department__c, Area_Of_Study__c FROM Tag__c WHERE Course__c =: currentCourse.Id])
        {
            //add to relevant set to display
            departmentSet.add(t.Department__c);
            areaOfStudySet.add(t.Area_Of_Study__c);
        }

        this.departmentTags = new List<String>(departmentSet);
        this.areaOfStudyTags = new List<String>(areaOfStudySet);

    }
    /**
     * Saves the new tag records related to the course
     * @return PageReference reloads the page
     */
    public PageReference saveTags()
    {
        Set<Tag__c> insertTags = new Set<Tag__c>();

        for(Tag__c t : newTags)
        {
            if(t.Department__c != null || t.Area_of_Study__c != null)
            {
                if(!areaOfStudyTags.contains(t.Area_of_Study__c))
                {
                    //Put in Tag
                    t.Course__c = currentCourse.Id;
                    insertTags.add(t);
                    //look through tag matrix to put in extra tags
                    for(Course_Tag_Matrix__c ctm : tagMatrix)
                    {
                        if(t.Area_of_Study__c != null && ctm.Secondary_Area_of_Study__c == t.Area_of_Study__c && (!areaOfStudyTags.contains(ctm.Primary_Area_of_Study__c))){
                            Tag__c relatedTag = new Tag__c();
                            relatedTag.Department__c = ctm.Department__c;
                            relatedTag.Area_of_Study__c = ctm.Primary_Area_of_Study__c;
                            relatedTag.Course__c = currentCourse.Id;
                            insertTags.add(relatedTag);

                            Tag__c relatedTag2 = new Tag__c();
                            relatedTag2.Department__c = ctm.Department__c;
                            relatedTag2.Area_of_Study__c = ctm.Primary_Area_of_Study__c;
                            relatedTag2.Course__c = currentCourse.Id;
                            insertTags.add(relatedTag2);
                        }
                        if(t.Area_of_Study__c != null && ctm.Primary_Area_of_Study__c == t.Area_of_Study__c && (!departmentTags.contains(ctm.Department__c)))
                        {
                            Tag__c relatedTag = new Tag__c();
                            relatedTag.Department__c = ctm.Department__c;
                            relatedTag.Course__c = currentCourse.Id;
                            relatedTag.Area_of_Study__c = t.Area_of_Study__c;
                            insertTags.add(relatedTag);
                        }
                    }

                }
            }
        }

        if(!insertTags.isEmpty())
        {
            System.debug(new List<Tag__c>(insertTags));
            insert new List<Tag__c>(insertTags);
        }
        
        PageReference pageRef = ApexPages.currentPage();
        pageRef.setRedirect(true);
        return pageRef;
    }

}