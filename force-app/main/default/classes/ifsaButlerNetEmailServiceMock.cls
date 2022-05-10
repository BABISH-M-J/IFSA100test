@isTest
public class ifsaButlerNetEmailServiceMock implements WebServiceMock {
    public void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) 
    {
        // Create response element from the autogenerated class.
        // Populate response element.
        // Add response element to the response parameter, as follows:
        //response.put('response_x', responseElement); 
        ifsaButlerNetEmailService.ArrayOfString result = new ifsaButlerNetEmailService.ArrayOfString();
        
        result.string_x = new List<String>{'SUCCESS:'};
        system.debug(requestName);
        if(requestName.contains('Create'))
        {
            ifsaButlerNetEmailService.CreateResponse_element r = new ifsaButlerNetEmailService.CreateResponse_element();
            r.CreateResult = result;
            response.put('response_x', r);
        }
        else if(requestName.contains('Edit'))
        {
            ifsaButlerNetEmailService.EditResponse_element r = new ifsaButlerNetEmailService.EditResponse_element();
            r.EditResult = result;
            response.put('response_x', r);
        }
        else if(requestName.contains('Delete'))
        {
            ifsaButlerNetEmailService.DeleteResponse_element r = new ifsaButlerNetEmailService.DeleteResponse_element();
            r.DeleteResult = result;
            response.put('response_x', r);
        }
        system.debug(response);
   }
}