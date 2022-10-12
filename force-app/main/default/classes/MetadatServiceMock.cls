@isTest
public class MetadatServiceMock implements WebServiceMock {
    public void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) 
    {
        List<MetadataService.FileProperties> result = new List<MetadataService.FileProperties>();
        MetadataService.FileProperties fileprop = new MetadataService.FileProperties();
        result.add(fileprop);
        result[0].fileName = 'Test';
        MetadataService.listMetadataResponse_element r = new MetadataService.listMetadataResponse_element();
        r.result = result;
        response.put('response_x', r);  
    }

}