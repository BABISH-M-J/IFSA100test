/**
 * Class for static methods for the course registration object. Creates a course record from a course registration record when
 * @author Cameron Ames
 */
// ApexDoc updated 2/16/2021 Brock Barlow
global without sharing class ifsaCourseRegDomainStatics
{
	/**
	 * Creates a new host institution type course record when one does not exist
	 * @param courseRegistrationIdList - A list of courseRegistrationIds to check
	 * @return Message saying the course has been linked, a new course record has been created or that an error has occured
	*/
	webService static String createCourseFromCourseReg(List<Id> courseRegistrationIdList)
	{		
		List<Course_Registration__c> courseRegList = [SELECT Id, Name, Application__c, Country__c, Course__c, Course_Code__c, Host_Credits__c, Butler_Department_Code__c, Host_Institution__c, Instructor_Full_Name__c, Instructor_First_Name__c, Instructor_Last_Name__c, US_Semester_Credit_Hours__c FROM Course_Registration__c WHERE Id IN: courseRegistrationIdList];
		List<Course__c> existingCourse = new List<Course__c>();
		Course_Registration__c courseRegToTest = null;
		if(courseRegList.size() == 1)
		{
			courseRegToTest = courseRegList.get(0);
			existingCourse = [SELECT Id, Name, Host_Credits__c FROM Course__c WHERE Host_Institution__c =: courseRegToTest.Host_Institution__c AND Course_Code__c =: courseRegToTest.Course_Code__c];
			if(existingCourse.size() == 1)
			{
				return linkCourseRegWithCourse(courseRegToTest, existingCourse.get(0));
			}
			else if(existingCourse.size() > 1 && (courseRegToTest.Course_Code__c == '' || courseRegToTest.Course_Code__c == null))
			{
				// The course registration does not have a course code and the host institution has more than one courses that do not use course codes
				// The logic above cannot determine what course this course registration should look up to. We need to determine a way to see if the
				// course registration links to one of the existing courses or a new course needs to be created.

				// Iterate over the Course__c in existingCourse
				for(Course__c course: existingCourse)
				{
					system.debug('Name: '+ course.Name + ', Credits: ' + course.Host_Credits__c);
					if(course.Name == courseRegToTest.Name && course.Host_Credits__c == courseRegToTest.Host_Credits__c)
					{
						return linkCourseRegWithCourse(courseRegToTest, course);
					}
				}
			}
		}
		List<Course__c> courses = new List<Course__c>();
		for(Course_Registration__c courseReg : courseRegList)
		{
			if(courseReg.Course__c != null)
			{
				return 'There is already a course associated with ' + courseReg.Name + ', so no courses were created.';
			}

			Course__c newCourse = new Course__c();
			newCourse.Name = courseReg.Name;
			newCourse.Course_Code__c = courseReg.Course_Code__c;
			newCourse.Host_Credits__c = courseReg.Host_Credits__c;
			newCourse.Butler_Department_Code__c = courseReg.Butler_Department_Code__c;
			newCourse.Host_Institution__c = courseReg.Host_Institution__c;
			//newCourse.US_Semester_Credit_Hours__c = courseReg.US_Semester_Credit_Hours__c;
			newCourse.RecordTypeId = Schema.SObjectType.Course__c.getRecordTypeInfosByName().get('Host Institution').getRecordTypeId();
			courses.add(newCourse);
		}

		try
		{
			insert(courses);
		}
		catch(Exception e)
		{
			return 'The course(s) were not created. Please try again. If you continue to have problems, contact the help desk.';
		}

		for(Course_Registration__c courseReg : courseRegList)
		{
			for(Course__c course : courses)
			{
				if(course.Name == courseReg.Name)
				{					
					courseReg.Course__c = course.Id;
				}
			}
		}		

		Database.update(courseRegList);

		return 'The course(s) were created successfully. Please refresh the page.'; 
	}
	/**
	 * Links course registration with an existing host insitution course
	 * @param courseReg - The course registration record to link
	 * @param existingCourse - The existing course record to link to
	 * @return Message saying the course has been linked
	*/
	private static String linkCourseRegWithCourse(Course_Registration__c courseReg, Course__c existingCourse)
	{
		courseReg.Name = existingCourse.Name;
		courseReg.Course__c = existingCourse.Id;

		Database.update(courseReg);

		return 'There is already a course associated with ' + existingCourse.Name + ', and this course registration has been updated to lookup to the existing course.';
	}
}