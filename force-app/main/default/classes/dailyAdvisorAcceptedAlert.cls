/**
 * Class for sending out daily acceptance alerts emails via apex.
 * @author Brock Barlow
 */
// ApexDoc updated 2/1/2021 Brock Barlow
global class dailyAdvisorAcceptedAlert implements Schedulable {
    
	/**
	 * Execute Method, required by Schedulable interface. Executes sendDailyAcceptanceAlert.
	 */
	global void execute(SchedulableContext SC) {                
        dailyAdvisorAcceptedAlert.sendDailyAcceptanceAlert();
	}
	/**
	 * This method is the bulk of the class. It is in a separate method so that it can be called without being scheduled. The method finds the first 100 applications that have and accepted status, and are awaiting this
	 * alert to be sent. It currently looks like this class is not actually sending the emails, but is updating the applications so it looks like the email was sent.
	 */
    public static void sendDailyAcceptanceAlert()
    {
    	List<Application__c> apps = [SELECT Id, Name, Owner.Name, Owner.Email, Program_Term__c, Program_Term__r.Name, Status__c, Status_Accepted__c, 
        	Status_Accepted_with_Conditions__c, Acceptance_Conditions__c, Student_Last_Name__c, Student_First_Name__c, Home_Institution_Advisor__c, 
        	Home_Institution_Advisor__r.Email, Home_Institution_Advisor__r.FirstName FROM Application__c WHERE Accepted_Alert_Status__c = 'Ready' 
        	AND (Status__c = 'Accepted' OR Status__c = 'Accepted (with Conditions)') AND Is_Custom__c = FALSE LIMIT 100]; // Removed China and India exceptions
        Map<Id, advisorEmailViewModel> advisorEmails = new Map<Id, advisorEmailViewModel>();        
        
        for(Application__c app: apps)
        {
            advisorEmailViewModel advisor = new advisorEmailViewModel();
            advisor.advisorId = app.Home_Institution_Advisor__c;
            advisor.name = app.Home_Institution_Advisor__r.FirstName;
            advisor.email = app.Home_Institution_Advisor__r.Email;
            advisorEmails.put(app.Home_Institution_Advisor__c, advisor);                        
        }
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<advisorEmailViewModel> badAdvisors = new List<advisorEmailViewModel>();
        
        for(advisorEmailViewModel advisor : advisorEmails.values())
        {
        	if(advisor.email != null)
            {
	            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	            mail.setReplyTo('no-reply@ifsa-butler.org');
	            mail.setSenderDisplayName('IFSA-Butler No Reply');
	            mail.setSubject('IFSA-Butler Student Acceptance Alert');
	            mail.setToAddresses(new List<String> {advisor.email});
            
	            String body = 
	            'Hi ' + advisor.Name + ', <br /><br />'
	            + 'Please find below a list of your students who have been recently accepted '
	            + 'to IFSA-Butler programs. If the acceptance is conditional, the conditions that need to be met will be listed. <br /><br />';
				for(Application__c app : apps)              
	            {            	
	                if(app.Home_Institution_Advisor__c == advisor.advisorId)
	                {
	                    body = body + app.Student_Last_Name__c + ', ' + app.Student_First_Name__c + ' | ' + app.Program_Term__r.Name + ' | Program Advisor: <a href="mailto:' + app.Owner.Email + '">' + app.Owner.Name + '</a> <br />';                
	                    
	                    if(app.Status__c == 'Accepted (with Conditions)')
	                    {
	                        body = body + 'Accepted on ' + app.Status_Accepted_with_Conditions__c.date().format() + '<br />'
	                        + '<b>Conditions:</b> <br />' + app.Acceptance_Conditions__c + '<br />';
	                    }
	                    else
	                    {
	                        body = body + 'Accepted on ' + app.Status_Accepted__c.date().format() + '<br />';
	                    }
	                    body = body + '<br />';
	                    //Mark that alert has been sent
	                    app.Accepted_Alert_Status__c = 'Sent';
	                }
	            }            
	            body = body + 'Thank you for your support of IFSA-Butler programs. Please contact us if you have any questions. <br /><br />'
	            + 'Sincerely,<br/>'
	            + 'Institute for Study Abroad, Butler University <br />'
	            + '6201 Corporate Drive, Suite 200 <br />'
	            + 'Indianapolis, IN 46278 <br />'	            
	            + '1 317 940 9336 <br/>'
	            + '1 800 858 0229 <br/>'
	            + '<a href="mailto:studyabroad@ifsa-butler.org">STUDYABROAD@IFSA-BUTLER.ORG</a><br/>';
	            
	            mail.setHtmlBody(body);
	            
                emails.add(mail);                
            }   	
            else
            {
                badAdvisors.add(advisor);
            }            
        }
        /* Removing task generation so that Brock Barlow does not have task notifications made for him
        if(emails.size() > 0)
        {
        	Messaging.sendEmail(emails);
        	Id brock = [SELECT Id FROM User WHERE Username LIKE 'bbarlow.1@ifsa-butler.%'].get(0).Id;
        	Task t = new Task();
        	t.Subject = 'dailyAdvisorAcceptedAlert has been run';
        	t.Description = 'Number of dailyAdvisorAcceptedAlerts sent: ' + emails.size();
        	t.ActivityDate = Date.today();
        	t.OwnerId = brock;

        	database.insert(t);
        }
		//Removing these lines of code so that these emails will not go out to IFSA Salesforce Admins
        if(badAdvisors.size() > 0)
        {
        	string contents = 'An acceptance alert was sent to a(n) advisor that does not have an email address <br /><br />';
	        for(advisorEmailViewModel a : badAdvisors)
	        {
	        	contents = contents + a.Name + ' ' + a.advisorId + ' <br />';
	        }
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
			mail.setSenderDisplayName('IFSA-Butler No Reply');
			mail.setToAddresses(toAddressList);
			mail.setSubject('Manually Triggered Error');
			mail.setHtmlBody('A manually triggered error occurred. The error is as follows: ' + contents);
	
			Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {mail});
        }
		*/
        database.update(apps);
    }
}