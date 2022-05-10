/**
 * Viewmodel for financial aid form in student portal, is not actively used
 * @author Brock Barlow
 */
// ApexDoc updated 2/4/2021 Brock Barlow
public with sharing class FinancialAidItemViewModel {
    /**
     * The type of financial aid
     */
    public String aidType {get; set;}
    /**
     * The amount of finacial aid
     */
    public Double disbursmentAmount {get; set;}
    /**
     * The date/time of disbursment
     */
    public DateTime disbursmentDate {get; set;}
}