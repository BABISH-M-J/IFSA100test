/**
 * Viewmodel for resources in custom portal
 * THE CUSTOM PORTAL IS POWERD BY THE CATALOG STUDENT PORTAL SO THAT EFFORTS ARE NOT DUPLICATED AS OF SUMMER 2020
 * @author Brock Barlow
 */
// ApexDoc updated 1/28/2021 Brock Barlow
public without sharing class customResourcesViewModel extends customBaseViewModel
{
	public List<Attachment> attachments {get;set;}
	public String customResourceInstructions {get;set;}
}