/**
 * View model for the custom portal profile page.
 * TODO: Refactor guardians
 * THE CUSTOM PORTAL IS POWERD BY THE CATALOG STUDENT PORTAL SO THAT EFFORTS ARE NOT DUPLICATED AS OF SUMMER 2020
 * @author Cameron Ames
 */
// ApexDoc updated 1/28/2021 Brock Barlow
public without sharing class customProfileViewModel extends customBaseViewModel
{
	/**
	 * @description The student's middle name
	 */
	public String StudentMiddleName {get;set;}

	/**
	 * @description The student's birth date
	 */
	public Date StudentBirthdate {get;set;}

	/**
	 * @description The student's cell phone number
	 */
	public String StudentMobilePhone {get;set;}
	
	/**
	 * @description The student's email address
	 */
	public String StudentEmail {get;set;}
	
	/**
	 * @description The student's mailing address' country
	 */
	public String StudentMailingCountry {get;set;}
	
	/**
	 * @description The student's Country of citizenship
	 */
	public String StudentCitizenCountry {get;set;}

	/**
	 * @description The student's sex
	 */
	public String StudentSex {get;set;}
	
	/**
	 * @description The student's citizenship
	 */
	public String StudentCitizenship {get;set;}
	
	/**
	 * @description If the student has attached a photo, this is the id.
	 */
	public String StudentPhotoId {get;set;}
	
	/**
	 * @description If the student is currently attaching a photo, this is where it is attached
	 */
	public Attachment photo {get;set;}
	
	/**
	 * @description The list of options for a student's us citizenship.
	 */
	public List<SelectOption> citizenshipOptions {get;set;}
	
	/**
	 * @description The list of options for a student's country.
	 */
	public List<SelectOption> countryOptions {get;set;}

	/**
	 * @description The list of options for a student's sex.
	 */
	public List<SelectOption> sexOptions {get;set;}

	/**
	 * @description A student's parents first name.
	 */
	public String GuardianFirstName {get;set;}

	/**
	 * @description A student's parents last name.
	 */
	public String GuardianLastName {get;set;}

	/**
	 * @description A student's parents email address.
	 */
	public String GuardianEmail {get;set;}

	/**
	 * @description A student's parents phone number.
	 */
	public String GuardianPhone {get;set;}
}