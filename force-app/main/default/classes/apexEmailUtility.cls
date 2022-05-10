/**
 * Utility class for sending out emails via apex.
 * @author Cameron Ames
 */
// ApexDoc updated 1/25/2021 Brock Barlow
public without sharing class apexEmailUtility
{
    /**
     * Sends an email notifying of a student's need for program approval. This is an invocable method, meaning it can be called from lightning processes etc.
     * @param applicationIdlist The list of applications which need an email sent out for their program approval.
     */
    @InvocableMethod(
        label='Send Program Approval Notification'
        description='Sends an email notifying of a student\'s need for program Approval.')
    public static void sendProgramApprovalNotification(List<Id> applicationIdList)
    {
        String communityURL;
        if(!apexInstanceUtility.isSandBox)
        {
            communityURL = 'https://portal.ifsa-butler.org';
        }
        else
        {
            Domain d = [SELECT Domain FROM Domain WHERE Domain LIKE '%ifsa%force%'].get(0);
            communityURL = d.Domain;    
        }

        //Get advisors based off the home institutions in the applications
        List<Application__c> applicationList = [SELECT Id, 
                                                        Name,
                                                        Applicant__r.Name,
                                                        Program_Term__r.Display_Name__c,
                                                        Applicant__r.Home_Institution__c, 
                                                        Applicant__r.Home_Institution__r.Account__r.Owner.Name, 
                                                        Applicant__r.Home_Institution__r.Account__r.Owner.Title,
                                                        Applicant__r.Home_Institution__r.Account__r.Owner.Email,
                                                        Program_Term__c, Program_Term__r.Program__c, 
                                                        Program_Term__r.Program__r.Host_Institution__c, 
                                                        Program_Term__r.Program__r.Host_Institution__r.Country__c, 
                                                        Program_Term__r.Program__r.Host_Institution__r.Country__r.Name,
                                                        (SELECT Id FROM Application_Items__r WHERE RecordType.Name = 'Program Approval') 
                                                        FROM Application__c 
                                                        WHERE Id IN: ApplicationIdList];

        List<Id> homeInstitutionIdList = new List<Id>();
        for(Application__c application : applicationList)
        {
            homeInstitutionIdList.add(application.Applicant__r.Home_Institution__c);
        }

        List<Contact> advisorList = [SELECT Id, 
                                            FirstName, 
                                            LastName, 
                                            Email, 
                                            Approval_Countries__c, 
                                            Account.Institution__c,
                                            Program_Approver__c,
                                            Summer_Only__c
                                            FROM Contact 
                                            WHERE Account.Institution__c IN: homeInstitutionIdList
                                            AND Do_not_send_approval__c = false
                                            AND RecordType.Name = 'Advisor'];

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        //Test all the advisors with all of the students
        for(Application__c application : applicationList)
        {
            //Keep track of how many program approval emails are cooresponding to this application. If there aren't any, notify sys admins.
            List<Contact> programApprovalAdvisorEmails = new List<Contact>();
            
            for(Contact advisor : advisorList)
            {
                if(advisor.Email != null && advisor.Program_Approver__c && advisor.Account.Institution__c == application.Applicant__r.Home_Institution__c)
                {
                    system.debug(LoggingLevel.INFO, 'Advisor.Summer_Ony__c: ' + advisor.Summer_Only__c);
                    if(advisor.Summer_Only__c == false || (advisor.Summer_Only__c == true && application.Program_Term__r.Display_Name__c.Contains('Summer')))
                    {
                        boolean IsSummer;
                        if(advisor.Summer_Only__c == true)
                        {
                            IsSummer = true;
                            system.debug(LoggingLevel.INFO, 'The advisor is not a summer advisor');
                        }
                        else
                        {
                            IsSummer = false;
                            system.debug(LoggingLevel.INFO, 'The advisor is not a summer advisor');
                        }
                        if(advisor.Approval_Countries__c == null || String.isBlank(String.valueOf(advisor.Approval_Countries__c).trim()))
                        {
                            programApprovalAdvisorEmails.add(advisor);
                            system.debug(LoggingLevel.INFO, 'The advisor does not approve by country.');
                            system.debug(LoggingLevel.INFO, programApprovalAdvisorEmails);
                        }
                        else if(application.Program_Term__c != null && application.Program_Term__r.Program__c != null && application.Program_Term__r.Program__r.Host_Institution__c != null && application.Program_Term__r.Program__r.Host_Institution__r.Country__c != null && String.valueOf(advisor.Approval_Countries__c).contains(application.Program_Term__r.Program__r.Host_Institution__r.Country__r.Name))
                        {
                            programApprovalAdvisorEmails.add(advisor);
                            system.debug(LoggingLevel.INFO, 'The advisor approves this country.');
                        }
                    }
                }
            }
            
            if(programApprovalAdvisorEmails.size() < 1)
            {
                //BBARLOW Commented out to disable Manually Triggered Error when student does not have a home school or the home school does not have a program approver
                //apexEmailUtility.sendErrorEmail('A student had no program Approval recipients. The application is: ' +  application.Name);
            }
            else
            {
                for(Contact c: programApprovalAdvisorEmails){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setReplyTo(application.Applicant__r.Home_Institution__r.Account__r.Owner.Email);
                    mail.setOrgWideEmailAddressId(emailAddressToOrgWideEmailMap.get('no-reply@ifsa-butler.org').Id);
                    mail.setTargetObjectId(c.Id);
                    mail.setWhatId(application.Id);
                    mail.setSubject('New Program Approval Request');
                    mail.setHtmlBody('Dear ' + c.FirstName + ' ' + c.LastName + ',<br/><br/> We have great news! The following student has opened an application with IFSA for an upcoming education abroad program:<br/><br/><b>' + application.Applicant__r.Name + ' ' + application.Program_Term__r.Display_Name__c + '</b><br/><br/>To approve this student, visit <a href="' + communityUrl + '/advisorportal/?StudentId=' + application.Application_Items__r[0].Id + '">the IFSA Advisor Login page</a> to enter the IFSA Advisor Portal or to create an account in order to log in.<br/><br/>Step by step instructions for completing the approval: <br/><ol><li>Once in the portal, click on the tile in the center that indicates, "Student Information: Approve Your Student."</li><li>When the page opens, it will allow you to search by student name at the top left of the page. For more search options, open the filters below the student search box and use filters to search by application, status, country, term, year, or other criteria. Click the gray "Apply Search/Filters" button to see results. Scroll down to see the results populate below the filter box.</li><li>To find students in need of home campus approval, use the Additional Option filter at the bottom of the filter list and search for "Pending Approvals Only."</li><li>Click the student name to see their open application(s) and click on the relevant program you want to approve the student to participate on. The student application items will appear on the right side of the screen. If a student has more than one application, each will need to be approved individually. You will receive a separate "New Program Approval Request" email for each application.</li><li>Click the gold colored box that says "Complete Program Approval" and follow the instructions on that form.</li><li>After submitting the Program Approval for the student, their Approval Status will show as "COMPLETE" at the top of their IFSA application items.</li></ol>If you have any questions, please contact me at <a href="mailto:' + application.Applicant__r.Home_Institution__r.Account__r.Owner.Email + '">'+ application.Applicant__r.Home_Institution__r.Account__r.Owner.Email + '.</a><br/><br/>Thank you for your support of IFSA programs.<br/><br/>' + application.Applicant__r.Home_Institution__r.Account__r.Owner.Name +'<br/>' + application.Applicant__r.Home_Institution__r.Account__r.Owner.Title + '<br/>Institute for Study Abroad (IFSA)<br/>6201 Corporate Drive, Suite 200<br/>Indianapolis, IN  46278<br/>(P): 800-858-0229<br/>(F): 317-940-9704<br/><a href="www.ifsa-butler.org">www.ifsa-butler.org</a>');

                    emails.add(mail);
                }
                
            }
        }
        
        List<Messaging.SendEmailResult> results;
        
        try {
            results = Messaging.sendEmail(emails, false);

            for (Messaging.SendEmailResult result : results) {
                if (!result.isSuccess()) {
                    sendErrorEmail(JSON.serialize(results));
                    return;
                }
            }

        } catch (exception e) {
            sendErrorEmail(e.getMessage() + '\n' + e.getStackTraceString());
        }
    }
    
    /**
     * Sends an email notifying all active system administrators of a silent error.
     * @param contents The error message.
     */
    public static void sendErrorEmail(String contents)
    {
        //Get sys admin emails
        List<User> userList = [SELECT Id, Email FROM User WHERE Profile.Name =: 'System Administrator' AND isActive =: true];
        List<String> toAddressList = new List<String>();
        
        for(User aUser : userList)
        {
            toAddressList.add(aUser.Email);
        }
        
        //Send message
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setReplyTo('no-reply@ifsa-butler.org');
        mail.setOrgWideEmailAddressId(emailAddressToOrgWideEmailMap.get('no-reply@ifsa-butler.org').Id);
        mail.setToAddresses(toAddressList);
        mail.setSubject('Manually Triggered Error');
        mail.setHtmlBody('A manually triggered error occurred. The error is as follows: ' + contents);

        if(!configurationManager.isTestMode())
        {
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {mail});
        }
    }
    
    /**
     * Sends a quick text-only email to someone(s).
     * @param subject The subject line of the email.
     * @param contents The actual email body.
     * @param userIds The list of the users to send this address to.
     * @return void, but an email.
     */
    public static void sendGeneralEmail(String subject, String contents, List<Id> userIds)
    {
        if(subject == null || contents == null || userIds == null || userIds.size() < 1)
        {
            String userIdString = '';
            if(userIds != null)
            {
                for(Id userId : userIds)
                {
                    userIdString += ' ' + userId;
                }
            }
           
            apexEmailUtility.sendErrorEmail('SendGeneralEmail was called with at least one bad parameter. subject: ' + subject + ' contents: ' + contents + ' userIds: ' + userIdString);
        }
        
        List<User> userList = [SELECT Id, Email FROM User WHERE Id IN: userIds];
        List<String> emailList = new List<String>();
        for(User aUser : userList)
        {
            if(aUser.Email != null)
            {
                emailList.add(aUser.Email);
            }
        }
        
        apexEmailUtility.sendGeneralEmail(subject, contents, emailList);
    }
    
    /**
     * Sends an email using apex
     * @param subject The subject of the email message
     * @param contents The body of the email message
     * @param emailList The receipents of the email message
     */
    public static void sendGeneralEmail(String subject, String contents, List<String> emailList)
    {
        /*if(emailList.size() < 1)
        {
            apexEmailUtility.sendErrorEmail('SendGeneralEmail was called, but none of the users had an email address. The users were: ' + emailList + ' Subject: ' + subject + ' contents: ' + contents);
        }
        
        //Send message
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setReplyTo('no-reply@ifsa-butler.org');
        mail.setSenderDisplayName('IFSA No Reply');
        mail.setToAddresses(emailList);
        mail.setSubject(subject);
        mail.setHtmlBody(contents);

        if(!configurationManager.isTestMode())
        {
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {mail});
        }*/
        sendGeneralEmail(subject, contents, emailList, false, null, null);
    }
    /**
     * Sends an email using apex
     * @param subject The subject of the email message
     * @param contents The body of the email message
     * @param emailList The receipents of the email message
     * @param fromUser If true, the message is sent from the current user, if false from the system desigated user
     */
    public static void sendGeneralEmail(String subject, String contents, List<Id> emailList, boolean fromUser)
    {
        sendGeneralEmail(subject, contents, emailList, true, null, null);
    }
    /**
     * Sends an email using apex
     * @param subject The subject of the email message
     * @param contents The body of the email message
     * @param emailList The receipents of the email message
     * @param fromUser If true, the message is sent from the current user, if false from the system desigated user
     * @param cc CC recipents
     * @param bcc BCC recipents
     */
    public static void sendGeneralEmail(String subject, String contents, List<Id> emailList, boolean fromUser, String cc, String bcc)
    {       
        if(emailList.size() < 1)
        {
            apexEmailUtility.sendErrorEmail('SendGeneralEmail was called, but none of the users had an email address. The users were: ' + emailList + ' Subject: ' + subject + ' contents: ' + contents);
        }
        List<String> ccEmails = new List<String>();
        List<String> bccEmails = new List<String>();
        if(cc!= null)
        {
            if(cc.contains(','))
            {
                cc.replace(', ', ',');
                String[] emails;
                emails = cc.split(',');
                system.debug(emails);
                for(String e: emails)
                {
                    ccEmails.add(e);
                }
            }
            else
            {
                ccEmails.add(cc);
            }
        }
        if(bcc!= null)
        {
            if(bcc.contains(','))
            {
                bcc.replace(', ', ',');
                String[] emails;
                emails = bcc.split(',');
                system.debug(emails);
                for(String e: emails)
                {
                    bccEmails.add(e);
                }
            }
            else
            {
                ccEmails.add(bcc);
            }
        }

        //Send message
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        if(!fromUser)
        {
            mail.setReplyTo('no-reply@ifsa-butler.org');
            mail.setOrgWideEmailAddressId(emailAddressToOrgWideEmailMap.get('no-reply@ifsa-butler.org').Id);
        }
        else
        {
            mail.setReplyTo(UserInfo.getUserEmail());
            mail.setSenderDisplayName(UserInfo.getName());
        }
        mail.setToAddresses(emailList);
        if(!ccEmails.isEmpty())
            mail.setCcAddresses(ccEmails);
        if(!bccEmails.isEmpty())
            mail.setBccAddresses(bccEmails);
        mail.setSubject(subject);
        mail.setHtmlBody(contents);

        if(!configurationManager.isTestMode())
        {
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {mail});
        }
    }

    /**
     * Sends an email notifying of a new advisor waiting approval.
     * @param advisorIds The ids of the new advisors.
     */
    public static void sendNewAdvisorAlert(List<Id> advisorIds)
    {
        List<Contact> advisorContacts = [SELECT Id, 
                                                Name, 
                                                Email, 
                                                Account.Name 
                                                FROM Contact 
                                                WHERE Id IN: advisorIds];

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setReplyTo('no-reply@ifsa-butler.org');
        mail.setOrgWideEmailAddressId(emailAddressToOrgWideEmailMap.get('no-reply@ifsa-butler.org').Id);
        mail.setSubject('New Advisors awaiting Portal Access');
        mail.setToAddresses(apexConfigurationUtility.getInstance().getNewAdvisorRecipients());
        
        String body = 
            'There are new advisors awaiting Approval to use the Portal in Salesforce.<br/>'
            + 'Click on an advisor below to visit their contact record to approve them.<br/><br/>'
            + '<table><thead><tr><th>Name</th><th>Email</th><th>Institution</th></tr></thead><tbody>';
        
        for(Contact aContact : advisorContacts)
        {
            body += ('<tr><td><a href="https://' + apexInstanceUtility.instance + '.salesforce.com/' + aContact.Id + '">' + aContact.Name + '</a></td><td>' + aContact.Email + '</td><td>' + aContact.Account.Name + '</td></tr>');
        }
        
        body += '</tbody><table>';
        
        mail.setHtmlBody(body);
        
        if(mail.getToAddresses().size() < 1)
        {
            apexEmailUtility.sendErrorEmail('There was no one to receive a new advisor alert. The advisors are ' + advisorIds);
        }
        else
        {
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {mail});
        }       
    }
    /**
     * Gets a map of org wide email addresses taken from https://salesforce.stackexchange.com/questions/113424/get-ids-of-org-wide-email-addresses-without-soql
     */
    public static map<String,OrgWideEmailAddress> emailAddressToOrgWideEmailMap
    {
        get
        {
            if(emailAddressToOrgWideEmailMap == null)
            {
                emailAddressToOrgWideEmailMap= new Map<String, OrgWideEmailAddress>();
                for (OrgWideEmailAddress owea: [SELECT Id, Address FROM OrgWideEmailAddress])
                {
                    emailAddressToOrgWideEmailMap.put(owea.Address, owea);               
                }
                    
            }
            return emailAddressToOrgWideEmailMap;      
        }
        set; // keep public if you want to inject a known value in testmethods
    }   
}