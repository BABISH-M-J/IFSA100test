/**
 * Queuable class that creates the BGR text file asynchronously
 * @author Brock Barlow
 */
// ApexDoc updated 1/28/2021 Brock Barlow
public with sharing class courseRegistrationQueueableService implements Queueable 
{
    private courseRegistrationViewModel viewModel {get; set;}
    private Butler_Grade_Report__c bgr {get;set;}

	/**
	 * Queueable execute method
	 * @param context
	 */
	public void execute(QueueableContext context) 
    {
        String returnMessage = '';
    	
    	if(bgr != null)
    	{
    		List<Id> courseRegIds = new List<Id>();
    		system.debug(viewModel);
    		for(hostInstitustionApplicationViewModel hostInst: viewModel.hostInstViewModels)
			{
				for(applicationCourseViewModel appCourse: hostInst.applicationCourses)
				{					
					for(studentOnSiteCourseRegViewModel courseRegVM: appCourse.courseRegistrations)
					{
						courseRegIds.add(courseRegVM.courseRegId);
						system.debug(courseRegVM.courseStatus);
					}
				}
			}
			List<Course_Registration_Grade__c> crgs = courseRegistrationController.createCourseGrades(courseRegIds, bgr.Id);
    		if(crgs != null)
    		{    			
    			courseRegistrationController.createTextFile(bgr);
                returnMessage = bgr.Id;
				// Updated Course_JS to query for job status email is no longer required
                /* Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setPlainTextBody('Butler Grade Report ' + bgr.Id + ' created');
                email.setSubject('BGR Created');
                email.setToAddresses(new List<Id>{UserInfo.getUserId()});
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});
                System.debug(UserInfo.getName() + ' ' + UserInfo.getUserEmail()); */
    		}
    		else    		
    		{
    			returnMessage = 'An error occured when saving grade records';
    			//Delete the Butler Grade Report Record since it will not have any 
    			//associated Course_Registration_Grade_Record__c records.

    			Database.Delete(bgr);
    		}
    	}
    	else
    	{
    		returnMessage = 'An error occured when saving';	
    	}

        System.debug(returnMessage);
    }
	/**
	 * Contstructor, intializes instance of courseRegistrationQueueableService
	 * @param vm <<courseRegistrationViewModel>>
	 * @param gr Butler_Grade_Report__c
	 */
    public courseRegistrationQueueableService(courseRegistrationViewModel vm, Butler_Grade_Report__c gr)
    {
        viewModel = vm;
        bgr = gr;
    }
}