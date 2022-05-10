/**
 * Very basic viewModel for Application - FUTURE replace with model_application
 * @author Brock Barlow
 */
// ApexDoc updated 1/25/2021 Brock Barlow
public with sharing class ApplicationViewModel {
    /**
     * The application record's id
     */
    public String id {get;set;}
    /** 
     * The application record's name
     */
    public String name {get;set;}
}