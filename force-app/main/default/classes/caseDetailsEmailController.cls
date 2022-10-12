/**
 * Controller for caseDetailsEmailComponent Visualforce component that is used in a VisaulForce email template. 
 * This controller get the students that are affected by a case so that the information is included to the case team
 * @author Brock Barlow
 */
// ApexDoc updated 1/27/2021 Brock Barlow
public with sharing class caseDetailsEmailController {
    /**
     * The Id of the case that has just been created / updated where an email is being sent.
     */
    public string caseId {get;set;}
    private Set<String> students;
    private Set<String> countries;
    private Set<String> programs;

    /**
     * Constructor, initializes the member set variables
     */
    public caseDetailsEmailController() {
        students = new Set<String>();
        countries = new Set<String>();
        programs = new Set<String>();

    }
    /**
     * Finds all of the students affected by the case and populates the students, programs and countries Set<String> variables and returns this.students
     */
    public Set<String> getStudents
    {
        get {
            for(Affected_Entity__c cs: [SELECT Id, Student__r.Name, Application__r.Program_Country__c, Application__r.Program_Term__c, Reason_Affected__c FROM Affected_Entity__c WHERE Case__c =: caseId AND RecordType.Name = 'Student' ORDER BY Reason_Affected__c, Student__r.Name])
            {
                students.add(cs.Student__r.Name);
                countries.add(cs.Application__r.Program_Country__c);
                programs.add(cs.Application__r.Program_Term__c);
            }
            return this.students;
        }
    }
    /**
     * Returns this.countries
     */
    public Set<String> getCountries
    {
        get{
            return this.countries;
        }
        
    }
    /**
     * Gets the programs that are related to the program term ids that are stored in this.programs and returns a Set<String> containing program names
     */
    public Set<String> getPrograms
    {
        get{
            Set<String> values = new Set<String>();
            for(Program_Term__c pt: [SELECT Id, Program__r.Name FROM Program_Term__c WHERE Id IN: this.programs ORDER BY Program__r.Name])
            {
                values.add(pt.Program__r.Name);
            }
            return values;
        }
    }    

}