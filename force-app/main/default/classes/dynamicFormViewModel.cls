/**
 * Viewmodel class for dynamic forms for the student portal
 * @author Brock Barlow
 */
// ApexDoc updated 2/1/2021 Brock Barlow
public with sharing class dynamicFormViewModel {
    /**
     * A Dynamic_Form__c record
     */
    public Dynamic_Form__c form { get; set; }
    /**
     * The application item record that the form is related to
     */
    public Id applicationItemId  { get; set; }
    /**
     * An instance of <<formBuilderComponentController>>.Form this is the same data model used with Form Builder LWC
     */
    public formBuilderComponentController.Form formData {get; set;}
    /**
     * Basic constructor
     */
    public dynamicFormViewModel() {

    }
    /**
     * Constructor, gets data about a form from an Application_Item__c
     * @param record An Application_Item__c record
     */
    public dynamicFormViewModel(Application_Item__c record) {
        Application_Item__c appItem = record;
        Application__c app = (Application__c) apexQueryUtility.selectAllFrom('Application__c', 'Id = \'' + appItem.Application__c + '\'').get(0);
        Contact student = (Contact) apexQueryUtility.selectAllFrom('Contact', 'Id = \'' + app.Applicant__c + '\'').get(0);
        // form = (Dynamic_Form__c) apexQueryUtility.selectAllFrom('Dynamic_Form__c', 'Id = \'' + appItem.Application_Requirement__r.Dynamic_Form__c + '\'').get(0);
        applicationItemId = appItem.Id;
        
        formData = formBuilderComponentController.initForm(appItem.Application_Requirement__r.Dynamic_Form__c, null);
        
        for(formBuilderComponentController.Item formItem: formData.items)
        {
            if(formItem.fieldType != 'No Response Required')
            {
                switch on formItem.desObj {
                    when 'Application_Item__c' {
                        formItem.response = (String) dynamicFormService.convertResponse(formItem, appItem.get(formItem.desField));
                    }
                    when 'Application__c' {
                        formItem.response = (String) dynamicFormService.convertResponse(formItem, app.get(formItem.desField));
                    }
                    when 'Contact' {
                        formItem.response = (String) dynamicFormService.convertResponse(formItem, student.get(formItem.desField));
                    }
                }  
            }
        }
    }
    
    /**
     * Saves data from a dynamic form to the proper records and fields
     */
    public boolean save()
    {
        Application_Item__c appItem = (Application_Item__c) apexQueryUtility.selectAllFrom('Application_Item__c', 'Id = \'' + applicationItemId + '\'').get(0);
        Application__c app = (Application__c) apexQueryUtility.selectAllFrom('Application__c', 'Id = \'' + appItem.Application__c + '\'').get(0);
        Contact student = (Contact) apexQueryUtility.selectAllFrom('Contact', 'Id = \'' + app.Applicant__c + '\'').get(0);

        Boolean saveContact = false;
        Boolean saveAppItem = false;
        Boolean saveApp = false;
        System.debug(form);
        for(formBuilderComponentController.Item formItem: formData.items)
        {
            if(formItem.fieldType != 'No_Response_Required' && formItem.fieldType != 'Signature')
            {
                try {
                    switch on formItem.desObj {
                        when 'Application_Item__c' {
                            appItem.put(formItem.desField, dynamicFormService.convertResponse(formItem));
                            saveAppItem = true;
                        }
                        when 'Application__c' {
                            app.put(formItem.desField, dynamicFormService.convertResponse(formItem));
                            saveApp = true;
                        }
                        when 'Contact' {
                            student.put(formItem.desField, dynamicFormService.convertResponse(formItem));
                            saveContact = true;
                        }
                        when null {
                            // Do Nothing
                        }
                        when else {
                            throw new formSaveException();
                        }
                    }  
                } catch (SObjectException ex) {
                    System.debug('Tried to write to a locked field');
                }
                
            }
        }
        
        List<SObject> objectsToUpdate = new List<SObject>();
        if(saveApp)
        {
            objectsToUpdate.add(app);
        }
        if(saveAppItem)
        {
            objectsToUpdate.add(appItem);
        }
        if(saveContact)
        {
            objectsToUpdate.add(student);
        }
        
        if(!objectsToUpdate.isEmpty())
        {
            try {
                database.update(objectsToUpdate);
            } catch (Exception e) {
                System.debug(e.getMessage());
                return false;
            }            
            return true;
        }
        if(objectsToUpdate.isEmpty() && form.RecordTypeId == Schema.SObjectType.Dynamic_Form__c.getRecordTypeInfosByName().get('CIF').getRecordTypeId())
        {
            return true;
        }
        return false;
    }

    /**
     * Exception class for dynamicFormViewModel.save
     */
    public class formSaveException extends Exception
    {

    }

}