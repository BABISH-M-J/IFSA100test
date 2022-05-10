/**
 * Service clas to be used by <<cmpTriggerHandler>>
 * @author Matt Eck
 */
// ApexDoc updated 1/28/2021 Brock Barlow
public with sharing class cmpService 
{
    /**
     * Checks Custom_Message_Text__c for images
     * @param newRecords
     */
    public static void checkForImagesInEmail(List<CMP__c> newRecords){
        for(CMP__c cmp : newRecords){
            if(cmp.Custom_Message_Text__c != null && cmp.Custom_Message_Text__c.contains('<img src=')){
                cmp.Custom_Message_Text__c.addError('Custom Messages cannot contain Images.');
            }
        }
    }
    /**
     * Sends CMP completed email when a CMP has been marked complete. Email is sent to the requester, and if the requester is a student
     * emails are sent to their home institution study abroad office
     * @param oldMap
     * @param newMap
     */
    public static void sendCMPCompleteEmail(Map<Id, CMP__c> oldMap, Map<Id, CMP__c> newMap){

        Map<CMP__c, Id> cmpToContact = new Map<CMP__c, Id>();
        Map<Id, Id> homeInstitutionToCon = new Map<Id, Id>();
        Map<Id, Map<String, String>> spToCon = new Map<Id, Map<String, String>>();

        Set<Id> conIds = new Set<Id>();
        List<Contact> relatedContacts = new List<Contact>();
        List<Support_Personnel__c> neededSPs = new List<Support_Personnel__c>();
        Id ceRecordType = Schema.SObjectType.CMP__c.getRecordTypeInfosByName().get('Course Equivalency').getRecordTypeId();
        Id ciRecordType = Schema.SObjectType.CMP__c.getRecordTypeInfosByName().get('Curriculum Integration').getRecordTypeId();
        Id chartCommunityId = [SELECT Id FROM Network WHERE Name = 'CHART'].Id;
        String chartURL = Network.getLoginUrl(chartCommunityId).removeEnd('/CH_Login');

        // Gather Contact ID Set, and map Con ID to CMP
        for(CMP__c cmp : newMap.values()){
            conIds.add(cmp.Contact__c);
            cmpToContact.put(cmp, cmp.Contact__c);
        }

        // Query Contacts
        relatedContacts = [SELECT Id, 
                           Email, 
                           Home_Institution__c,
                           Active_Application__r.Program_Term__r.Program__c,
                           Home_institution__r.Field_Director__r.Email,
                           (SELECT Id FROM Support_Personnel__r) 
                           FROM Contact 
                           WHERE Id IN :conIds];

        // Map Con ID to the Home Institution associated with them
        for(Contact c : relatedContacts){
            homeInstitutionToCon.put(c.Home_Institution__c, c.Id);
        }

        // Query Support Personnel related to Home Institutions sorted above.
        neededSPs = [SELECT Id, 
                    IFSA_Staff__r.Email, 
                    Non_IFSA_Staff__r.Email,
                    Home_Institution__c,
                    Program__c
                    FROM Support_Personnel__c
                    WHERE Support_Role_Type__c = 'Advisor' 
                    AND Home_institution__c IN :homeInstitutionToCon.keySet()];

        // Loop Through SP Records, 
        // Map Set of SP Emails to Contact records related to the Home Institutions in homeInstitutionToCon mappings
        for(Support_Personnel__c sp : neededSPs){
            //For SPs related to Home institutions
            if(sp.Home_Institution__c != null){
                // If Con ID already exists in spToCon mapping
                if(spToCon.containsKey(homeInstitutionToCon.get(sp.Home_Institution__c)))
                {
                    Map<String, String> tempSet = spToCon.get(homeInstitutionToCon.get(sp.Home_Institution__c));
                    if(sp.IFSA_Staff__r.Email != null){
                        tempSet.put(sp.IFSA_Staff__r.Email, 'Home Institution');
                    }
                    else if(sp.Non_IFSA_Staff__r.Email != null){
                        tempSet.put(sp.Non_IFSA_Staff__r.Email, 'Home Institution');
                    }
                    
                    spToCon.put(homeInstitutionToCon.get(sp.Home_Institution__c), tempSet);
                }
                // If Con ID does NOT exists in spToCon mapping
                else{
                    if(sp.IFSA_Staff__r.Email != null){
                        spToCon.put(homeInstitutionToCon.get(sp.Home_Institution__c), new Map<String, String>{sp.IFSA_Staff__r.Email => 'Home Institution'});
                    }
                    else if(sp.Non_IFSA_Staff__r.Email != null){
                        spToCon.put(homeInstitutionToCon.get(sp.Home_Institution__c), new Map<String, String>{sp.Non_IFSA_Staff__r.Email => 'Home Institution'});
                    }
                }
            }
        }

        // Additional Query of CMP to gather subfields needed for email message
        List<CMP__c> cmpAddInfo = [SELECT Id, 
                                       Contact__r.Home_Institution__r.Field_Director__r.Email,
                                       Contact__r.Active_Application__r.Program_Term__r.Owner.Email, 
                                       Contact__r.FirstName, 
                                       Contact__r.LastName,
                                       LastModifiedBy.Name,
                                       LastModifiedBy.Email 
                                       FROM CMP__c 
                                       WHERE Id IN :newMap.KeySet()];

        Map<Id, CMP__c> cmpAddInfoMap = new Map<Id, CMP__c>(cmpAddInfo);
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        // Loop through CMPs to generate emails
        for(CMP__c cmp : newMap.values()){
            // Only CMPs with a status of Completed that was not previouslt Completed will generate emails
            if(cmp.Status__c != oldMap.get(cmp.Id).Status__c && cmp.Status__c == 'Completed'){
                //Different email body, and recipients will be sent depending on record type
                if(cmp.RecordTypeId == ceRecordType){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setReplyTo(cmpAddInfoMap.get(cmp.Id).LastModifiedBy.Email);
                    mail.setSenderDisplayName(cmpAddInfoMap.get(cmp.Id).LastModifiedBy.Name);
                    mail.setSubject('Your IFSA study abroad class equivalency report is ready for download!');

                    String messageBody = '<p>Thank you for filling out the IFSA class equivalency request form, so we can help address your specific academic needs as you are planning to study abroad.  Your custom report has been completed by IFSA staff! <a href="'+chartURL+'?projectId='+cmp.Id+'">You can view it by clicking here</a>.</p>';
                    messageBody += '<p>In the report, IFSA has provided a list of potential matches abroad to your home institution curriculum specified in your request. Your next step is to verify with your study abroad or academic advisors at your home institution whether or not the potential equivalents are approved. You may find it helpful to download or print this report. You can also download pdfs of the individual class records to share with your home institution advisors.</p>';
                    messageBody += '<p>Please let me/your IFSA program advisor know if you have any further questions. We look forward to supporting your study abroad endeavor with IFSA in the near future!</p>';
                    // Only add custom message text if it exists on CMP
                    if(cmp.Custom_Message_Text__c != null){
                        messageBody += cmp.Custom_Message_Text__c;
                    }
                    messageBody += '<p>Best regards,</p><p>' + cmpAddInfoMap.get(cmp.Id).LastModifiedBy.Name + '</p>';
                    
                    mail.setHtmlBody(messageBody);
                    mail.setTargetObjectId(cmp.Contact__c);
                    mail.setSaveAsActivity(true);

                    // emailRecievers will always include contact on CMP
                    // Check for Field Director, as well as if there are any emails attributed to the COn ID in spTo Con Mapping
                    List<String> emailRecievers = new List<String>();
                    emailRecievers.add(cmp.Contact_Email__c);
                    if(cmpAddInfoMap.get(cmp.Id).Contact__r.Home_Institution__r.Field_Director__r.Email != null){
                        emailRecievers.add(cmpAddInfoMap.get(cmp.Id).Contact__r.Home_Institution__r.Field_Director__r.Email);
                    }
                    if(cmpAddInfoMap.get(cmp.Id).Contact__r.Active_Application__r.Program_Term__r.Owner.Email != null){
                        emailRecievers.add(cmpAddInfoMap.get(cmp.Id).Contact__r.Active_Application__r.Program_Term__r.Owner.Email);
                    }
                    if(cmp.Academic_Advisor_Email__c != null){
                        emailRecievers.add(cmp.Academic_Advisor_Email__c);
                    }
                    if(spToCon.containsKey(cmp.contact__c))
                    {
                        emailRecievers.addAll(spToCon.get(cmp.Contact__c).KeySet());
                    }

                    mail.setToAddresses(emailRecievers);

                    emails.add(mail);
                }
                else if(cmp.RecordTypeId == ciRecordType){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setReplyTo(cmpAddInfoMap.get(cmp.Id).LastModifiedBy.Email);
                    mail.setSenderDisplayName(cmpAddInfoMap.get(cmp.Id).LastModifiedBy.Name);
                    mail.setSubject('Your IFSA curriculum integration report is ready for download!');

                    String messageBody = '<p>Thank you for requesting a curriculum integration matching project from IFSA, so we can help identify the best academic fit on our programs which meet your specific institutional needs.  Your custom report has been completed by IFSA staff! <a href="'+chartURL+'?projectId='+cmp.Id+'">You can view it by clicking here</a>.</p>';
                    messageBody += '<p>In the report, IFSA has provided a list of potential matches abroad to your home institution curriculum specified in your request. For the IFSA programs that you already approve, students at your institution who use our CHART system will now see these classes as potential matches. We very much welcome your feedback! You will see in the report that you have the ability to confirm, deny, edit or add additional matches to a single class offered abroad. In the case of a denial, you even have the option to provide the reason why the class has been denied. This gives us the opportunity to more deeply understand your requirements in our efforts to find suitable potential equivalents.</p>';
                    messageBody += '<p>In about 60 days, we will send a brief survey so that we can learn about the outcomes of this project and how it has impacted your work. Please let me or your IFSA field director know if you have any further questions.</p>';
                    // Only add custom message text if it exists on CMP
                    if(cmp.Custom_Message_Text__c != null){
                        messageBody += cmp.Custom_Message_Text__c;
                    }
                    messageBody += '<p>Best regards,</p><p>' + cmpAddInfoMap.get(cmp.Id).LastModifiedBy.Name + '</p>';
                    
                    mail.setHtmlBody(messageBody);
                    mail.setTargetObjectId(cmp.Contact__c);
                    mail.setSaveAsActivity(true);

                    // Check for Field Director, as well as if there are any emails attributed to the COn ID in spTo Con Mapping
                    List<String> emailRecievers = new List<String>();
                    if(cmpAddInfoMap.get(cmp.Id).Contact__r.Home_Institution__r.Field_Director__r.Email != null){
                        emailRecievers.add(cmpAddInfoMap.get(cmp.Id).Contact__r.Home_Institution__r.Field_Director__r.Email);
                    }

                    //Not Sending CI emails to Program Advisors
                    if(spToCon.containsKey(cmp.contact__c))
                    {
                        Map<String, String> emailMap = spToCon.get(cmp.Contact__c);
                        for(String email : emailMap.keySet())
                        {
                            if(emailMap.get(email) == 'Home Institution'){
                                emailRecievers.add(email);
                            }
                        }
                    }

                    mail.setToAddresses(emailRecievers);
                    if(!emailRecievers.isEmpty())
                    {
                        emails.add(mail);
                    }
                }
            }
        }

        //If there are emails to send, send them
        if(!emails.isEmpty()){
            Messaging.sendEmail(emails);
        }
    }
    /**
     * Sets the completed date of newly completed CMP__c records
     * @param oldMap
     * @param newMap
     */
    public static void setCompletedDate(Map<Id, CMP__c> oldMap, Map<Id, CMP__c> newMap)
    {
        for(Id recordId: newMap.keySet())
        {
            CMP__c oldRecord = oldMap.get(recordId);
            CMP__c newRecord = newMap.get(recordId);

            if(newRecord.Status__c == 'Completed' && oldRecord.Status__c != newRecord.Status__c)
            {
                newRecord.Completed_Date__c = Datetime.now();
            }
        }
    }
    /**
     * Programattically sets new Title__c on CMP__c. CI projects from institutions use Curriculum Integration for <Major> at <Institution Name>
     * CE projects from students use Class Equivalency <number> for <Student Name>
     * @param newRecords
     */
    public static void setRecordName(List<CMP__c> newRecords)
    {
        Id ceRT = Schema.SObjectType.CMP__c.getRecordTypeInfosByName().get('Course Equivalency').getRecordTypeId();
        Id ciRT = Schema.SObjectType.CMP__c.getRecordTypeInfosByName().get('Curriculum Integration').getRecordTypeId();
        List<Id> accountIds = new List<Id>();
        List<Id> contactIds = new List<Id>();
        for(CMP__c cmp: newRecords)
        {
            if(cmp.RecordTypeId == ceRT)
            {
                contactIds.add(cmp.Contact__c);    
            }
            accountIds.add(cmp.Home_Institution_Account__c);
        }
        Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id IN: accountIds]);
        Map<Id, Contact> contacts = new Map<Id,Contact>([SELECT Id, Name, (SELECT Id, Title__c FROM Course_Matching_Projects__r ORDER BY CreatedDate DESC LIMIT 1) FROM Contact WHERE Id IN: contactIds]);
        for(CMP__c cmp: newRecords)
        {
            Account a = accounts.get(cmp.Home_Institution_Account__c);
            if(cmp.RecordTypeId == ceRT)
            {
                Contact c = contacts.get(cmp.Contact__c);
                Integer cmpCount;
                if(!c.Course_Matching_Projects__r.isEmpty())
                {
                    String lastCMPNumber = c.Course_Matching_Projects__r.get(0).Title__c.substringBefore('for').replaceAll('[^0-9]', '');
                    cmpCount = Integer.valueOf(lastCMPNumber) + 1;
                }
                else 
                {
                    cmpCount = 1;
                }
                cmp.Title__c = 'Class Equivalency ' + cmpCount + ' for ' + c.Name;
            }
            else if(cmp.RecordTypeId == ciRT)
            {
                cmp.Title__c = 'Curriculum Integration for ' + cmp.Major__c + ' at ' + a.Name;
            }
        }
    }
}