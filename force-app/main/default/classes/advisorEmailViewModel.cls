/**
 * Model class used with sending advisor emails
 * @author Brock Barlow
 */
// ApexDoc updated 1/22/2021 Brock Barlow
public with sharing class advisorEmailViewModel {
    /**
     * The advisor's contact record id
     */
    public Id advisorId {get;set;}
    /**
     * The advisor's name
     */
    public String name {get;set;}
    /**
     * The advisor's email address
     */
    public String email {get;set;}
}