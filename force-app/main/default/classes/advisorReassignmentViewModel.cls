/**
 * @description Viewmodel class used with <<advisorReassignmentController>>
 * @author Brock Barlow
 */
// ApexDoc updated 1/22/2021 Brock Barlow
public class advisorReassignmentViewModel 
{
    /**
     * Contact record of the leaving advisor
     */
    public Contact leavingAdvisor {get;set;}
    /**
     * Id of the advisor who is replacing the leaving advisor
     */
    public String newAdvisor {get;set;}
    /**
     * A List<SelectOption> of the advisors that remain at the home institituion
     */
    public List<SelectOption> homeInstitutionAdvisors {get;set;}
}