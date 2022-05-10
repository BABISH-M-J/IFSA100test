/**
 * All Javascript Remoting Methods for CHART should return an instance of chartJSRemotingResponse. 
 * Please look at the class chartJSRemotingResponse to understand how it works. There are a number 
 * of different constructors to use based on the situation.
 * 
 * This class helps CHART to provide better error handling than our previous communities have. By using 
 * error codes, diagnosing issues with CHART has become much easier than before because when an end user
 * (internal or external) provides an error message or a screenshot of an error it is easier to pinpoint 
 * where the failure has occured and we can provide a better user experiance by catching these exceptions
 * and providing a user friendy error message, instead of saying "Opps, something went wrong"
 * 
 * @author Brock Barlow
 */
// ApexDoc updated 1/27/2021 Brock Barlow
public class chartJSRemotingResponse
{
    /**
     * Error codes used in CHART
     * BASIC CHART COURSE ERRORS
     *   CHART_ERROR_1001, Cannot retrieve courses from CHART
     *   CHART_ERROR_1002, Cannot retrieve course details from CHART
     * BASIC CHART CMP ERRORS
     *   CHART_ERROR_2001, Cannot retrieve course equivalency projects from CHART
     *   CHART_ERROR_2002, Cannot retrieve course equivalency project details
     *   CHART_ERROR_2003, Cannot save course equivalency project
     *   CHART_ERROR_2004, Cannot update Course Equivalency Filter setting
     *   CHART_ERROR_2005, Cannot update Course Equivalency status
     *   CHART_ERROR_2006, Cannot retrieve course equivalency records related to your school.
     * CHART CE / CMP ERRORS
     *   CHART_ERROR_3001, Cannot save new home institution course record from course details.
     *   CHART_ERROR_3002, Cannot save new course equivalency record from course details.
     *   CHART_ERROR_3003, Cannot save new CMP_Course_Equivalency__c record from course details.
     *   CHART_ERROR_3004, Cannot save new course equivalency record from course search.
     *   CHART_ERROR_3005, Cannot save new course equivalency records from course search.
     *   CHART_ERROR_3006, Could not save new CMP_Course_Equivalency__c record from course search.
     *   CHART_ERROR_3007, Could not save new CMP_Course_Equivalency__c records from course search.
     *   CHART_ERROR_3008, Could not retrieve specific course equivalency details
     * CHART CE FILE UPLOAD ERRORS
     *   CHART_ERROR_4001, Could not upload class equivalency file. File data was invalid.
     *   CHART_ERROR_4002, Could not create uploaded file task.
     *   CHART_ERROR_4003, Could not upload class equivalency file.
     * CHART FAVORTIE ERRORS
     *   CHART_ERROR_5000 Could not load favorites.
     */
    public enum errorCodes 
    {
        // BASIC CHART COURSE ERRORS
        CHART_ERROR_1001, // Cannot retrieve courses from CHART
        CHART_ERROR_1002, // Cannot retrieve course details from CHART
        // BASIC CHART CMP ERRORS
        CHART_ERROR_2001, // Cannot retrieve course equivalency projects from CHART
        CHART_ERROR_2002, // Cannot retrieve course equivalency project details
        CHART_ERROR_2003, // Cannot save course equivalency project
        CHART_ERROR_2004, // Cannot update Course Equivalency Filter setting
        CHART_ERROR_2005, // Cannot update Course Equivalency status
        CHART_ERROR_2006, // Cannot retrieve course equivalency records related to your school.
        // CHART CE / CMP ERRORS
        CHART_ERROR_3001, // Cannot save new home institution course record from course details.
        CHART_ERROR_3002, // Cannot save new course equivalency record from course details.
        CHART_ERROR_3003, // Cannot save new CMP_Course_Equivalency__c record from course details.
        CHART_ERROR_3004, // Cannot save new course equivalency record from course search.
        CHART_ERROR_3005, // Cannot save new course equivalency records from course search.
        CHART_ERROR_3006, // Could not save new CMP_Course_Equivalency__c record from course search.
        CHART_ERROR_3007, // Could not save new CMP_Course_Equivalency__c records from course search.
        CHART_ERROR_3008, // Could not retrieve specific course equivalency details
        // CHART CE FILE UPLOAD ERRORS
        CHART_ERROR_4001, // Could not upload class equivalency file. File data was invalid.
        CHART_ERROR_4002, // Could not create uploaded file task.
        CHART_ERROR_4003, // Could not upload class equivalency file.
        // CHART FAVORTIE ERRORS
        CHART_ERROR_5000 // Could not load favorites.
    }
    /**
     * Success status of a JavaScript remoting operation
     */
    public Boolean success { get; set; }
    /**
     * A message provided by a JavaScript remoting operation
     */
    public String message { get; set; }
    /**
     * The exception message from a JavaScript remoting operation
     */
    public String execptionMessage {get;set;}
    /**
     * The stack trace from a JavaScript remoting operation
     */
    public String execptionStackTrace {get;set;}
    /**
     * The exception type from a JavaScript remoting operation
     */
    public String exceptionTypeName {get;set;}
    /**
     * The line number where the exception occured in a JavaScript remoting operation
     */
    public Integer exceptionLineNumber {get;set;}
    /**
     * The error code value see Enum 'errorCodes'
     */
    public errorCodes errorCode { get; set; }
    /**
     * The object that is returned to the CHART AngularJS application.
     */
    public Object payload { get; set; }

    /**
     * Basic constructor
     */
    public chartJSRemotingResponse() {}
    
    /**
     * Basic successful operation completed response
     * @param  value Boolean value, true if operation was successfull, throws execption if false
     * @return       returns new instance of chartJSRemotingResponse
     */
    public chartJSRemotingResponse(Boolean value)
    {
        if(!value)
        {
            throw new chartJSRemotingResponseException();
        }
        success = true;
        message = 'SUCCESS';
    }

    /**
     * Successful operation completed with a payload to return to JS
     * @param  pl Payload to return
     * @return    returns new instance of chartJSRemotingResponse
     */
    public chartJSRemotingResponse(Object pl) 
    {
        this(true);
        payload = pl;
    }

    /**
     * Unsuccessful operation completed, return error code and message
     * @param  ec Error code
     * @return    returns new instance of chartJSRemotingResponse
     */
    public chartJSRemotingResponse(errorCodes ec)
    {
        errorCode = ec;        
        CHART_Error_Code__mdt errormessage = [SELECT Error_Message__c FROM CHART_Error_Code__mdt WHERE DeveloperName =: ec.name()];
        message = 'ERROR: ' + errormessage.Error_Message__c + ' ERROR CODE: ' + ec.name();
        success = false;
    }

    /**
     * Unsuccessful operation completed, return error code, message, and exception message
     * @param  ec Error code
     * @param  e  Thrown exception
     * @return    returns new instance of chartJSRemotingResponse
     */
    public chartJSRemotingResponse(errorCodes ec, Exception e)
    {
        this(ec);
        exceptionLineNumber = e.getLineNumber();
        execptionMessage = e.getMessage();
        execptionStackTrace = e.getStackTraceString();
        exceptionTypeName = e.getTypeName();
    }
    
    /**
     * Custom Exception class for chartJSRemotingResponse
     */
    public class chartJSRemotingResponseException extends Exception {
       
    }
}